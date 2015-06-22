//
//  HBSTPollChoiceTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 9/4/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTPollChoiceTableViewCell.h"

@implementation HBSTPollChoiceTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.selectedBackgroundView.backgroundColor = [HBSTUtil colorFromHex:@"64964b"];
    
    self.choiceLabel.textColor = [UIColor whiteColor];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.choiceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    self.choiceLabel.textColor = [HBSTUtil colorFromHex:@"64964b"];
}

@end
