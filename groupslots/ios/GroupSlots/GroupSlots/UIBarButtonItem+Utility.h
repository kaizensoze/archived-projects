//
//  UIBarButtonItem+Utility.h
//  GroupSlots
//
//  Created by Joe Gallo on 9/11/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Utility)

+ (UIBarButtonItem *)barItemWithImage:(UIImage*)image target:(id)target action:(SEL)action;

@end
