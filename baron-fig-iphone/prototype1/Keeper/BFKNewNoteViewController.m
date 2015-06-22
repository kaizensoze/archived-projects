//
//  BFKNewNoteViewController.m
//  Keeper
//
//  Created by Joe Gallo on 11/17/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKNewNoteViewController.h"
#import "BFKUtil.h"
#import "BFKCapturedNote.h"
#import "BFKAppDelegate.h"
#import "BFKNotebook.h"
#import "BFKSection.h"
#import "BFKPage.h"
#import "BFKDao.h"

@interface BFKNewNoteViewController ()
    @property (weak, nonatomic) IBOutlet UITextView *noteTextView;
    @property (weak, nonatomic) IBOutlet UIButton *saveButton;

    // change location
    @property (strong, nonatomic) NSArray *notebookNames;
    @property (strong, nonatomic) NSArray *sectionNames;

    @property (weak, nonatomic) IBOutlet UIButton *locationButton;

    @property (weak, nonatomic) IBOutlet UIView *changeLocationView;
    @property (weak, nonatomic) IBOutlet UIView *noteOverlay;
    @property (weak, nonatomic) IBOutlet UITextField *notebookTextField;
    @property (weak, nonatomic) IBOutlet UITextField *sectionTextField;

    @property (strong, nonatomic) UITableView *autocompleteTableView;
    @property (strong, nonatomic) NSArray *autocompleteResults;

    @property (nonatomic) float keyboardHeight;
@end

@implementation BFKNewNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reinitializeView];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.tracker set:kGAIScreenName value:@"New Note View"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [self unregisterForKeyboardNotifications];
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)reinitializeView {
    self.notebookNames = [BFKDao notebookNames];
    self.sectionNames = [BFKDao sectionNames];
    
    self.noteTextView.text = @"";
    self.notebookTextField.text = @"";
    self.sectionTextField.text = @"";
    
    [self hideChangeLocationView:nil];
    
    [self.noteTextView becomeFirstResponder];
    
    // note text view
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = 17;
    paragraphStyle.maximumLineHeight = 17;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: self.noteTextView.font,
                                 NSForegroundColorAttributeName: self.noteTextView.textColor,
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.noteTextView.text
                                                                           attributes:attributes];
    self.noteTextView.attributedText = attributedString;
    
    // notebook/section text view placeholder
    [self.notebookTextField setValue:[BFKUtil colorFromHex:@"ffffff" alpha:0.65] forKeyPath:@"_placeholderLabel.textColor"];
    [self.sectionTextField setValue:[BFKUtil colorFromHex:@"ffffff" alpha:0.65] forKeyPath:@"_placeholderLabel.textColor"];
    
    // autocomplete
    self.autocompleteResults = @[];
    
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
                                 NSForegroundColorAttributeName: [BFKUtil colorFromHex:@"9e7688"]
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
    self.noteOverlay.hidden = NO;
    self.changeLocationView.hidden = NO;
    self.autocompleteTableView.hidden = NO;
    
    self.saveButton.hidden = YES;
    
    [self.notebookTextField becomeFirstResponder];
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
    
    self.noteOverlay.hidden = YES;
    self.changeLocationView.hidden = YES;
    
    self.saveButton.hidden = NO;
    self.autocompleteTableView.hidden = YES;
    
    [self.noteTextView becomeFirstResponder];
}

- (void)focusNoteTextView {
    [self.noteTextView becomeFirstResponder];
}

#pragma mark - Save note

- (IBAction)saveNote:(id)sender {
    if ([BFKUtil isEmpty:self.notebookTextField.text]) {
        [BFKUtil showAlert:@"" message:@"Please specify a notebook." delegate:nil];
        return;
    }
    
    if ([BFKUtil isEmpty:self.sectionTextField.text]) {
        [BFKUtil showAlert:@"" message:@"Please specify a section." delegate:nil];
        return;
    }
    
    if ([BFKUtil isEmpty:self.noteTextView.text]) {
        [BFKUtil showAlert:@"" message:@"Please enter a note." delegate:nil];
        return;
    }
    
    BFKNotebook *notebook = [BFKDao findOrCreateNotebookWithName:self.notebookTextField.text];
    BFKSection *section = [BFKDao findOrCreateSectionWithName:self.sectionTextField.text notebook:notebook];
    
    // set suggested notebook, section
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.suggestedNotebook = notebook.name;
    appDelegate.suggestedSection = section.name;
    
    BFKCapturedNote *note = [BFKDao createCapturedNote:self.noteTextView.text];
    BFKPage *page = [BFKDao createPageWithItem:note];

    [notebook addSectionsObject:section];
    [section addPagesObject:page];

    [BFKDao saveContext];
    
    [self close:nil];
    [self.delegate savedNoteForNotebook:notebook section:section];
}

#pragma mark - Close

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//#pragma mark - Touches ended
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
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
    
    if (self.autocompleteResults.count > 0) {
        self.autocompleteTableView.hidden = NO;
    } else {
//        self.autocompleteTableView.hidden = YES;
    }
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
        [self saveNote:nil];
    }
    
    return YES;
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
    
    // reposition save button
    CGRect frame = self.saveButton.frame;
    frame.origin.y = self.view.frame.size.height - kbSize.height - self.saveButton.frame.size.height - 10;
    self.saveButton.frame = frame;
    
    // reposition location
    frame = self.locationButton.frame;
    frame.origin.y = self.view.frame.size.height - kbSize.height - self.locationButton.frame.size.height - 6;
    self.locationButton.frame = frame;
    
    if (!self.autocompleteTableView) {
        // autocomplete table view
        self.autocompleteTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                                                   self.changeLocationView.frame.size.height,
                                                                                   self.view.frame.size.width,
                                                                                   self.view.frame.size.height
                                                                                    - self.keyboardHeight
                                                                                    - self.changeLocationView.frame.size.height)];
        self.autocompleteTableView.dataSource = self;
        self.autocompleteTableView.delegate = self;
        self.autocompleteTableView.hidden = YES;
        [self.view addSubview:self.autocompleteTableView];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(hideChangeLocationView:)];
        [self.autocompleteTableView addGestureRecognizer:tapGR];
    }
}

@end
