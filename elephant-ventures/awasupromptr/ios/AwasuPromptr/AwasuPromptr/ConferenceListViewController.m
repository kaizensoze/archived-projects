//
//  ConferenceListViewController.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "ConferenceListViewController.h"
#import "Conference.h"
#import "Prompt.h"
#import "ConferenceListCell.h"
#import "User.h"
#import "ConferenceDetailViewController.h"

@interface ConferenceListViewController ()
    @property (strong, nonatomic) NSMutableArray *conferences;

    @property (weak, nonatomic) IBOutlet UIView *favoritesToggleView;
    @property (weak, nonatomic) IBOutlet UILabel *allLabel;
    @property (weak, nonatomic) IBOutlet UISwitch *favoritesSwitch;
    @property (weak, nonatomic) IBOutlet UILabel *favesLabel;

    @property (weak, nonatomic) IBOutlet UIView *promptsView;
    @property (weak, nonatomic) IBOutlet UILabel *upcomingPromptsLabel;

    @property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ConferenceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [Util colorFromHex:@"#d3d3d3"];
    
    [self loadFavoritesToggleView];
    [self loadPromptsView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.conferences.count == 0) {
        #warning TODO: remove
        [self addTestData];
    }
    
//    DDLogInfo(@"conferences:");
//    for (Conference *conference in self.conferences) {
//        DDLogInfo(@"%@", conference);
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)addTestData {
    // conference 1
    Conference *conference = [[Conference alloc] initWithId:@"1"];
    conference.name = @"IA SUMMIT";
    conference.startDate = [Util stringToDate:@"05/24/2013" dateFormat:@"MM/dd/yyyy"];
    conference.endDate = [Util stringToDate:@"05/26/2013" dateFormat:@"MM/dd/yyyy"];
    conference.city = @"Austin";
    conference.stateAbbrev = @"TX";
    conference.details = @"The IA Summit is the premiere, community-curated, and volunteer-run gathering"
                          "on the wondrous meticulous paradigm featuring miraculous and titillating buzz words"
                          "such as expecto patronum.";
    conference.imageURL = [[NSBundle mainBundle] URLForResource: @"conference1" withExtension:@"png"];
    conference.webURL = [[NSURL alloc] initWithString:@"http://www.google.com"];
    
    Prompt *prompt = [[Prompt alloc] initWithId:@"1"];
    prompt.conference = conference;
    prompt.type = SUBMISSION_DUE;
    prompt.detail = @"Proposal Due";
    prompt.shortDetail = @"DUE";
    prompt.numDaysLeft = @2;
    [conference.prompts addObject:prompt];

    prompt = [[Prompt alloc] initWithId:@"2"];
    prompt.conference = conference;
    prompt.type = PRICE_INCREASE;
    prompt.detail = @"Price Increase";
    prompt.shortDetail = @"$60";
    prompt.numDaysLeft = @4;
    [conference.prompts addObject:prompt];

    [self.conferences addObject:conference];

    // conference 2
    conference = [[Conference alloc] initWithId:@"2"];
    conference.name = @"AIGA (RE)Design Conference 13";
    conference.startDate = [Util stringToDate:@"05/24/2013" dateFormat:@"MM/dd/yyyy"];
    conference.endDate = [Util stringToDate:@"05/26/2013" dateFormat:@"MM/dd/yyyy"];
    conference.city = @"Minneapolis";
    conference.stateAbbrev = @"MN";
    conference.details = @"The (Re)design Awards 13 is the premiere, community-curated, and volunteer-run gathering"
                          "on the wondrous meticulous paradigm featuring miraculous and titillating buzz words"
                          "such as expecto patronum.";
    conference.imageURL = [[NSBundle mainBundle] URLForResource: @"conference2" withExtension:@"png"];
    conference.webURL = [[NSURL alloc] initWithString:@"http://www.google.com"];
    
    prompt = [[Prompt alloc] initWithId:@"3"];
    prompt.conference = conference;
    prompt.type = SUBMISSION_DUE;
    prompt.detail = @"Application Deadline";
    prompt.shortDetail = @"DUE";
    prompt.numDaysLeft = @4;
    [conference.prompts addObject:prompt];
    
    prompt = [[Prompt alloc] initWithId:@"4"];
    prompt.conference = conference;
    prompt.type = HOUSING_AVAILABILITY;
    prompt.detail = @"Housing";
    prompt.shortDetail = @"OPEN";
    prompt.numDaysLeft = @7;
    [conference.prompts addObject:prompt];
    
    [self.conferences addObject:conference];
    
    [self.tableView reloadData];
}

