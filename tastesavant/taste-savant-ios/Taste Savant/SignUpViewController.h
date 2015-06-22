//
//  SignUpViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 10/25/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChimpKit.h"

@interface SignUpViewController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate, UIAlertViewDelegate, ChimpKitDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmField;

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *email;

@end
