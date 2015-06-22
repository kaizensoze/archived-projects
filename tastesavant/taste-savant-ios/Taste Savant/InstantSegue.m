//
//  InstantSegue.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/7/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "InstantSegue.h"

@implementation InstantSegue


- (void)perform {
    [[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:nil];
}

@end
