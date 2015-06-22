//
//  HBSTSearchDisplayController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/29/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTSearchDisplayController.h"

@implementation HBSTSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated {
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
}

@end
