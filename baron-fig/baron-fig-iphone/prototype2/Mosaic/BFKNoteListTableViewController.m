//
//  BFKNoteListTableViewController.m
//  Mosaic
//
//  Created by Joe Gallo on 1/18/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import "BFKNoteListTableViewController.h"
#import "BFKUtil.h"
#import "BFKAppDelegate.h"
#import "BFKDao.h"
#import "BFKNoteTableViewCell.h"
#import "BFKNotePart.h"
#import "BFKNoteTableViewController.h"

@interface BFKNoteListTableViewController ()
    @property (strong, nonatomic) NSMutableArray *notes;
    @property (strong, nonatomic) UIImageView *bgImageView;
    @property (strong, nonatomic) UIView *firstNoteTooltipView;
    @property (nonatomic) BOOL showTooltip;
@end

@implementation BFKNoteListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // make sure status bar is visible
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    // background color
    self.view.backgroundColor = [BFKUtil colorFromHex:@"693148"];
    
    // background image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"note-list-bg"]];
    imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.alpha = 0;
    self.tableView.backgroundView = imageView;
    self.bgImageView = imageView;
    
    // table view
    [self setupTableView];
    
    self.showTooltip = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // light status bar
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.notes = [[BFKDao notes] mutableCopy];
    [self.tableView reloadData];
    
    // navigation bar
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.showTooltip = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self removeTooltip:NO];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupNavigationBar {
    // background color
    [self.navigationController.navigationBar setBarTintColor:[BFKUtil colorFromHex:@"693148"]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    // bar button items
    NSDictionary *barButtonItemAttributes = @{
                                              NSFontAttributeName: [UIFont fontWithName:@"GothamBook" size:12],
                                              NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"]
                                              };
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    // title
    self.navigationItem.title = @"MY NOTES";
    
    NSDictionary *navbarTitleAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"GothamBold" size:12],
                                            NSForegroundColorAttributeName: [UIColor whiteColor]
                                            };
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleAttributes];
    
    // back button (for note view)
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Notes"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    // hide toolbar
    self.navigationController.toolbarHidden = YES;
}

- (void)setupTableView {
    // hide empty table view cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // add custom tap recognizer to table view
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleTapOnTableView:)];
    [self.tableView addGestureRecognizer:tapGR];
}

- (void)createAndShowTooltip {
    // background
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tooltip-bg"]];
    backgroundImageView.frame = CGRectMake(162, 58,
                                           backgroundImageView.frame.size.width,
                                           backgroundImageView.frame.size.height);
    
    // label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5,
                                                               backgroundImageView.frame.size.width,
                                                               backgroundImageView.frame.size.height)];
    NSString *labelText = @"Tap to add your first note";
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Regular" size:13],
                                 NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:labelText
                                                                                       attributes:attributes];
    label.attributedText = attributedText;
    
    [backgroundImageView addSubview:label];
    
    // assign tooltip view to variable
    self.firstNoteTooltipView = backgroundImageView;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.firstNoteTooltipView];
}

- (void)removeTooltip:(BOOL)animate {
    float duration = 0.25;
    if (!animate) {
        duration = 0;
    }
    
    // fade out
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.firstNoteTooltipView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [self.firstNoteTooltipView removeFromSuperview];
                     }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numRows = self.notes.count;
    
    // hide/fade in background image
    if (numRows == 0) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.bgImageView.alpha = 1;
                         }
                         completion:nil];
        
        // if no notes, show tooltip only once
        if (self.showTooltip) {
            [self createAndShowTooltip];
            self.showTooltip = NO;
        }
    } else {
        self.bgImageView.alpha = 0;
    }
    
    return numRows;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BFKNote *note = [self.notes objectAtIndex:indexPath.row];
        [BFKDao deleteNote:note];
        [self.notes removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NoteCell";
    
    BFKNote *note = (BFKNote *)[self.notes objectAtIndex:indexPath.row];
    
    BFKNoteTableViewCell *cell = (BFKNoteTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BFKNoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // name
    cell.nameLabel.text = note.name;
    
    BFKNotePart *firstNotePart = (BFKNotePart *)note.noteParts.firstObject;
    BFKNotePart *lastNotePart = (BFKNotePart *)note.noteParts.lastObject;
    
    if (firstNotePart && lastNotePart) {
        // date
        NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, h:mm a"];
        cell.dateLabel.text = [dateFormatter stringFromDate:lastNotePart.date];
        
        // body
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.minimumLineHeight = 16;
        paragraphStyle.maximumLineHeight = 16;
//        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        // safety net for if there are note parts but they're all images
        NSString *firstNotePartText = @"";
        if (firstNotePart.text) {
            firstNotePartText = firstNotePart.text;
        }
        if (lastNotePart.text) {
            firstNotePartText = lastNotePart.text;
        }
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName: cell.bodyLabel.font,
                                     NSForegroundColorAttributeName: cell.bodyLabel.textColor,
                                     NSParagraphStyleAttributeName: paragraphStyle
                                     };
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:firstNotePartText
                                                                               attributes:attributes];
        cell.bodyLabel.attributedText = attributedString;
        [BFKUtil adjustText:cell.bodyLabel width:284 height:42];
    } else {
        cell.dateLabel.text = @"";
        cell.bodyLabel.text = @"";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 81;
}

#pragma mark - Actions

- (IBAction)toggleSidebar:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewDeckController toggleLeftView];
    
    [self removeTooltip:NO];
}

- (IBAction)handleTapOnTableView:(UIGestureRecognizer*)recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    if (indexPath) {
        recognizer.cancelsTouchesInView = NO;
    } else {
        [self removeTooltip:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"goToNote"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BFKNote *note = [self.notes objectAtIndex:indexPath.row];
        BFKNoteTableViewController *vc = (BFKNoteTableViewController *)segue.destinationViewController;
        vc.note = note;
    }
}

@end
