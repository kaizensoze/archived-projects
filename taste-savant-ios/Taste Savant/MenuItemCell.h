//
//  MenuItemCell.h
//  Taste Savant
//
//  Created by Joe Gallo on 5/19/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
