//
//  LepraLoginViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraLoginViewController.h"
#import "LepraLoginCell.h"
#import <AFHTTPRequestOperation.h>

@interface LepraLoginViewController ()

@property (strong, nonatomic) NSString* challenge;

@end

@implementation LepraLoginViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self configureNavigationBarWithColor:COLOR_FROM_HEX(0xF1, 0x1C, 0x37)];
	
	self.navigationController.navigationBar.hidden = YES;
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.01];
	
	[self.tableView setBackgroundColor:COLOR_FROM_GENERIC_HEX(0x39, 0x45, 0x5c)];
	[self.view setBackgroundColor:COLOR_FROM_GENERIC_HEX(0x39, 0x45, 0x5c)];
	
	__loginCell = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

//------------------------------------------------------------------------------------------
#pragma mark - UITableView methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1; // only one cell which is static
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.tableView.frame.size.height;
}

static LepraLoginCell *__loginCell;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LepraLoginCell *loginCell;
	if (__loginCell) {
		loginCell = __loginCell;
	}
	else {
		loginCell = [self.tableView dequeueReusableCellWithIdentifier:[LepraLoginCell cellIdentifier]];
		__loginCell = loginCell;
		
		if (![LepraGeneralHelper isEmpty:DEFAULTS_OBJ(DEF_KEY_LOGIN_EMAIL)]) {
			[__loginCell.loginField setText:DEFAULTS_OBJ(DEF_KEY_LOGIN_EMAIL)];
		}
		[__loginCell.passwordField setText:@""];
//		[__loginCell.loginField setText:@"Bakenbard"];
//		[__loginCell.passwordField setText:@"Mx8-D5V-32T-z8f"];
	}
	
	[__loginCell updateCapcha:nil];
	return loginCell;
}

//------------------------------------------------------------------------------
#pragma mark - User Actions

- (IBAction)loginTap:(id)sender
{
	NSString* login = __loginCell.loginField.text;
	NSString* password = __loginCell.passwordField.text;
	NSString* capcha = __loginCell.capchaField.text;
	
	if (![LepraGeneralHelper isEmpty:login] && ![LepraGeneralHelper isEmpty:password]) {
		[[LepraAPIManager sharedManager] loginWithLogin:login password:password recaptchaChallenge:self.challenge capcha:capcha success:^{
			self.completionBlock(YES);
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if ([error.domain isEqualToString:@"captcha_required"]) {
				[TSMessage showNotificationInViewController:self title:@"Быстрая попытка входа, попробуйте ещё раз через несколько секунд" subtitle:nil type:TSMessageNotificationTypeError];
			} else if ([error.domain isEqualToString:@"invalid_password"]) {
				[__loginCell updateCapcha:nil];
				[TSMessage showNotificationInViewController:self title:@"Неверный пароль" subtitle:nil type:TSMessageNotificationTypeError];
			} else {
				[TSMessage showNotificationInViewController:self title:@"Произошла ошибка" subtitle:nil type:TSMessageNotificationTypeError];
			}
		}];
	}
}

- (NSString*)getCaptchaPublicKey:(NSString*)loginPage
{
	NSRange publicKeyRange = [loginPage rangeOfString:@"loginHandler.recaptcha_public_key = '"];
	if (publicKeyRange.location != NSNotFound) {
		NSString *tmpStr = [loginPage substringFromIndex:publicKeyRange.location + publicKeyRange.length];
		tmpStr = [tmpStr substringToIndex:[tmpStr rangeOfString:@"'"].location];
		return tmpStr;
	} else {
		return nil;
	}
}

- (NSString*)getChallenge:(NSString*)challengePage
{
	NSRange challengeRange = [challengePage rangeOfString:@"challenge : '"];
	if (challengeRange.location != NSNotFound) {
		NSString *tmpStr = [challengePage substringFromIndex:challengeRange.location + challengeRange.length];
		tmpStr = [tmpStr substringToIndex:[tmpStr rangeOfString:@"'"].location];
		return tmpStr;
	} else {
		return nil;
	}
}

- (void)cancelHud
{
	[[LepraContainerViewController sharedContainer] hideHudInView:self.view];
}


- (IBAction)forgotTap:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://leprosorium.ru/amnesia/"]];
}

@end
