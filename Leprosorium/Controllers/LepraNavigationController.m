//
//  LepraNavigationController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraNavigationController.h"

@interface LepraNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation LepraNavigationController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	__weak LepraNavigationController *weakSelf = self;
	
	if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
	{
		self.interactivePopGestureRecognizer.delegate = weakSelf;
		self.delegate = weakSelf;
	}
	
	//	self.view.layer.masksToBounds = NO;
	//	self.view.layer.shadowRadius = 20;
	//	self.view.layer.shadowOpacity = 0.2;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return [self.topViewController preferredStatusBarStyle];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
	   didShowViewController:(UIViewController *)viewController
					animated:(BOOL)animate
{
	if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && self.viewControllers.count>1) {
		self.interactivePopGestureRecognizer.enabled = YES;
	}
	else {
		
		self.interactivePopGestureRecognizer.enabled = NO;
		[self.navigationBar setNeedsLayout];
	}
}

@end
