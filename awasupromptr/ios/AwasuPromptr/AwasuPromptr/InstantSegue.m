//
//  InstantSegue.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "InstantSegue.h"

@implementation InstantSegue

- (void)perform {
    [[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:nil];
}

@end
