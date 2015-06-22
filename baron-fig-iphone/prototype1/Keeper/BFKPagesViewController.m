//
//  BFKPagesViewController.m
//  Keeper
//
//  Created by Joe Gallo on 11/23/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKPagesViewController.h"
#import "BFKPage.h"
#import "BFKAppDelegate.h"
#import "BFKUtil.h"
#import "BFKDao.h"
#import "BFKShare.h"
#import "BFKCapturedImage.h"
#import "BFKPagesGridCollectionViewCell.h"
#import "BFKPagesSingleCollectionViewCell.h"

@interface BFKPagesViewController ()
    @property (strong, nonatomic) NSMutableOrderedSet *pages;
    @property (nonatomic) BFKPagesMode pagesMode;

    @property (strong, nonatomic) UIBarButtonItem *pagesGridBarButtonItem;
    @property (strong, nonatomic) UIBarButtonItem *pagesSingleBarButtonItem;
    @property (strong, nonatomic) UIBarButtonItem *sharePageBarButtonItem;

    @property (weak, nonatomic) IBOutlet UICollectionView *pagesGridCollectionView;
    @property (weak, nonatomic) IBOutlet UICollectionView *pagesSingleCollectionView;

    @property (weak, nonatomic) IBOutlet UILabel *numPagesLabel;
    @property (weak, nonatomic) IBOutlet UILabel *pageIndexLabel;

    // change location
    @property (strong, nonatomic) NSArray *notebookNames;
    @property (strong, nonatomic) NSArray *sectionNames;

    @property (weak, nonatomic) IBOutlet UIButton *locationButton;

    @property (weak, nonatomic) IBOutlet UIView *changeLocationViewOverlay;
    @property (weak, nonatomic) IBOutlet UIView *changeLocationView;
    @property (weak, nonatomic) IBOutlet UITextField *notebookTextField;
    @property (weak, nonatomic) IBOutlet UITextField *sectionTextField;

    @property (strong, nonatomic) UITableView *autocompleteTableView;
    @property (strong, nonatomic) NSArray *autocompleteResults;

    @property (nonatomic) BOOL inEditMode;
    @property (weak, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGR;

    @property (strong, nonatomic) BFKShare *share;
    @property (weak, nonatomic) IBOutlet UIView *shareView;
    @property (weak, nonatomic) IBOutlet UIView *shareOverlay;

    @property (strong, nonatomic) BFKPage *pagePendingDeletion;

    @property (strong, nonatomic) NSIndexPath *indexPathOverride;

    @property (nonatomic) CGPoint slideUpViewMinCenter;
    @property (nonatomic) CGPoint slideUpViewMaxCenter;
    @property (nonatomic) float viewSuperviewYDiff;

    @property (nonatomic) CGRect lastNoteTextViewFrame;
@end

@implementation BFKPagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [BFKUtil colorFromHex:@"d0d8e2"];
    
    self.pagesGridBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pages-grid-button"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showGridPageView:)];
    self.pagesSingleBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pages-single-button"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                    action:@selector(showSinglePageView:)];
    self.sharePageBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share-page-button"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showSharePageView:)];
    
    self.share = [[BFKShare alloc] init];
    
    // adjustment for collection view
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.slideUpViewMinCenter = CGPointMake(160, 18);
    self.slideUpViewMaxCenter = CGPointMake(160, 398);
    self.viewSuperviewYDiff = 190.5;
    
    // autocomplete tableview
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:self.autocompleteTableView];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(hideChangeLocationView:)];
    [self.autocompleteTableView addGestureRecognizer:tapGR];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // show status/navigation bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self setupAndShowNavigationBar];
    
    self.pages = [self.section.pages mutableCopy];
    [self.pagesGridCollectionView reloadData];
    [self.pagesSingleCollectionView reloadData];
    
    [self setPagesMode:BFKPagesSingleMode];
    
    [self disableEditMode];
    
    self.shareView.hidden = YES;
    self.shareOverlay.hidden = YES;
    
    [self updateShareButton];
    
    // autocomplete
    self.autocompleteResults = @[];
    
    self.notebookNames = [BFKDao notebookNames];
    self.sectionNames = [BFKDao sectionNames];
    
    // prefill notebook/section
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.suggestedNotebook && [self.notebookNames indexOfObject:appDelegate.suggestedNotebook] != NSNotFound) {
        self.notebookTextField.text = appDelegate.suggestedNotebook;
    } else if (self.notebookNames.count > 0) {
        self.notebookTextField.text = self.notebookNames.firstObject;
    }
    if (appDelegate.suggestedSection && [self.sectionNames indexOfObject:appDelegate.suggestedSection] != NSNotFound) {
        self.sectionTextField.text = appDelegate.suggestedSection;
    } else if (self.sectionNames.count > 0) {
        self.sectionTextField.text = self.sectionNames.firstObject;
    }
    [self updateLocation];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.tracker set:kGAIScreenName value:@"Pages View"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterForKeyboardNotifications];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupAndShowNavigationBar {
    // make navigation bar transparent
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
    self.navigationController.navigationBar.tintColor = [BFKUtil colorFromHex:@"693148"];
    
    // set navigation bar title
    self.navigationItem.title = [self.section.name uppercaseString];
    
    NSDictionary *navbarTitleAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Bold" size:12],
                                            NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"]
                                            };
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleAttributes];
}

