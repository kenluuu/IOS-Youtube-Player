//
//  VideoInfo.h
//  IOS-Youtube-Player
//
//  Created by Ken Lu on 4/10/18.
//  Copyright © 2018 Ken Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoInfo : NSObject
@property (strong, nonatomic) NSString *videoTitle;
@property (strong, nonatomic) NSString *channelName;
@property (strong, nonatomic) NSString *videoThumbNailURL;
@property (strong, nonatomic) NSString *videoId;
@property (assign, nonatomic) BOOL isShown;
- (instancetype)initWithVideoData:(NSString *)title channelTitle:(NSString *)title videoThumbNailURL:(NSString *)thumbNailURL videoId:(NSString*)vidId;

@end
