//
//  NoteViewController.m
//  AwasuPromptr
//
//  Created by Joe Gallo on 7/1/13.
//  Copyright (c) 2013 Elephant Ventures LLC. All rights reserved.
//

#import "NoteViewController.h"
#import "Note.h"
#include <stdlib.h>

@interface NoteViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *backButton;
    @property (weak, nonatomic) IBOutlet UIView *navigationTitleView;
    @property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;

    @property (weak, nonatomic) IBOutlet UITextView *noteTextView;

    @property (weak, nonatomic) IBOutlet UIButton *deleteButton;
    @property (weak, nonatomic) IBOutlet UIButton *saveButton;

    @property (strong, nonatomic) UIColor *placeholderColor;
@end

@implementation NoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [Util colorFromHex:@"#696969"];
    
    [self loadCustomNavigationBar];
    
    [self loadNoteTextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadCustomNavigationBar {
    self.navigationTitleView.backgroundColor = [Util colorFromHex:@"#dddddd"];
    
    self.navigationTitleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16.45];
    self.navigationTitleLabel.textColor = [Util colorFromHex:@"#373737"];
    
    NSString *titleText;
    if (!self.note) {
        titleText = @"New note";
    } else {
        titleText = @"Note";
    }
    self.navigationTitleLabel.text = [titleText uppercaseString];
}

- (IBAction)back:(id)sender {
    if (self.note) {
        [self saveNote:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadNoteTextView {
    self.placeholderColor = [Util colorFromHex:@"#9f9f9f"];
    
    // use appropriate font+color (placeholder or normal) based on text view content
    if (self.note.content.length == 0) {
        [self addPlaceholderText];
    } else {
        [self useNormalText];
        self.noteTextView.text = self.note.content;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    // remove placeholder text
    if (self.noteTextView.textColor == self.placeholderColor) {
        self.noteTextView.text = @"";
    }
    [self useNormalText];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    // show placeholder text
    if (self.noteTextView.text.length == 0) {
        [self addPlaceholderText];
    }
}

- (void)useNormalText {
    self.noteTextView.font = [UIFont fontWithName:@"Helvetica-Light" size:16.45];
    self.noteTextView.textColor = [Util colorFromHex:@"#373737"];
}

- (void)addPlaceholderText {
    self.noteTextView.font = [UIFont fontWithName:@"Helvetica-Light" size:16.45];
    self.noteTextView.textColor = self.placeholderColor;
    self.noteTextView.text = [@"Add a note to yourself" uppercaseString];
}

- (IBAction)deleteNote:(id)sender {
    if (self.note) {
        [self.delegate noteDeleted:self.note];
    }
    self.note = nil;
    self.noteTextView.text = @"";
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveNote:(id)sender {
    if (!self.note) {
        #warning FIXME: remove random hardcoded id
        self.note = [[Note alloc] initWithId:[[NSNumber numberWithInt:arc4random_uniform(30)] stringValue]];
    }
    self.note.content = self.noteTextView.text;

    [self.delegate noteSaved:self.note];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
