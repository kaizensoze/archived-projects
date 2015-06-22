//
//  BFKNoteTableViewController.m
//  Mosaic
//
//  Created by Joe Gallo on 1/18/15.
//  Copyright (c) 2015 Baron Fig. All rights reserved.
//

#import "BFKNoteTableViewController.h"
#import "BFKUtil.h"
#import "BFKAppDelegate.h"
#import "BFKNotePart.h"
#import "BFKDao.h"
#import "BFKNotePartTableViewCell.h"

@interface BFKNoteTableViewController ()
    @property (strong, nonatomic) UIImageView *bgImageView;
    @property (nonatomic) BOOL bgImageLoading;
    @property (strong, nonatomic) UIView *nameBarView;
    @property (strong, nonatomic) UITextField *nameTextField;
    @property (strong, nonatomic) UITextField *notePartTextField;
    @property (strong, nonatomic) NSDictionary *textViewAttributes;
    @property (nonatomic) CGSize kbSize;
    @property (strong, nonatomic) UIBarButtonItem *backBarButtonItem;
    @property (nonatomic) BOOL existingNote;
    @property (strong, nonatomic) AVAudioPlayer *audioPlayer;
    @property (strong, nonatomic) UIActionSheet *imageActionSheet;
    @property (nonatomic) BOOL returningFromImagePicker;
    @property (strong, nonatomic) UIImage *lastPickedImage;
@end

@implementation BFKNoteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // check if view is being used for existing note
    if (self.note) {
        self.existingNote = YES;
    }
    
    // initialize new note
    if (!self.existingNote) {
        BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:context];
        self.note = (BFKNote *)[[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        self.note.name = @"New Note";
    }
    
    // background color
    self.view.backgroundColor = [UIColor whiteColor];
    
    // background image
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new-note-bg"]];
    imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.alpha = 0;
    self.tableView.backgroundView = imageView;
    self.bgImageView = imageView;
    self.bgImageLoading = YES;
    
    // table view
    [self setupTableView];
    
    // tool bar
    [self setupToolbar];
    
    // audio player
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"ADD_01" ofType:@"wav"];
    NSURL *soundURL = [[NSURL alloc] initFileURLWithPath:soundPath];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    if (error) {
        DDLogInfo(@"%@", [error description]);
    }
    self.audioPlayer.delegate = self;
    
    // image action sheet
    self.imageActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Use Camera", @"Choose From Library", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // dark status bar
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [self registerForKeyboardNotifications];
    
    if (self.returningFromImagePicker) {
//        self.bgImageView.alpha = 0;
        [self.notePartTextField becomeFirstResponder];
    }
    
    if (!self.existingNote) {
        // focus note part textfield and show keyboard
        [self.notePartTextField becomeFirstResponder];
        
        // add name bar above tableview
        self.nameBarView = [self createNameBar];
        float nameBarViewY = [UIApplication sharedApplication].statusBarFrame.size.height
                                + self.navigationController.navigationBar.frame.size.height;
        self.nameBarView.frame = CGRectMake(0, nameBarViewY,
                                            self.nameBarView.frame.size.width, self.nameBarView.frame.size.height);
        [self.tableView.superview addSubview:self.nameBarView];
    }
    
    // navigation bar
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.returningFromImagePicker) {
        self.returningFromImagePicker = NO;
    }
    
    if (!self.existingNote) {
        // fade in background image
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.bgImageView.alpha = 1;
                         }
                         completion:^(BOOL finished){
                             self.bgImageLoading = NO;
                         }];
    } else {
        self.bgImageLoading = NO;
    }
    
    // adjust tableview relative to name bar
    float nameBarHeight = self.nameBarView.frame.size.height;
    
    CGRect frame = self.tableView.frame;
    frame.origin.y += nameBarHeight;
    frame.size.height -= nameBarHeight;
    self.tableView.frame = frame;
    
    // adjust tool bar
    [self adjustToolBar];
    
    if (self.existingNote) {
        [self scrollToBottomOfLastNotePart];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // force dismiss keyboard
    [self.view endEditing:YES];
    
    [self unregisterForKeyboardNotifications];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupNavigationBar {
    // background color
    [self.navigationController.navigationBar setBarTintColor:[BFKUtil colorFromHex:@"fffefb"]];
    [self.navigationController.navigationBar setTintColor:[BFKUtil colorFromHex:@"693148"]];
    [self.navigationController.navigationBar setTranslucent:NO];

    // bar button items
    NSDictionary *barButtonItemAttributes = @{
                                              NSFontAttributeName: [UIFont fontWithName:@"GothamBook" size:12],
                                              NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"]
                                              };
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTintColor:[BFKUtil colorFromHex:@"693148"]];
    
    // title
    self.navigationItem.title = self.note.name;
    
    NSDictionary *navbarTitleAttributes = @{
                                            NSFontAttributeName: [UIFont fontWithName:@"GothamBold" size:12],
                                            NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"]
                                            };
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleAttributes];
    
    // cancel button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(cancel:)];
    
    // back button
    self.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Notes"
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(back:)];
    
    if (self.existingNote) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // show toolbar
    self.navigationController.toolbarHidden = NO;
}

