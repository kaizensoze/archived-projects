//
//  ILUImageCollectionViewCell.h
//  illuminex
//
//  Created by Joe Gallo on 11/13/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILUItemImagesCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *onHandImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end
