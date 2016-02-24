//
//  LepraMenuViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraMenuViewController.h"
#import "LepraMenuProfileCell.h"
#import "LepraMenuElementCell.h"
#import "LepraMenuGertrudaCell.h"
#import "LepraMenuHeaderCell.h"

#import "LepraUnderground.h"

@interface LepraMenuViewController ()

@property (strong, nonatomic) NSMutableArray *dataSource;

@end

@implementation LepraMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//	if ([[DEFAULTS_OBJ(DEF_KEY_LOGIN_EMAIL) lowercaseString] isEqualToString:@"jim_di"]) {
//		self.dataSource = @[kMenuItemKeyProfile, kMenuItemKeyPrefs, kMenuItemKeyAbout, kMenuItemKeyLogout];
//	} else {
//		self.dataSource = @[kMenuItemKeyProfile, kMenuItemKeyMyThings, kMenuItemKeyFavourites, kMenuItemKeyInbox, kMenuItemKeyUnderground, kMenuItemKeyPrefs, kMenuItemKeyAbout, kMenuItemKeyLogout];
//	}

	[self fillData];
	
	[self.tableView reloadData];
	
	[self.menuDelegate menuControllerPickedMenuItemKey:self.dataSource[1]];
	
	self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50.0)];
//	self.tableView.tableFooterView.frame = CGRectMake(0, 0, 0, 50.0);
	
	[self.tableView setSeparatorColor:[[LepraGeneralHelper redColor] colorWithAlphaComponent:0.5]];
	
	[self.tableView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
	[self.view setBackgroundColor:[LepraGeneralHelper redColorLight]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self fillData];
	[self refreshView];
}

- (void)setTableView:(UITableView *)tableView
{
	[super setTableView:tableView];
	self.tableView.scrollsToTop = NO;
}

- (void)fillData
{
	self.dataSource = [[NSMutableArray alloc] init];
	[self.dataSource addObject:kMenuItemKeyProfile];
	[self.dataSource addObject:kMenuItemKeyMyThings];
	[self.dataSource addObject:kMenuItemKeyFavourites];
	[self.dataSource addObject:kMenuItemKeyInbox];
	[self.dataSource addObject:kMenuItemKeyUnderground];
	
	
	NSDictionary *favoritesUnergrounds = DEFAULTS_OBJ(DEF_KEY_MENU_UNDERGROUNDS);
	NSArray *favoritesUnergroundsTitles = favoritesUnergrounds[kUndergroundItemKeyLink];
	
	if (![LepraGeneralHelper isEmpty:favoritesUnergroundsTitles]) {
		[self.dataSource addObject:kMenuItemKeyHeader];
		
		for (NSString* title in favoritesUnergroundsTitles) {
			[self.dataSource addObject:title];
		}
		
		[self.dataSource addObject:kMenuItemKeyHeader];
	}
	
	[self.dataSource addObject:kMenuItemKeyPrefs];
	[self.dataSource addObject:kMenuItemKeyAbout];
	[self.dataSource addObject:kMenuItemKeyLogout];
}

//-----------------------------------------------------------------------------------------------------
#pragma mark - Table view methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.y<0) {
		[scrollView setContentOffset:CGPointZero];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dataSource.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==0) {
		return [LepraMenuGertrudaCell cellHeight];
	} else if (indexPath.row==1) {
		return [LepraMenuProfileCell cellHeight];
	} else {
		if ([self.dataSource[indexPath.row-1] isEqualToString:kMenuItemKeyHeader]) {
			return [LepraMenuHeaderCell cellHeight];
		} else {
			return [LepraMenuElementCell cellHeight];
		}
	}
}

static NSDictionary *__reuseIds;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==0) {
		LepraMenuGertrudaCell *gertrudaCell = [self.tableView dequeueReusableCellWithIdentifier:[LepraMenuGertrudaCell cellIdentifier]];
		[gertrudaCell setGertruda:DEFAULTS_OBJ(GERTRUDA_LINK) tagline:DEFAULTS_OBJ(TAGLINE_TEXT)];
		return gertrudaCell;
	} else if (indexPath.row==1) {
		LepraMenuProfileCell *profileCell = [self.tableView dequeueReusableCellWithIdentifier:[LepraMenuProfileCell cellIdentifier]];
		[profileCell setName:DEFAULTS_OBJ(DEF_KEY_USER)[@"login"]];
		return profileCell;
	} else {
		NSString* key = self.dataSource[indexPath.row-1];
		if ([key isEqualToString:kMenuItemKeyHeader]) {
			LepraMenuHeaderCell *headerCell = [self.tableView dequeueReusableCellWithIdentifier:[LepraMenuHeaderCell cellIdentifier]];
			return headerCell;
		} else {
			LepraMenuElementCell *elementCell = [self.tableView dequeueReusableCellWithIdentifier:[LepraMenuElementCell cellIdentifier]];
			[elementCell setMenuItemKey:key];
			
			if ([key isEqualToString:kMenuItemKeyMyThings]) {
				[elementCell setCount:DEFAULTS_OBJ(MY_THINGS_COUNT)];
			} else if ([key isEqualToString:kMenuItemKeyInbox]) {
				[elementCell setCount:DEFAULTS_OBJ(INBOX_COUNT)];
			} else {
				[elementCell setCount:nil];
			}
			return elementCell;
		}
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==0) {
		[self.menuDelegate menuControllerPickedMenuItemKey:kMenuItemKeyMain];
	} else if (indexPath.row!=self.dataSource.count) {
		NSString* key = self.dataSource[indexPath.row-1];
		if (![key isEqualToString:kMenuItemKeyHeader]) {
			[self.menuDelegate menuControllerPickedMenuItemKey:self.dataSource[indexPath.row-1]];
		}
	} else {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self logoutTap];
	}
}

//-----------------------------------------------------------------------------------------------------
#pragma mark - Refreshing view

- (void)refreshView
{
	NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
	if ([LepraGeneralHelper isNull:selectedIndexPath]) {
		selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	}
	[self.tableView reloadData];
	@try {
		[self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
	@catch (NSException *exception) { }
}

//-----------------------------------------------------------------------------------------------------
#pragma mark - User actions

- (void)logoutTap
{
	// MAKE SURE USER WANTS TO LOGOUT
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Действительно хотите покинуть убежище?"
														message:@"Ну правда..."
													   delegate:self
											  cancelButtonTitle:@"Не уйду никогда!"
											  otherButtonTitles:@"Уйти", nil];
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0: { // cancel
			break;
		}
		case 1: { // logout confirmed
//			[[DOAPIManager sharedManager] logout];
			[[LepraContainerViewController sharedContainer] logoutAnimated:YES];
		}
	}
}

@end