- (void)updatePagesInfo {
    // # pages label
    self.numPagesLabel.text = [NSString stringWithFormat:@"%d %@",
                               self.pages.count,
                               [[BFKUtil singlePluralize:@"page" amount:self.pages.count] uppercaseString]];
    
    if (self.pages.count == 0) {
        self.pageIndexLabel.hidden = YES;
        self.locationButton.hidden = YES;
        return;
    }
    
    // page index label
    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    if (!indexPath) {
        indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    if (self.indexPathOverride) {
        indexPath = self.indexPathOverride;
    }
    self.indexPathOverride = nil;
    self.pageIndexLabel.text = [NSString stringWithFormat:@"%d of %d", indexPath.item+1, self.pages.count];
}

- (UICollectionView *)getCollectionView {
    if (self.pagesMode == BFKPagesGridMode) {
        return self.pagesGridCollectionView;
    } else {
        return self.pagesSingleCollectionView;
    }
}

- (void)setPagesMode:(BFKPagesMode)pagesMode {
    _pagesMode = pagesMode;
    
    if (_pagesMode == BFKPagesGridMode) {
        self.navigationItem.rightBarButtonItems = @[self.pagesSingleBarButtonItem];
        
        self.pagesGridCollectionView.hidden = NO;
        self.pagesSingleCollectionView.hidden = YES;
        
        self.numPagesLabel.hidden = NO;
        self.pageIndexLabel.hidden = YES;
        self.locationButton.hidden = YES;
        
//        if (self.inEditMode) {
//            [self enableEditMode:nil];
//        }
    } else {
        self.navigationItem.rightBarButtonItems = @[self.pagesGridBarButtonItem, self.sharePageBarButtonItem];
        [self updateShareButton];
        
        self.pagesSingleCollectionView.hidden = NO;
        self.pagesGridCollectionView.hidden = YES;
        
        self.pageIndexLabel.hidden = NO;
        self.locationButton.hidden = NO;
        self.numPagesLabel.hidden = YES;
        
        if (self.pages.count == 0) {
            self.pageIndexLabel.hidden = YES;
        }
        
        // go to last item
        if (self.goToLastItem && [self.goToLastItem boolValue]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.pages.count-1 inSection:0];
            [self.pagesSingleCollectionView scrollToItemAtIndexPath:indexPath
                                                   atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                           animated:NO];
            self.indexPathOverride = indexPath;
            self.goToLastItem = nil;
        }
    }
    
    [self updatePagesInfo];
}

#pragma mark - Show grid page view

- (IBAction)showGridPageView:(id)sender {
    [self setPagesMode:BFKPagesGridMode];
}

#pragma mark - Show single page view

- (IBAction)showSinglePageView:(id)sender {
    [self setPagesMode:BFKPagesSingleMode];
}

#pragma mark - Update share button
- (void)updateShareButton {
    if (self.pages.count == 0) {
        self.sharePageBarButtonItem.enabled = NO;
    } else {
        self.sharePageBarButtonItem.enabled = YES;
    }
}

#pragma mark - Show share page view

- (IBAction)showSharePageView:(id)sender {
    CGRect frame = self.shareView.frame;
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    self.shareView.frame = frame;
    
    self.shareView.hidden = NO;
    self.shareOverlay.hidden = NO;
}

