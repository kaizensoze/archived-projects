//
//  ChatCell.m
//  GroupSlots
//
//  Created by Joe Gallo on 9/14/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "ChatCell.h"

@implementation ChatCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.nameLabel.textColor = [Util colorFromHex:@"a2a2a0"];
    self.timeAgoLabel.textColor = [Util colorFromHex:@"d4d5d7"];
    self.messageLabel.textColor = [Util colorFromHex:@"363636"];
}

@end
