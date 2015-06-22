//
//  WebViewController.h
//  Taste Savant
//
//  Created by Joe Gallo on 4/29/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) NSString *url;

@end
