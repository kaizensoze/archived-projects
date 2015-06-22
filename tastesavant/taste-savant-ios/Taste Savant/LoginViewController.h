//
//  LoginViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 10/25/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginDelegate.h"

@interface LoginViewController : UIViewController <UIGestureRecognizerDelegate, LoginDelegate, UIActionSheetDelegate, UITextFieldDelegate>

- (void)goToMain;

@end