- (IBAction)hideSharePageView:(id)sender {
    [self.view endEditing:YES];
    self.shareView.hidden = YES;
    self.shareOverlay.hidden = YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BFKPage *page = self.pages[indexPath.item];
    
    UICollectionViewCell *cell;
    
    if (collectionView == self.pagesGridCollectionView) {
        BFKPagesGridCollectionViewCell *thisCell = (BFKPagesGridCollectionViewCell *)
                                                   [collectionView dequeueReusableCellWithReuseIdentifier:@"PagesGridCell"
                                                                                             forIndexPath:indexPath];
        if ([page.item isKindOfClass:[BFKCapturedImage class]]) {
            BFKCapturedImage *capturedImage = (BFKCapturedImage *)page.item;
            thisCell.pageImageView.image = [UIImage imageWithData:capturedImage.image];
        } else {
            thisCell.pageImageView.image = [UIImage imageNamed:@"note-page"];
        }
        
        if (self.inEditMode) {
            thisCell.deleteButton.hidden = NO;
            [BFKUtil wobble:thisCell];
        } else {
            thisCell.deleteButton.hidden = YES;
            [thisCell.layer removeAllAnimations]; // remove wobble
        }
        
        cell = thisCell;
    } else {
        BFKPagesSingleCollectionViewCell *thisCell = (BFKPagesSingleCollectionViewCell *)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"PagesSingleCell"
                                                  forIndexPath:indexPath];
        
//        [BFKUtil setBorder:thisCell.noteTextView];
        
        thisCell.slideForNoteButton.center = self.slideUpViewMaxCenter;
        thisCell.scrollView.center = CGPointMake(thisCell.scrollView.center.x,
                                                 thisCell.slideForNoteButton.center.y - self.viewSuperviewYDiff);
        
        if ([page.item isKindOfClass:[BFKCapturedImage class]]) {
            // captured image
            BFKCapturedImage *capturedImage = (BFKCapturedImage *)page.item;
            thisCell.scrollView.hidden = NO;
            thisCell.pageImageView.image = [UIImage imageWithData:capturedImage.image];
            
            // zoom
            thisCell.scrollView.contentSize = thisCell.pageImageView.frame.size;
            thisCell.scrollView.zoomScale = 1.0;
            thisCell.scrollView.minimumZoomScale = 1.0;
            thisCell.scrollView.maximumZoomScale = 1.5;
            
            if (page.item.note) {
                thisCell.noteTextView.text = page.item.note;
                thisCell.noteTextView.frame = CGRectMake(10, 35, 300, 370);
                
                if (thisCell.gestureRecognizers.count == 0) {
                    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(slideForNote:)];
                    [thisCell.slideForNoteButton addGestureRecognizer:panGR];
                    
                    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(resignNoteTextView:)];
                    [thisCell addGestureRecognizer:tapGR];
                }
                
                thisCell.slideForNoteButton.hidden = NO;
            } else {
                thisCell.slideForNoteButton.hidden = YES;
            }
        } else if ([page.item isKindOfClass:[BFKCapturedNote class]]) {
            // captured note
            thisCell.scrollView.hidden = YES;
            thisCell.slideForNoteButton.hidden = YES;
            
            thisCell.noteTextView.frame = CGRectMake(10, 5, 300, 400);
            thisCell.noteTextView.text = page.item.note;
        }
        
        cell = thisCell;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDataSource_Draggable

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pagesMode == BFKPagesGridMode) {
        return YES;
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
canMoveItemAtIndexPath:(NSIndexPath *)indexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    if (self.pagesMode == BFKPagesGridMode) {
        return YES;
    }
    return NO;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView
   moveItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    if (self.pagesMode == BFKPagesSingleMode) {
        return;
    }
    
    BFKPage *page = self.pages[fromIndexPath.item];
    
    [self.pages removeObjectAtIndex:fromIndexPath.item];
    [self.pages insertObject:page atIndex:toIndexPath.item];
    
    [self.section setPages:[self.pages copy]];
    [BFKDao saveContext];
    
    [self.pagesSingleCollectionView reloadData];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.inEditMode) {
        return;
    }
    
    if (collectionView == self.pagesGridCollectionView) {
        [self.pagesSingleCollectionView scrollToItemAtIndexPath:indexPath
                                               atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                       animated:NO];
        self.indexPathOverride = indexPath;
        [self setPagesMode:BFKPagesSingleMode];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.pagesGridCollectionView) {
        return CGSizeMake(85, 115);
    } else {
        return CGSizeMake(320, 415);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.pagesGridCollectionView) {
        return 10;
    } else {
        return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (collectionView == self.pagesGridCollectionView) {
        return 10;
    } else {
        return 0;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.pagesSingleCollectionView) {
        [self updatePagesInfo];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    BFKPagesSingleCollectionViewCell *cell = (BFKPagesSingleCollectionViewCell *)
                                             [self.pagesSingleCollectionView cellForItemAtIndexPath:indexPath];
    return cell.pageImageView;
}

#pragma mark - Delete page

- (IBAction)deletePage:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.pagesGridCollectionView];
    buttonPosition.x = buttonPosition.x + button.frame.size.width;
    buttonPosition.y = buttonPosition.y + button.frame.size.height;
    
    NSIndexPath *indexPath = [self.pagesGridCollectionView indexPathForItemAtPoint:buttonPosition];
    BFKPage *page = self.pages[indexPath.item];
    self.pagePendingDeletion = page;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete page?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        int index = [self.pages indexOfObject:self.pagePendingDeletion];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];

        [BFKDao deletePage:self.pagePendingDeletion];
        [self.pages removeObject:self.pagePendingDeletion];

        [self.section setPages:[self.pages copy]];
        [BFKDao saveContext];

        [self.pagesGridCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        [self.pagesSingleCollectionView reloadData];
        
        [self updatePagesInfo];
    }

    self.pagePendingDeletion = nil;
}

