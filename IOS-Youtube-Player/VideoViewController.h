//
//  VideoViewController.h
//  IOS-Youtube-Player
//
//  Created by Ken Lu on 4/10/18.
//  Copyright © 2018 Ken Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoInfo.h"
#import <XCDYouTubeVideoPlayerViewController.h>

@interface VideoViewController : UIViewController<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) UIView *videoContainer;
@property (strong, nonatomic) MPNowPlayingInfoCenter *MPInfoCenter;
@property (strong, nonatomic) NSString *selectedVideoId;
@property (strong, nonatomic) NSMutableArray *videos;
@property (strong, nonatomic) UITapGestureRecognizer *tap;
- (void)handleVideoPressed:(NSMutableArray *)videos selectedVideoId:(NSString *)selectedVideoId;
- (void)handleTap:(UITapGestureRecognizer *)sender;
@end
