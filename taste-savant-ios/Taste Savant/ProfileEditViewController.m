//
//  ProfileEditViewController.m
//  Taste Savant
//
//  Created by Joe Gallo on 11/5/12.
//  Copyright (c) 2012 Taste Savant. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "OptionsViewController.h"
#import "User.h"
#import "MainTabBarController.h"

@interface ProfileEditViewController ()
    @property (weak, nonatomic) UITextField *activeField;
    @property (strong, nonatomic) NSArray *genderOptions;
    @property (strong, nonatomic) NSArray *reviewerTypeOptions;

    @property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
    @property (weak, nonatomic) IBOutlet UILabel *requiredLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *imageField;
    @property (weak, nonatomic) IBOutlet UILabel *editImageLabel;
    @property (weak, nonatomic) IBOutlet UIButton *editImageButton;
    @property (weak, nonatomic) IBOutlet UITextField *firstNameField;
    @property (weak, nonatomic) IBOutlet UITextField *lastNameField;
    @property (weak, nonatomic) IBOutlet UITextField *emailField;
    @property (weak, nonatomic) IBOutlet UITextField *genderField;
    @property (weak, nonatomic) IBOutlet UITextField *birthdayField;
    @property (weak, nonatomic) IBOutlet UITextField *zipcodeField;
    @property (weak, nonatomic) IBOutlet UITextField *locationField;
    @property (weak, nonatomic) IBOutlet UITextField *typeExpertField;
    @property (weak, nonatomic) IBOutlet UITextField *reviewerTypeField;
    @property (weak, nonatomic) IBOutlet UITextField *favoriteFoodField;
    @property (weak, nonatomic) IBOutlet UITextField *favoriteRestaurantField;
    @property (weak, nonatomic) IBOutlet UIButton *saveButton;

    @property (strong, nonatomic) UIActionSheet *imageActionSheet;

    @property (strong, nonatomic) UIAlertController *birthdayAlertController;
    @property (strong, nonatomic) UIDatePicker *birthdayPicker;

    @property (nonatomic) BOOL imageChanged;
@end

@implementation ProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // scroll view
    UIView *scrollViewSubview = ((UIView *)self.scrollView.subviews[0]);
    [self.scrollView setContentSize:scrollViewSubview.frame.size];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    self.requiredLabel.textColor = [Util colorFromHex:@"362f2d"];
    
    // disable edit profile for social auth users
    if (self.delegate.profile.viaSocialAuth) {
        self.editImageLabel.hidden = YES;
        self.editImageButton.hidden = YES;
    }
    
    // text fields
    [CustomStyler styleTextField:self.firstNameField];
    [CustomStyler styleTextField:self.lastNameField];
    [CustomStyler styleTextField:self.emailField];
    [CustomStyler styleTextField:self.birthdayField];
    [CustomStyler styleTextField:self.zipcodeField];
    [CustomStyler styleTextField:self.locationField];
    [CustomStyler styleTextField:self.typeExpertField];
    [CustomStyler styleTextField:self.favoriteFoodField];
    [CustomStyler styleTextField:self.favoriteRestaurantField];
    
    // disclosure fields
    [CustomStyler styleDisclosureTextField:self.genderField];
    [CustomStyler styleDisclosureTextField:self.reviewerTypeField];
    
    // save button
    [CustomStyler styleButton:self.saveButton];
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [Util hideHUD];
    
    if (self.forceEdit || [self.delegate.profile missingRequiredInfo]) {
        self.navigationItem.leftBarButtonItem = nil;
        [self checkForAndFillInFacebookInfo];
    } else {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate.tracker set:kGAIScreenName value:@"Profile Edit Screen"];
    [appDelegate.tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterForKeyboardNotifications];
}

