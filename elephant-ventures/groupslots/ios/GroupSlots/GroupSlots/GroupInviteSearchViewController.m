//
//  GroupInviteMembersViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 6/14/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "GroupInviteSearchViewController.h"
#import "User.h"

@interface GroupInviteSearchViewController ()
    @property (strong, nonatomic) NSMutableArray *searchResults;
    @property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
    @property (weak, nonatomic) IBOutlet UITableView *tableView;

    @property (strong, nonatomic) UIAlertView *inviteConfirmAlert;
    @property (strong, nonatomic) UIAlertView *inviteSuccessAlert;
@end

@implementation GroupInviteSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTestSearchResults];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
    [self.searchBar becomeFirstResponder];
}

- (void)addTestSearchResults {
    self.searchResults = [[NSMutableArray alloc] init];
    
    User *user = [[User alloc] initWithUsername:@"adam.smith" firstName:@"Adam" lastName:@"Smith"];
    [self.searchResults addObject:user];
    
    user = [[User alloc] initWithUsername:@"sam.lawrence" firstName:@"Samuel" lastName:@"Lawrence"];
    [self.searchResults addObject:user];
    
    user = [[User alloc] initWithUsername:@"jim.johnson" firstName:@"Jim" lastName:@"Johnson"];
    [self.searchResults addObject:user];
    
    user = [[User alloc] initWithUsername:@"sarah.williams" firstName:@"Sarah" lastName:@"Williams"];
    [self.searchResults addObject:user];
    
    [self.searchResults sortUsingDescriptors:
     [NSArray arrayWithObjects:
      [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES],
      [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES],
      nil]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.searchResults objectAtIndex:indexPath.row];
    
    static NSString *cellIdentifier = @"GroupInviteSearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = user.name;
    cell.detailTextLabel.text = user.username;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.searchResults objectAtIndex:indexPath.row];
    
    self.inviteConfirmAlert = [[UIAlertView alloc] initWithTitle:nil
                                                         message:[NSString stringWithFormat:@"Invite %@ to group?", user.name]
                                                        delegate:self
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"No", @"Yes", nil];
    [self.inviteConfirmAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.inviteConfirmAlert) {
        if (buttonIndex == 1) {
            #warning TODO: create group invite
            
            self.inviteSuccessAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Invitation Sent!"
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"OK", nil];
            [self.inviteSuccessAlert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    } else if (alertView == self.inviteSuccessAlert) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
