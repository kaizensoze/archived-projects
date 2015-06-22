//
//  BFKCaptureViewController.m
//  Keeper
//
//  Created by Joe Gallo on 10/23/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BFKAppDelegate.h"
#import "BFKCustomStyler.h"
#import "BFKReviewViewController.h"
#import "BFKUtil.h"
#import "UIView+Snapshot.h"
#import "UIImage+Utility.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "BFKCapturedItem.h"
#import "BFKCapturedImage.h"
#import "BFKCapturedNote.h"
#import "BFKNewNoteViewController.h"
#import "BFKDao.h"
#import "BFKSectionsViewController.h"
#import "BFKPagesViewController.h"

@interface BFKCaptureViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *captureButton1;
    @property (weak, nonatomic) IBOutlet UIButton *captureButton2;

    @property (weak, nonatomic) IBOutlet UIImageView *captureOverlay;
    @property (weak, nonatomic) IBOutlet UIButton *flashButton;
    @property (weak, nonatomic) IBOutlet UIButton *noteButton;
    @property (weak, nonatomic) IBOutlet UITextView *noteTextView;
    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

    @property (strong, nonatomic) AVCaptureSession *session;
    @property (strong, nonatomic) AVCaptureDevice *device;
    @property (strong, nonatomic) AVCaptureStillImageOutput *imageOutput;
    @property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

    @property (strong, nonatomic) CALayer *mask;
    @property (nonatomic) CGRect cropRect;

    @property (strong, nonatomic) UIImageView *captureImageView;
    @property (weak, nonatomic) IBOutlet UIImageView *importedImageView;

    @property (weak, nonatomic) IBOutlet UIButton *closeImportedImageButton;

    @property (nonatomic) BFKCaptureMode captureMode;

    @property (nonatomic) BOOL showingImagePicker;

    @property (weak, nonatomic) IBOutlet UIButton *singleMultiButton;
    @property (weak, nonatomic) IBOutlet UITextField *singleMultiTextField;

    @property (strong, nonatomic) NSMutableArray *capturedItems;
    @property (nonatomic) int captureCount;

    @property (strong, nonatomic) BFKNewNoteViewController *noteNewVC;
    @property (strong, nonatomic) BFKReviewViewController *reviewVC;
@end

@implementation BFKCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // captured objects
    self.capturedItems = [[NSMutableArray alloc] init];
    
    // image capture
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [self setFlash:NO];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    [self.session addInput:input];
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    self.imageOutput.outputSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    [self.session addOutput:self.imageOutput];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.bounds;
    [self.previewLayer removeFromSuperlayer];
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    [self.session startRunning];
    
    // mask
    self.mask = [CALayer layer];
    self.mask.contents = (id)[[UIImage imageNamed:@"capture-overlay-mask"] CGImage];
    self.mask.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    // crop rect
    self.cropRect = CGRectMake(17, 61, 285, 387);
    
    // capture image view
    self.captureImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    self.captureImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    // flash button
    [BFKCustomStyler adjustButton:self.flashButton];
    
    // note text view
    self.noteTextView.hidden = YES;
    
    // scroll view
    self.scrollView.contentSize = self.view.frame.size;
    
    // remove multi-mode for now
    self.singleMultiButton.hidden = YES;
    self.singleMultiTextField.hidden = YES;
    
    self.noteNewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NewNote"];
    __unused UIView *noteNewView = self.noteNewVC.view; // preload new note view
    
    self.reviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Review"];
    __unused UIView *reviewView = self.noteNewVC.view; // preload review view
    
//    [BFKUtil roundCorners:self.importedImageView radius:15];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    
    // set to capture mode and reset capture count
    if (self.captureMode != BFKNoteCaptureMode && !self.showingImagePicker) {
        [self setToCaptureMode];
    }
    
//    if (!self.showingImagePicker) {
        self.capturedItems = [[NSMutableArray alloc] init];
        self.captureCount = 0;
//    }
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BFKAppDelegate *appDelegate = (BFKAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.tracker set:kGAIScreenName value:@"Capture View"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    
    [self.noteTextView resignFirstResponder];
    
    [self unregisterForKeyboardNotifications];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Capture

- (IBAction)capture:(id)sender {
    // handle capture based on mode (capture, imported image, note)
    if (self.captureMode == BFKCaptureCaptureMode) {
        DDLogInfo(@"capture:capture");
        
        AVCaptureConnection *videoConnection = nil;
        for (AVCaptureConnection *connection in self.imageOutput.connections) {
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                    videoConnection = connection;
                    break;
                }
            }
            if (videoConnection) { break; }
        }
        
        [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
            UIImage *image = [self imageFromSampleBuffer:imageSampleBuffer];
            
            self.captureImageView.layer.mask = self.mask;
            self.captureImageView.layer.masksToBounds = YES;
            self.captureImageView.image = image;
            
            // save masked image to UIImage object
            UIImage *maskedImage = [self.captureImageView makeSnapshot];
            
            // crop masked image
            UIImage *croppedMaskedImage = [maskedImage cropFromRect:self.cropRect];
            
            BFKCapturedImage *item = [BFKDao createCapturedImage:croppedMaskedImage];
            [self.capturedItems addObject:item];
            
            self.captureCount++;
            [self checkCaptureCount];
        }];
    } else if (self.captureMode == BFKImportedImageCaptureMode) {
        DDLogInfo(@"capture:image");
        
        UIImage *importedImage = self.importedImageView.image;
        
        BFKCapturedImage *item = [BFKDao createCapturedImage:importedImage];
        item.imported = [NSNumber numberWithBool:YES];
        [self.capturedItems addObject:item];
        
        self.captureCount++;
        [self checkCaptureCount];
    } else {
        DDLogInfo(@"capture:notes");
        
        NSString *note = self.noteTextView.text;
        
        BFKCapturedNote *item = [[BFKCapturedNote alloc] init];
        item.note = note;
        [self.capturedItems addObject:item];
        
        self.captureCount++;
        [self checkCaptureCount];
    }
    
    // NOTE: checkCaptureCount is called in each block due to the async nature of captureStillImageAsynchronouslyFromConnection (it's just an easier workaround)
}