- (void)viewDidUnload {
    self.imageField = nil;
    self.firstNameField = nil;
    self.lastNameField = nil;
    self.emailField = nil;
    self.genderField = nil;
    self.birthdayField = nil;
    self.zipcodeField = nil;
    self.locationField = nil;
    self.typeExpertField = nil;
    self.reviewerTypeField = nil;
    self.favoriteFoodField = nil;
    self.favoriteRestaurantField = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

- (void)setup {
    self.imageChanged = NO;
    
    self.genderOptions = @[@"F", @"M"];
    self.reviewerTypeOptions = @[@"easily_pleased", @"middle_of_the_road", @"discerning_diner"];
    
    // image
    if (self.delegate.profile.image) {
        self.imageField.image = self.delegate.profile.image;
    } else {
        [self.imageField setImageWithURL:[NSURL URLWithString: self.delegate.profile.imageURL]
                        placeholderImage:[UIImage imageNamed:@"profile-placeholder.png"]];
    }
    
    [CustomStyler roundCorners:self.imageField radius:5];
    [CustomStyler setBorder:self.imageField width:1.0 color:[Util colorFromHex:@"cccccc"]];
    
    // image action sheet
    self.imageActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Use Camera", @"Choose From Library", nil];
    
    // birthday action sheet
    self.birthdayAlertController = [UIAlertController alertControllerWithTitle:@"Pick a date."
                                                                       message:@"\n\n\n\n\n\n\n\n\n"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    CGRect frame = datePicker.frame;
    frame.origin.y = 15;
    datePicker.frame = frame;
    [self.birthdayAlertController.view addSubview:datePicker];
    
    self.birthdayPicker = datePicker;
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [self setBirthdayTextField];
                                                   [self.birthdayAlertController dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [self.birthdayAlertController addAction:ok];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        [self.birthdayAlertController dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    [self.birthdayAlertController addAction:cancel];
    
    // fill in text fields
    self.firstNameField.text = self.delegate.profile.firstName;
    self.lastNameField.text = self.delegate.profile.lastName;
    self.emailField.text = self.delegate.profile.email;
    self.birthdayField.text = self.delegate.profile.birthday;
    self.zipcodeField.text = self.delegate.profile.zipcode;
    self.locationField.text = self.delegate.profile.location;
    self.typeExpertField.text = self.delegate.profile.typeExpert;
    self.favoriteFoodField.text = self.delegate.profile.favoriteFood;
    self.favoriteRestaurantField.text = self.delegate.profile.favoriteRestaurant;
    
    // fill in disclosure fields
    [self updateGender:self.delegate.profile.gender];
    [self updateReviewerType:self.delegate.profile.reviewerType];
}

- (void)checkForAndFillInFacebookInfo {
    if (appDelegate.facebookData != nil) {
        self.firstNameField.text = [appDelegate.facebookData objectForKeyNotNull:@"first_name"];
        self.lastNameField.text = [appDelegate.facebookData objectForKeyNotNull:@"last_name"];
        self.emailField.text = [appDelegate.facebookData objectForKeyNotNull:@"email"];
        
        [self updateGender:[[[appDelegate.facebookData objectForKeyNotNull:@"gender"] capitalizedString] substringToIndex:1]];
        
        NSArray *birthdayParts = [[appDelegate.facebookData objectForKeyNotNull:@"birthday"] componentsSeparatedByString:@"/"];
        if (birthdayParts.count > 0) {
            self.birthdayField.text = [NSString stringWithFormat:@"%@-%@-%@", birthdayParts[2], birthdayParts[0], birthdayParts[1]];
        }
    }
}

#pragma mark - Image picker

- (IBAction)showImagePicker {
    [self.imageActionSheet showInView:self.view];
}

#pragma mark - Birthday picker

- (void)showBirthdayPicker {
    NSDate *birthday = [Util stringToDate:self.birthdayField.text dateFormat:@"yyyy-MM-dd"];
    if (birthday != nil) {
        self.birthdayPicker.date = birthday;
    }
    [self presentViewController:self.birthdayAlertController animated:YES completion:nil];
}

- (void)setBirthdayTextField {
    NSDate *birthday = self.birthdayPicker.date;
    NSString *birthdayString = [Util dateToString:birthday dateFormat:@"yyyy-MM-dd"];
    self.birthdayField.text = birthdayString;
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
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.imageField.image = image;
    self.imageChanged = YES;
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor];
    }];
}

- (void)openEditor {
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.keepingCropAspectRatio = YES;
    controller.toolbarHidden = YES;
    controller.delegate = self;
    controller.image = self.imageField.image;
    
    UIImage *image = self.imageField.image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - PECropViewControllerDelegate

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage {
    [controller dismissViewControllerAnimated:YES completion:NULL];
    self.imageField.image = croppedImage;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Disclosure buttons

- (void)updateGender:(NSString *)newVal {
    NSString *gender = [Util genderLabelForValue:newVal];
    if (gender) {
        self.genderField.text = gender;
    }
}

- (void)updateReviewerType:(NSString *)newVal {
    NSString *reviewerType = [Util reviewerTypeLabelForValue:newVal];
    if (reviewerType) {
        self.reviewerTypeField.text = reviewerType;
    }
}

#pragma mark - Validation

- (BOOL)validate {
    // check required fields
    if ([Util isEmptyTextField:self.firstNameField]) {
        [Util showErrorAlert:@"First name is required." delegate:self];
        return NO;
    }
    if ([Util isEmptyTextField:self.lastNameField]) {
        [Util showErrorAlert:@"Last name is required." delegate:self];
        return NO;
    }
    if ([Util isEmptyTextField:self.emailField]) {
        [Util showErrorAlert:@"Email is required." delegate:self];
        return NO;
    }
    
    // check email formatting
    if (![Util emailValid:self.emailField.text]) {
        [Util showErrorAlert:@"Please enter a valid email address." delegate:self];
        return NO;
    }
    
    // check birthday formatting
    if (![Util isEmptyTextField:self.birthdayField]) {
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\d{4}-\\d{2}-\\d{2}$"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:self.birthdayField.text
                                                            options:0
                                                              range:NSMakeRange(0, [self.birthdayField.text length])];
        if (numberOfMatches != 1) {
            [Util showErrorAlert:@"Birthday must be of form YYYY-MM-DD." delegate:self];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Cancel

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Save

- (IBAction)save:(id)sender {
    if (![self validate]) {
        return;
    }
    
    [self saveProfileInfo];
}

- (void)saveProfileInfo {
    NSString *url = [NSString stringWithFormat: @"%@/users/%@/", API_URL_PREFIX, self.delegate.profile.username];
    
    self.delegate.profile.firstName = [Util clean:self.firstNameField.text];
    self.delegate.profile.lastName = [Util clean:self.lastNameField.text];
    self.delegate.profile.email = [Util clean:self.emailField.text];
    self.delegate.profile.gender = [Util genderValueForLabel:self.genderField.text];
    self.delegate.profile.birthday = [Util clean:self.birthdayField.text];
    self.delegate.profile.zipcode = [Util clean:self.zipcodeField.text];
    self.delegate.profile.location = [Util clean:self.locationField.text];
    self.delegate.profile.typeExpert = [Util clean:self.typeExpertField.text];
    self.delegate.profile.reviewerType = [Util reviewerTypeValueForLabel:self.reviewerTypeField.text];
    self.delegate.profile.favoriteFood = [Util clean:self.favoriteFoodField.text];
    self.delegate.profile.favoriteRestaurant = [Util clean:self.favoriteRestaurantField.text];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.delegate.profile.firstName forKey:@"first_name"];
    [params setValue:self.delegate.profile.lastName forKey:@"last_name"];
    [params setValue:self.delegate.profile.email forKey:@"email"];
    [params setValue:self.delegate.profile.gender forKey:@"gender"];
    [params setValue:self.delegate.profile.birthday forKey:@"birthday"];
    [params setValue:self.delegate.profile.zipcode forKey:@"zipcode"];
    [params setValue:self.delegate.profile.location forKey:@"location"];
    [params setValue:self.delegate.profile.typeExpert forKey:@"type_expert"];
    [params setValue:self.delegate.profile.reviewerType forKey:@"type_reviewer"];
    [params setValue:self.delegate.profile.favoriteFood forKey:@"favorite_food"];
    [params setValue:self.delegate.profile.favoriteRestaurant forKey:@"favorite_restaurant"];
    
    NSURLRequest *request = [appDelegate.httpClient requestWithMethod:@"PUT" path:url parameters:params];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [Util showHUDWithTitle:@"Saving..."];
        
        if (self.imageChanged) {
            [self saveAvatarImage];
        } else {
            [self signalDelegate];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [Util showNetworkingErrorAlert:(int)response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

#pragma mark - Avatar Image

- (void)saveAvatarImage {
    NSString *url = [NSString stringWithFormat: @"/%@/users/%@/avatar/", API_URL_PREFIX_PARTIAL, self.delegate.profile.username];
    UIImage *resizedImage = [self scaleImage:self.imageField.image toSize:CGSizeMake(105.0, 105.0)];
    NSData *imageData = UIImagePNGRepresentation(resizedImage);

    NSURLRequest *request = [appDelegate.httpClient multipartFormRequestWithMethod:@"POST" path:url parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"avatar" fileName:@"avatar.png" mimeType:@"image/png"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // set local image
        self.delegate.profile.image = self.imageField.image;
        
        // signal delegate
        [self signalDelegate];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Util showNetworkingErrorAlert:operation.response.statusCode error:error srcFunction:__func__];
    }];
    [appDelegate.httpClient.operationQueue addOperation:operation];
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Delegate

- (void)signalDelegate {
    appDelegate.loggedInUser = self.delegate.profile;
    [appDelegate saveLoggedInUserToDevice];
    
    [Util hideHUD];
    
    if (self.forceEdit) {
        MainTabBarController *tabBarController = (MainTabBarController *)appDelegate.window.rootViewController;
        [tabBarController goToTab:@"Search"];
        self.forceEdit = NO;
    } else {
        [self.delegate profileEditComplete];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKeyNotNull:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.birthdayField) {
        [self showBirthdayPicker];
        return NO;
    } else if (textField == self.genderField) {
        [self performSegueWithIdentifier:@"optionsGender" sender:self];
        return NO;
    } else if (textField == self.reviewerTypeField) {
        [self performSegueWithIdentifier:@"optionsReviewerType" sender:self];
        return NO;
    } else {
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // gender
    if ([[segue identifier] isEqualToString:@"optionsGender"]) {
        [self.view endEditing:YES];
        OptionsViewController *vc = (OptionsViewController *)segue.destinationViewController;
        vc.navigationItem.title = @"Gender";
        vc.options = self.genderOptions;
        vc.displayFunction = @selector(genderLabelForValue:);
        vc.methodToCallOnSelect = @selector(updateGender:);
    }
    
    // type of reviewer
    if ([[segue identifier] isEqualToString:@"optionsReviewerType"]) {
        [self.view endEditing:YES];
        OptionsViewController *vc = (OptionsViewController *)segue.destinationViewController;
        vc.navigationItem.title = @"Type of Reviewer";
        
        vc.options = self.reviewerTypeOptions;
        vc.displayFunction = @selector(reviewerTypeLabelForValue:);
        vc.methodToCallOnSelect = @selector(updateReviewerType:);
    }
}

@end
