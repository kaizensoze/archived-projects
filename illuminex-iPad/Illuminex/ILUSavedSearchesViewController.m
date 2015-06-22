//
//  ILUSavedSearchesViewController.m
//  illuminex
//
//  Created by Joe Gallo on 11/2/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUSavedSearchesViewController.h"
#import "ILUSearchParams.h"
#import "ILUSavedSearchTableViewCell.h"
#import "ILUSavedSearch.h"

@interface ILUSavedSearchesViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *searchButton;
    @property (weak, nonatomic) IBOutlet UITableView *savedSearchesTableView;

    @property (strong, nonatomic) NSMutableArray *savedSearches;
@end

@implementation ILUSavedSearchesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // new search button
    [ILUCustomStyler styleButton:self.searchButton];
    
    // get saved searches from NSUserDefaults
    NSMutableArray *userDefaultSavedSearches = (NSMutableArray *)[appDelegate objectForKey:@"savedSearches"];
    self.savedSearches = userDefaultSavedSearches;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.savedSearches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SavedSearchCell";
    
    ILUSavedSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ILUSavedSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ILUSavedSearch *savedSearch = self.savedSearches[indexPath.row];
    
    cell.theImageView.image = [UIImage imageNamed:@"search-result-diamond-example-small"];
    cell.titleLabel.text = savedSearch.title;
    cell.titleTextField.tintColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
}

#pragma mark - Edit saved search

- (IBAction)editSavedSearch:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.savedSearchesTableView];
    NSIndexPath *indexPath = [self.savedSearchesTableView indexPathForRowAtPoint:buttonPosition];
    ILUSavedSearchTableViewCell *cell = (ILUSavedSearchTableViewCell *)
                                          [self.savedSearchesTableView cellForRowAtIndexPath:indexPath];
    
    cell.editButton.hidden = YES;
    cell.saveButton.hidden = NO;
    
    cell.titleTextField.text = cell.titleLabel.text;
    cell.titleLabel.hidden = YES;
    cell.titleTextField.hidden = NO;
    cell.titleTextFieldBackgroundImageView.hidden = NO;
}

#pragma mark - Save saved search

- (IBAction)saveSavedSearch:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.savedSearchesTableView];
    NSIndexPath *indexPath = [self.savedSearchesTableView indexPathForRowAtPoint:buttonPosition];
    ILUSavedSearchTableViewCell *cell = (ILUSavedSearchTableViewCell *)
                                          [self.savedSearchesTableView cellForRowAtIndexPath:indexPath];
    
    cell.saveButton.hidden = YES;
    cell.editButton.hidden = NO;
    
    ILUSavedSearch *savedSearch = self.savedSearches[indexPath.row];
    savedSearch.title = cell.titleTextField.text;
    
    cell.titleLabel.text = savedSearch.title;
    cell.titleTextField.hidden = YES;
    cell.titleTextFieldBackgroundImageView.hidden = YES;
    cell.titleLabel.hidden = NO;
    
    [appDelegate saveObject:self.savedSearches forKey:@"savedSearches"];
}

#pragma mark - Delete saved search

- (IBAction)deleteSavedSearch:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.savedSearchesTableView];
    NSIndexPath *indexPath = [self.savedSearchesTableView indexPathForRowAtPoint:buttonPosition];
    
    // remove from data source
    [self.savedSearches removeObjectAtIndex:indexPath.row];
    
    // remove from table
    [self.savedSearchesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    // update saved searches stored in user defaults
    [appDelegate saveObject:self.savedSearches forKey:@"savedSearches"];
}

#pragma mark - Open flyout menu

- (IBAction)openFlyoutMenu:(id)sender {
    [appDelegate.viewDeckController toggleLeftView];
}

#pragma mark - New search

- (IBAction)newSearch:(id)sender {
    UIViewController *searchVC = [storyboard instantiateViewControllerWithIdentifier:@"Search"];
    appDelegate.viewDeckController.centerController = searchVC;
}

#pragma mark - Touches ended

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
