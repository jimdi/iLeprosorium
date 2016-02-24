//
//  LepraNewLoginViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 06.06.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraNewLoginViewController.h"
#import "LepraDoneAccessoryView.h"

@interface LepraNewLoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordSeparatorHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginSeparatorHeight;


@property (weak, nonatomic) IBOutlet UITextField *loginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (strong, nonatomic) LepraDoneAccessoryView *doneAccessory;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonBottomConstraint;

@property (strong, nonatomic) UIColor *buttonColor;

@property (nonatomic) BOOL loginLoading;
@property (nonatomic) BOOL shitPhone;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passwordBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBottomConstraint;

@end

@implementation LepraNewLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSArray *backgroundImagesLinks = @[[UIImage imageNamed:@"login_0"],
									   [UIImage imageNamed:@"login_1"],
									   [UIImage imageNamed:@"login_2"],
									   [UIImage imageNamed:@"login_3"],
									   [UIImage imageNamed:@"login_4"],
									   [UIImage imageNamed:@"login_5"]
									   ];
	
	[self.backgroundImageView setImage:[backgroundImagesLinks objectAtIndex:[LepraGeneralHelper randomWithMin:0 max:backgroundImagesLinks.count-1]]];
	
	self.buttonColor = [LepraGeneralHelper redColor];
	
	self.doneAccessory = [LepraDoneAccessoryView loadFromNib];
	self.doneAccessory.buttonNext.hidden = YES;
	self.doneAccessory.buttonPrev.hidden = YES;
	[self.doneAccessory.buttonDone addTarget:self
									  action:@selector(doneTap:)
							forControlEvents:UIControlEventTouchUpInside];
	[self.doneAccessory.buttonDone setTintColor:self.buttonColor];
	
	[self.loginButton setBackgroundImage:[LepraGeneralHelper imageWithColor:self.buttonColor] forState:UIControlStateNormal];
	[self.loginButton setBackgroundImage:[LepraGeneralHelper imageWithColor:[self.buttonColor colorWithAlphaComponent:0.5]] forState:UIControlStateHighlighted];
	
	[self.loginField setDelegate:self];
	[self.passwordField setDelegate:self];
	
	self.loginSeparatorHeight.constant = 1.0/[UIScreen mainScreen].scale;
	self.passwordSeparatorHeight.constant = 1.0/[UIScreen mainScreen].scale;
	
	self.shitPhone = self.view.frame.size.height<500.0;
	
	if (self.shitPhone) {
		self.bottomConstraintToShrinkWhenKeyboardAppears.constant = 10.0;
		self.loginBottomConstraint.constant = 10.0;
		self.passwordBottomConstraint.constant = 10.0;
	}
	
	self.bottomConstraintToShrinkWhenKeyboardAppears = self.loginButtonBottomConstraint;
	
	
	[self.loginField setText:@"Bakenbard"];
	[self.passwordField setText:@"Mx8-D5V-32T-z8f"];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleDefault;
}

//----------------------------------------------------------------------
#pragma mark - User Actions

- (void)doneTap:(UIButton *)sender
{
	[self.doneAccessory.viewAccessoryIsFor endEditing:YES];
}

- (IBAction)loginButtonTap:(id)sender {
	NSString* login = self.loginField.text;
	NSString* password = self.passwordField.text;
	
	self.loginLoading = YES;
	[self animateLoginButton];
	[self.loginField setEnabled:NO];
	[self.passwordField setEnabled:NO];
	[self.loginButton setEnabled:NO];
	
	if (![LepraGeneralHelper isEmpty:login] && ![LepraGeneralHelper isEmpty:password]) {
		[[LepraAPIManager sharedManager] loginWithLogin:login password:password recaptchaChallenge:nil capcha:nil success:^{
			self.completionBlock(YES);
			self.loginLoading = NO;
			[self.loginField setEnabled:YES];
			[self.passwordField setEnabled:YES];
			[self.loginButton setEnabled:YES];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if ([error.domain isEqualToString:@"captcha_required"]) {
				[TSMessage showNotificationInViewController:self title:@"Быстрая попытка входа, попробуйте ещё раз через несколько секунд" subtitle:nil type:TSMessageNotificationTypeError];
			} else if ([error.domain isEqualToString:@"invalid_password"]) {
				[TSMessage showNotificationInViewController:self title:@"Неверный пароль" subtitle:nil type:TSMessageNotificationTypeError];
			} else {
				[TSMessage showNotificationInViewController:self title:@"Произошла ошибка" subtitle:nil type:TSMessageNotificationTypeError];
			}
			self.loginLoading = NO;
			[self.loginField setEnabled:YES];
			[self.passwordField setEnabled:YES];
			[self.loginButton setEnabled:YES];
		}];
	}
}

- (void)animateLoginButton {
	if (self.loginLoading) {
		[UIView animateWithDuration:0.5 animations:^{
			[self.loginButton setAlpha:0.5];
		} completion:^(BOOL finished) {
			if (self.loginLoading) {
				[UIView animateWithDuration:0.5 animations:^{
					[self.loginButton setAlpha:1.0];
				} completion:^(BOOL finished) {
					[self animateLoginButton];
				}];
			}
		}];
	}
}

//----------------------------------------------------------------------
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	textField.inputAccessoryView = self.doneAccessory;
	self.doneAccessory.viewAccessoryIsFor = textField;
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField isEqual:self.loginField]) {
		[self.passwordField becomeFirstResponder];
	} else if ([textField isEqual:self.passwordField]) {
		[self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
	return YES;
}

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
		if (self.shitPhone) {
			self.bottomConstraintToShrinkWhenKeyboardAppears.constant = keyboardBounds.size.height + 10.0;
		} else {
			self.bottomConstraintToShrinkWhenKeyboardAppears.constant = keyboardBounds.size.height + 30.0;
		}
		
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

@end
