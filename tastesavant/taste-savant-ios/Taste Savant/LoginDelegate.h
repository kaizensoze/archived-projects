//
//  LoginDelegate.h
//  Taste Savant
//
//  Created by Joe Gallo on 2/26/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoginDelegate <NSObject>

- (void)loginSucceeded;
- (void)loginFailed;

@end
