//
//  AccountSettingsViewController.m
//  GroupSlots
//
//  Created by Joe Gallo on 5/22/13.
//  Copyright (c) 2013 Elephant Ventures. All rights reserved.
//

#import "AccountSettingsViewController.h"
#import "User.h"

@interface AccountSettingsViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *playersClubIdLabel;
    @property (weak, nonatomic) IBOutlet UILabel *firstNameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;
    @property (weak, nonatomic) IBOutlet UILabel *emailLabel;
    @property (weak, nonatomic) IBOutlet UISwitch *searchableByNameSwitch;
@end

@implementation AccountSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [appDelegate useMainNav:self];
    
    self.usernameLabel.text = appDelegate.loggedInUser.username;
    self.playersClubIdLabel.text = appDelegate.loggedInUser.playersClubId;
    self.firstNameLabel.text = appDelegate.loggedInUser.firstName;
    self.lastNameLabel.text = appDelegate.loggedInUser.lastName;
    self.emailLabel.text = appDelegate.loggedInUser.email;
    
    [self.searchableByNameSwitch setOn:appDelegate.loggedInUser.searchableByName];
    [self.searchableByNameSwitch addTarget:self action:@selector(changeSearchableSetting:)
                          forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    appDelegate.socketIO.delegate = self;
}

- (IBAction)changeSearchableSetting:(id)sender {
    BOOL setting = [sender isOn];
    appDelegate.loggedInUser.searchableByName = setting;
    [appDelegate saveLoggedInUserToDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