- (void)setupTableView {
    // hide empty table view cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // add custom tap recognizer to table view
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleTapOnTableView:)];
    [self.tableView addGestureRecognizer:tapGR];
}

- (void)setupToolbar {
    // background color
    self.navigationController.toolbar.barTintColor = [BFKUtil colorFromHex:@"fffefb"];
//    self.navigationController.toolbar.layer.borderColor = [BFKUtil colorFromHex:@"c6aeb8"].CGColor;
    
    // camera button
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake(0, 0, 17, 14);
    [cameraButton setBackgroundImage:[UIImage imageNamed:@"camera-button"] forState:UIControlStateNormal];
//    cameraButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cameraButton addTarget:self action:@selector(showImagePickerView:) forControlEvents:UIControlEventTouchUpInside];
//    [BFKUtil setBorder:cameraButton];
    
    UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
    
    // text field
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 230, 25)];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"Start Note";
    [textField setValue:[BFKUtil colorFromHex:@"b597a4"] forKeyPath:@"_placeholderLabel.textColor"];
    textField.font = [UIFont fontWithName:@"GothamBook" size:12];
    textField.textColor = [BFKUtil colorFromHex:@"693148"];
    textField.tintColor = [BFKUtil colorFromHex:@"693148"];
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    textField.delegate = self;
    self.notePartTextField = textField;
    UIBarButtonItem *textItem = [[UIBarButtonItem alloc] initWithCustomView:textField];
    
    // add button
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain
                                                               target:self action:@selector(addNotePartText:)];
    NSDictionary *addItemAttributes = @{
                                        NSFontAttributeName: [UIFont fontWithName:@"GothamMedium" size:12],
                                        NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"693148"]
                                        };
    [addItem setTitleTextAttributes:addItemAttributes forState:UIControlStateNormal];
    
    self.toolbarItems = @[cameraItem, textItem, addItem];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int numRows = self.note.noteParts.count;
    
    // hide/fade in background image
    if (numRows == 0) {
        if (!self.bgImageLoading) {
            [UIView animateWithDuration:0.5
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.bgImageView.alpha = 1;
                             }
                             completion:nil];
        }
    } else {
        self.bgImageView.alpha = 0;
    }
    
    return numRows;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                      title:@"Delete"
                                                                    handler:^(UITableViewRowAction *action,
                                                                              NSIndexPath *indexPath) {
                                                                        [self.note removeObjectFromNotePartsAtIndex:indexPath.row];
                                                                        [self.tableView reloadData];
                                                                    }];
    
    return @[button];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NotePartCell";
    
    BFKNotePart *notePart = (BFKNotePart *)[self.note.noteParts objectAtIndex:indexPath.row];
    
    BFKNotePartTableViewCell *cell = (BFKNotePartTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[BFKNotePartTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // date
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM dd, h:mm a"];
    cell.dateLabel.text = [dateFormatter stringFromDate:notePart.date];
    
    // text
    if (!notePart.text) {
        cell.textView.hidden = YES;
    } else {
        cell.textView.hidden = NO;
        cell.textView.text = notePart.text;
        
        // style text
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.minimumLineHeight = 16;
        paragraphStyle.maximumLineHeight = 16;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName: cell.textView.font,
                                     NSForegroundColorAttributeName: cell.textView.textColor,
                                     NSParagraphStyleAttributeName: paragraphStyle
                                     };
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:notePart.text
                                                                               attributes:attributes];
        cell.textView.attributedText = attributedString;
        
        // adjust text view to fit content
        self.textViewAttributes = attributes;
        
        UIEdgeInsets textViewInsets = cell.textView.textContainerInset;
        float textWidth = cell.textView.frame.size.width - textViewInsets.left - textViewInsets.right - 10;
        CGSize contentSize = [BFKUtil textSize:notePart.text attributes:attributes width:textWidth height:MAXFLOAT];
        CGRect frame = cell.textView.frame;
        frame.size.height = textViewInsets.top + contentSize.height + 3 + textViewInsets.bottom;
        cell.textView.frame = frame;
    }
    
    // image
    if (!notePart.image) {
        cell.outerImageView.hidden = YES;
        cell.theImageView.hidden = YES;
    } else {
        cell.outerImageView.hidden = NO;
        cell.theImageView.hidden = NO;
        cell.theImageView.image = [UIImage imageWithData:notePart.image];
    }
    
