//
//  CriticDelegate.h
//  Taste Savant
//
//  Created by Joe Gallo on 7/6/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Critic;

@protocol CriticDelegate <NSObject>

- (void)criticDoneLoading:(Critic *)critic;

@end
