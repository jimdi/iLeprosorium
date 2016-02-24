//
//  LepraCommonViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LepraCommonViewController : UIViewController

@property (nonatomic) BOOL locksViewDeckOnViewWillAppear;

+ (NSString *)storyboardID;
- (void)methodCalledFromDealloc;

//------------------------------------------------------------------------------
#pragma mark - Configuring self
- (void)configureNavigationBarWithColor:(UIColor *)color;
- (void)configureNavigationBarWithColor:(UIColor *)color titleColor:(UIColor *)titleColor;

//------------------------------------------------------------------------------
#pragma mark - Adding stuff to navigation bar
// navigation activity indicator
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorNavigation;
- (void)addActivityIndicatorToNavigationBar;

- (void)addMenuButton;
- (void)addMenuButtonWithColor:(UIColor*)color;
- (void)menuButtonPressed:(UIButton *)button;

//------------------------------------------------------------------------------
#pragma mark - Keyboard shit
@property (weak, nonatomic) NSLayoutConstraint *bottomConstraintToShrinkWhenKeyboardAppears;
@property (strong, nonatomic) NSNumber *savebottomConstraintToShrinkWhenKeyboardAppearsConstant;
- (void)keyboardWillShow:(NSNotification *)note;
- (void)keyboardWillHide:(NSNotification *)note;

@end