#pragma mark - Check capture count

- (void)checkCaptureCount {
    // determine whether or not to go to review screen
    if (self.captureCount >= [self.singleMultiTextField.text intValue]) {
        [self reviewCapturedItems];
    }
}

#pragma mark - Image from sample buffer

- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little |kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0 orientation:UIImageOrientationRight];
    
    CGImageRelease(quartzImage);
    
    return image;
}

#pragma mark - Toggle flash

- (IBAction)toggleFlash:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    [self setFlash:button.selected];
}

- (void)setFlash:(BOOL)flash {
    [self.device lockForConfiguration:nil];
    self.device.flashMode = flash ? AVCaptureFlashModeOn : AVCaptureFlashModeOff;
    [self.device unlockForConfiguration];
}

#pragma mark - Upload image

- (IBAction)uploadImage:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    picker.allowsEditing = YES;
    picker.delegate = self;
    
    picker.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    self.showingImagePicker = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    // show imported image view
    self.importedImageView.image = image;
    
    // set to imported image mode
    [self setToImportedImageMode];
    
    [self dismissViewControllerAnimated:YES completion:^(void) {
        self.showingImagePicker = NO;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)closeImportedImage:(id)sender {
    self.closeImportedImageButton.hidden = YES;
//    [self.closeImportedImageButton removeFromSuperview];
    
    if (self.noteTextView.text.length > 0) {
        [self setToNoteMode];
    } else {
        [self setToCaptureMode];
    }
}

#pragma mark - Set to modes

- (void)setToCaptureMode {
    DDLogInfo(@"mode: capture");
    
    self.captureButton1.hidden = NO;
    self.captureButton2.hidden = YES;
    self.importedImageView.hidden = YES;
    self.closeImportedImageButton.hidden = YES;
    self.captureOverlay.hidden = NO;
    self.previewLayer.hidden = NO;
    self.flashButton.hidden = NO;
    self.noteButton.hidden = NO;
    
    self.captureMode = BFKCaptureCaptureMode;
}

- (void)setToImportedImageMode {
    DDLogInfo(@"mode: imported image");
    
    self.captureButton1.hidden = YES;
    self.captureButton2.hidden = NO;
    self.importedImageView.hidden = NO;
    self.closeImportedImageButton.hidden = NO;
    self.captureOverlay.hidden = YES;
    self.previewLayer.hidden = YES;
    self.flashButton.hidden = YES;
    self.noteButton.hidden = YES;
    self.noteTextView.hidden = YES;

    self.closeImportedImageButton.hidden = NO;
    
    self.captureMode = BFKImportedImageCaptureMode;
}

- (void)setToNoteMode {
    DDLogInfo(@"mode: note");
    
    self.importedImageView.image = nil;
    self.importedImageView.hidden = YES;
    self.closeImportedImageButton.hidden = YES;
    self.captureOverlay.hidden = NO;
    self.previewLayer.hidden = YES;
    self.flashButton.hidden = YES;
    self.noteTextView.hidden = NO;
    
    self.captureMode = BFKNoteCaptureMode;
}

#pragma mark - Back

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Show note view
- (IBAction)showNewNote:(id)sender {
    self.noteNewVC.delegate = self;
    self.noteNewVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:self.noteNewVC animated:YES completion:nil];
}

#pragma mark - Start new note

- (IBAction)startNewNote:(id)sender {
    self.noteButton.hidden = YES;
    
    self.noteTextView.hidden = NO;
    [self.noteTextView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self setToNoteMode];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.noteTextView.hidden = YES;
        self.noteButton.hidden = NO;
        
        [self setToCaptureMode];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length == 0) {
        textField.text = @"1";
    }
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillBeShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height + 35, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - Touches ended

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Review content

- (void)reviewCapturedItems {
    self.reviewVC.capturedItems = [self.capturedItems copy];
    [self.navigationController pushViewController:self.reviewVC animated:YES];
}

#pragma mark - Saved note

- (void)savedNoteForNotebook:(BFKNotebook *)notebook section:(BFKSection *)section {
    // hack for going from capture page to pages view on saving new note
    NSMutableArray *newVCList = [self.navigationController.viewControllers mutableCopy];
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
    
    self.navigationController.viewControllers = [newVCList copy];
}

@end
