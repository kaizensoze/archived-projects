//
//  UIView+Snapshot.m
//  Keeper
//
//  Created by Joe Gallo on 11/8/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "UIView+Snapshot.h"

@implementation UIView (Snapshot)

- (UIImage *)makeSnapshot {
    CALayer *layer = self.layer;
    UIGraphicsBeginImageContext(layer.frame.size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
