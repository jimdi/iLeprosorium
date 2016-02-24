//
//  LepraFeedPrefsViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 19.04.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraFeedPrefsViewController.h"
#import "LepraPrefsToggleCell.h"
#import <MZFormSheetController.h>

@interface LepraFeedPrefsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray* feedTypeArray;
@property (strong, nonatomic) NSString* selectedFeedType;
@property (strong, nonatomic) NSArray* feedTresholdArray;
@property (strong, nonatomic) NSString* selectedFeedTreshold;

@property (nonatomic) BOOL mainPage;
@property (nonatomic) BOOL myThings;
@property (nonatomic) BOOL favourite;
@property (strong, nonatomic) NSArray* sortArray;
@property (strong, nonatomic) NSString* selectedSort;

@property (strong, nonatomic) NSArray* periodArray;
@property (strong, nonatomic) NSString* selectedPeriod;

@property (strong, nonatomic) NSArray* unreadArray;
@property (strong, nonatomic) NSString* selectedUnread;
@end

@implementation LepraFeedPrefsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.mainPage = [self.pageLink isEqualToString:MAIN_PAGE_LINK];
	self.myThings = [self.pageLink isEqualToString:@"my_things"];
	self.favourite = [self.pageLink isEqualToString:@"favourite"];
	
	if (self.favourite) {
		self.selectedSort = DEFAULTS_OBJ(DEF_KEY_FAVOURITE_SORT);
		self.sortArray = @[@"0", @"1"];
		
		self.selectedSort = [LepraGeneralHelper coalesce:self.selectedSort with:@"0"];
	} else if (self.myThings) {
		NSDictionary* myThingsParams = DEFAULTS_OBJ(DEF_KEY_MY_THINGS_DICT);
		if ([LepraGeneralHelper isNull:myThingsParams]) {
			myThingsParams = [[NSDictionary alloc] init];
		}
		
		self.selectedSort = myThingsParams[kMyThingsDictSort];
		self.sortArray = @[@"0", @"1"];
		self.selectedSort = [LepraGeneralHelper coalesce:self.selectedSort with:@"0"];
		
		self.selectedPeriod = myThingsParams[kMyThingsDictPeriod];
		self.periodArray = @[@"1", @"3", @"7", @"14", @"30"];
		self.selectedPeriod = [LepraGeneralHelper coalesce:self.selectedPeriod with:@"30"];
		
		self.selectedUnread = myThingsParams[kMyThingsDictUnread];
		self.unreadArray = @[@"0", @"1"];
		self.selectedUnread = [LepraGeneralHelper coalesce:self.selectedUnread with:@"0"];
		
	} else {
		self.selectedFeedTreshold = DEFAULTS_OBJ(DEF_KEY_TRESHOLD_DICT)[self.pageLink];
		if (self.mainPage) {
			// type =	"mixed"
			//			"main"
			//			"personal"
			// treshold =	"disabled"	// NIGHTMARE (ВСЁ)
			//				"0"			// HARDCORE
			//				"50"		// HARD
			//				"250"		// NORMAL
			//				"500"		// MEDIUM
			//				"1000"		// EASY
			
			self.feedTypeArray = @[@"main", @"mixed", @"personal"];
			self.feedTresholdArray = @[@"1000", @"500", @"250", @"50", @"0", @"disabled"];
			
			self.selectedFeedTreshold = [LepraGeneralHelper coalesce:self.selectedFeedTreshold with:@"250"];
			self.selectedFeedType = DEFAULTS_OBJ(DEF_KEY_MAIN_PAGE_TYPE);
			self.selectedFeedType = [LepraGeneralHelper coalesce:self.selectedFeedType with:@"main"];
		} else {
			// treshold =	"disabled"	// NIGHTMARE (ВСЁ)
			//				"-25"		// HARDCORE
			//				"-5"		// HARD
			//				"0"			// NORMAL
			//				"5"			// MEDIUM
			//				"25"		// EASY
			
			self.feedTypeArray = @[];
			self.feedTresholdArray = @[@"25", @"5", @"0", @"-5", @"-25", @"disabled"];
			
			self.selectedFeedTreshold = [LepraGeneralHelper coalesce:self.selectedFeedTreshold with:@"0"];
		}
	}
	
	[self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	self.tableView.layer.cornerRadius = 6.0;
	[self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self.delegate needReloadFeed];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if (self.favourite) {
		return 1;
	} else if (self.myThings) {
		return 3;
	} else if (self.mainPage) {
		return 2;
	} else {
		return 1;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.favourite) {
		return self.sortArray.count;
	} else if (self.myThings) {
		if (section == 0) {
			return self.sortArray.count;
		} else if (section == 1) {
			return self.periodArray.count;
		} else {
			return self.unreadArray.count;
		}
	} else if (self.mainPage) {
		if (section==0) {
			return self.feedTypeArray.count;
		} else {
			return self.feedTresholdArray.count;
		}
	} else {
		return self.feedTresholdArray.count;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LepraPrefsToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraPrefsToggleCell cellIdentifier]];
	if (self.favourite) {
		NSString *sortType = self.sortArray[indexPath.row];
		NSString *title;
		if ([sortType isEqualToString:@"0"]) {
			title = @"По дате поста";
		} else {
			title = @"По дате добавления";
		}
		[cell setOn:[sortType isEqualToString:self.selectedSort] text:title];
	} else if (self.myThings) {
		if (indexPath.section==0) {
			NSString *sortType = self.sortArray[indexPath.row];
			NSString *title;
			if ([sortType isEqualToString:@"0"]) {
				title = @"По времени";
			} else {
				title = @"По последним комментариям";
			}
			[cell setOn:[sortType isEqualToString:self.selectedSort] text:title];
		} else if (indexPath.section==1) {
			NSString *periodType = self.periodArray[indexPath.row];
			NSString *title;
			if ([periodType isEqualToString:@"1"]) {
				title = @"Сутки";
			} else if ([periodType isEqualToString:@"3"]) {
				title = @"Трое суток";
			} else if ([periodType isEqualToString:@"7"]) {
				title = @"Неделя";
			} else if ([periodType isEqualToString:@"14"]) {
				title = @"Две недели";
			} else {
				title = @"Месяц";
			}
			[cell setOn:[periodType isEqualToString:self.selectedPeriod] text:title];
		} else {
			NSString *unreadType = self.unreadArray[indexPath.row];
			NSString *title;
			if ([unreadType isEqualToString:@"0"]) {
				title = @"Все посты и комментарии";
			} else {
				title = @"Только новые";
			}
			[cell setOn:[unreadType isEqualToString:self.selectedUnread] text:title];
		}
	} else if (self.mainPage) {
		if (indexPath.section==0) {
			NSString *feedType = self.feedTypeArray[indexPath.row];
			NSString *title;
			if ([feedType isEqualToString:@"main"]) {
				title = @"Только главная";
			} else if ([feedType isEqualToString:@"mixed"]) {
				title = @"Главная и подлепры";
			} else {
				title = @"Только подлепры";
			}
			[cell setOn:[feedType isEqualToString:self.selectedFeedType] text:title];
		} else {
			NSString *feedTreshold = self.feedTresholdArray[indexPath.row];
			NSString *title;
			if (indexPath.row==0) {
				title = @"EASY (1000+)";
			} else if (indexPath.row==1) {
				title = @"MEDIUM (500)";
			} else if (indexPath.row==2) {
				title = @"NORMAL (250)";
			} else if (indexPath.row==3) {
				title = @"HARD (50)";
			} else if (indexPath.row==4) {
				title = @"HARDCORE (0)";
			} else {
				title = @"NIGHTMARE (ВСЁ)";
			}
			[cell setOn:[feedTreshold isEqualToString:self.selectedFeedTreshold] text:title];
		}
	} else {
		NSString *feedTreshold = self.feedTresholdArray[indexPath.row];
		NSString *title;
		if (indexPath.row==0) {
			title = @"EASY (25+)";
		} else if (indexPath.row==1) {
			title = @"MEDIUM (5)";
		} else if (indexPath.row==2) {
			title = @"NORMAL (0)";
		} else if (indexPath.row==3) {
			title = @"HARD (-5)";
		} else if (indexPath.row==4) {
			title = @"HARDCORE (-25)";
		} else {
			title = @"NIGHTMARE (ВСЁ)";
		}
		[cell setOn:[feedTreshold isEqualToString:self.selectedFeedTreshold] text:title];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.favourite) {
		self.selectedSort = self.sortArray[indexPath.row];
		[DEFAULTS setObject:self.selectedSort forKey:DEF_KEY_FAVOURITE_SORT];
	} else if (self.myThings) {
		NSDictionary* myThingsParams = DEFAULTS_OBJ(DEF_KEY_MY_THINGS_DICT);
		if ([LepraGeneralHelper isNull:myThingsParams]) {
			myThingsParams = [[NSDictionary alloc] init];
		}
		NSMutableDictionary *mutableMyThingsDict = [myThingsParams mutableCopy];
		if (indexPath.section == 0) {
			self.selectedSort = self.sortArray[indexPath.row];
			[mutableMyThingsDict setObject:self.selectedSort forKey:kMyThingsDictSort];
		} else if (indexPath.section == 1) {
			self.selectedPeriod = self.periodArray[indexPath.row];
			[mutableMyThingsDict setObject:self.selectedPeriod forKey:kMyThingsDictPeriod];
		} else {
			self.selectedUnread = self.unreadArray[indexPath.row];
			[mutableMyThingsDict setObject:self.selectedUnread forKey:kMyThingsDictUnread];
		}
		myThingsParams = mutableMyThingsDict;
		[DEFAULTS setObject:myThingsParams forKey:DEF_KEY_MY_THINGS_DICT];
	} else if (self.mainPage && indexPath.section==0) {
		self.selectedFeedType = self.feedTypeArray[indexPath.row];
		[DEFAULTS setObject:self.selectedFeedType forKey:DEF_KEY_MAIN_PAGE_TYPE];
	} else {
		self.selectedFeedTreshold = self.feedTresholdArray[indexPath.row];
		NSMutableDictionary* mutableDict = [DEFAULTS_OBJ(DEF_KEY_TRESHOLD_DICT) mutableCopy];
		if ([LepraGeneralHelper isNull:mutableDict]) {
			mutableDict = [[NSMutableDictionary alloc] init];
		}
		[mutableDict setObject:self.selectedFeedTreshold forKey:self.pageLink];
		[DEFAULTS setObject:[mutableDict copy] forKey:DEF_KEY_TRESHOLD_DICT];
	}
	[DEFAULTS synchronize];
	[tableView reloadData];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (IBAction)closeButtonTap:(id)sender {
	[self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

@end