#pragma mark - Enable edit mode

- (IBAction)enableEditMode:(id)sender {
    // show delete button
    self.inEditMode = YES;
    [[self getCollectionView] reloadData];
    
    // enable drag/drop
    [self getCollectionView].draggable = YES;
    
    // disable view controller's long press gesture
    self.longPressGR.enabled = NO;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone target:self
                                                                  action:@selector(disableEditMode)];
    NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"BrandonGrotesque-Regular" size:14.0], NSFontAttributeName, nil];
    [doneButton setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = doneButton;
}

#pragma mark - Disable edit mode

- (void)disableEditMode {
    // hide delete button
    self.inEditMode = NO;
    [[self getCollectionView] reloadData];
    
    // disable drag/drop
    [self getCollectionView].draggable = NO;
    
    // enable view controller's long press gesture
    self.longPressGR.enabled = YES;
    
    if (self.pagesMode == BFKPagesGridMode) {
        self.navigationItem.rightBarButtonItem = nil;
        [self setPagesMode:BFKPagesGridMode];
    }
}

#pragma mark - Update location

- (void)updateLocation {
    NSString *locationText = [NSString stringWithFormat:@"%@ > %@", self.section.notebook.name, self.section.name];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Regular" size:13],
                                 NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"]
                                 };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:locationText
                                                                                         attributes:attributes];
    [self.locationButton setAttributedTitle:attributedString forState:UIControlStateNormal];
}

#pragma mark - Show change location view

- (IBAction)showChangeLocationView:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [self.navigationController setNavigationBarHidden:YES];
    
    self.changeLocationViewOverlay.hidden = NO;
    self.changeLocationView.hidden = NO;
    self.autocompleteTableView.hidden = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [self.notebookTextField becomeFirstResponder];
    [UIView commitAnimations];
}

#pragma mark - Hide change location view

- (IBAction)hideChangeLocationView:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tapGR = (UITapGestureRecognizer *)sender;
        CGPoint tapLocation = [tapGR locationInView:self.autocompleteTableView];
        NSIndexPath *indexPath = [self.autocompleteTableView indexPathForRowAtPoint:tapLocation];
        if (indexPath) {
            tapGR.cancelsTouchesInView = NO;
            return;
        }
    }
    
    self.changeLocationViewOverlay.hidden = YES;
    self.changeLocationView.hidden = YES;
    self.autocompleteTableView.hidden = YES;
    
    [self.view endEditing:YES];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    if (self.pagesSingleCollectionView.center.y >= self.slideUpViewMaxCenter.y) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self resetSearchAutocompleteResults];
    [self searchAutocompleteResultsForSubstring:textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *substring = [NSString stringWithString:textField.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchAutocompleteResultsForSubstring:substring];
    return YES;
}

