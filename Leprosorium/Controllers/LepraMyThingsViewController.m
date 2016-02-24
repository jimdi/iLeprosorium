//
//  LepraMyThingsViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 30.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraMyThingsViewController.h"
#import "LepraFeedPrefsViewController.h"
#import <MZFormSheetController.h>

@interface LepraMyThingsViewController () <LepraFeedPrefsViewControllerDelegate>

@end

@implementation LepraMyThingsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Мои вещи";
	
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
	NSDictionary *myThingsParams = DEFAULTS_OBJ(DEF_KEY_MY_THINGS_DICT);
	myThingsParams = [LepraGeneralHelper coalesce:myThingsParams with:[[NSDictionary alloc] init]];
	
	NSString *sort = myThingsParams[kMyThingsDictSort];
	sort = [LepraGeneralHelper coalesce:sort with:@"0"];
	
	NSString *period = myThingsParams[kMyThingsDictPeriod];
	period = [LepraGeneralHelper coalesce:period with:@"30"];
	
	NSString *unread = myThingsParams[kMyThingsDictUnread];
	unread = [LepraGeneralHelper coalesce:unread with:@"0"];
	
	[[LepraHTTPClient sharedClient] setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[[LepraHTTPClient sharedClient] postPath:@"ajax/interest/moar" parameters:@{@"offset":@(0), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN), @"sort":@([sort integerValue]), @"period":@([period integerValue]), @"unread":@([unread integerValue])} success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
		[[LepraHTTPClient sharedClient] setDefaultHeader:@"Accept" value:@"text/hmtl"];
		[[LepraHTTPClient sharedClient] postPath:@"ajax/interest/moar" parameters:@{@"offset":@(self.posts.count), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
	prefsVC.pageLink = @"my_things";
	MZFormSheetController* registrationVCSheet = [[MZFormSheetController alloc] initWithViewController:prefsVC];
	[registrationVCSheet setShouldDismissOnBackgroundViewTap:YES];
	[registrationVCSheet setShouldCenterVertically:YES];
	[registrationVCSheet setPresentedFormSheetSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40.0, 330)];
	[self mz_presentFormSheetController:registrationVCSheet animated:YES completionHandler:nil];
}

@end
