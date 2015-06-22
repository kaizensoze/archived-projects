//
//  PasswordResetViewController.m
//  TasteSavant
//
//  Created by Joe Gallo on 2/7/14.
//  Copyright (c) 2014 Taste Savant. All rights reserved.
//

#import "PasswordResetViewController.h"

@interface PasswordResetViewController ()
    @property (weak, nonatomic) IBOutlet UITextField *emailTextField;
    @property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;
@end

@implementation PasswordResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [CustomStyler styleTextField:self.emailTextField];
    
    [CustomStyler styleButton:self.resetPasswordButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [appDelegate.tracker set:kGAIScreenName value:@"Password Reset"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidUnload {
    self.emailTextField = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self resetPassword:nil];
    }
    
    return YES;
}

- (IBAction)resetPassword:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.emailTextField.text forKey:@"email"];
    
    NSString *url = [NSString stringWithFormat: @"%@/reset-request/", API_URL_PREFIX];
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"POST" path:url parameters:params];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if ([response[@"status_message"] isEqualToString:@"error"]) {
            DDLogInfo(@"%@", response[@"errors"]);
            
            NSString *errorMessage = [[[response[@"errors"] allValues] firstObject] firstObject];
            [Util showErrorAlert:errorMessage delegate:nil];
        } else {
            [Util showAlert:@"" message:@"An email has been sent." delegate:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util showNetworkingErrorAlert:operation.response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
