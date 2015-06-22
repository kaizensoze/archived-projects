//
//  BFKShare.h
//  Mosaic
//
//  Created by Joe Gallo on 11/29/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BFKNotePart.h"

@interface BFKShare : NSObject

- (void)shareInstagram:(UIImage *)image vc:(UIViewController *)vc;
- (void)shareFacebook:(BFKNotePart *)item vc:(UIViewController *)vc;
- (void)shareTwitter:(BFKNotePart *)item vc:(UIViewController *)vc;
- (void)shareEmail:(BFKNotePart *)item vc:(UIViewController *)vc;

@end
