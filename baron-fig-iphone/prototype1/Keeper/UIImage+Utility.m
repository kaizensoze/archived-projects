//
//  UIImage+Utility.m
//  Keeper
//
//  Created by Joe Gallo on 11/8/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)

- (UIImage *)cropFromRect:(CGRect)fromRect {
    fromRect = CGRectMake(fromRect.origin.x * self.scale,
                          fromRect.origin.y * self.scale,
                          fromRect.size.width * self.scale,
                          fromRect.size.height * self.scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, fromRect);
    UIImage* crop = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return crop;
}

- (UIColor *)averageColor {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), self.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

- (float)percentageDark {
    CFDataRef imageData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage));
    const UInt8 *pixels = CFDataGetBytePtr(imageData);
    
    int darkThreshold = 10;
    int darkPixels = 0;
    
    int length = CFDataGetLength(imageData);
    for (int i=0; i < length; i += 4) {
        int r = pixels[i];
        int g = pixels[i+1];
        int b = pixels[i+2];
        
        if (r < darkThreshold || g < darkThreshold || b < darkThreshold) {
            darkPixels++;
        }
    }
    
    CFRelease(imageData);
    
    return darkPixels / (self.size.width * self.size.height);
}

@end
