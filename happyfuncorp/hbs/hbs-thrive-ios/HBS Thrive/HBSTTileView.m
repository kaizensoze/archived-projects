//
//  HBSTTileView.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/13/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTTileView.h"

@implementation HBSTTileView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    self.layer.cornerRadius = 5;
    self.layer.masksToBounds = YES;
    
    if (!self.color) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    } else {
        self.backgroundColor = self.color;
    }
    self.label.textColor = [UIColor whiteColor];
}

@end
