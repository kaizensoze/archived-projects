//
//  HBSTHelpNowTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/27/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTHelpNowTableViewCell.h"

@implementation HBSTHelpNowTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    self.titleLabel.textColor = [UIColor blackColor];
    [HBSTUtil adjustText:self.titleLabel width:277 height:MAXFLOAT];
    
    self.bodyLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    self.bodyLabel.textColor = [UIColor blackColor];
    [HBSTUtil adjustText:self.bodyLabel width:277 height:MAXFLOAT];
    
    // adjust body label
    CGRect bodyFrame = self.bodyLabel.frame;
    bodyFrame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 5;
    self.bodyLabel.frame = bodyFrame;
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    self.phoneLabel.attributedText = [[NSAttributedString alloc] initWithString:self.phoneLabel.text attributes:underlineAttribute];
    self.phoneLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.phoneLabel.textColor = [UIColor blackColor];
    [self.phoneLabel sizeToFit];
    
    // adjust phone image/label
    float startY = self.bodyLabel.frame.origin.y + self.bodyLabel.frame.size.height + 13;
    
    CGRect phoneImageFrame = self.phoneImageView.frame;
    phoneImageFrame.origin.y = startY;
    self.phoneImageView.frame = phoneImageFrame;
    
    CGRect phoneLabelFrame = self.phoneLabel.frame;
    phoneLabelFrame.origin.y = startY - 4; // not entirely sure why the -4 is needed
    self.phoneLabel.frame = phoneLabelFrame;
}

@end
