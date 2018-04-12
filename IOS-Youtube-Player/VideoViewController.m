//
//  VideoViewController.m
//  IOS-Youtube-Player
//
//  Created by Ken Lu on 4/10/18.
//  Copyright © 2018 Ken Lu. All rights reserved.
//

#import "VideoViewController.h"
#import "VideoCell.h"
#import <AVFoundation/AVFoundation.h>

@interface VideoViewController ()
@property (strong, nonatomic) XCDYouTubeVideoPlayerViewController *videoPlayerController;
@property (strong, nonatomic) UIView *videoContainer;
@property (strong, nonatomic) UICollectionView *videoList;
@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@end

@implementation VideoViewController
static NSString *const cellId = @"cellId";
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    @try {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
    }
    @catch (NSException *exception) {
        
    }
    
    self.view.backgroundColor = [[UIColor alloc] initWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1];
    CGFloat width = self.view.frame.size.width;
    self.videoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width * 9/16)];
    [self.view addSubview:self.videoContainer];
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.videoContainer addGestureRecognizer:self.pan];
    [self createRemoteCommandCenterControls];
    [self playVideoWithId];
    [self createVideoList];
    [self addObservers];
    [self addSwipeDown];
    
}
- (void)addSwipeDown {
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeDown)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeGesture];
}

- (void)handleSwipeDown {
    [self dismissViewControllerAnimated:YES completion:^{
        UIApplication.sharedApplication.keyWindow.windowLevel = UIWindowLevelNormal;
    }];
}

- (void)createRemoteCommandCenterControls {
    [UIApplication.sharedApplication beginReceivingRemoteControlEvents];
    MPRemoteCommandCenter.sharedCommandCenter.playCommand.enabled = YES;
    MPRemoteCommandCenter.sharedCommandCenter.pauseCommand.enabled = YES;
    [MPRemoteCommandCenter.sharedCommandCenter.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (self.videoPlayerController.preventStateChange) {
            self.videoPlayerController.preventStateChange = NO;
        }
        [self.videoPlayerController.moviePlayer play];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [MPRemoteCommandCenter.sharedCommandCenter.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        if (self.videoPlayerController.preventStateChange) {
            self.videoPlayerController.preventStateChange = NO;
        }
        [self.videoPlayerController.moviePlayer pause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
};

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayBackStateChange) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)playVideoWithId {
    [self.videoPlayerController.moviePlayer stop];
    self.videoPlayerController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:self.selectedVideoId];
    self.videoPlayerController.preferredVideoQualities = @[@18];
    [self.videoPlayerController presentInView:self.videoContainer];
    [self.videoPlayerController.moviePlayer play];
    
}

- (void)handleWillResignActive {
    self.videoPlayerController.preventStateChange = YES;
}

- (void)handlePlayBackStateChange {
    if (self.videoPlayerController.preventStateChange) {
        [self.videoPlayerController.moviePlayer play];
    }
}

- (void)handleWillEnterForeground {
    self.videoPlayerController.preventStateChange = NO;
}

- (void)handleVideoPressed:(NSMutableArray *)videos selectedVideoId:(NSString *)vidId {
    self.videos = videos;
    self.selectedVideoId = vidId;
    NSLog(@"%@", self.selectedVideoId);
    NSLog(@"%@", vidId);
    [self playVideoWithId];
    [self.videoList reloadData];
    
}

- (void)createVideoList {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(self.view.frame.size.width, 125);
    self.videoList = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.videoList.delegate = self;
    self.videoList.dataSource = self;
    [self.view addSubview:self.videoList];
    [self.videoList registerClass:[VideoCell class] forCellWithReuseIdentifier:cellId];
    self.videoList.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.videoList.topAnchor constraintEqualToAnchor:self.videoContainer.bottomAnchor] setActive:YES];
    [[self.videoList.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    [[self.videoList.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.videoList.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    self.videoList.backgroundColor = [[UIColor alloc] initWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _videos.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [self.videoList dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSURL *thumbNailURL = [[NSURL alloc] initWithString:[self.videos[indexPath.item] videoThumbNailURL]];
    [self getThumbNailImage:thumbNailURL videoCell:cell];
    cell.videoTitleLabel.text = [self.videos[indexPath.item] videoTitle];
    cell.videoChannelLabel.text = [self.videos[indexPath.item] channelName];
    return cell;
}

- (void)getThumbNailImage:(NSURL *)thumbNailURL videoCell:(VideoCell *)cell{
    [[[NSURLSession sharedSession] dataTaskWithURL:thumbNailURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.thumbNailImageView.image = [UIImage imageWithData:data];
        });
    }] resume];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = (VideoCell *)[self.videoList cellForItemAtIndexPath:indexPath];
    if ([self.videos[indexPath.item] videoId] == self.selectedVideoId) {
        return;
    }
    self.MPInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    self.MPInfoCenter.nowPlayingInfo = nil;
    NSMutableDictionary *currentVideoInfo = [[NSMutableDictionary alloc] init];
    NSString *title = cell.videoTitleLabel.text;
    NSString *channel = cell.videoChannelLabel.text;
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:cell.thumbNailImageView.image];
    [currentVideoInfo setValue:title forKey:MPMediaItemPropertyTitle];
    [currentVideoInfo setValue:channel forKey:MPMediaItemPropertyArtist];
    [currentVideoInfo setValue:artwork forKey:MPMediaItemPropertyArtwork];
    self.MPInfoCenter.nowPlayingInfo = currentVideoInfo;
    self.selectedVideoId = [self.videos[indexPath.item] videoId];
    [self playVideoWithId];
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    CGPoint translation = [sender translationInView:self.view];
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
            UIApplication.sharedApplication.keyWindow.windowLevel = UIWindowLevelNormal;
            if (translation.y < 0) {
                break;
            }
            self.view.center = CGPointMake(self.view.center.x, self.view.center.y + translation.y);
            [sender setTranslation:CGPointZero inView:self.view];
            
            break;
        case UIGestureRecognizerStateEnded:
            if (self.view.center.y < UIScreen.mainScreen.bounds.size.height * 3/4) {
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.view.center = UIApplication.sharedApplication.keyWindow.center;
                } completion:^(BOOL finished) {
                     UIApplication.sharedApplication.keyWindow.windowLevel = UIWindowLevelStatusBar;
                }];
            } else {
                [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.view.frame = CGRectMake(self.view.frame.size.width-150, self.view.frame.size.height-120, 140, 100);
                    self.videoContainer.frame = CGRectMake(0, 0, 140, 100);
                } completion:^(BOOL finished) {
                    UIApplication.sharedApplication.keyWindow.windowLevel = UIWindowLevelNormal;
                }];
            }
            
            break;
        default:
            break;
    }
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    CGFloat width = size.width;
    CGFloat height = size.height;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (UIDeviceOrientationIsPortrait(UIDevice.currentDevice.orientation)) {
            self.videoContainer.frame = CGRectMake(0, 0, width, width * 9/16);
        } else {
            self.videoContainer.frame = CGRectMake(0, 0, width, height);
        }
    } completion:nil];
}


@end