//    cell.backgroundColor = [UIColor greenColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BFKNotePart *notePart = [self.note.noteParts objectAtIndex:indexPath.row];
    
    float height;
    
    if (notePart.text) {
        NSDictionary *attributes = self.textViewAttributes;
        if (!attributes) {
            attributes = @{};
        }
        
        float textWidth = 301 - 10;
        CGSize contentSize = [BFKUtil textSize:notePart.text attributes:attributes width:textWidth height:MAXFLOAT];
        
        // yPos + topInset + textHeight + bonus + bottomInset + bottomPadding
        height = 29 + 8 + contentSize.height + 3 + 8 + 8;
    } else if (notePart.image) {
        // yPos + imageContainerHeight + bottomPadding
        height = 29 + 194 + 8;
    }
        
    return height;
}

#pragma mark - Name bar view

- (UIView *)createNameBar {
    float viewHeight = 38;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, viewHeight)];
    view.backgroundColor = [BFKUtil colorFromHex:@"fffefb"];
    
    // label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 40, viewHeight)];
    label.font = [UIFont fontWithName:@"GothamBook" size:12];
    label.textColor = [BFKUtil colorFromHex:@"693148"];
    label.text = @"Name:";
    [view addSubview:label];
    
    // textfield
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(59, 1, 250, viewHeight)];
    textField.borderStyle = UITextBorderStyleNone;
    textField.font = [UIFont fontWithName:@"GothamBook" size:12];
    textField.textColor = [BFKUtil colorFromHex:@"693148"];
    textField.delegate = self;
    self.nameTextField = textField;
    [view addSubview:textField];
    
    // bottom border
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, viewHeight, view.bounds.size.width, 0.5)];
    borderView.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:borderView];
    
    return view;
}

- (void)removeNameBar {
    // only remove name bar and adjust table view if it's not already removed
    if (!self.nameBarView.hidden) {
        float nameBarHeight = self.nameBarView.frame.size.height;
        CGRect frame = self.tableView.frame;
        frame.origin.y -= nameBarHeight;
        frame.size.height += nameBarHeight;
        self.tableView.frame = frame;
    }
    self.nameBarView.hidden = YES;
}

