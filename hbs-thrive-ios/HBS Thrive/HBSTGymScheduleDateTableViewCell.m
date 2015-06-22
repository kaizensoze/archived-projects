//
//  HBSTGymScheduleDateTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/26/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTGymScheduleDateTableViewCell.h"

@implementation HBSTGymScheduleDateTableViewCell

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
    
    self.dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25];
    self.dateLabel.textColor = [UIColor whiteColor];
}

@end
