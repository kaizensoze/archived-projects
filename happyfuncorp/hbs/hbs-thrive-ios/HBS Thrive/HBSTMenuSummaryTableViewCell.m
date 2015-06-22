//
//  HBSTMenuSummaryTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/26/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTMenuSummaryTableViewCell.h"

@implementation HBSTMenuSummaryTableViewCell

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
    
    self.summaryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    self.summaryLabel.textColor = [UIColor whiteColor];
}

@end
