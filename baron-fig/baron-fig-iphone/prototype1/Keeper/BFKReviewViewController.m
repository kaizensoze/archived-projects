//
//  BFKReviewViewController.m
//  Keeper
//
//  Created by Joe Gallo on 11/6/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKReviewViewController.h"
#import "BFKUtil.h"
#import "BFKAppDelegate.h"
#import "UIImage+Utility.h"
#import "BFKCustomStyler.h"
#import "BFKCapturedItem.h"
#import "BFKCapturedImage.h"
#import "BFKCapturedNote.h"
#import "BFKPage.h"
#import "BFKSection.h"
#import "BFKNotebook.h"
#import "BFKDao.h"
#import "BFKNotebooksViewController.h"
#import "BFKShare.h"
#import "BFKSectionsViewController.h"
#import "BFKPagesViewController.h"

@interface BFKReviewViewController ()
    // slide up (snapshot)
    @property (weak, nonatomic) IBOutlet UIView *slideUpView;
    @property (weak, nonatomic) IBOutlet UIImageView *snapshotImageView;
    @property (weak, nonatomic) IBOutlet UIScrollView *snapshotScrollView;
    @property (weak, nonatomic) IBOutlet UITextView *snapshotTextView;
    @property (weak, nonatomic) IBOutlet UIView *snapshotSwipeView;
    @property (weak, nonatomic) IBOutlet UIButton *slideForNoteButton;

    @property (nonatomic) CGPoint slideUpViewMinCenter;
    @property (nonatomic) CGPoint slideUpViewMaxCenter;

    // share/save
    @property (weak, nonatomic) IBOutlet UIView *shareSaveView;
    @property (weak, nonatomic) IBOutlet UIButton *locationButton;

    // change location
    @property (strong, nonatomic) NSArray *notebookNames;
    @property (strong, nonatomic) NSArray *sectionNames;

    @property (weak, nonatomic) IBOutlet UIView *changeLocationViewOverlay;
    @property (weak, nonatomic) IBOutlet UIView *changeLocationView;
    @property (weak, nonatomic) IBOutlet UITextField *notebookTextField;
    @property (weak, nonatomic) IBOutlet UITextField *sectionTextField;

    @property (strong, nonatomic) UITableView *autocompleteTableView;
    @property (strong, nonatomic) NSArray *autocompleteResults;

    // note
    @property (weak, nonatomic) IBOutlet UIView *noteView;
    @property (weak, nonatomic) IBOutlet UITextView *noteTextView;
    @property (strong, nonatomic) NSString *noteTextViewPlaceholderText;

    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

    @property (nonatomic) int capturedItemIndex;

    @property (strong, nonatomic) BFKShare *share;
@end

@implementation BFKReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set navigation bar title
    self.navigationItem.title = @"REVIEW";
    
//    // snapshot image
//    self.snapshotScrollView.contentSize = self.snapshotImageView.frame.size;
//    self.snapshotScrollView.minimumZoomScale = 1.0;
//    self.snapshotScrollView.maximumZoomScale = 2.0;
    
//    // snapshow text view
//    [BFKUtil setBorder:self.snapshotTextView width:1 color:[UIColor whiteColor]];
//    [BFKUtil roundCorners:self.snapshotTextView radius:10];
    
