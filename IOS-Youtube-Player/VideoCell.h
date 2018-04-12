//
//  Video Cell.h
//  IOS-Youtube-Player
//
//  Created by Ken Lu on 4/10/18.
//  Copyright © 2018 Ken Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoCell : UICollectionViewCell
@property (strong, nonatomic) UILabel *videoTitleLabel;
@property (strong, nonatomic) UILabel *videoChannelLabel;
@property (strong, nonatomic) UIImageView *thumbNailImageView;
@property (strong, nonatomic) UIView *dividerLine;
@property (assign, nonatomic) NSString *videoId;

@end
