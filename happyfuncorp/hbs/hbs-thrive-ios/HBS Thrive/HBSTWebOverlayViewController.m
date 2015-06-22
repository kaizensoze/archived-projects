//
//  HBSTWebOverlayViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/22/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTWebOverlayViewController.h"

@interface HBSTWebOverlayViewController ()
    @property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation HBSTWebOverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    [self.webView loadRequest:request];
    
    self.title = self.url.absoluteString;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = [HBSTUtil colorFromHex:@"64964b"];
    
    UIImage *leftButtonImage = [[UIImage imageNamed:@"popup-close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:leftButtonImage
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = leftBarButtonItem;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
