//
//  LepraUndergroundViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraUndergroundViewController.h"
#import <TFHpple.h>
#import "LepraUndergroundCell.h"
#import <AFHTTPRequestOperation.h>

#import "LepraUnderground.h"

#import "LepraMainPagePostsViewController.h"

#import "LepraProfileViewController.h"
#import "LepraProfilePostsViewController.h"
#import "LepraProfileCommentsViewController.h"
#import "LepraSwipeViewController.h"

@interface LepraUndergroundViewController () <LepraUndergroundCellDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) LepraLoadMoreView *loadMoreView;

@property (nonatomic) BOOL allLoaded;
@property (nonatomic) BOOL secondTryLoadMore;

@property (strong, nonatomic) NSMutableArray *domains;
@property (strong, nonatomic) NSMutableArray *filteredDomains;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation LepraUndergroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
	
	self.title = @"Блоги империи";
	
	if (self.navigationController.viewControllers.count==1) {
		[self addMenuButton];
	}
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(updateUnderground) forControlEvents:UIControlEventValueChanged];
	
	[self.tableView addSubview:self.refreshControl];
	
	[self.tableView setTableFooterView:[UIView new]];
	[self.tableView.tableFooterView setFrame:CGRectZero];
	
	self.loadMoreView = [LepraLoadMoreView loadFromNib];
	[self.loadMoreView stopLoad];
	self.secondTryLoadMore = NO;
	
	onceToken = 0;
	
	[self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	[self.view setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	[self.refreshControl setTintColor:[UIColor whiteColor]];
	[self.refreshControl setBackgroundColor:[LepraGeneralHelper blueColor]];
	[self.searchBar setHidden:YES];
	[self.searchBar setBackgroundImage:[LepraGeneralHelper imageWithColor:[LepraGeneralHelper blueColor]] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[self.searchBar setTintColor:[LepraGeneralHelper blueColor]];
	[self.searchDisplayController.searchResultsTableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	[self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	[self.searchBar setDelegate:self];
	
	UIView *hackView = [[UIView alloc] initWithFrame:CGRectMake(0, -2000, self.view.frame.size.width, 2000)];
	UIView *searchHackView = [[UIView alloc] initWithFrame:CGRectMake(0, -20.0, self.view.frame.size.width, 20.0)];
	[hackView setBackgroundColor:[LepraGeneralHelper blueColor]];
	[searchHackView setBackgroundColor:[LepraGeneralHelper blueColor]];
	[self.tableView insertSubview:hackView atIndex:0];
	[self.view addSubview:searchHackView];
}

static dispatch_once_t onceToken;

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self configureNavigationBarWithColor:[LepraGeneralHelper blueColor] titleColor:[UIColor whiteColor]];
	dispatch_once(&onceToken, ^{
		[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
		[self.refreshControl beginRefreshing];
		[self updateUnderground];
	});
}

- (void)updateUnderground
{
	self.allLoaded = NO;
	[self updateUnderground:0];
}

- (void)updateUnderground:(NSInteger)offset
{
	if (!self.allLoaded) {
		[self.loadMoreView startLoad];
		[[LepraHTTPClient sharedClient] setDefaultHeader:@"Accept" value:@"text/hmtl"];
		[[LepraHTTPClient sharedClient] postPath:@"ajax/blogs/top" parameters:@{@"offset":@(offset), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
			if (offset==0) {
				self.domains = [[NSMutableArray alloc] init];
			}
			NSDictionary *object = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
			[self parseDomains:object forArray:self.domains];
			[self.searchBar setHidden:NO];
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"FAIL");
			[self.refreshControl endRefreshing];
			[self.loadMoreView stopLoad];
		}];
	}
}

- (void)parseDomains:(NSDictionary*)object forArray:(NSMutableArray*)array
{
	TFHpple *domainsPage;
	if (object[@"template"]) {
		domainsPage = [TFHpple hppleWithHTMLData:[object[@"template"] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	if (object[@"domains"]) {
		NSArray* domains = object[@"domains"];
		for (NSDictionary* domain in domains) {
			LepraUnderground* undergroundObject = [[LepraUnderground alloc] init];
			undergroundObject.logoLink = [LepraGeneralHelper coalesce:domain[@"attributes"][@"logo"] with:@""];
			NSString *title = domain[@"name"];
			if (![LepraGeneralHelper isEmpty:title]) {
				undergroundObject.title = title;
			} else {
				undergroundObject.title = @"Какой-то noname клуб";
			}
			undergroundObject.link = [LepraGeneralHelper coalesce:domain[@"url"] with:@""];
			undergroundObject.authorUserName = [LepraGeneralHelper coalesce:domain[@"owner"][@"login"] with:@""];
			undergroundObject.ownerTitle = domain[@"attributes"][@"domain_owner_title"];
			while ([undergroundObject.ownerTitle hasSuffix:@" "]) {
				undergroundObject.ownerTitle = [undergroundObject.ownerTitle substringToIndex:undergroundObject.ownerTitle.length-1];
			}
			if ([LepraGeneralHelper isEmpty:undergroundObject.ownerTitle]) {
				undergroundObject.ownerTitle = @"Хозяин";
			}
			undergroundObject.ownerTitle = [undergroundObject.ownerTitle stringByAppendingString:@":"];
			if ([domain[@"subscribed"] integerValue]==1) {
				undergroundObject.inMain = @(YES);
			} else {
				undergroundObject.inMain = @(NO);
			}
			undergroundObject.domainId = [domain[@"id"] stringValue];
			if (![LepraGeneralHelper isNull:domain[@"marked_as_adult"]]) {
				undergroundObject.adult = @([domain[@"marked_as_adult"] boolValue]);
			} else {
				undergroundObject.adult = @(NO);
			}
			
			NSArray *myThingsToggles = [domainsPage searchWithXPathQuery:[NSString stringWithFormat:@"//*[@id='js-blogs_list_controls_interests_%@']", undergroundObject.domainId]];
			if (myThingsToggles.count>0) {
				TFHppleElement *myThingsToggle = [myThingsToggles firstObject];
				if ([myThingsToggle.attributes[@"checked"] isEqualToString:@"checked"]) {
					undergroundObject.inMyThings = @(YES);
				} else {
					undergroundObject.inMyThings = @(NO);
				}
			} else {
				undergroundObject.inMyThings = @(NO);
			}
			[array addObject:undergroundObject];
		}
		[self.refreshControl endRefreshing];
		[self.tableView reloadData];
		[self.loadMoreView stopLoad];
	} else {
		[self.refreshControl endRefreshing];
		[self.loadMoreView allLoaded];
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if ([tableView isEqual:self.tableView]) {
		return self.domains.count + 1;
	} else {
		return self.filteredDomains.count;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([tableView isEqual:self.tableView]) {
		if (section<self.domains.count) {
			return 1;
		} else {
			return 0;
		}
	} else {
		return 1;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [LepraUndergroundCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LepraUnderground* domain;
	if ([tableView isEqual:self.tableView]) {
		domain = self.domains[indexPath.section];
	} else {
		domain = self.filteredDomains[indexPath.section];
	}
	LepraUndergroundCell* cell = [self.tableView dequeueReusableCellWithIdentifier:[LepraUndergroundCell cellIdentifier]];
	[cell setDomain:domain];
	[cell setCellDelegate:self];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	LepraUnderground* domain;
	if ([tableView isEqual:self.tableView]) {
		domain = self.domains[indexPath.section];
	} else {
		domain = self.filteredDomains[indexPath.section];
	}
	LepraMainPagePostsViewController *pageVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraMainPagePostsViewController storyboardID]];
	pageVC.pageLink = domain.link;
	[self.navigationController pushViewController:pageVC animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if ([tableView isEqual:self.tableView]) {
		if (section == self.domains.count) {
			if (self.secondTryLoadMore) {
				[self updateUnderground:self.domains.count];
				if (self.allLoaded) {
					[self.loadMoreView allLoaded];
				}
				return self.loadMoreView;
			} else {
				self.secondTryLoadMore = YES;
				UIView *emptyView = [[UIView alloc] init];
				[emptyView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
				return emptyView;
			}
		}
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if ([tableView isEqual:self.tableView]) {
		if (section == self.domains.count) {
			return 30.0;
		}
	}
	return 5.0;
}

- (void)cellAskForOpenProfile:(NSString*)userName
{
	LepraProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfileViewController storyboardID]];
	profileVC.userName = userName;
	LepraProfilePostsViewController *profilePostsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfilePostsViewController storyboardID]];
	profilePostsVC.userName = userName;
	LepraProfileCommentsViewController *profileCommentsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfileCommentsViewController storyboardID]];
	profileCommentsVC.userName = userName;
	
	LepraSwipeViewController *swipeController = [[LepraSwipeViewController alloc] initWithViewControllers:@[profileVC, profilePostsVC, profileCommentsVC]];
	swipeController.title = userName;
	[self.navigationController pushViewController:swipeController animated:YES];
}

- (void)cellAskForSubscribe:(LepraUnderground*)domain
{
	if (domain.inMain.boolValue) {
		[[LepraAPIManager sharedManager] unsubscribeDomainId:domain.domainId success:^{
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			domain.inMain = @(!domain.inMain.boolValue);
			[self.tableView reloadData];
		}];
	} else {
		[[LepraAPIManager sharedManager] subscribeDomainId:domain.domainId success:^{
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			domain.inMain = @(!domain.inMain.boolValue);
			[self.tableView reloadData];
		}];
	}
	domain.inMain = @(!domain.inMain.boolValue);
	[self.tableView reloadData];
}

- (void)cellAskForSubscribeMyThings:(LepraUnderground*)domain
{
	if (domain.inMyThings.boolValue) {
		[[LepraAPIManager sharedManager] unsubscribeMyThingsDomainId:domain.domainId success:^{
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			domain.inMyThings = @(!domain.inMyThings.boolValue);
			[self.tableView reloadData];
		}];
	} else {
		[[LepraAPIManager sharedManager] subscribeMyThingsDomainId:domain.domainId success:^{
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			domain.inMyThings = @(!domain.inMyThings.boolValue);
			[self.tableView reloadData];
		}];
	}
	domain.inMyThings = @(!domain.inMyThings.boolValue);
	[self.tableView reloadData];
}

- (void)cellAskForLeftMenu:(LepraUnderground *)domain
{
	NSDictionary *favoritesUnergrounds = DEFAULTS_OBJ(DEF_KEY_MENU_UNDERGROUNDS);
	if (!favoritesUnergrounds) {
		favoritesUnergrounds = [[NSDictionary alloc] init];
	}
	NSMutableDictionary* mutableFavoritesUnergrounds = [favoritesUnergrounds mutableCopy];
	NSMutableArray *images = [mutableFavoritesUnergrounds[kUndergroundItemKeyImageLink] mutableCopy];
	NSMutableArray *links = [mutableFavoritesUnergrounds[kUndergroundItemKeyLink] mutableCopy];
	if (!images) {
		images = [[NSMutableArray alloc] init];
	}
	if (!links) {
		links = [[NSMutableArray alloc] init];
	}
	if ([links containsObject:domain.link]) {
		NSInteger index = [links indexOfObject:domain.link];
		[links removeObjectAtIndex:index];
		[images removeObjectAtIndex:index];
	} else {
		[links addObject:domain.link];
		[images addObject:domain.logoLink];
	}
	[mutableFavoritesUnergrounds setObject:links forKey:kUndergroundItemKeyLink];
	[mutableFavoritesUnergrounds setObject:images forKey:kUndergroundItemKeyImageLink];
	[DEFAULTS setObject:mutableFavoritesUnergrounds forKey:DEF_KEY_MENU_UNDERGROUNDS];
	[DEFAULTS synchronize];
	[self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[[LepraAPIManager sharedManager] searchUndergroundWithQuery:searchBar.text success:^(NSDictionary *domains) {
		self.filteredDomains = [[NSMutableArray alloc] init];
		[self parseDomains:domains forArray:self.filteredDomains];
		[self.searchDisplayController.searchResultsTableView reloadData];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

@end