- (void)loadFavoritesToggleView {
    self.favoritesToggleView.backgroundColor = [Util colorFromHex:@"#22aea4"];
    
    UIFont *favesViewFont = [UIFont fontWithName:@"Helvetica-Light" size:14.5];
    
    self.allLabel.font = favesViewFont;
    self.allLabel.textColor = [UIColor whiteColor];
    
    self.favesLabel.font = favesViewFont;
    self.favesLabel.textColor = [UIColor whiteColor];
    
    #warning FIXME: use custom framework to fully customize switch
    self.favoritesSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75);
    self.favoritesSwitch.onTintColor = [Util colorFromHex:@"#1a4e4a"];
    self.favoritesSwitch.thumbTintColor = [UIColor whiteColor];
    [self.favoritesSwitch addTarget:self action:@selector(favoritesSwitchFlipped:) forControlEvents:UIControlEventValueChanged];
}

- (void)loadPromptsView {
    self.promptsView.backgroundColor = [Util colorFromHex:@"#1e837c"];
    
    // TODO: new prompts image
    UITapGestureRecognizer *promptsTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                   action:@selector(togglePromptsView:)];
    [self.promptsView addGestureRecognizer:promptsTapGR];
    
    #warning TODO: figure out how to get number of new prompts
    NSNumber *numUpcomingPrompts = @3;
    
    UIFont *regularFont = [UIFont fontWithName:@"Helvetica-Light" size:11.3];
    UIFont *boldFont = [UIFont fontWithName:@"Helvetica-Bold" size:11.3];
    
    self.upcomingPromptsLabel.font = regularFont;
    self.upcomingPromptsLabel.textColor = [UIColor whiteColor];
    
    NSDictionary *attributesNamePart = @{
                                         NSFontAttributeName : boldFont
                                         };
    
    self.upcomingPromptsLabel.text = [NSString stringWithFormat:@"%d New Prompts", [numUpcomingPrompts intValue]];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.upcomingPromptsLabel.text
                                                                           attributes:nil];
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    [mutableAttributedString addAttributes:attributesNamePart range:NSMakeRange(0, [numUpcomingPrompts stringValue].length)];
    
    self.upcomingPromptsLabel.attributedText = mutableAttributedString;
}

- (IBAction)favoritesSwitchFlipped:(id)sender {
    DDLogInfo(@"switch flipped");
}

- (IBAction)togglePromptsView:(id)sender {
    [appDelegate.viewDeckController toggleRightView];
}

- (IBAction)toggleFavorite:(id)sender {
    UIButton *favoriteButton = (UIButton *)sender;
    favoriteButton.selected = !favoriteButton.selected;
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Conference *conference = [self.conferences objectAtIndex:indexPath.section];
    
    if (favoriteButton.selected) {
        [appDelegate.loggedInUser.favorites addObject:conference];
    } else {
        [appDelegate.loggedInUser.favorites removeObject:conference];
    }
    
//    DDLogInfo(@"user's favorites: %@", appDelegate.loggedInUser.favorites);
}

- (IBAction)goToConferenceDetails:(id)sender {
    [self performSegueWithIdentifier:@"goToConferenceDetail" sender:sender];
}

- (NSMutableArray *)conferences {
    if (!_conferences) {
        _conferences = [[NSMutableArray alloc] init];
    }
    return _conferences;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.conferences.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Conference *conference = [self.conferences objectAtIndex:indexPath.section];
    
    static NSString *cellIdentifier = @"ConferenceListCell";
    ConferenceListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ConferenceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"conference-list-cell-bg.png"]];
    
    [cell.conferenceImageView setImageWithURL:conference.imageURL
                             placeholderImage:nil];
    
    cell.dateRangeLabel.text = [conference dateRangeString];
    cell.dateRangeLabel.font = [UIFont fontWithName:@"Helvetica-SemiBold" size:18.11];
    cell.dateRangeLabel.textColor = [Util colorFromHex:@"#28a7b2"];
    
    cell.locationLabel.text = [conference locationString];
    cell.locationLabel.font = [UIFont fontWithName:@"Helvetica-SemiBoldItalic" size:15.8];
    cell.locationLabel.textColor = [Util colorFromHex:@"#252525"];
    
    [cell sizeToFit];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToConferenceDetail"]) {
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        
        Conference *conference = [self.conferences objectAtIndex:indexPath.section];
        
        ConferenceDetailViewController *vc = (ConferenceDetailViewController *)segue.destinationViewController;
        vc.conference = conference;
    }
}

@end
