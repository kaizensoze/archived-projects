//
//  NotLoggedInViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 11/18/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotLoggedInViewController : UIViewController

@property (strong, nonatomic) NSString *loginButtonDetail;
@property (weak, nonatomic) IBOutlet UIButton *showLoginButton;

@end
