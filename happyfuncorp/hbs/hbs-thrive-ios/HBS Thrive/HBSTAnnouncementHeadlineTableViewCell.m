//
//  HBSTAnnouncementHeadlineTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/27/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTAnnouncementHeadlineTableViewCell.h"

@implementation HBSTAnnouncementHeadlineTableViewCell

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
    
    self.headlineLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    self.headlineLabel.textColor = [UIColor whiteColor];
    [HBSTUtil adjustText:self.headlineLabel width:240 height:MAXFLOAT];
}

@end
