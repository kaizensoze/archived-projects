//
//  ConferenceDetailViewController.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "ConferenceDetailViewController.h"
#import "Conference.h"
#import "Prompt.h"
#import "NoteViewController.h"
#import "Note.h"
#import "User.h"

@interface ConferenceDetailViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *backButton;
    @property (weak, nonatomic) IBOutlet UIView *navigationTitleView;
    @property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;

    @property (weak, nonatomic) IBOutlet UITableView *tableView;

    @property (weak, nonatomic) IBOutlet UIButton *optionsButton;
    @property (weak, nonatomic) IBOutlet UIButton *emailButton;
    @property (weak, nonatomic) IBOutlet UIButton *noteButton;

    @property (strong, nonatomic) MFMailComposeViewController *mailController;
@end

@implementation ConferenceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [Util colorFromHex:@"#f6f6f6"];
    
    [self loadCustomNavigationBar];
    
    [self customizeTableView];
    
    self.mailController = [[MFMailComposeViewController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadCustomNavigationBar {
    self.navigationTitleView.backgroundColor = [Util colorFromHex:@"#dddddd"];
    
    self.navigationTitleLabel.text = [@"Conference Details" uppercaseString];
    self.navigationTitleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16.45];
    self.navigationTitleLabel.textColor = [Util colorFromHex:@"#373737"];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)customizeTableView {
    self.tableView.sectionHeaderHeight = 0.0;
    self.tableView.sectionFooterHeight = 0.0;
}

- (IBAction)showOptions:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Open in Safari", nil];
    [actionSheet showInView:[self.view superview]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        NSURL *url = self.conference.webURL;
        if (![[UIApplication sharedApplication] openURL:url]) {
            DDLogError(@"Failed to open url: %@", [url description]);
        }
    }
}

- (IBAction)showMail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        NSMutableString *body = [NSMutableString string];
        [body appendFormat:@"<div style=\"margin-bottom: 10px; font-family: Helvetica-Light; font-size: 16.45px; color: #373737;\">%@</div>",
                            self.conference.name];
        [body appendFormat:@"<div style=\"margin-bottom: 10px; font-family: Helvetica-Light; font-size: 16.45px; color: #373737;\">%@</div>",
                            [self.conference dateRangeString]];
        [body appendFormat:@"<div style=\"margin-bottom: 10px; font-family: Helvetica-Light; font-size: 16.45px; color: #373737;\">%@</div>",
                            [self.conference locationString]];
        for (Prompt *prompt in self.conference.prompts) {
            [body appendFormat:@"<div style=\"margin-bottom: 10px; font-family: Helvetica-Light; font-size: 16.45px; color: #373737;\"><b>%2d days</b>: %@</div>",
                                [prompt.numDaysLeft intValue],
                                prompt.detail];
        }
        [body appendFormat:@"<a style=\"font-family: Helvetica-Light; font-size: 16.45px; color: #1e837c;\" href=\"%@\">%@</a>",
                            self.conference.webURL,
                            [self.conference.webURL description]];
        
        [self.mailController setSubject:[[NSString stringWithFormat:@"%@ details", self.conference.name] uppercaseString]];
        [self.mailController setMessageBody:[body uppercaseString] isHTML:YES];
        self.mailController.mailComposeDelegate = self;
        [self presentViewController:self.mailController animated:YES completion:nil];
    } else {
        [Util showErrorAlert:@"Unable to send mail on device." delegate:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self.mailController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showNote:(id)sender {
    [self performSegueWithIdentifier:@"goToNote" sender:sender];
}

- (void)noteDeleted:(Note *)note {
    DDLogInfo(@"note deleted");
    [appDelegate.loggedInUser.notes removeObject:note];
}

- (void)noteSaved:(Note *)note {
    DDLogInfo(@"note saved");
    
    NSMutableArray *userNotes = appDelegate.loggedInUser.notes;
    note.conference = self.conference;
    if (![userNotes containsObject:note]) {
        [userNotes addObject:note];
    } else {
        [userNotes replaceObjectAtIndex:[userNotes indexOfObject:note] withObject:note];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ConferenceDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    [Util addBorder:cell.contentView];
    cell.textLabel.text = @"test";
    
    [cell sizeToFit];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToNote"]) {
        NoteViewController *vc = (NoteViewController *)segue.destinationViewController;
        vc.delegate = self;
        
        if (sender) {
            // editing existing note
            #warning TODO: get note from sender
            Note *note = nil;
            vc.note = note;
        }
        
        DDLogInfo(@"user notes: %@", appDelegate.loggedInUser.notes);
    }
}

@end
