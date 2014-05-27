//
//  ViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 4/5/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "TestUser.h"
#import "Reward.h"
#import "ActivityLogEvent.h"
#import "FormCell.h"

@interface LoginViewController ()
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UITableView *loginFormTableView;
    @property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
    @property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
    @property (strong, nonatomic) NSArray *textFieldPlaceholders;
    @property (weak, nonatomic) IBOutlet UIButton *loginButton;
    @property (weak, nonatomic) IBOutlet UILabel *loginHelpLink;
    @property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // hide navigation bar
    self.navigationController.navigationBarHidden = YES;
    
    // scroll view
    float viewHeight = ((UIView *)self.scrollView.subviews[0]).frame.size.height;
    [self.scrollView setContentSize: CGSizeMake(320, viewHeight)];
    
    // form text field placeholders
    self.textFieldPlaceholders = @[@"Username",
                                   @"Password"];
    
    // form background color
    self.loginFormTableView.backgroundColor = [UIColor clearColor];
    
    // login help link
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToLoginHelp:)];
    [self.loginHelpLink addGestureRecognizer:tapGR];
    
    // style buttons
    [Util styleButton:self.loginButton];
    [Util styleButton:self.signUpButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.textFieldPlaceholders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FormCell";
    FormCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[FormCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    // text field
    cell.textField.placeholder = self.textFieldPlaceholders[row];
    [self assignTextField:cell.textField];
    [Util styleFormTextField:cell.textField];
    
    cell.textField.rightViewMode = UITextFieldViewModeAlways;
    if (row == 0) {
        cell.textField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield-icon-username"]];
    } else {
        cell.textField.rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield-icon-password"]];
    }
    
    // background
    int numRows = [self.loginFormTableView numberOfRowsInSection:section];
    [Util setFormTableCellBackground:cell row:row numRows:numRows];
    
    return cell;
}

- (void)assignTextField:(UITextField *)textField {
    int rowIndex = [self.textFieldPlaceholders indexOfObject:textField.placeholder];
    switch (rowIndex) {
        case 0:
            self.usernameTextField = textField;
            self.usernameTextField.returnKeyType = UIReturnKeyNext;
            self.usernameTextField.delegate = self;
            break;
        case 1:
            self.passwordTextField = textField;
            self.passwordTextField.secureTextEntry = YES;
            self.passwordTextField.returnKeyType = UIReturnKeyDone;
            self.passwordTextField.delegate = self;
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self login:nil];
    }
    
    return YES;
}

- (IBAction)login:(UIButton *)button {
    if ([Util isEmpty:self.usernameTextField]) {
        [Util showErrorAlert:@"Please enter a username." delegate:nil];
    } else if ([Util isEmpty:self.passwordTextField]) {
        [Util showErrorAlert:@"Please enter a password." delegate:nil];
    } else {
        #warning FIXME: stubbed out for now
//        NSDictionary *data = @{@"casinoId" : appDelegate.casinoId,
//                               @"username" : self.usernameTextField.text,
//                               @"password" : self.passwordTextField.text
//                               };
//        [appDelegate.socketIO sendEvent:@"login" withData:data];
        [self login];
    }
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    NSDictionary *response = [packet dataAsJSON];
    NSString *eventName = response[@"name"];
    NSDictionary *JSON = response[@"args"][0];
    
    if ([eventName isEqualToString:@"login"]) {
        if ([JSON[@"status"] isEqualToString:@"error"]) {
            [Util showErrorAlert:JSON[@"message"] delegate:nil];
        } else {
            [self login];
        }
    }
}

- (void)login {
    #warning TODO: remove this test code
    User *user = [[TestUser alloc] init];
    appDelegate.loggedInUser = user;
    [appDelegate saveLoggedInUserToDevice];
    
    // go to group page
    UIViewController *centerVC = [Util determineActiveOrInactiveGroupVC];
    [Util setCenterViewController:centerVC];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Segues

- (IBAction)goToLoginHelp:(id)sender {
    [self performSegueWithIdentifier:@"goToLoginHelp" sender:self];
}

@end
