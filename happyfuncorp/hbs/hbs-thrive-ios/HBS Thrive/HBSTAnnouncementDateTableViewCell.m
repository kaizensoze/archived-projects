//
//  HBSTAnnouncementDateTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/27/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTAnnouncementDateTableViewCell.h"

@implementation HBSTAnnouncementDateTableViewCell

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
    
    self.startEndLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    self.startEndLabel.textColor = [UIColor whiteColor];
    
    self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.dateLabel.textColor = [UIColor whiteColor];
}

@end
