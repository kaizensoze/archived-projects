//
//  BFKNotebooksViewController.m
//  Keeper
//
//  Created by Joe Gallo on 10/22/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKNotebooksViewController.h"
#import "BFKUtil.h"
#import "BFKAppDelegate.h"
#import "BFKDao.h"
#import "BFKSectionsViewController.h"
#import "BFKNotebookCollectionViewCell.h"
#import "BFKNewNotebookCollectionViewCell.h"

@interface BFKNotebooksViewController ()
    @property (strong, nonatomic) NSMutableArray *notebooks;

    @property (weak, nonatomic) IBOutlet UICollectionView *notebookCollectionView;
    @property (nonatomic) BOOL inEditMode;
    @property (weak, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGR;

    @property (weak, nonatomic) IBOutlet UILabel *numNotebooksLabel;
    @property (weak, nonatomic) IBOutlet UILabel *numSectionsLabel;

    @property (strong, nonatomic) BFKNotebook *notebookPendingDeletion;

    @property (weak, nonatomic) IBOutlet UIView *editNotebookNameView;
    @property (weak, nonatomic) IBOutlet UIView *editNotebookNameOverlay;
    @property (weak, nonatomic) IBOutlet UITextField *editNotebookNameTextField;
    @property (strong, nonatomic) BFKNotebook *notebookToEdit;
    @property (nonatomic) float keyboardHeight;
@end

@implementation BFKNotebooksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [BFKUtil colorFromHex:@"693148"];
    
    // adjustment for collection view
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.editNotebookNameTextField setValue:[BFKUtil colorFromHex:@"ffffff" alpha:0.65]
                                  forKeyPath:@"_placeholderLabel.textColor"];
    
//    [BFKUtil setBorder:self.notebookCollectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // show status/navigation bar
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self setupAndShowNavigationBar];
    
    [self disableEditMode];
    
    self.notebooks = [[BFKDao notebooks] mutableCopy];
    [self.notebookCollectionView reloadData];
    
    [self updateNotebookInfo];
    
    [self registerForKeyboardNotifications];
    
//    [BFKDao describeData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.tracker set:kGAIScreenName value:@"Notebooks View"];
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
    
    // set navigation bar title
    self.navigationItem.title = [@"notebooks" uppercaseString];
    
    NSDictionary *navbarTitleAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"BrandonGrotesque-Bold" size:12],
                                            NSForegroundColorAttributeName: [UIColor whiteColor]
                                            };
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleAttributes];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)updateNotebookInfo {
    self.numNotebooksLabel.text = [NSString stringWithFormat:@"%lu %@",
                                   (unsigned long)self.notebooks.count,
                                   [[BFKUtil singlePluralize:@"notebook" amount:self.notebooks.count] uppercaseString]];
    
    int numSections = [BFKDao numSections];
    self.numSectionsLabel.text = [NSString stringWithFormat:@"%d %@",
                                  numSections,
                                  [[BFKUtil singlePluralize:@"section" amount:numSections] uppercaseString]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    #warning Dynamically setting content inset of collection view [regardless of what's specified in storyboard]
    
    int numItems = self.notebooks.count + 1;
    if (numItems == 1) {
        [collectionView setContentInset:UIEdgeInsetsMake(0, 80, 0, 70)];
    } else {
        [collectionView setContentInset:UIEdgeInsetsMake(0, 70, 0, 70)];
    }
    return numItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if (indexPath.item < self.notebooks.count) {
        BFKNotebook *notebook = self.notebooks[indexPath.item];
        
        BFKNotebookCollectionViewCell *thisCell = (BFKNotebookCollectionViewCell *)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"NotebookCell" forIndexPath:indexPath];
        thisCell.nameLabel.text = notebook.name;
        
        // manually adjust y position of name label (compensation for storyboard bug)
        CGRect frame = thisCell.nameLabel.frame;
        frame.origin.y = 296;
        thisCell.nameLabel.frame = frame;
        
        if (self.inEditMode) {
            thisCell.deleteButton.hidden = NO;
            
            UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(showEditNotebookNameView:)];
            [thisCell.nameLabel addGestureRecognizer:tapGR];
            
            [BFKUtil wobble:thisCell];
        } else {
            thisCell.deleteButton.hidden = YES;
            [thisCell.nameLabel removeGestureRecognizer:thisCell.nameLabel.gestureRecognizers.firstObject];
            [thisCell.layer removeAllAnimations]; // remove wobble
        }
        
        cell = thisCell;
    } else {
        BFKNewNotebookCollectionViewCell *thisCell = (BFKNewNotebookCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"NewNotebookCell" forIndexPath:indexPath];
        
        cell = thisCell;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDataSource_Draggable

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= self.notebooks.count) {
        return NO;
    }
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
canMoveItemAtIndexPath:(NSIndexPath *)indexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    if (indexPath.item >= self.notebooks.count || toIndexPath.item >= self.notebooks.count) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView
   moveItemAtIndexPath:(NSIndexPath *)fromIndexPath
           toIndexPath:(NSIndexPath *)toIndexPath {
    BFKNotebook *notebook = self.notebooks[fromIndexPath.item];
    
    [self.notebooks removeObjectAtIndex:fromIndexPath.item];
    [self.notebooks insertObject:notebook atIndex:toIndexPath.item];
    
    // reorder notebooks and save (core data)
    int i = 0;
    for (BFKNotebook *notebook in self.notebooks) {
        notebook.sortOrder = [NSNumber numberWithInt:i++];
    }
    
    [BFKDao saveContext];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.inEditMode) {
        return;
    }
    
    if (indexPath.item < self.notebooks.count) {
        BFKNotebook *notebook = self.notebooks[indexPath.item];
        [self goToSectionsForNotebook:notebook];
    } else {
        [self createNewNotebook];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.notebooks.count) {
        return CGSizeMake(181, 335);
    } else {
        return CGSizeMake(165, 335);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 24;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 24;
}

