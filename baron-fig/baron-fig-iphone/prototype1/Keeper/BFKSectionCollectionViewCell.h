//
//  BFKSectionCollectionViewCell.h
//  Keeper
//
//  Created by Joe Gallo on 11/23/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BFKSectionCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UIImageView *stackTopImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sectionImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
