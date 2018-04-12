//
//  Video Cell.m
//  IOS-Youtube-Player
//
//  Created by Ken Lu on 4/10/18.
//  Copyright © 2018 Ken Lu. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell
- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        
    }
    return self;
}


- (void)setupView {
    [self createTitleLabel];
    [self createImageView];
    [self createChannelLabel];
    [self addConstraints];
}

- (void)createTitleLabel {
    self.videoTitleLabel = [[UILabel alloc] init];
    [self.videoTitleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.videoTitleLabel setTextColor:[[UIColor alloc] initWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];
    [self addSubview:self.videoTitleLabel];
    self.videoTitleLabel.numberOfLines = 3;
    [self.videoTitleLabel sizeToFit];
    self.videoTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
}
- (void)createChannelLabel {
    self.videoChannelLabel = [[UILabel alloc] init];
    [self.videoChannelLabel setFont:[UIFont systemFontOfSize:12]];
    [self.videoChannelLabel setTextColor:[[UIColor alloc] initWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];
    [self addSubview:self.videoChannelLabel];
    self.videoChannelLabel.numberOfLines = 1;
    self.videoChannelLabel.translatesAutoresizingMaskIntoConstraints = NO;
}
- (void)createImageView {
    self.thumbNailImageView = [[UIImageView alloc] init];
    [self addSubview:self.thumbNailImageView];
    
    self.thumbNailImageView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)addConstraints {
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[v0(v1)]-8-[v1]-8-|" options:0 metrics:nil views:@{@"v0":self.thumbNailImageView, @"v1":self.videoTitleLabel}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-8-[v0(v1)]-8-[v1]-8-|" options:0 metrics:nil views:@{@"v0":self.thumbNailImageView, @"v1":self.videoChannelLabel}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[v0]-8-|" options:0 metrics:nil views:@{@"v0":self.thumbNailImageView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[v0]-4-[v1]" options:0 metrics:nil views:@{@"v0":self.videoTitleLabel, @"v1":self.videoChannelLabel}]];

}
@end
