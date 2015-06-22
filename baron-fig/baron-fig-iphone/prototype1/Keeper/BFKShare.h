//
//  BFKShare.h
//  Keeper
//
//  Created by Joe Gallo on 11/29/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BFKCapturedItem.h"
#import "BFKCapturedImage.h"
#import "BFKCapturedNote.h"

@interface BFKShare : NSObject

- (void)shareInstagram:(UIImage *)image vc:(UIViewController *)vc;
- (void)shareFacebook:(BFKCapturedItem *)item vc:(UIViewController *)vc;
- (void)shareTwitter:(BFKCapturedItem *)item vc:(UIViewController *)vc;
- (void)shareEmail:(BFKCapturedItem *)item vc:(UIViewController *)vc;

@end
