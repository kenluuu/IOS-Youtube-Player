//
//  VideoListController.m
//  IOS-Youtube-Player
//
//  Created by Ken Lu on 4/10/18.
//  Copyright © 2018 Ken Lu. All rights reserved.
//

#import "VideoListController.h"
#import "VideoCell.h"
#import "VideoInfo.h"
#import "AppDelegate.h"
#import "VideoViewController.h"

@interface VideoListController ()
@property (nonatomic, strong) NSString *youtubeSearchEndPoint;
@property (nonatomic, strong) NSMutableArray *videosList;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSString *videoSearchTerm;
@property (nonatomic, strong) UIView *blackView;
@end

@implementation VideoListController
static NSString *const cellId = @"cellId";
static NSString *const youtubeAPIURL = @"https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=30&order=relevance&type=video&safeSearch=moderate&regionCode=US&key=AIzaSyD8NCqACDbiXkLh0CwF1ZgF0OkWy1-THmU";
static NSString *const defaultEndPoint = @"https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&maxResults=25&key=AIzaSyD8NCqACDbiXkLh0CwF1ZgF0OkWy1-THmU";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    self.collectionView.backgroundColor = [[UIColor alloc] initWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1];
    self.collectionView.alwaysBounceVertical = YES;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backButton;
    self.videoSearchTerm = self.data;
    self.youtubeSearchEndPoint = self.videoSearchTerm ? [self makeSearchString] : defaultEndPoint;
    self.videosList = [[NSMutableArray alloc] init];
    [self getVideoInfo];
    [self addSearchBar];
    
    [self.collectionView registerClass:[VideoCell class] forCellWithReuseIdentifier:cellId];
}


- (NSString *)makeSearchString {
    NSString *searchEndPoint = [[NSString stringWithFormat:@"%@%@%@", youtubeAPIURL,@"&q=", self.videoSearchTerm] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    return searchEndPoint;
}
//Create Search Bar and adds it to the Navigation bar
- (void)addSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.placeholder = @"Search";
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    if (self.videoSearchTerm) {
        self.searchBar.text = self.videoSearchTerm;
    }
    
    
    self.searchBar.delegate = self;
    
    //set cancel button in navigation bar to white color
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTintColor:[UIColor whiteColor]];
    //Get the UITextField in search bar
    UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
    
    //make text field text color a different uicolor
    searchField.textColor = [[UIColor alloc] initWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1];
    
    //add search bar to navigation bar
    [self.navigationItem setTitleView:self.searchBar];
}

- (void)removeSelf {
    [self.blackView removeFromSuperview];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar endEditing:YES];
    self.collectionView.scrollEnabled = YES;
}

//add black view on screen when text is entered on search bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    self.blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.collectionView.frame.size.width, self.collectionView.contentSize.height + self.view.bounds.size.height)];
    [self.blackView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeSelf)]];
    self.blackView.backgroundColor = [[UIColor alloc] initWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    [self.collectionView addSubview:self.blackView];
    self.collectionView.scrollEnabled = NO;
    searchBar.keyboardAppearance = UIKeyboardAppearanceDark;
    
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self removeSelf];
    
}

//add new video list controller when a search is made
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    VideoListController *newVideoList = [[VideoListController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    newVideoList.data = searchBar.text;
    searchBar.text = self.videoSearchTerm;
    [self.navigationController pushViewController:newVideoList animated:YES];
    [self removeSelf];
    
}

//Fetch Video Data from youtube api
- (void)getVideoInfo {
    NSURL *endPointURL = [[NSURL alloc] initWithString:self.youtubeSearchEndPoint];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:endPointURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return;
        }
        NSDictionary *videosData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        NSArray *items = videosData[@"items"];
        for(int i=0; i<items.count; i++) {
            NSString *title = items[i][@"snippet"][@"title"];
            NSString *thumbNailURL = items[i][@"snippet"][@"thumbnails"][@"medium"][@"url"];
            NSString *channelTitle = items[i][@"snippet"][@"channelTitle"];
            NSString *vidId = self.youtubeSearchEndPoint == defaultEndPoint ? items[i][@"id"] : items[i][@"id"][@"videoId"];
            VideoInfo *vidInfo = [[VideoInfo alloc] initWithVideoData:title channelTitle:channelTitle videoThumbNailURL:thumbNailURL videoId:vidId];
            vidInfo.isShown = NO;
            [self.videosList addObject:vidInfo];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }] resume];
}

//Tells how many cells to make
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _videosList.count;
}

//Give cells data
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSURL *thumbNailURL = [[NSURL alloc] initWithString:[self.videosList[indexPath.item] videoThumbNailURL]];
    [self getThumbNailImage:thumbNailURL videoCell:cell];
    
    cell.videoTitleLabel.text = [self.videosList[indexPath.item] videoTitle];
    cell.videoChannelLabel.text = [self.videosList[indexPath.item] channelName];
    cell.videoId = [self.videosList[indexPath.item] videoId];
    return cell;
}


// Fetching Video Thumb Nails
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


//Cell on selected
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCell *cell = (VideoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!((AppDelegate *) UIApplication.sharedApplication.delegate).videoViewController) {
        ((AppDelegate *) UIApplication.sharedApplication.delegate).videoViewController = [[VideoViewController  alloc] init];
        [window addSubview: ((AppDelegate *) UIApplication.sharedApplication.delegate).videoViewController.view];
    }
    
    UIApplication.sharedApplication.keyWindow.windowLevel = UIWindowLevelStatusBar;
    NSString *selectedVidId = [self.videosList[indexPath.item] videoId];
    [((AppDelegate *) UIApplication.sharedApplication.delegate).videoViewController handleVideoPressed:self.videosList selectedVideoId:selectedVidId];
    [self addNowPlayingInfo:cell];

}
//
- (void)addNowPlayingInfo:(VideoCell *)cell {
    ((AppDelegate *) UIApplication.sharedApplication.delegate).videoViewController.MPInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    ((AppDelegate *) UIApplication.sharedApplication.delegate).videoViewController.MPInfoCenter.nowPlayingInfo = nil;
    NSMutableDictionary *currentVideoInfo = [[NSMutableDictionary alloc] init];
    NSString *title = cell.videoTitleLabel.text;
    NSString *channel = cell.videoChannelLabel.text;
    MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:cell.thumbNailImageView.image];

    [currentVideoInfo setValue:title forKey:MPMediaItemPropertyTitle];
    [currentVideoInfo setValue:channel forKey:MPMediaItemPropertyArtist];
    [currentVideoInfo setValue:artwork forKey:MPMediaItemPropertyArtwork];
    ((AppDelegate *) UIApplication.sharedApplication.delegate).videoViewController.MPInfoCenter.nowPlayingInfo = currentVideoInfo;
}

//fade cells in when they appear
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.videosList[indexPath.item] isShown]) {
        cell.alpha = 0;
        [UIView animateWithDuration:0.5 animations:^{
            cell.alpha = 1;
        }];
        [self.videosList[indexPath.item] setIsShown:YES];
    }
}

//Size of Collection View Cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.view.frame.size.width;
    return CGSizeMake(width, 125);
}

//making the minimum vertical line spacing between cells 0
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