#pragma mark - Go to sections for notebook

- (void)goToSectionsForNotebook:(BFKNotebook *)notebook {
    BFKSectionsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Sections"];
    vc.notebook = notebook;
    
    // set suggested notebook
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.suggestedNotebook = notebook.name;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Create new notebook

- (void)createNewNotebook {
    BFKNotebook *newNotebook = [BFKDao createNotebookWithName:@"New Notebook"];
    [self.notebooks addObject:newNotebook];
    [self.notebookCollectionView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.notebooks.count-1 inSection:0];
    [self.notebookCollectionView scrollToItemAtIndexPath:indexPath
                                        atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                animated:YES];
    
    self.notebookToEdit = newNotebook;
    [self showEditNotebookNameView:nil];
    
    [self updateNotebookInfo];
}

#pragma mark - Delete notebook

- (IBAction)deleteNotebook:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.notebookCollectionView];
    buttonPosition.x = buttonPosition.x + button.frame.size.width;
    buttonPosition.y = buttonPosition.y + button.frame.size.height;
    
    NSIndexPath *indexPath = [self.notebookCollectionView indexPathForItemAtPoint:buttonPosition];
    BFKNotebook *notebook = self.notebooks[indexPath.item];
    self.notebookPendingDeletion = notebook;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete notebook?"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        int index = [self.notebooks indexOfObject:self.notebookPendingDeletion];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        
        [BFKDao deleteNotebook:self.notebookPendingDeletion];
        [self.notebooks removeObject:self.notebookPendingDeletion];
        [self.notebookCollectionView deleteItemsAtIndexPaths:@[indexPath]];
        
        if (indexPath.item - 1 >= 0) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:0];
            [self.notebookCollectionView scrollToItemAtIndexPath:newIndexPath
                                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                                        animated:YES];
        }
        
        [self updateNotebookInfo];
        
        // if only the new notebook image is showing, you can't tell you're still in edit mode so disable it
        if (self.notebooks.count == 0) {
            [self disableEditMode];
        }
    }
    
    self.notebookPendingDeletion = nil;
}

#pragma mark - Show edit notebook name view

- (IBAction)showEditNotebookNameView:(id)sender {
    if (sender) {
        UITapGestureRecognizer *tapGR = (UITapGestureRecognizer *)sender;
        UILabel *editNameLabel = (UILabel *)tapGR.view;
        CGPoint editNameLabelPosition = [editNameLabel convertPoint:CGPointZero toView:self.notebookCollectionView];
        
        NSIndexPath *indexPath = [self.notebookCollectionView indexPathForItemAtPoint:editNameLabelPosition];
        BFKNotebook *notebook = self.notebooks[indexPath.item];
        self.notebookToEdit = notebook;
    }
    
    self.editNotebookNameOverlay.hidden = NO;
    self.editNotebookNameView.hidden = NO;
    
    self.editNotebookNameTextField.text = @"";
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [self.editNotebookNameTextField becomeFirstResponder];
    [UIView commitAnimations];
    
    CGRect frame = self.editNotebookNameView.frame;
    frame.origin.y = self.view.frame.size.height - self.keyboardHeight - frame.size.height;
    self.editNotebookNameView.frame = frame;
}

#pragma mark - Hide edit notebook name view

- (IBAction)hideEditNotebookNameView:(id)sender {
    self.editNotebookNameView.hidden = YES;
    self.editNotebookNameOverlay.hidden = YES;
    
    [self.editNotebookNameTextField resignFirstResponder];
}

#pragma mark - Edit notebook name

- (IBAction)editNotebookName:(id)sender {
    [self hideEditNotebookNameView:nil];
    
    self.notebookToEdit.name = self.editNotebookNameTextField.text;
    [BFKDao saveContext];
    
    [self.notebookCollectionView reloadData];
    
    self.notebookToEdit = nil;
    
    [self disableEditMode];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.editNotebookNameTextField) {
        [self editNotebookName:nil];
    }
    return YES;
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
    self.keyboardHeight = kbSize.height;
}

#pragma mark - Enable edit mode

- (IBAction)enableEditMode:(id)sender {
    // show delete button
    self.inEditMode = YES;
    [self.notebookCollectionView reloadData];
    
    // enable drag/drop
    self.notebookCollectionView.draggable = YES;
    
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
    [self.notebookCollectionView reloadData];
    
    // disable drag/drop
    self.notebookCollectionView.draggable = NO;
    
    // enable view controller's long press gesture
    self.longPressGR.enabled = YES;
    
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Toggle sidebar

- (IBAction)toggleSidebar:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewDeckController toggleLeftView];
}

#pragma mark - Import content

- (IBAction)importContent:(id)sender {
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.navigationController pushViewController:appDelegate.captureVC animated:YES];
}

#pragma mark - Touches ended

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
//}

@end
