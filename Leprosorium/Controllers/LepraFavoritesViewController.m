//
//  LepraFavoritesViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 30.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraFavoritesViewController.h"
#import "LepraFeedPrefsViewController.h"
#import <MZFormSheetController.h>

@interface LepraFavoritesViewController() <LepraFeedPrefsViewControllerDelegate>

@end

@implementation LepraFavoritesViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Избранное";
	
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_item_prefs"] style:UIBarButtonItemStylePlain target:self action:@selector(feedPrefsTap)]];
}

- (void)needReloadFeed
{
	[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
	[self.refreshControl beginRefreshing];
	[self updatePosts];
}

- (void)updatePosts
{
	NSString *sort = DEFAULTS_OBJ(DEF_KEY_FAVOURITE_SORT);
	sort = [LepraGeneralHelper coalesce:sort with:@"0"];
	[[LepraHTTPClient sharedClient] setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[[LepraHTTPClient sharedClient] postPath:@"ajax/favourites/list" parameters:@{@"offset":@([sort integerValue]), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN), @"sort":@(0)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		self.posts = [[NSMutableArray alloc] init];
		NSDictionary *object = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
		NSString* html = object[@"template"];
		if (![LepraGeneralHelper isEmpty:html]) {
			if ([html rangeOfString:@"b-no_posts"].location==NSNotFound) {
				[self parsePostsPage:object[@"template"]];
			} else {
				[self.loadMoreView allLoaded];
				self.allLoaded = YES;
			}
		}
		[self.refreshControl endRefreshing];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"FAIL");
		[self.refreshControl endRefreshing];
		[self.loadMoreView stopLoad];
	}];
}

- (void)loadMorePosts
{
	if (!self.allLoaded && self.secondTryLoadMore) {
		self.page++;
		[self.loadMoreView startLoad];
		NSString *sort = DEFAULTS_OBJ(DEF_KEY_FAVOURITE_SORT);
		sort = [LepraGeneralHelper coalesce:sort with:@"0"];
		[[LepraHTTPClient sharedClient] setDefaultHeader:@"Accept" value:@"text/hmtl"];
		[[LepraHTTPClient sharedClient] postPath:@"ajax/favourites/list" parameters:@{@"offset":@(self.posts.count), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN), @"sort":@([sort integerValue])} success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSDictionary *object = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
			NSString* html = object[@"template"];
			if (![LepraGeneralHelper isEmpty:html]) {
				if ([html rangeOfString:@"b-no_posts"].location==NSNotFound) {
					[self parsePostsPage:object[@"template"]];
				} else {
					[self.loadMoreView allLoaded];
					self.allLoaded = YES;
				}
			}
			[self.loadMoreView stopLoad];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if (operation.response.statusCode == 404) {
				[self.loadMoreView allLoaded];
				self.allLoaded = YES;
			}
		}];
	}
}

- (void)feedPrefsTap {
	LepraFeedPrefsViewController *prefsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraFeedPrefsViewController storyboardID]];
	prefsVC.delegate = self;
	prefsVC.pageLink = @"favourite";
	MZFormSheetController* registrationVCSheet = [[MZFormSheetController alloc] initWithViewController:prefsVC];
	[registrationVCSheet setShouldDismissOnBackgroundViewTap:YES];
	[registrationVCSheet setShouldCenterVertically:YES];
	[registrationVCSheet setPresentedFormSheetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40.0, 330)];
	[self mz_presentFormSheetController:registrationVCSheet animated:YES completionHandler:nil];
}

@end
