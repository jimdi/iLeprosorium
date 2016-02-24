//
//  LepraSwipeViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 23.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraSwipeViewController.h"
#import "LepraPostDetailCommentsViewController.h"

@interface LepraSwipeViewController () <MGSwipeTabBarControllerDelegate>

@property (strong, nonatomic) UIView *topSelectorView;
@property (strong, nonatomic) UIView *currentViewSelector;

@end

@implementation LepraSwipeViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (self.navigationController.viewControllers.count==1) {
		[self addMenuButtonWithColor:[UIColor whiteColor]];
	}
	
	[self.view setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	
//	[self performSelector:@selector(configureTopSelector) withObject:nil afterDelay:0.01];
	[self configureTopSelector];
	
	CGRect selectorRect = self.currentViewSelector.frame;
	selectorRect.origin.x = self.selectedIndex * selectorRect.size.width;
	[UIView animateWithDuration:0.2 animations:^{
		self.currentViewSelector.frame = selectorRect;
	}];
}

- (void)configureTopSelector
{
	self.topSelectorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height + self.navigationController.navigationBar.frame.origin.y, self.navigationController.view.frame.size.width, 50.0)];
	[self.topSelectorView setBackgroundColor:[LepraGeneralHelper redColorLight]];
	
	self.currentViewSelector = [[UIView alloc] initWithFrame:CGRectMake(0, self.topSelectorView.frame.size.height-5.0, self.topSelectorView.frame.size.width/self.viewControllers.count, 5.0)];
	[self.currentViewSelector setBackgroundColor:[UIColor whiteColor]];
	[self.topSelectorView addSubview:self.currentViewSelector];
	[self.navigationController.view addSubview:self.topSelectorView];
	
	for (UIViewController *vc in self.viewControllers) {
		UIButton *titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
		[titleButton setTitle:vc.title forState:UIControlStateNormal];
		[titleButton setTintColor:[UIColor whiteColor]];
		[titleButton addTarget:self action:@selector(selectVC:) forControlEvents:UIControlEventTouchUpInside];
		[titleButton setFrame:CGRectMake(self.currentViewSelector.frame.size.width * [self.viewControllers indexOfObject:vc], 0, self.currentViewSelector.frame.size.width, 45.0)];
		[self.topSelectorView addSubview:titleButton];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.topSelectorView removeFromSuperview];
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

- (void)selectVC:(UIButton*)sender
{
	NSInteger index = (sender.frame.origin.x + 1) / self.currentViewSelector.frame.size.width;
	[self setSelectedIndex:index animated:YES];
}

#pragma mark - MGSwipeTabBarController

- (void) swipeTabBarController:(MGSwipeTabBarController *)swipeTabBarController willScrollToIndex:(NSInteger)toIndex fromIndex:(NSInteger)fromIndex {
	if (toIndex<0) {
		return;
	}
	if (toIndex==self.viewControllers.count) {
		toIndex = self.viewControllers.count-1;
	}
	CGRect selectorRect = self.currentViewSelector.frame;
	selectorRect.origin.x = toIndex * selectorRect.size.width;
	[UIView animateWithDuration:0.2 animations:^{
		self.currentViewSelector.frame = selectorRect;
	}];
}
- (void)swipeTabBarController:(MGSwipeTabBarController *)swipeTabBarController panning:(CGFloat)pan
{
	if (pan<0) {
		[self.viewDeckController openLeftViewAnimated:YES];
		[self setSelectedIndex:0 animated:NO];
	}
}

@end