//    NSData *imgData = UIImagePNGRepresentation((UIImage *)self.capturedItems[0]);
//    NSLog(@"Size of Image (bytes): %d",[imgData length]);
    
    // swipe gestures for prev/next item
    UISwipeGestureRecognizer* swipeLeftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNextItem:)];
    swipeLeftGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.snapshotScrollView addGestureRecognizer:swipeLeftGR];
    
    UISwipeGestureRecognizer* swipeRightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showPrevItem:)];
    swipeRightGR.direction = UISwipeGestureRecognizerDirectionRight;
    [self.snapshotScrollView addGestureRecognizer:swipeRightGR];
    
    swipeLeftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNextItem:)];
    swipeLeftGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.snapshotTextView addGestureRecognizer:swipeLeftGR];
    
    swipeRightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showPrevItem:)];
    swipeRightGR.direction = UISwipeGestureRecognizerDirectionRight;
    [self.snapshotTextView addGestureRecognizer:swipeRightGR];
    
    swipeLeftGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showNextItem:)];
    swipeLeftGR.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.snapshotSwipeView addGestureRecognizer:swipeLeftGR];
    
    swipeRightGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showPrevItem:)];
    swipeRightGR.direction = UISwipeGestureRecognizerDirectionRight;
    [self.snapshotSwipeView addGestureRecognizer:swipeRightGR];
    
    // notebook/section text view placeholder
    [self.notebookTextField setValue:[BFKUtil colorFromHex:@"ffffff" alpha:0.65] forKeyPath:@"_placeholderLabel.textColor"];
    [self.sectionTextField setValue:[BFKUtil colorFromHex:@"ffffff" alpha:0.65] forKeyPath:@"_placeholderLabel.textColor"];
    
    // autocomplete tableview
    self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.autocompleteTableView.dataSource = self;
    self.autocompleteTableView.delegate = self;
    self.autocompleteTableView.hidden = YES;
    [self.view addSubview:self.autocompleteTableView];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(hideChangeLocationView:)];
    [self.autocompleteTableView addGestureRecognizer:tapGR];
    
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideForNote:)];
    [self.slideForNoteButton addGestureRecognizer:panGR];
    
    // notebook/section textfields
    [self.notebookTextField setValue:[BFKUtil colorFromHex:@"ffffff" alpha:0.65] forKeyPath:@"_placeholderLabel.textColor"];
    [self.sectionTextField setValue:[BFKUtil colorFromHex:@"ffffff" alpha:0.65] forKeyPath:@"_placeholderLabel.textColor"];
    
    // scroll view
    self.scrollView.contentSize = self.view.frame.size;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.slideUpViewMinCenter = CGPointMake(160, -168);
    self.slideUpViewMaxCenter = CGPointMake(160, 233);
    
    self.share = [[BFKShare alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary *navbarTitleAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Bold" size:12],
                                            NSForegroundColorAttributeName: [UIColor whiteColor]
                                            };
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleAttributes];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.capturedItemIndex = 0;
    [self loadCapturedItem];
    
    self.autocompleteResults = @[];
    
    // note text view
    self.noteTextViewPlaceholderText = @"Add a note...";
    self.noteTextView.text = self.noteTextViewPlaceholderText;
    self.noteTextView.textColor = [BFKUtil colorFromHex:@"4D4D4E" alpha:0.65];
    
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
    [appDelegate.tracker set:kGAIScreenName value:@"Review View"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    // show status/navigation bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    [self unregisterForKeyboardNotifications];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Update location

- (void)updateLocation {
    NSString *notebookText = self.notebookTextField.text;
    if ([BFKUtil isEmpty:notebookText]) {
        notebookText = self.notebookTextField.placeholder;
    }
    
    NSString *sectionText = self.sectionTextField.text;
    if ([BFKUtil isEmpty:sectionText]) {
        sectionText = self.sectionTextField.placeholder;
    }
    
    NSString *locationText = [NSString stringWithFormat:@"%@ > %@", notebookText, sectionText];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Regular" size:13],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]
                                 };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:locationText
                                                                                         attributes:attributes];
    
    // show notebook/section placeholers as grayed out
    if ([BFKUtil isEmpty:self.notebookTextField.text]) {
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor lightGrayColor]
                                 range:NSMakeRange(0, notebookText.length)];
    }
    if ([BFKUtil isEmpty:self.sectionTextField.text]) {
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor lightGrayColor]
                                 range:NSMakeRange(notebookText.length + 3, sectionText.length)];
    }
    
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
    
    if (self.slideUpView.center.y == self.slideUpViewMaxCenter.y) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

#pragma mark - Show previous item

- (IBAction)showPrevItem:(id)sender {
    if (self.capturedItemIndex-1 >= 0) {
        self.capturedItemIndex--;
        [self loadCapturedItem];
    }
}

#pragma mark - Show next item

- (IBAction)showNextItem:(id)sender {
    if (self.capturedItemIndex+1 < self.capturedItems.count) {
        self.capturedItemIndex++;
        [self loadCapturedItem];
    }
}

# pragma mark - Load captured item

