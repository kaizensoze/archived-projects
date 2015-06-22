//
//  ILUSearchResultCollectionViewCell.h
//  Illuminex
//
//  Created by Joe Gallo on 10/21/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILUSearchResultCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIView *infoOverlayView;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@property (weak, nonatomic) IBOutlet UIView *rightBorderView;
@property (weak, nonatomic) IBOutlet UIView *bottomBorderView;

@end
