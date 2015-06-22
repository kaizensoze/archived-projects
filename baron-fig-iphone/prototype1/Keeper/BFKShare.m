//
//  BFKShare.m
//  Keeper
//
//  Created by Joe Gallo on 11/29/14.
//  Copyright (c) 2014 Baron Fig. All rights reserved.
//

#import "BFKShare.h"
#import "BFKUtil.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface BFKShare ()
    @property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;

    @property (strong, nonatomic) NSArray *twitterAccounts;
    @property (strong, nonatomic) NSArray *facebookAccounts;
@end

@implementation BFKShare

- (id)init {
    self = [super init];
    if (self) {
        self.twitterAccounts = @[];
        self.facebookAccounts = @[];
    }
    return self;
}

#pragma mark - Share instagram

- (void)shareInstagram:(UIImage *)image vc:(UIViewController *)vc {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://"];
    if (![[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [BFKUtil showAlert:@"" message:@"The Instagram app is required." delegate:nil];
        return;
    }
    
    // write image to file
    NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/snapshot.igo"];
    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.documentInteractionController.UTI = @"com.instagram.exclusivegram";
//    self.documentInteractionController.delegate = vc;
    
    //    NSMutableDictionary *annotationDict = [[NSMutableDictionary alloc] init];
    //    [annotationDict setValue:@"Instagram Caption" forKey:@"InstagramCaption"];
    //    self.documentInteractionController.annotation = [annotationDict copy];
    
    [self.documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:vc.view animated:YES];
}

#pragma mark - Share facebook

- (void)shareFacebook:(BFKCapturedItem *)item vc:(UIViewController *)vc {
    [self refreshFacebookAccountsAndShareItem:item vc:vc];
}

- (void)refreshFacebookAccountsAndShareItem:(BFKCapturedItem *)item vc:(UIViewController *)vc {
    [self obtainAccessToFacebookAccountsWithBlock:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if (self.facebookAccounts.count == 0) {
                    [BFKUtil showAlert:@"" message:@"A Facebook account in settings is required." delegate:nil];
                    return;
                }
                
                NSArray *items;
                if ([item isKindOfClass:[BFKCapturedNote class]]) {
                    items = @[item.note];
                } else {
                    items = @[item.note, [UIImage imageWithData:((BFKCapturedImage *)item).image]];
                }
                
                UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                         applicationActivities:nil];
                activityVC.excludedActivityTypes = @[UIActivityTypeAddToReadingList,
                                                     UIActivityTypeAirDrop,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeMail,
                                                     UIActivityTypeMessage,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypePostToTwitter,
                                                     UIActivityTypePostToVimeo,
                                                     UIActivityTypePostToWeibo,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeSaveToCameraRoll];
                [vc presentViewController:activityVC animated:YES completion:nil];
            }
            else {
                if (error.code == 6) {
                    [BFKUtil showAlert:@"" message:@"A Facebook account in settings is required." delegate:nil];
                } else {
                    [BFKUtil showAlert:@"" message:@"Unable to access Facebook account.\n\nCheck app permissions under Privacy settings." delegate:nil];
                }
            }
        });
    }];
}

- (void)obtainAccessToFacebookAccountsWithBlock:(void (^)(BOOL, NSError *))block {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *facebookType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.facebookAccounts = [accountStore accountsWithAccountType:facebookType];
        } else {
            DDLogInfo(@"%@", error);
        }
        block(granted, error);
    };
    
    NSDictionary *options = @{
                              @"ACFacebookAppIdKey" : @"1568707440031067",
                              @"ACFacebookPermissionsKey" : @[@"basic_info"], // @"publish_actions", @"email"
                              @"ACFacebookAudienceKey" : ACFacebookAudienceEveryone
                              };
    
    [accountStore requestAccessToAccountsWithType:facebookType options:options completion:handler];
}

#pragma mark - Share twitter

- (void)shareTwitter:(BFKCapturedItem *)item vc:(UIViewController *)vc {
    [self refreshTwitterAccountsAndShareImage:item vc:vc];
}

- (void)refreshTwitterAccountsAndShareImage:(BFKCapturedItem *)item vc:(UIViewController *)vc {
    [self obtainAccessToTwitterAccountsWithBlock:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                if (self.twitterAccounts.count == 0) {
                    [BFKUtil showAlert:@"" message:@"A Twitter account in settings is required." delegate:nil];
                    return;
                }
                
                NSArray *items;
                if ([item isKindOfClass:[BFKCapturedNote class]]) {
                    items = @[item.note];
                } else {
                    items = @[item.note, [UIImage imageWithData:((BFKCapturedImage *)item).image]];
                }
                
                UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                                         applicationActivities:nil];
                activityVC.excludedActivityTypes = @[UIActivityTypeAddToReadingList,
                                                     UIActivityTypeAirDrop,
                                                     UIActivityTypeAssignToContact,
                                                     UIActivityTypeCopyToPasteboard,
                                                     UIActivityTypeMail,
                                                     UIActivityTypeMessage,
                                                     UIActivityTypePostToFacebook,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypePostToVimeo,
                                                     UIActivityTypePostToWeibo,
                                                     UIActivityTypePrint,
                                                     UIActivityTypeSaveToCameraRoll];
                [vc presentViewController:activityVC animated:YES completion:nil];
            }
            else {
                [BFKUtil showAlert:@"" message:@"Unable to access Twitter account.\n\nCheck app permissions under Privacy settings."
                          delegate:nil];
            }
        });
    }];
}

- (void)obtainAccessToTwitterAccountsWithBlock:(void (^)(BOOL, NSError *))block {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.twitterAccounts = [accountStore accountsWithAccountType:twitterType];
        } else {
            DDLogInfo(@"%@", error);
        }
        block(granted, error);
    };
    
    [accountStore requestAccessToAccountsWithType:twitterType options:nil completion:handler];
}

#pragma mark - Share email

- (void)shareEmail:(BFKCapturedItem *)item vc:(UIViewController *)vc {
    NSArray *items;
    if ([item isKindOfClass:[BFKCapturedNote class]]) {
        items = @[item.note];
    } else {
        // write image to file
        NSString *filePath=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/snapshot.png"];
        UIImage *image = [UIImage imageWithData:((BFKCapturedImage *)item).image];
        [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        
        NSURL *url = [NSURL fileURLWithPath:filePath];
        
        items = @[item.note, url];
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:items
                                                                             applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeAddToReadingList,
                                         UIActivityTypeAirDrop,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeMessage,
                                         UIActivityTypePostToFacebook,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypePostToTwitter,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         UIActivityTypeSaveToCameraRoll];
    [vc presentViewController:activityVC animated:YES completion:nil];
}

@end