- (void)loadCapturedItem {
    BFKCapturedItem *item = self.capturedItems[self.capturedItemIndex];
    if ([item isKindOfClass:[BFKCapturedNote class]]) {
        self.snapshotScrollView.hidden = YES;
        self.snapshotTextView.hidden = NO;
        
        self.snapshotTextView.text = ((BFKCapturedNote *)item).note;
    } else {
        self.snapshotScrollView.hidden = NO;
        self.snapshotTextView.hidden = YES;
        
        self.snapshotImageView.image = [UIImage imageWithData:((BFKCapturedImage *)item).image];
        
        self.noteTextView.text = ((BFKCapturedImage *)item).note;
        if (self.noteTextView.text.length == 0) {
            self.noteTextView.text = self.noteTextViewPlaceholderText;
        }
        
//        if ([((BFKCapturedImage *)item).imported boolValue]) {
//            [BFKUtil roundCorners:self.snapshotImageView radius:15];
//        }
    }
    
    self.notebookTextField.text = item.page.section.notebook.name;
    self.sectionTextField.text = item.page.section.name;
}

#pragma mark - Slide for note

- (IBAction)slideForNote:(id)sender {
    // dismiss keyboard if open
    [self.view endEditing:YES];
    
    UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *)sender;
    
    CGPoint center;
    
    center = panGR.view.superview.center;
    CGPoint translation = [panGR translationInView:panGR.view.superview];
    center = CGPointMake(center.x, center.y + translation.y);
    if (center.y < self.slideUpViewMinCenter.y) {
        center = self.slideUpViewMinCenter;
    }
    if (center.y > self.slideUpViewMaxCenter.y) {
        center = self.slideUpViewMaxCenter;
    }
    
    panGR.view.superview.center = center;
    [panGR setTranslation:CGPointZero inView:panGR.view.superview];
    
    if (center.y == self.slideUpViewMaxCenter.y) {
        [self.navigationController setNavigationBarHidden:NO];
    } else {
        [self.navigationController setNavigationBarHidden:YES];
    }

    if (panGR.state == UIGestureRecognizerStateEnded) {
        float velocityY = 0.2 * [panGR velocityInView:panGR.view.superview].y;
        CGPoint finalCenter = CGPointMake(panGR.view.superview.center.x,
                                         panGR.view.superview.center.y + velocityY);
        
        if (finalCenter.y < self.slideUpViewMinCenter.y) {
            finalCenter = self.slideUpViewMinCenter;
        }
        if (finalCenter.y > self.slideUpViewMaxCenter.y) {
            finalCenter = self.slideUpViewMaxCenter;
        }
        
        if (finalCenter.y == self.slideUpViewMaxCenter.y) {
            [self.navigationController setNavigationBarHidden:NO];
        } else {
            [self.navigationController setNavigationBarHidden:YES];
        }
        
        float animationDuration = fabsf(velocityY * 0.00002) + 0.2;
        
        if (fabsf(center.y - finalCenter.y) >= 25) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            panGR.view.superview.center = finalCenter;
            [UIView commitAnimations];
        }
        
        // if past midway, slide to end
        float midpoint = ((self.slideUpViewMinCenter.y - self.slideUpViewMaxCenter.y) / 2) + self.slideUpViewMaxCenter.y;
        if (center.y < finalCenter.y && finalCenter.y >= midpoint && finalCenter.y < self.slideUpViewMaxCenter.y) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            panGR.view.superview.center = self.slideUpViewMaxCenter;
            [UIView commitAnimations];
        } else if (center.y > finalCenter.y && finalCenter.y <= midpoint && finalCenter.y > self.slideUpViewMinCenter.y) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            panGR.view.superview.center = self.slideUpViewMinCenter;
            [UIView commitAnimations];
        }
    }
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
    
    // managed objects in captured items array aren't saved to context yet so save them
    [BFKDao saveManagedObjects:self.capturedItems];
    
    BFKNotebook *notebook = [BFKDao findOrCreateNotebookWithName:self.notebookTextField.text];
    BFKSection *section = [BFKDao findOrCreateSectionWithName:self.sectionTextField.text notebook:notebook];

    // set suggested notebook, section
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.suggestedNotebook = notebook.name;
    appDelegate.suggestedSection = section.name;
    
    [notebook addSectionsObject:section];
    
    for (BFKCapturedItem *capturedItem in self.capturedItems) {
        // note
        if (![BFKUtil isEmpty:self.notebookTextField.text]
            && ![self.noteTextView.text isEqualToString:self.noteTextViewPlaceholderText]) {
            capturedItem.note = self.noteTextView.text;
        }
        
        BFKPage *page = [BFKDao createPageWithItem:capturedItem];
        [section addPagesObject:page];
    }
    
    [BFKDao saveContext];
    
    // hack for going from review page to pages view
    NSMutableArray *newVCList = [self.navigationController.viewControllers mutableCopy];
    [newVCList removeLastObject];
    [newVCList removeLastObject];
    
    BOOL hasSectionsVC = NO;
    BOOL hasPagesVC = NO;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[BFKSectionsViewController class]]) {
            BFKSectionsViewController *sectionsVC = (BFKSectionsViewController *)vc;
            sectionsVC.notebook = notebook;
            hasSectionsVC = YES;
        }
        if ([vc isKindOfClass:[BFKPagesViewController class]]) {
            BFKPagesViewController *pagesVC = (BFKPagesViewController *)vc;
            pagesVC.section = section;
            pagesVC.goToLastItem = [NSNumber numberWithBool:YES];
            hasPagesVC = YES;
        }
    }
    
    if (!hasSectionsVC) {
        BFKSectionsViewController *sectionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Sections"];
        sectionsVC.notebook = notebook;
        [newVCList addObject:sectionsVC];
    }
    if (!hasPagesVC) {
        BFKPagesViewController *pagesVC = (BFKPagesViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"Pages"];
        pagesVC.section = section;
        pagesVC.goToLastItem = [NSNumber numberWithBool:YES];
        [newVCList addObject:pagesVC];
    }
    
    [newVCList addObject:self];
    self.navigationController.viewControllers = [newVCList copy];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return self.snapshotImageView;
