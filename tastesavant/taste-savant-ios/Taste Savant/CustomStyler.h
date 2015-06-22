//
//  CustomStyler.h
//  TasteSavant
//
//  Created by Joe Gallo on 10/30/13.
//  Copyright (c) 2013 Taste Savant. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Neighborhood.h"

@interface CustomStyler : NSObject

+ (void)setViewEnabled:(UIView *)view enabled:(BOOL)enabled;

+ (UILabel *)createTitleViewLabel:(NSString *)titleText;

+ (void)styleButton:(UIButton *)button;
+ (void)styleButton2:(UIButton *)button;
+ (void)styleSelectButton:(UIButton *)button corners:(int)corners;

+ (void)customizeDistanceButton:(UIButton *)button;
+ (NSAttributedString *)createAttributedStringForDistanceButton:(NSString *)part1 and:(NSString *)part2 color:(UIColor *)color;

+ (void)styleTextField:(UITextField *)textField;
+ (void)styleDisclosureTextField:(UITextField *)textField;

+ (void)styleSegmentedControl:(UISegmentedControl *)segmentedControl;

+ (void)styleOptionCell:(UITableViewCell *)cell;

+ (void)setAndStyleRestaurantInfo:(Restaurant *)restaurant
                               vc:(UIViewController *)vc
                 linkToRestaurant:(BOOL)linkToRestaurant;

+ (UIView *)createTableHeaderView:(UITableView *)tableView str:(NSString *)str;
+ (UIView *)createTableHeaderView2:(UITableView *)tableView attrStr:(NSAttributedString *)attrStr;

+ (NSAttributedString *)createAttributedStringForTableHeaderView:(NSString *)part1 and:(NSString *)part2;

+ (void)addSearchResultIndexView:(UIImageView *)imageView index:(NSInteger)index;

+ (UITableViewCell *)createLoadMoreTableCell:(UITableView *)tableView vc:(UIViewController *)vc;
+ (void)showLoadMoreSpinner:(UITableViewCell *)loadMoreTableCell;

+ (void)customizeSearchBar:(UISearchBar *)searchBar;
+ (void)alwaysEnableSearchButtonInKeyboard:(UISearchBar *)searchBar;
+ (void)customizeLocationSearchBar:(UISearchBar *)searchBar neighborhood:(Neighborhood *)neighborhood;
+ (void)setSearchBarIcon:(UISearchBar *)searchBar;

+ (void)makePhoneNumberLink:(UILabel *)label;

+ (void)roundCorners:(UIView *)view radius:(float)radius;

+ (void)setBorder:(UIView *)view;
+ (void)setBorder:(UIView *)view width:(float)width color:(UIColor *)color;

@end
