//
//  GroupInviteViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/13/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupInviteViewController.h"
#import "GroupInviteFacebookViewController.h"
#import "GroupInviteBumpViewController.h"

@interface GroupInviteViewController ()
    @property (weak, nonatomic) IBOutlet UITextField *searchTextField;
    @property (weak, nonatomic) IBOutlet UIButton *facebookButton;
    @property (weak, nonatomic) IBOutlet UIButton *twitterButton;
    @property (weak, nonatomic) IBOutlet UIButton *bumpButton;
    @property (weak, nonatomic) IBOutlet UIButton *smsButton;
    @property (weak, nonatomic) IBOutlet UIButton *mailButton;
    @property (strong, nonatomic) GroupInviteBumpViewController *bumpController;
    @property (strong, nonatomic) MFMessageComposeViewController *smsController;
    @property (strong, nonatomic) MFMailComposeViewController *mailController;
@end

@implementation GroupInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Util checkForBackButton:self];

    // search text field
    [self.searchTextField setValue:[Util colorFromHex:@"6f7278"] forKeyPath:@"_placeholderLabel.textColor"];

    self.bumpController = [[GroupInviteBumpViewController alloc] initWithParent:self];
    self.smsController = [[MFMessageComposeViewController alloc] init];
//    self.mailController = [[MFMailComposeViewController alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.bumpController endBumpSession];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Facebook invite

- (IBAction)facebookInvite:(id)sender {
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupInviteFacebook"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Twitter invite

- (IBAction)twitterInvite:(id)sender {
}

#pragma mark - Bump invite

- (IBAction)bumpInvite:(id)sender {
    [self.bumpController startBumpSession];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self performSegueWithIdentifier:@"goToGroupInviteSearch" sender:self];
    return NO;
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    [self.smsController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)smsInvite:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        self.smsController.body = @"Join GroupSlots!";
        self.smsController.messageComposeDelegate = self;
        [self presentViewController:self.smsController animated:YES completion:nil];
    } else {
        [Util showErrorAlert:@"Unable to send SMS on device." delegate:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    [self.mailController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)mailInvite:(id)sender {
    if (self.mailController && [MFMailComposeViewController canSendMail]) {
        [self.mailController setSubject:@"GroupSlots invitation"];
        [self.mailController setMessageBody:@"Join GroupSlots!" isHTML:YES];
        self.mailController.mailComposeDelegate = self;
        [self presentViewController:self.mailController animated:YES completion:nil];
    } else {
        [Util showErrorAlert:@"Unable to send mail on device." delegate:nil];
    }
}

@end