- (void)searchAutocompleteResultsForSubstring:(NSString *)substring {
    NSArray *arrayToSearch;
    if ([self.notebookTextField isFirstResponder]) {
        arrayToSearch = self.notebookNames;
    } else {
        arrayToSearch = self.sectionNames;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", substring];
    self.autocompleteResults = [[arrayToSearch filteredArrayUsingPredicate:predicate] mutableCopy];
    if ([substring isEqualToString:@""]) {
        self.autocompleteResults = arrayToSearch;
    }
    [self.autocompleteTableView reloadData];
    
//    if (self.autocompleteResults.count > 0) {
//        self.autocompleteTableView.hidden = NO;
//    } else {
//        self.autocompleteTableView.hidden = YES;
//    }
}

- (void)resetSearchAutocompleteResults {
    [self searchAutocompleteResultsForSubstring:@""];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self updateLocation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.notebookTextField) {
        [self.sectionTextField becomeFirstResponder];
    } else if (textField == self.sectionTextField) {
        [self save:nil];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.lastNoteTextViewFrame = textView.frame;
    
    CGRect frame = textView.frame;
    frame.size.height = 150;
    textView.frame = frame;
    
    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    BFKPagesSingleCollectionViewCell *cell = (BFKPagesSingleCollectionViewCell *)[self.pagesSingleCollectionView cellForItemAtIndexPath:indexPath];
    cell.saveNoteButton.hidden = NO;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    textView.frame = self.lastNoteTextViewFrame;
   
    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    BFKPagesSingleCollectionViewCell *cell = (BFKPagesSingleCollectionViewCell *)[self.pagesSingleCollectionView cellForItemAtIndexPath:indexPath];
    cell.saveNoteButton.hidden = YES;
}

- (IBAction)resignNoteTextView:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)saveNote:(id)sender {
    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    BFKPagesSingleCollectionViewCell *cell = (BFKPagesSingleCollectionViewCell *)
                                             [self.pagesSingleCollectionView cellForItemAtIndexPath:indexPath];
    BFKPage *page = self.pages[indexPath.item];
    page.item.note = cell.noteTextView.text;
    
    [BFKDao saveContext];
    
    [cell.noteTextView resignFirstResponder];
}

#pragma mark - Save

- (IBAction)save:(id)sender {
    if ([BFKUtil isEmpty:self.notebookTextField.text]) {
        [BFKUtil showAlert:@"" message:@"Please specify a notebook." delegate:nil];
        return;
    }
    
    if ([BFKUtil isEmpty:self.sectionTextField.text]) {
        [BFKUtil showAlert:@"" message:@"Please specify a section." delegate:nil];
        return;
    }
    
    BFKNotebook *notebook = [BFKDao findOrCreateNotebookWithName:self.notebookTextField.text];
    BFKSection *section = [BFKDao findOrCreateSectionWithName:self.sectionTextField.text notebook:notebook];
    
//    // set suggested notebook, section
//    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
//    appDelegate.suggestedNotebook = notebook.name;
//    appDelegate.suggestedSection = section.name;
    
    [notebook addSectionsObject:section];

    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    BFKPage *page = self.pages[indexPath.item];
    
    page.section = section;
    
    [BFKDao saveContext];
    
    self.pages = [self.section.pages mutableCopy];
    
    [self.pagesSingleCollectionView reloadData];
    [self.pagesGridCollectionView reloadData];
    [self updatePagesInfo];
    [self updateShareButton];
    
    [self hideChangeLocationView:nil];
}

# pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.autocompleteResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.autocompleteResults[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if ([self.autocompleteTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.autocompleteTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.autocompleteTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.autocompleteTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *autocompleteString = self.autocompleteResults[indexPath.row];
    
    UITextField *textField;
    if ([self.notebookTextField isFirstResponder]) {
        textField = self.notebookTextField;
    } else {
        textField = self.sectionTextField;
    }
    textField.text = autocompleteString;
    
    [self resetSearchAutocompleteResults];
}

#pragma mark - Slide for note

