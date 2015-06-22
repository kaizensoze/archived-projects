//
//  HBSTWhoToCallTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/27/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTWhoToCallTableViewCell.h"

@implementation HBSTWhoToCallTableViewCell

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
    
    self.label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    self.label.textColor = [HBSTUtil colorFromHex:@"64964b"];
    [HBSTUtil adjustText:self.label width:260 height:MAXFLOAT];
    
    self.extraView.backgroundColor = [HBSTUtil colorFromHex:@"eff4ed"];
    
    self.nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.nameLabel.textColor = [UIColor blackColor];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    self.emailLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.emailLabel.textColor = [UIColor blackColor];
    self.emailLabel.attributedText = [[NSAttributedString alloc] initWithString:self.emailLabel.text attributes:underlineAttribute];
    
    self.phoneLabel.attributedText = [[NSAttributedString alloc] initWithString:self.phoneLabel.text attributes:underlineAttribute];
    self.phoneLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.phoneLabel.textColor = [UIColor blackColor];
    
    // check for missing fields and hide them
    self.nameLabel.hidden = NO;
    self.emailImageView.hidden = NO;
    self.emailLabel.hidden = NO;
    self.phoneImageView.hidden = NO;
    self.phoneLabel.hidden = NO;
    
    NSMutableArray *fields = [@[@"name", @"email", @"phone"] mutableCopy];
    if (self.nameLabel.text.length == 0) {
        [fields removeObject:@"name"];
        self.nameLabel.hidden = YES;
    }
    if (self.emailLabel.text.length == 0) {
        [fields removeObject:@"email"];
        self.emailImageView.hidden = YES;
        self.emailLabel.hidden = YES;
    }
    if (self.phoneLabel.text.length == 0) {
        [fields removeObject:@"phone"];
        self.phoneImageView.hidden = YES;
        self.phoneLabel.hidden = YES;
    }
    
    // if any fields are missing, adjust accordingly
    NSArray *yStartPositions = @[@[@7, @0], @[@32, @26], @[@60, @54]];
    for (int i=0; i < fields.count; i++) {
        NSString *field = fields[i];
        
        UIImageView *imageView;
        UILabel *label;
        if ([field isEqualToString:@"name"]) {
            label = self.nameLabel;
        } else if ([field isEqualToString:@"email"]) {
            imageView = self.emailImageView;
            label = self.emailLabel;
        } else {
            imageView = self.phoneImageView;
            label = self.phoneLabel;
        }
        
        if (imageView) {
            CGRect imageViewFrame = imageView.frame;
            imageViewFrame.origin.y = [yStartPositions[i][0] floatValue];
            imageView.frame = imageViewFrame;
        }
        
        CGRect labelFrame = label.frame;
        labelFrame.origin.y = [yStartPositions[i][1] floatValue];
        label.frame = labelFrame;
    }
    
    // adjust y position of extra view relative to label
    CGRect frame = self.extraView.frame;
    frame.origin.y = self.label.frame.origin.y + self.label.frame.size.height + 15;
    self.extraView.frame = frame;
    
    // adjust height of extra view
    float adjustedHeight = 0;
    adjustedHeight += fields.count * (21 + 7);
    adjustedHeight += 10;
    
    frame = self.extraView.frame;
    frame.size.height = adjustedHeight;
    self.extraView.frame = frame;
}

@end
