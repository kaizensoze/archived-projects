//
//  CustomSegmentedControl.m
//  TasteSavant
//
//  Created by Joe Gallo on 11/6/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "CustomSegmentedControl.h"

@implementation CustomSegmentedControl

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self layoutSubviews];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // adjust uilabels
    for (UIView *segment in self.subviews) {
        for (UIView *label in segment.subviews) {
            if ([label isKindOfClass:[UILabel class]]) {
                UILabel *titleLabel = (UILabel *)label;
                
                // skip if it's a single-line label
                if ([@[@"Distance", @"A-Z"] containsObject:titleLabel.text]) {
                    continue;
                }
                
                titleLabel.numberOfLines = 0;
                titleLabel.frame = CGRectMake(0, 0, segment.frame.size.width, segment.frame.size.height);
            }
        }
    }
}

@end
