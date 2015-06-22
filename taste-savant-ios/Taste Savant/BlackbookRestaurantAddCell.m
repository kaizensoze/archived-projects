//
//  BlackbookRestaurantAddCell.m
//  TasteSavant
//
//  Created by user on 5/25/14.
//  Copyright (c) 2014 Taste Savant. All rights reserved.
//

#import "BlackbookRestaurantAddCell.h"

@implementation BlackbookRestaurantAddCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // remove border/background
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.backgroundColor = [UIColor clearColor];
    
    // change placeholder font/color
    [self.textField setValue:[Util colorFromHex:@"f26c4f"] forKeyPath:@"_placeholderLabel.textColor"];
    self.textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    // change text font/color
    self.textField.textColor = [Util colorFromHex:@"b5b5b5"];
}

@end
