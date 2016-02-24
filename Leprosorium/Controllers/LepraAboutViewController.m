//
//  LepraAboutViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 02.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraAboutViewController.h"
#import <TTTAttributedLabel.h>

#import "LepraProfileViewController.h"
#import "LepraProfilePostsViewController.h"
#import "LepraProfileCommentsViewController.h"
#import "LepraSwipeViewController.h"

@interface LepraAboutViewController () <TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@end

@implementation LepraAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	if (self.navigationController.viewControllers.count==1) {
		[self addMenuButton];
	}

    self.title = @"О приложении";
	
	
	[self.aboutLabel setLinkAttributes:@{NSForegroundColorAttributeName : [LepraGeneralHelper blueColor],
											NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
	[self.aboutLabel setActiveLinkAttributes:@{NSForegroundColorAttributeName : [LepraGeneralHelper blueColor],
												  NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
	
	NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"Клиент для убежища leprosorium.ru.\nНаконец-то дождались!\n\nYARRR!\n\nВыстрадано и выпарсено:\nJim_Di\nRoma Bakenbard" attributes:@{NSFontAttributeName : TEXT_FONT, NSForegroundColorAttributeName : [LepraGeneralHelper blueColor], NSParagraphStyleAttributeName : paragraphStyle}];
	
	[self.aboutLabel setAttributedText:string];
	[self.aboutLabel setTextAlignment:NSTextAlignmentCenter];
	[self.aboutLabel setTextColor:[UIColor whiteColor]];
	[self.aboutLabel addLinkToURL:[NSURL URLWithString:@"Jim_Di"] withRange:[self.aboutLabel.text rangeOfString:@"Jim_Di"]];
	[self.aboutLabel addLinkToURL:[NSURL URLWithString:@"Bakenbard"] withRange:[self.aboutLabel.text rangeOfString:@"Roma Bakenbard"]];
	[self.aboutLabel setDelegate:self];
	
	[self.emailButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Написать разработчику" attributes:@{NSFontAttributeName : TEXT_FONT, NSForegroundColorAttributeName : [LepraGeneralHelper blueColor]}] forState:UIControlStateNormal];
	
	[self.view setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self configureNavigationBarWithColor:[LepraGeneralHelper blueColor] titleColor:[UIColor whiteColor]];
}

- (IBAction)emailTap:(id)sender
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:roma.bakenbard@gmail.com?&subject=From%20'Leprosorium%20iOS%20App'"]];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
	NSString *absouluteUrl = url.absoluteString;
	if ([absouluteUrl isEqualToString:@"Jim_Di"] || [absouluteUrl isEqualToString:@"Bakenbard"]) {
		LepraProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfileViewController storyboardID]];
		profileVC.userName = absouluteUrl;
		LepraProfilePostsViewController *profilePostsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfilePostsViewController storyboardID]];
		profilePostsVC.userName = absouluteUrl;
		LepraProfileCommentsViewController *profileCommentsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfileCommentsViewController storyboardID]];
		profileCommentsVC.userName = absouluteUrl;
		
		LepraSwipeViewController *swipeController = [[LepraSwipeViewController alloc] initWithViewControllers:@[profileVC, profilePostsVC, profileCommentsVC]];
		swipeController.title = absouluteUrl;
		[self.navigationController pushViewController:swipeController animated:YES];
	}
	[[UIApplication sharedApplication] openURL:url];
}

@end