- (IBAction)slideForNote:(id)sender {
    // dismiss keyboard if open
    [self.view endEditing:YES];
    
    UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)sender;
    
    UIView *view = panGR.view;
    
    BFKPagesSingleCollectionViewCell *cell = (BFKPagesSingleCollectionViewCell *)panGR.view.superview.superview;
    UIView *superview = cell.scrollView;
    
    CGPoint center;
    
    center = view.center;
    CGPoint translation = [panGR translationInView:view];
    center = CGPointMake(center.x, center.y + translation.y);
    if (center.y < self.slideUpViewMinCenter.y) {
        center = self.slideUpViewMinCenter;
    }
    if (center.y > self.slideUpViewMaxCenter.y) {
        center = self.slideUpViewMaxCenter;
    }
    
    view.center = center;
    superview.center = CGPointMake(superview.center.x, view.center.y - self.viewSuperviewYDiff);
    [panGR setTranslation:CGPointZero inView:view];
    
    if (panGR.state == UIGestureRecognizerStateEnded) {
        float velocityY = 0.2 * [panGR velocityInView:view].y;
        CGPoint finalCenter = CGPointMake(view.center.x,
                                          view.center.y + velocityY);
        
        if (finalCenter.y < self.slideUpViewMinCenter.y) {
            finalCenter = self.slideUpViewMinCenter;
        }
        if (finalCenter.y > self.slideUpViewMaxCenter.y) {
            finalCenter = self.slideUpViewMaxCenter;
        }
        
        float animationDuration = fabsf(velocityY * 0.00002) + 0.2;
        
        if (fabsf(center.y - finalCenter.y) >= 25) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            view.center = finalCenter;
            superview.center = CGPointMake(superview.center.x, view.center.y - self.viewSuperviewYDiff);
            [UIView commitAnimations];
        }
        
        // if past midway, slide to end
        float midpoint = ((self.slideUpViewMinCenter.y - self.slideUpViewMaxCenter.y) / 2) + self.slideUpViewMaxCenter.y;
        if (center.y < finalCenter.y && finalCenter.y >= midpoint && finalCenter.y < self.slideUpViewMaxCenter.y) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            view.center = self.slideUpViewMaxCenter;
            superview.center = CGPointMake(superview.center.x, view.center.y - self.viewSuperviewYDiff);
            [UIView commitAnimations];
        } else if (center.y > finalCenter.y && finalCenter.y <= midpoint && finalCenter.y > self.slideUpViewMinCenter.y) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            view.center = self.slideUpViewMinCenter;
            superview.center = CGPointMake(superview.center.x, view.center.y - self.viewSuperviewYDiff);
            [UIView commitAnimations];
        }
    }
}

#pragma mark - Import content

- (IBAction)importContent:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController pushViewController:appDelegate.captureVC animated:YES];
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}

- (void)keyboardWillBeShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // position autocomplete table view
    self.autocompleteTableView.frame = CGRectMake(0,
                                                  self.changeLocationView.frame.size.height,
                                                  self.view.frame.size.width,
                                                  self.view.frame.size.height
                                                  - kbSize.height
                                                  - self.changeLocationView.frame.size.height);
}

#pragma mark - Share instagram

- (IBAction)shareInstagram:(id)sender {
    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    BFKPage *page = (BFKPage *)self.pages[indexPath.item];
    BFKCapturedImage *item = (BFKCapturedImage *)page.item;
    UIImage *image = [UIImage imageWithData:item.image];
    
    [self.share shareInstagram:image vc:self];
}

#pragma mark - Share facebook

- (IBAction)shareFacebook:(id)sender {
    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    BFKPage *page = (BFKPage *)self.pages[indexPath.item];
    BFKCapturedItem *item = page.item;
    
    [self.share shareFacebook:item vc:self];
    [self hideSharePageView:nil];
}

#pragma mark - Share twitter

- (IBAction)shareTwitter:(id)sender {
    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    BFKPage *page = (BFKPage *)self.pages[indexPath.item];
    BFKCapturedItem *item = page.item;
    
    [self.share shareTwitter:item vc:self];
    [self hideSharePageView:nil];
}

#pragma mark - Share email

- (IBAction)shareEmail:(id)sender {
    NSIndexPath *indexPath = [self.pagesSingleCollectionView indexPathsForVisibleItems].firstObject;
    BFKPage *page = (BFKPage *)self.pages[indexPath.item];
    BFKCapturedItem *item = page.item;
    
    [self.share shareEmail:item vc:self];
    [self hideSharePageView:nil];
}

#pragma mark - Touches ended

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
//}

@end
