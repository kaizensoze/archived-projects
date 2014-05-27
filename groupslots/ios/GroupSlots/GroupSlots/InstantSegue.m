//
//  InstantSegue.m
//  GroupSlots
//
//  Created by Joe Gallo on 4/9/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "InstantSegue.h"

@implementation InstantSegue

- (void)perform {
    [[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:nil];
}

@end
