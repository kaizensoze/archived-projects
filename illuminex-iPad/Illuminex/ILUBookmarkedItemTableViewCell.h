//
//  ILUBookmarkedItemTableViewCell.h
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILUBookmarkedItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *onHandImageView;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *itemDetailsButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end
