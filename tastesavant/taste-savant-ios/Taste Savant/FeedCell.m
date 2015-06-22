//
//  CustomTableViewCell.m
//  Taste Savant
//
//  Created by Joe Gallo on 1/6/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "FeedCell.h"

@implementation FeedCell


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
    
    // date
    self.dateLabel.textColor = [Util colorFromHex:@"999999"];
    
    // description
    self.entryDescriptionLabel.textColor = [Util colorFromHex:@"333333"];
    [Util adjustText:self.entryDescriptionLabel width:218 height:41];
}

@end
