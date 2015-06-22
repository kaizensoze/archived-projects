//
//  HBSTWelcomePopupContentViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/22/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTWelcomePopupContentViewController.h"
#import "HBSTWebOverlayViewController.h"

@interface HBSTWelcomePopupContentViewController ()
    @property (weak, nonatomic) IBOutlet UILabel *hiLabel;
    @property (weak, nonatomic) IBOutlet UITextView *hereToHelpTextView;
@end

@implementation HBSTWelcomePopupContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.hiLabel.textColor = [UIColor whiteColor];
    self.hiLabel.text = [NSString stringWithFormat:@"Hi, %@", self.firstName];
    
    self.hereToHelpTextView.textColor = [UIColor whiteColor];
    [HBSTUtil removeTextViewPadding:self.hereToHelpTextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([URL.absoluteString hasPrefix:@"mailto:"]) {
        NSString *email = [URL.absoluteString stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
        appDelegate.mailVC = nil;
        appDelegate.mailVC = [[MFMailComposeViewController alloc] init];
        appDelegate.mailVC.mailComposeDelegate = appDelegate;
        [appDelegate.mailVC setToRecipients:@[email]];
        [appDelegate.window.rootViewController presentViewController:appDelegate.mailVC animated:YES completion:nil];
        return NO;
    } else if ([URL.absoluteString hasPrefix:@"tel:"]) {
        return YES;
    } else {
        UINavigationController *nc = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"WebOverlayNav"];
        HBSTWebOverlayViewController *webOverlayVC = (HBSTWebOverlayViewController *)nc.viewControllers[0];
        webOverlayVC.url = URL;
        [appDelegate.window.rootViewController presentViewController:nc animated:YES completion:nil];
        return NO;
    }
}

@end
