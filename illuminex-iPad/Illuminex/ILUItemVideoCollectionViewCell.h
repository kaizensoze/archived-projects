//
//  ILUVideoCollectionViewCell.h
//  illuminex
//
//  Created by Joe Gallo on 11/13/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ILUItemVideoCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *onHandImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *videoPlayerView;
@property (strong, nonatomic) AVPlayer *videoPlayer;

@end
