//
//  BFKSectionsViewController.m
//  Keeper
//
//  Created by Joe Gallo on 11/20/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKSectionsViewController.h"
#import "BFKUtil.h"
#import "BFKAppDelegate.h"
#import "BFKSection.h"
#import "BFKSectionCollectionViewCell.h"
#import "BFKDao.h"
#import "BFKPagesViewController.h"

@interface BFKSectionsViewController ()
    @property (strong, nonatomic) NSMutableOrderedSet *sections;

    @property (weak, nonatomic) IBOutlet UICollectionView *sectionCollectionView;
    @property (nonatomic) BOOL inEditMode;
    @property (weak, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGR;

    @property (weak, nonatomic) IBOutlet UILabel *numSectionsLabel;
    @property (weak, nonatomic) IBOutlet UILabel *numPagesLabel;

    @property (strong, nonatomic) BFKSection *sectionPendingDeletion;

    @property (weak, nonatomic) IBOutlet UIView *editSectionNameView;
    @property (weak, nonatomic) IBOutlet UIView *editSectionNameOverlay;
    @property (weak, nonatomic) IBOutlet UITextField *editSectionNameTextField;
    @property (strong, nonatomic) BFKSection *sectionToEdit;
    @property (nonatomic) float keyboardHeight;
@end

@implementation BFKSectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [BFKUtil colorFromHex:@"d0d8e2"];
    
    // adjustment for collection view
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.editSectionNameTextField setValue:[BFKUtil colorFromHex:@"ffffff" alpha:0.65] forKeyPath:@"_placeholderLabel.textColor"];
    
//    [BFKUtil setBorder:self.sectionCollectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // show status/navigation bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self setupAndShowNavigationBar];
    
    [self disableEditMode];
    
    self.sections = [self.notebook.sections mutableCopy];
    [self.sectionCollectionView reloadData];
    
    [self updateSectionInfo];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.tracker set:kGAIScreenName value:@"Sections View"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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
    self.navigationItem.title = [self.notebook.name uppercaseString];
    
    NSDictionary *navbarTitleAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Bold" size:12],
                                            NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"]
                                            };
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleAttributes];
}

- (void)updateSectionInfo {
    self.numSectionsLabel.text = [NSString stringWithFormat:@"%lu %@",
                                  (unsigned long)self.sections.count,
                                  [[BFKUtil singlePluralize:@"section" amount:self.sections.count] uppercaseString]];
    
    int numPages = self.notebook.numPages;
    self.numPagesLabel.text = [NSString stringWithFormat:@"%d %@",
                               numPages,
                               [[BFKUtil singlePluralize:@"page" amount:numPages] uppercaseString]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sections.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BFKSection *section = self.sections[indexPath.item];
    
    BFKSectionCollectionViewCell *cell = (BFKSectionCollectionViewCell *)
    [collectionView dequeueReusableCellWithReuseIdentifier:@"SectionCell" forIndexPath:indexPath];
    
    if (section.pages.count > 0) {
        // base layer
        if (section.pages.count == 1) {
            cell.sectionImageView.image = [UIImage imageNamed:@"single-page-section"];
        } else {
            cell.sectionImageView.image = [UIImage imageNamed:@"multi-page-section"];
        }
        
        // top layer
        BFKPage *page = section.pages.firstObject;
        BFKCapturedItem *item = page.item;
        
        cell.stackTopImageView.layer.allowsEdgeAntialiasing = YES;
        cell.stackTopImageView.transform = CGAffineTransformMakeRotation(RADIANS(4.8));
        
        if ([item isKindOfClass:[BFKCapturedImage class]]) {
            cell.topImageView.image = [UIImage imageWithData:((BFKCapturedImage *)item).image];
            cell.stackTopImageView.image = [UIImage imageWithData:((BFKCapturedImage *)item).image];
        } else if ([item isKindOfClass:[BFKCapturedNote class]]) {
            cell.topImageView.image = [UIImage imageNamed:@"note-page"];
            cell.stackTopImageView.image = [UIImage imageNamed:@"note-page"];
        }
        
        // rotate top layer accordingly (slight angle for multi page section)
        if (section.pages.count > 1) {
            cell.topImageView.hidden = YES;
            cell.stackTopImageView.hidden = NO;
            cell.sectionImageView.hidden = NO;
        } else {
            cell.topImageView.hidden = NO;
            cell.stackTopImageView.hidden = YES;
            cell.sectionImageView.hidden = YES;
        }
    }
    cell.nameLabel.text = section.name;
    
    if (self.inEditMode) {
        cell.deleteButton.hidden = NO;
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(showEditSectionNameView:)];
        [cell.nameLabel addGestureRecognizer:tapGR];
        
        [BFKUtil wobble:cell];
    } else {
        cell.deleteButton.hidden = YES;
        [cell.nameLabel removeGestureRecognizer:cell.nameLabel.gestureRecognizers.firstObject];
        [cell.layer removeAllAnimations]; // remove wobble
    }
    
    return cell;
}

