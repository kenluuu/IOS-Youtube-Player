//
//  VideoListController.h
//  IOS-Youtube-Player
//
//  Created by Ken Lu on 4/10/18.
//  Copyright © 2018 Ken Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoListController : UICollectionViewController<UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UINavigationControllerDelegate>
@property(strong, nonatomic) NSString *data;
@end
