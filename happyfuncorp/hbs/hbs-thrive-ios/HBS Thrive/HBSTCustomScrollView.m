//
//  HBSTCustomScrollView.m
//  HBS Thrive
//
//  Created by Joe Gallo on 9/5/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTCustomScrollView.h"

@implementation HBSTCustomScrollView

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
