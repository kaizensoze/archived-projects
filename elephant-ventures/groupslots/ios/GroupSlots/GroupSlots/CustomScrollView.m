//
//  CustomScrollView.m
//  GroupSlots
//
//  Created by Joe Gallo on 4/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // If not dragging, send event to next responder
    if (!self.dragging) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
    else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // If not dragging, send event to next responder
    if (!self.dragging) {
        [self.nextResponder touchesMoved:touches withEvent:event];
    }
    else {
        [super touchesMoved:touches withEvent: event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // If not dragging, send event to next responder
    if (!self.dragging) {
        [self.nextResponder touchesEnded:touches withEvent:event];
    }
    else {
        [super touchesEnded:touches withEvent:event];
    }
}

@end
