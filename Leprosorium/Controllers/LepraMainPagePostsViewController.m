//
//  LepraMainPagePostsViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraMainPagePostsViewController.h"
#import "LepraFeedPrefsViewController.h"
#import <MZFormSheetController.h>

@interface LepraMainPagePostsViewController () <LepraFeedPrefsViewControllerDelegate>

@end

@implementation LepraMainPagePostsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
//	if ([[DEFAULTS_OBJ(DEF_KEY_LOGIN_EMAIL) lowercaseString] isEqualToString:@"jim_di"]) {
//		self.pageLink = [LepraGeneralHelper coalesce:self.pageLink with:@"novice.leprosorium.ru"];
//	} else {
		self.pageLink = [LepraGeneralHelper coalesce:self.pageLink with:@"leprosorium.ru"];
//	}
	self.title = self.pageLink;
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_item_prefs"] style:UIBarButtonItemStylePlain target:self action:@selector(feedPrefsTap)]];
}

- (void)updatePosts
{
	self.page = 1;
	
	NSString *treshold = DEFAULTS_OBJ(DEF_KEY_TRESHOLD_DICT)[self.pageLink];
	
	if ([self.pageLink isEqualToString:MAIN_PAGE_LINK]) {
		treshold = [LepraGeneralHelper coalesce:treshold with:@"250"];
		NSString *mainPageFeedType = DEFAULTS_OBJ(DEF_KEY_MAIN_PAGE_TYPE);
		mainPageFeedType = [LepraGeneralHelper coalesce:mainPageFeedType with:@"main"];
		[[LepraAPIManager sharedManager] getPostsFromMainPage:self.page type:mainPageFeedType treshold:treshold success:^(NSString *postsPage) {
			self.posts = [[NSMutableArray alloc] init];
			[self parsePostsPage:postsPage];
			[self.refreshControl endRefreshing];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self.refreshControl endRefreshing];
		}];
	} else {
		treshold = [LepraGeneralHelper coalesce:treshold with:@"0"];
		[[LepraAPIManager sharedManager] getPostsFromPageLink:self.pageLink page:self.page treshold:treshold success:^(NSString *postsPage) {
			self.posts = [[NSMutableArray alloc] init];
			[self parsePostsPage:postsPage];
			[self.refreshControl endRefreshing];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			[self.refreshControl endRefreshing];
		}];
	}
}

- (void)loadMorePosts
{
	NSString *treshold = DEFAULTS_OBJ(DEF_KEY_TRESHOLD_DICT)[self.pageLink];
	if (!self.allLoaded && self.secondTryLoadMore) {
		self.page++;
		[self.loadMoreView startLoad];
		if ([self.pageLink isEqualToString:MAIN_PAGE_LINK]) {
			treshold = [LepraGeneralHelper coalesce:treshold with:@"250"];
			NSString *mainPageFeedType = DEFAULTS_OBJ(DEF_KEY_MAIN_PAGE_TYPE);
			mainPageFeedType = [LepraGeneralHelper coalesce:mainPageFeedType with:@"main"];
			[[LepraAPIManager sharedManager] getPostsFromMainPage:self.page type:mainPageFeedType treshold:treshold success:^(NSString *postsPage) {
				[self parsePostsPage:postsPage];
				[self.loadMoreView stopLoad];
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				if (operation.response.statusCode == 404) {
					[self.loadMoreView allLoaded];
					self.allLoaded = YES;
					self.page--;
				}
			}];
		} else {
			treshold = [LepraGeneralHelper coalesce:treshold with:@"0"];
			[[LepraAPIManager sharedManager] getPostsFromPageLink:self.pageLink page:self.page treshold:treshold success:^(NSString *postsPage) {
				[self parsePostsPage:postsPage];
				[self.loadMoreView stopLoad];
			} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				if (operation.response.statusCode == 404) {
					[self.loadMoreView allLoaded];
					self.allLoaded = YES;
					self.page--;
				}
			}];
		}
	}
}

- (void)feedPrefsTap {
	LepraFeedPrefsViewController *prefsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraFeedPrefsViewController storyboardID]];
	prefsVC.delegate = self;
	prefsVC.pageLink = self.pageLink;
	MZFormSheetController* registrationVCSheet = [[MZFormSheetController alloc] initWithViewController:prefsVC];
	[registrationVCSheet setShouldDismissOnBackgroundViewTap:YES];
	[registrationVCSheet setShouldCenterVertically:YES];
	[registrationVCSheet setPresentedFormSheetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40.0, 330)];
	[self mz_presentFormSheetController:registrationVCSheet animated:YES completionHandler:nil];
}

- (void)needReloadFeed
{
	[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
	[self.refreshControl beginRefreshing];
	[self updatePosts];
}

@end
