//
//  HBSTDidYouKnowTableViewCell.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/28/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTDidYouKnowTableViewCell.h"

@implementation HBSTDidYouKnowTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//        self.clipsToBounds = YES;
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
    [HBSTUtil adjustText:self.titleLabel width:268 height:MAXFLOAT];
    
    self.extraView.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    UIColor *color = [UIColor blackColor];
    
    self.websiteLabel.font = font;
    self.websiteLabel.textColor = color;
    self.websiteLabel.attributedText = [[NSAttributedString alloc] initWithString:self.websiteLabel.text
                                                                       attributes:underlineAttribute];
    
    self.emailLabel.font = font;
    self.emailLabel.textColor = color;
    self.emailLabel.attributedText = [[NSAttributedString alloc] initWithString:self.emailLabel.text
                                                                     attributes:underlineAttribute];
    
    self.phoneLabel.font = font;
    self.phoneLabel.textColor = color;
    self.phoneLabel.attributedText = [[NSAttributedString alloc] initWithString:self.phoneLabel.text
                                                                     attributes:underlineAttribute];
    
    // check for missing fields and hide them
    self.websiteImageView.hidden = NO;
    self.websiteLabel.hidden = NO;
    self.emailImageView.hidden = NO;
    self.emailLabel.hidden = NO;
    self.phoneImageView.hidden = NO;
    self.phoneLabel.hidden = NO;
    
    NSMutableArray *fields = [@[@"website", @"email", @"phone"] mutableCopy];
    if (self.websiteLabel.text.length == 0) {
        [fields removeObject:@"website"];
        self.websiteImageView.hidden = YES;
        self.websiteLabel.hidden = YES;
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
    NSArray *yStartPositions = @[@[@4, @2], @[@31, @29], @[@57, @55]];
    for (int i=0; i < fields.count; i++) {
        NSString *field = fields[i];
        
        UIImageView *imageView;
        UILabel *label;
        if ([field isEqualToString:@"website"]) {
            imageView = self.websiteImageView;
            label = self.websiteLabel;
        } else if ([field isEqualToString:@"email"]) {
            imageView = self.emailImageView;
            label = self.emailLabel;
        } else {
            imageView = self.phoneImageView;
            label = self.phoneLabel;
        }
        
        CGRect imageViewFrame = imageView.frame;
        imageViewFrame.origin.y = [yStartPositions[i][0] floatValue];
        imageView.frame = imageViewFrame;
        
        CGRect labelFrame = label.frame;
        labelFrame.origin.y = [yStartPositions[i][1] floatValue];
        label.frame = labelFrame;
    }
    
    // adjust y position of extra view relative to title label
    CGRect frame = self.extraView.frame;
    frame.origin.y = self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height + 14;
    self.extraView.frame = frame;
    
    // adjust height of extra view
    float adjustedHeight = 2;
    adjustedHeight += fields.count * (15 + 12);
    
    frame = self.extraView.frame;
    frame.size.height = adjustedHeight;
    self.extraView.frame = frame;
}

@end
