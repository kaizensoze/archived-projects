//
//  BFKFeedback1TableViewCell.m
//  Mosaic
//
//  Created by Joe Gallo on 10/24/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKNotePartTableViewCell.h"
#import "BFKUtil.h"

@implementation BFKNotePartTableViewCell

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
    
    // text view
    self.textView.layer.borderColor = [BFKUtil colorFromHex:@"dcced6"].CGColor;
    self.textView.layer.borderWidth = 0.5;
    [BFKUtil roundCorners:self.textView radius:5];
    
//    self.textView.textContainer.lineFragmentPadding = 9;
    
    // image view
    self.outerImageView.layer.borderColor = [BFKUtil colorFromHex:@"dcced6"].CGColor;
    self.outerImageView.layer.borderWidth = 0.5;
    [BFKUtil roundCorners:self.outerImageView radius:5];
    
    [BFKUtil roundCorners:self.theImageView radius:5];
}

@end
