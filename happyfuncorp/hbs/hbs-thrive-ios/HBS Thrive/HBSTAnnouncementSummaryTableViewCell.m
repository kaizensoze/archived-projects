//
//  HBSTAnnouncementSummaryTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/27/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTAnnouncementSummaryTableViewCell.h"

@implementation HBSTAnnouncementSummaryTableViewCell

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
    
    self.summaryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    self.summaryLabel.textColor = [UIColor whiteColor];
    [HBSTUtil adjustText:self.summaryLabel width:240 height:MAXFLOAT];
}

@end