//}

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
    self.scrollView.scrollEnabled = NO;
    
    if ([textView.text isEqualToString:self.noteTextViewPlaceholderText]) {
        textView.text = @"";
        textView.textColor = [BFKUtil colorFromHex:@"4D4D4E"];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.scrollView.scrollEnabled = YES;
    
    BFKCapturedImage *item = (BFKCapturedImage *)self.capturedItems[self.capturedItemIndex];
    item.note = textView.text;
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = self.noteTextViewPlaceholderText;
        textView.textColor = [BFKUtil colorFromHex:@"4D4D4E" alpha:0.65];
    }
}

#pragma mark - Touches ended

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
//}

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

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    // autocomplete table view
    self.autocompleteTableView.frame = CGRectMake(0,
                                                  self.changeLocationView.frame.size.height,
                                                  self.view.frame.size.width,
                                                  self.view.frame.size.height
                                                  - kbSize.height
                                                  - self.changeLocationView.frame.size.height);
}

#pragma mark - Share instagram

- (IBAction)shareInstagram:(id)sender {
    [self.share shareInstagram:self.snapshotImageView.image vc:self];
}

#pragma mark - Share facebook

- (IBAction)shareFacebook:(id)sender {
    BFKCapturedImage *item = self.capturedItems.firstObject;
    if (![BFKUtil isEmpty:self.noteTextView.text]) {
        item.note = self.noteTextView.text;
    }
    
    [self.share shareFacebook:item vc:self];
}

#pragma mark - Share twitter

- (IBAction)shareTwitter:(id)sender {
    BFKCapturedImage *item = self.capturedItems.firstObject;
    if (![BFKUtil isEmpty:self.noteTextView.text]) {
        item.note = self.noteTextView.text;
    }
    
    [self.share shareTwitter:item vc:self];
}

#pragma mark - Share email

- (IBAction)shareEmail:(id)sender {
    BFKCapturedImage *item = self.capturedItems.firstObject;
    if (![BFKUtil isEmpty:self.noteTextView.text]) {
        item.note = self.noteTextView.text;
    }
    
    [self.share shareEmail:item vc:self];
}

@end
