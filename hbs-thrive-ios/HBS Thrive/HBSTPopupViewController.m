//
//  HBSTPopupViewController.m
//  HBS Thrive
//
//  Created by Joe Gallo on 8/14/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "HBSTPopupViewController.h"
#import "HBSTHomeViewController.h"

@interface HBSTPopupViewController ()
    @property (weak, nonatomic) IBOutlet UIButton *closeButton;
    @property (weak, nonatomic) IBOutlet UILabel *titleLabel;
    @property (weak, nonatomic) IBOutlet UIImageView *bottomSeparatorImageView;
    @property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
    @property (strong, nonatomic) IBOutlet UILabel *emptyLabel;

    @property (strong, nonatomic) UIPageViewController *pageController;
@end

@implementation HBSTPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    
    self.view.layer.cornerRadius = 4;
    self.view.layer.masksToBounds = YES;
    
    self.titleLabel.text = self.title;
    self.titleLabel.textColor = [UIColor whiteColor];
    
    self.emptyLabel.text = self.emptyMessage;
    [HBSTUtil adjustText:self.emptyLabel width:240 height:MAXFLOAT];
    
    self.closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    if (self.contentViewControllers.count > 0) {
        [self.pageController setViewControllers:[NSArray arrayWithObject:self.contentViewControllers.firstObject]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
        self.pageController.view.frame = CGRectMake(0, 45, self.view.frame.size.width, self.view.frame.size.height - 45 - 20);
        self.pageController.dataSource = self;
        self.pageController.delegate = self;
        [self.view addSubview:self.pageController.view];
        
        self.pageControl.numberOfPages = self.contentViewControllers.count;
        self.pageControl.currentPage = 0;
        
        self.emptyLabel.hidden = YES;
    } else {
        self.emptyLabel.hidden = NO;
    }
    
    // welcome popup exception
    if ([self.titleLabel.text isEqualToString:@"Welcome"]
        || [self.titleLabel.text isEqualToString:@"Flash Poll"]) {
        self.bottomSeparatorImageView.hidden = YES;
        self.pageControl.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self.contentViewControllers indexOfObject:viewController];
    
    if (index == 0) {
        return nil;
    }
    
    NSUInteger newIndex = index - 1;
    return self.contentViewControllers[newIndex];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self.contentViewControllers indexOfObject:viewController];
    
    if (index == self.contentViewControllers.count - 1) {
        return nil;
    }
    
    NSUInteger newIndex = index + 1;
    return self.contentViewControllers[newIndex];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    if (completed) {
        NSUInteger currentPageIndex = [self.contentViewControllers indexOfObject:self.pageController.viewControllers.lastObject];
        self.pageControl.currentPage = currentPageIndex;
    }
}

- (IBAction)close:(id)sender {
    [self.delegate popupClosed];
}

@end