#pragma mark - UICollectionViewDataSource_Draggable

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
canMoveItemAtIndexPath:(NSIndexPath *)indexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView
   moveItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    BFKSection *section = self.sections[fromIndexPath.item];
    
    [self.sections removeObjectAtIndex:fromIndexPath.item];
    [self.sections insertObject:section atIndex:toIndexPath.item];
    
    [self.notebook setSections:[self.sections copy]];
    [BFKDao saveContext];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.inEditMode) {
        return;
    }
    
    BFKSection *section = self.sections[indexPath.item];
    [self goToPagesForSection:section];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(101, 167);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 35;
}

#pragma mark - Go to pages for section

- (void)goToPagesForSection:(BFKSection *)section {
    BFKPagesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Pages"];
    vc.section = section;
    
    // set suggested section
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.suggestedSection = section.name;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Delete section

- (IBAction)deleteSection:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.sectionCollectionView];
    buttonPosition.x = buttonPosition.x + button.frame.size.width;
    buttonPosition.y = buttonPosition.y + button.frame.size.height;
    
    NSIndexPath *indexPath = [self.sectionCollectionView indexPathForItemAtPoint:buttonPosition];
    BFKSection *section = self.sections[indexPath.item];
    self.sectionPendingDeletion = section;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete section?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        int index = [self.sections indexOfObject:self.sectionPendingDeletion];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        
        [BFKDao deleteSection:self.sectionPendingDeletion];
        [self.sections removeObject:self.sectionPendingDeletion];
        
        [self.notebook setSections:[self.sections copy]];
        [BFKDao saveContext];
        
        [self.sectionCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        
        [self updateSectionInfo];
    }
    
    self.sectionPendingDeletion = nil;
}

#pragma mark - Show edit section name view

- (IBAction)showEditSectionNameView:(id)sender {
    if (sender) {
        UITapGestureRecognizer *tapGR = (UITapGestureRecognizer *)sender;
        UILabel *editNameLabel = (UILabel *)tapGR.view;
        CGPoint editNameLabelPosition = [editNameLabel convertPoint:CGPointZero toView:self.sectionCollectionView];
        
        NSIndexPath *indexPath = [self.sectionCollectionView indexPathForItemAtPoint:editNameLabelPosition];
        BFKSection *section = self.sections[indexPath.item];
        self.sectionToEdit = section;
    }
    
    self.editSectionNameView.hidden = NO;
    self.editSectionNameOverlay.hidden = NO;
    
    self.editSectionNameTextField.text = @"";
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [self.editSectionNameTextField becomeFirstResponder];
    [UIView commitAnimations];
    
    CGRect frame = self.editSectionNameView.frame;
    frame.origin.y = self.view.frame.size.height - self.keyboardHeight - frame.size.height;
    self.editSectionNameView.frame = frame;
}

#pragma mark - Hide edit notebook name view

- (IBAction)hideEditSectionNameView:(id)sender {
    self.editSectionNameView.hidden = YES;
    self.editSectionNameOverlay.hidden = YES;
    
    [self.editSectionNameTextField resignFirstResponder];
}

#pragma mark - Edit notebook name

- (IBAction)editSectionName:(id)sender {
    [self hideEditSectionNameView:nil];
    
    self.sectionToEdit.name = self.editSectionNameTextField.text;
    [BFKDao saveContext];
    
    [self.sectionCollectionView reloadData];
    
    self.sectionToEdit = nil;
    
    [self disableEditMode];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.editSectionNameTextField) {
        [self editSectionName:nil];
    }
    return YES;
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
    self.keyboardHeight = kbSize.height;
}

#pragma mark - Enable edit mode

- (IBAction)enableEditMode:(id)sender {
    // show delete button
    self.inEditMode = YES;
    [self.sectionCollectionView reloadData];
    
    // enable drag/drop
    self.sectionCollectionView.draggable = YES;
    
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
    [self.sectionCollectionView reloadData];
    
    // disable drag/drop
    self.sectionCollectionView.draggable = NO;
    
    // enable view controller's long press gesture
    self.longPressGR.enabled = YES;
    
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Import content

- (IBAction)importContent:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController pushViewController:appDelegate.captureVC animated:YES];
}

#pragma mark - Touches ended

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
