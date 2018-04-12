//
//  VideoInfo.m
//  IOS-Youtube-Player
//
//  Created by Ken Lu on 4/10/18.
//  Copyright © 2018 Ken Lu. All rights reserved.
//

#import "VideoInfo.h"

@implementation VideoInfo
- (instancetype)initWithVideoData:(NSString *)title channelTitle:(NSString *)channel  videoThumbNailURL:(NSString *)thumbNailURL videoId:(NSString *)vidId {
    self = [super init];
    if (self) {
        self.videoTitle = title;
        self.channelName = channel;
        self.videoThumbNailURL = thumbNailURL;
        self.videoId = vidId;
    }
    return self;
}

@end
