//
//  BFKCustomScrollView.m
//  Keeper
//
//  Created by Joe Gallo on 11/1/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKCustomScrollView.h"

@implementation BFKCustomScrollView

- (id)initWithFrame:(CGRect)frame {
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
        [super touchesMoved:touches withEvent:event];
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