#pragma mark - Actions

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [BFKDao deleteNote:self.note];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addNotePartText:(id)sender {
    if ([BFKUtil isEmpty:self.notePartTextField.text]) {
        return;
    }
    
    // add note part
    BFKNotePart *notePart = [BFKDao createNotePartWithText:self.notePartTextField.text];
    NSMutableOrderedSet *noteParts = [self.note.noteParts mutableCopy];
    [noteParts addObject:notePart];
    [self.note setNoteParts:[noteParts copy]];
    
    // if first note part and no name set, set name to first 3 words of note part
    if (self.note.noteParts.count == 1 && [self.note.name isEqualToString:@"New Note"]) {
        NSArray *words = [notePart.text componentsSeparatedByString:@" "];
        int nWords = MIN(words.count, 3);
        NSArray *firstWords = [words subarrayWithRange:NSMakeRange(0, nWords)];
        NSString *notePartTextPart = [firstWords componentsJoinedByString:@" "];
        [self updateName:notePartTextPart updateNameTextField:YES];
    }
    
    // update note
    [BFKDao saveContext];
    
    self.notePartTextField.text = @"";
    
    // common logic post adding note part
    [self postAddNotePart:NO];
}

- (void)addNotePartImage:(UIImage *)image {
    // add note part
    BFKNotePart *notePart = [BFKDao createNotePartWithImage:image];
    NSMutableOrderedSet *noteParts = [self.note.noteParts mutableCopy];
    [noteParts addObject:notePart];
    [self.note setNoteParts:[noteParts copy]];
    
    // update note
    [BFKDao saveContext];
    
    // common logic post adding note part
    [self postAddNotePart:YES];
}

- (void)postAddNotePart:(BOOL)showBackButton {
    // update tableview
    [self.tableView beginUpdates];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.note.noteParts.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    [self.tableView endUpdates];
    [self.tableView reloadData];
    
    // remove name bar
    [self removeNameBar];
    
    // remove cancel button
    self.navigationItem.rightBarButtonItem = nil;
    
    // add back button
    if (!self.existingNote || showBackButton) {
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
    }
    
    // scroll to bottom of last note part
    [self scrollToBottomOfLastNotePart];
    
    // play sound
    [self.audioPlayer play];
}

- (IBAction)handleTapOnTableView:(UIGestureRecognizer*)recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    if (indexPath) {
        recognizer.cancelsTouchesInView = NO;
    } else {
        [self.nameTextField resignFirstResponder];
        [self.notePartTextField resignFirstResponder];
    }
}

- (void)scrollToBottomOfLastNotePart {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.note.noteParts.count-1 inSection:0];
    if (indexPath.row >= 0) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)adjustToolBar {
    // adjust tool bar
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    CGRect toolBarFrame = self.navigationController.toolbar.frame;
    toolBarFrame.origin.y = screenHeight - self.kbSize.height - toolBarFrame.size.height;
    self.navigationController.toolbar.frame = toolBarFrame;
}

- (void)updateName:(NSString *)name updateNameTextField:(BOOL)updateNameTextField {
    if ([BFKUtil isEmpty:name]) {
        name = @"New Note";
    }
    self.navigationItem.title = name;
    if (updateNameTextField) {
        self.nameTextField.text = name;
    }
    self.note.name = name;
}

#pragma mark - Image picker

- (IBAction)showImagePickerView:(id)sender {
    [self.imageActionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.imageActionSheet) {
        switch (buttonIndex) {
            case 0:
                [self useCamera];
                break;
            case 1:
                [self useCameraRoll];
                break;
            default:
                break;
        }
    }
}

#pragma mark - Camera/Roll selection

- (void)useCamera {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)useCameraRoll {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.returningFromImagePicker = YES;
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.lastPickedImage = image;
    self.existingNote = YES;
    [picker dismissViewControllerAnimated:YES completion:^{
        [self addNotePartImage:self.lastPickedImage];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.returningFromImagePicker = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.nameTextField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self updateName:newString updateNameTextField:NO];
    }
    return YES;
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.kbSize = kbSize;
    
    [self adjustToolBar];
}

- (void)keyboardDidShow:(NSNotification*)aNotification {
    // scroll to bottom of last note part
    [self scrollToBottomOfLastNotePart];
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    float screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    // adjust tool bar
    CGRect toolBarFrame = self.navigationController.toolbar.frame;
    toolBarFrame.origin.y = screenHeight - toolBarFrame.size.height;
    self.navigationController.toolbar.frame = toolBarFrame;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
