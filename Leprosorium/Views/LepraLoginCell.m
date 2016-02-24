//
//  LepraLoginCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraLoginCell.h"

#import "LepraDoneAccessoryView.h"

@interface LepraLoginCell() <UITextFieldDelegate>

@property (strong, nonatomic) LepraDoneAccessoryView *doneAccessory;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *capchaImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *capchaFieldHeight;

@end

@implementation LepraLoginCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.passwordField.delegate = self;
	[self.passwordField setBackgroundColor:[LepraGeneralHelper blueColor]];
	self.loginField.delegate = self;
	[self.loginField setBackgroundColor:[LepraGeneralHelper blueColor]];
	self.capchaField.delegate = self;
	[self.capchaField setBackgroundColor:[LepraGeneralHelper blueColor]];
	
	self.doneAccessory = [LepraDoneAccessoryView loadFromNib];
	self.doneAccessory.buttonNext.hidden = YES;
	self.doneAccessory.buttonPrev.hidden = YES;
	[self.doneAccessory.buttonDone addTarget:self
									  action:@selector(doneTap:)
							forControlEvents:UIControlEventTouchUpInside];
	
	[self.signInButton setTitle:@"YARRR!" forState:UIControlStateNormal];
	
	[self.forgotPasswordButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Забыли пароль?" attributes:@{NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}] forState:UIControlStateNormal];
	
	[self.loginField setPlaceholder:@"Логин"];
	[self.passwordField setPlaceholder:@"Пароль"];
	[self.capchaField setPlaceholder:@"Два слова с картинки"];
	
	[self setBackgroundColor:COLOR_FROM_GENERIC_HEX(0x39, 0x45, 0x5c)];
}

- (void)updateCapcha:(NSString*)capchaLink
{
	[self.capchaField setText:@""];
	if ([LepraGeneralHelper isEmpty:capchaLink]) {
		self.capchaFieldHeight.constant = 0.0;
		self.capchaImageViewHeight.constant = 0.0;
		self.capchaImageView.hidden = YES;
		self.capchaField.hidden = YES;
	} else {
		self.capchaFieldHeight.constant = 40.0;
		self.capchaImageViewHeight.constant = 130.0;
		[self.capchaImageView sd_setImageWithURL:[NSURL URLWithString:capchaLink]];
		self.capchaImageView.hidden = NO;
		self.capchaField.hidden = NO;
	}
	[self.contentView layoutIfNeeded];
}

//----------------------------------------------------------------------
#pragma mark - User Actions

- (void)doneTap:(UIButton *)sender
{
	[self.doneAccessory.viewAccessoryIsFor endEditing:YES];
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
		if (self.capchaField.hidden) {
			[self.signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
		} else {
			[self.capchaField becomeFirstResponder];
		}
	} else if ([textField isEqual:self.capchaField]) {
		[self.signInButton sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
	return YES;
}

@end
