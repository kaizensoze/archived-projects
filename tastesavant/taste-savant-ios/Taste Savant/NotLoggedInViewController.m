//
//  NotLoggedInViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/18/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "NotLoggedInViewController.h"

@interface NotLoggedInViewController ()
    @property (weak, nonatomic) IBOutlet UITextField *customLocationTextField;
    @property (weak, nonatomic) IBOutlet UIButton *customLocationButton;
@end

@implementation NotLoggedInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [CustomStyler styleButton2:self.showLoginButton];
    
    [CustomStyler setBorder:self.customLocationButton width:1 color:[UIColor blueColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // adjust button position for non-retina devices
    if (!IS_IPHONE_5) {
        CGRect buttonFrame = self.showLoginButton.frame;
        buttonFrame.origin.y = 155;
        self.showLoginButton.frame = buttonFrame;
    }
    
    // set button title
    NSString *buttonText;
    if (self.loginButtonDetail == nil) {
        buttonText = @"Log In";
    } else {
        buttonText = [@"Log In to " stringByAppendingString:[self.loginButtonDetail capitalizedString]];
    }
    [self.showLoginButton setTitle:buttonText forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    self.showLoginButton = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)showLogin:(id)sender {
    [appDelegate showLogin:self.parentViewController];
}

- (IBAction)setCustomLocation:(id)sender {
    NSString *text = self.customLocationTextField.text;
    if (text.length == 0) {
        appDelegate.customLocation = nil;
    } else {
        @try {
            NSArray *parts = [text componentsSeparatedByString:@","];
            double lat = [[Util clean:parts[0]] doubleValue];
            double lng = [[Util clean:parts[1]] doubleValue];
            appDelegate.customLocation = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        } @catch (NSException *e) {
            appDelegate.customLocation = nil;
        }
        
        self.customLocationTextField.textColor = [UIColor greenColor];
    }
    
    if ([appDelegate.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [appDelegate.locationManager requestWhenInUseAuthorization];
    }
    [appDelegate.locationManager startUpdatingLocation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.textColor = [UIColor blackColor];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    textField.textColor = [UIColor blackColor];
    return YES;
}

@end
