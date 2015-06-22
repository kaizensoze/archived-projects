//
//  ProfileDelegate.h
//  Taste Savant
//
//  Created by Joe Gallo on 1/27/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@protocol ProfileDelegate <NSObject>

- (void)profileDoneLoading:(User *)profile;

@end
