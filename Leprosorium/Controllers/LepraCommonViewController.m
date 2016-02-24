//
//  LepraCommonViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonViewController.h"

@interface LepraCommonViewController ()

@end

@implementation LepraCommonViewController

+ (NSString *)storyboardID
{
	return NSStringFromClass([self class]);
}

//------------------------------------------------------------------------------
#pragma mark - NSObject

- (void)dealloc
{
	NSLog(@"[%@ dealloc]", self);
	[self methodCalledFromDealloc];
}

- (void)methodCalledFromDealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

//------------------------------------------------------------------------------
#pragma mark - UIViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	SIGNUP_FOR_NOTIFICATION(UIKeyboardWillShowNotification, @selector(keyboardWillShow:));
	SIGNUP_FOR_NOTIFICATION(UIKeyboardWillHideNotification, @selector(keyboardWillHide:));
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.viewDeckController.panningMode = self.locksViewDeckOnViewWillAppear? IIViewDeckNoPanning : IIViewDeckDelegatePanning;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
	return YES;
}

//------------------------------------------------------------------------------
#pragma mark - Configuring self

- (void)configureNavigationBarWithColor:(UIColor *)color
{
	UIColor *tintColor = color;
	UIColor *titleColor = [UIColor black25PercentColor];
	
	UIImageView *navShadow = [LepraGeneralHelper findHairlineImageViewUnder:self.navigationController.navigationBar];
	[navShadow setHidden:YES];
	
	[self.navigationController.navigationBar setTranslucent:NO];
	[self.navigationController.navigationBar setBarTintColor:tintColor];
	[self.navigationController.navigationBar setTintColor:titleColor];
	
	NSDictionary *attr = @{ NSForegroundColorAttributeName : titleColor, NSFontAttributeName : TEXT_FONT_BOLD };
	[self.navigationController.navigationBar setTitleTextAttributes:attr];
}

- (void)configureNavigationBarWithColor:(UIColor *)color titleColor:(UIColor *)titleColor
{
	UIColor *tintColor = color;
	
	UIImageView *navShadow = [LepraGeneralHelper findHairlineImageViewUnder:self.navigationController.navigationBar];
	[navShadow setHidden:YES];
	
	[self.navigationController.navigationBar setTranslucent:NO];
	[self.navigationController.navigationBar setBarTintColor:tintColor];
	[self.navigationController.navigationBar setTintColor:titleColor];
	
	NSDictionary *attr = @{ NSForegroundColorAttributeName : titleColor };
	[self.navigationController.navigationBar setTitleTextAttributes:attr];
}


//------------------------------------------------------------------------------
#pragma mark - Adding stuff to navigation bar
// navigation activity indicator
- (void)addActivityIndicatorToNavigationBar
{
	self.activityIndicatorNavigation = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self.activityIndicatorNavigation setHidesWhenStopped:YES];
	[self.activityIndicatorNavigation setColor:[UIColor whiteColor]];
	
	UIView *placeholder = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 44, 44)];
	[placeholder addSubview:self.activityIndicatorNavigation];
	[self.activityIndicatorNavigation setCenter:CGPointMake(placeholder.frame.size.width/2., placeholder.frame.size.height/2.)];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:placeholder];
}

// menu button
- (void)addMenuButton
{
	[self addMenuButtonWithColor:[UIColor whiteColor]];
}

- (void)addMenuButtonWithColor:(UIColor*)color
{
	UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
	NSString *imageName = @"menu_icon";
	[menuButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:imageName] withColor:color] forState:UIControlStateNormal];
	menuButton.frame = CGRectMake(0., 0., 44., 44.);
	menuButton.imageEdgeInsets = UIEdgeInsetsMake(0., 0, 0., 0.);
	
	[menuButton addTarget:self
				   action:@selector(menuButtonPressed:)
		 forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
									   target:nil action:nil];
	negativeSpacer.width = -15;
	
	self.navigationItem.leftBarButtonItems = @[negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:menuButton]];
}

- (void)menuButtonPressed:(UIButton *)button
{
	[self.viewDeckController openLeftViewAnimated:YES];
}


//-------------------------------------------------------------------------------------------------------
#pragma mark - Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note
{
	if (self.bottomConstraintToShrinkWhenKeyboardAppears) {
		
		// get keyboard size and loctaion
		CGRect keyboardBounds;
		[[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
		NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
		NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
		
		// Need to translate the bounds to account for rotation.
		keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
		
		if (!self.savebottomConstraintToShrinkWhenKeyboardAppearsConstant) {
			self.savebottomConstraintToShrinkWhenKeyboardAppearsConstant = @(self.bottomConstraintToShrinkWhenKeyboardAppears.constant);
		}
		self.bottomConstraintToShrinkWhenKeyboardAppears.constant = keyboardBounds.size.height;
		
		// animations settings
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:[duration doubleValue]];
		[UIView setAnimationCurve:[curve intValue]];
		
		[self.view layoutIfNeeded];
		
		// commit animations
		[UIView commitAnimations];
	}
}

- (void)keyboardWillHide:(NSNotification *)note
{
	if (self.bottomConstraintToShrinkWhenKeyboardAppears) {
		if (self.savebottomConstraintToShrinkWhenKeyboardAppearsConstant) {
			NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
			NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
			
			self.bottomConstraintToShrinkWhenKeyboardAppears.constant = self.savebottomConstraintToShrinkWhenKeyboardAppearsConstant.floatValue;
			
			// animations settings
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationBeginsFromCurrentState:YES];
			[UIView setAnimationDuration:[duration doubleValue]];
			[UIView setAnimationCurve:[curve intValue]];
			
			[self.view layoutIfNeeded];
			
			// commit animations
			[UIView commitAnimations];
			
			self.savebottomConstraintToShrinkWhenKeyboardAppearsConstant = nil;
		}
	}
}

@end
