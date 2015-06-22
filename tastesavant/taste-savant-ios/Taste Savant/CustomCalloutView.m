//
//  CustomCalloutView.m
//  TasteSavant
//
//  Created by Joe Gallo on 11/3/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import "CustomCalloutView.h"

@implementation CustomCalloutView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.clipsToBounds && !self.hidden && self.alpha > 0) {
        for (UIView *subview in self.subviews.reverseObjectEnumerator) {
            CGPoint subPoint = [subview convertPoint:point fromView:self];
            UIView *result = [subview hitTest:subPoint withEvent:event];
            if (result != nil) {
                return result;
                break;
            }
        }
    }
    
    // use this to pass the 'touch' onward in case no subviews trigger the touch
    return [super hitTest:point withEvent:event];
}

@end
