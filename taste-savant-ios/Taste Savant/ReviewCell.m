//
//  ReviewTableViewCell.m
//  Taste Savant
//
//  Created by Joe Gallo on 1/26/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "ReviewCell.h"

@implementation ReviewCell

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
    
    // publish date
    self.publishDateLabel.textColor = [Util colorFromHex:@"999999"];
    [Util adjustText:self.publishDateLabel width:210 height:14];
    
    // subject
    self.subjectLabel.textColor = [Util colorFromHex:@"f26522"];
//    [Util adjustText:self.subjectLabel width:210 height:19];
    
    // review body text
    self.reviewBodyTextLabel.textColor = [Util colorFromHex:@"333333"];
    
    // hack for differences between review cell on profile and review list views
    if (self.publishDateLabel.font.pointSize == 10) {
        [Util adjustText:self.reviewBodyTextLabel width:213 height:40];
    } else {
        [Util adjustText:self.reviewBodyTextLabel width:213 height:58];
    }
}

@end
