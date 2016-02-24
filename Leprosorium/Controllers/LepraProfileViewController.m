//
//  LepraProfileViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 10.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraProfileViewController.h"
#import <TFHpple.h>

#import "LepraProfileInfoCell.h"
#import "LepraProfileContactCell.h"
#import "LepraProfileUserTextCell.h"
#import "LepraProfileImageCell.h"
#import "UIViewController+MGSwipeTabBarController.h"
#import "LepraProfile.h"

@interface LepraProfileViewController () <LepraProfileImageCellDelegate, LepraProfileInfoCellDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) LepraProfile *profile;

//@property (strong, nonatomic) NSString *userpicLink;
//@property (strong, nonatomic) NSString *fullName;
//@property (strong, nonatomic) NSString *location;
//@property (strong, nonatomic) NSString *invitedBy;
//@property (strong, nonatomic) NSString *carma;
//
//@property (strong, nonatomic) NSString *posts;
//
//@property (strong, nonatomic) NSMutableArray *contactsTypes;
//@property (strong, nonatomic) NSMutableArray *contactsValues;
//
//@property (strong, nonatomic) NSMutableArray *userTextObjects;
//@property (strong, nonatomic) NSMutableArray *userTextLinks;
//@property (strong, nonatomic) TFHppleElement *userText;

@end

@implementation LepraProfileViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Профиль";
	
	
	if (self.navigationController.viewControllers.count==1) {
		[self addMenuButton];
	}
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl setTintColor:[UIColor blackColor]];
	[self.refreshControl addTarget:self action:@selector(updateProfile) forControlEvents:UIControlEventValueChanged];
	
	[self.tableView addSubview:self.refreshControl];
	
	[self.tableView setTableFooterView:[UIView new]];
	[self.tableView.tableFooterView setFrame:CGRectZero];

	onceToken = 0;
	
	[self registerCellForId:[LepraProfileUserTextCell cellIdentifier]];
	[self registerCellForId:[LepraProfileImageCell cellIdentifier]];
	
	self.profile = [[LepraProfile alloc] init];
	self.profile.userName = [LepraGeneralHelper coalesce:self.userName with:DEFAULTS_OBJ(DEF_KEY_USER)[@"login"]];
	
	[self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	[self.view setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

static dispatch_once_t onceToken;

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	dispatch_once(&onceToken, ^{
		[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
		[self.refreshControl beginRefreshing];
		[self updateProfile];
	});
}

- (void)updateProfile {
	[[LepraAPIManager sharedManager] getUserByUserName:self.profile.userName success:^(NSString *userPage) {
		[self parseUserPage:userPage];
		[self.refreshControl endRefreshing];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self.refreshControl endRefreshing];
	}];
}

- (void)parseUserPage:(NSString*)page {
	TFHpple *userPage = [TFHpple hppleWithHTMLData:[page dataUsingEncoding:NSUTF8StringEncoding]];
	
	//userID
	NSArray *userIdNodes = [userPage searchWithXPathQuery:@"//table[@class='b-user_name-table']//script"];
	if (userIdNodes.count>0) {
		TFHppleElement *userIdElement = [userIdNodes firstObject];
		NSString* userInfo = userIdElement.firstChild.content;
		NSRange idRange = [userInfo rangeOfString:@".init('"];
		if (idRange.location!=NSNotFound) {
			NSString* userId = [userInfo substringFromIndex:idRange.location + idRange.length];
			userId = [userId substringToIndex:[userId rangeOfString:@"'"].location];
			self.profile.userId = userId;
		}
	}
	
	//userpic
	NSArray *userpicNodes = [userPage searchWithXPathQuery:@"//table[@class='b-userpic']//img"];
	if (userpicNodes.count > 0) {
		TFHppleElement *userpicElement = [userpicNodes firstObject];
		self.profile.userpicLink = userpicElement.attributes[@"src"];
	}
	
	
	//fullname
	NSArray *fullnameNodes = [userPage searchWithXPathQuery:@"//*[@class='b-user_full_name']"];
	if (fullnameNodes.count > 0) {
		TFHppleElement *fullnameElement = [fullnameNodes firstObject];
		self.profile.fullName = fullnameElement.firstChild.content;
	}
	
	//location
	NSArray *locationNodes = [userPage searchWithXPathQuery:@"//*[@class='b-user_residence']"];
	if (locationNodes.count > 0) {
		TFHppleElement *locationElement = [locationNodes firstObject];
		NSString *location = locationElement.firstChild.content;
		location = locationElement.firstChild.content;
		location = [location stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		location = [location stringByReplacingOccurrencesOfString:@"\t" withString:@""];
		self.profile.location = location;
	}
	
	//invited
	NSArray *invitedNodes = [userPage searchWithXPathQuery:@"//*[@class='b-user_parent']//a"];
	if (invitedNodes.count > 0) {
		TFHppleElement *invitedElement = [invitedNodes firstObject];
		self.profile.invitedBy = invitedElement.firstChild.content;
	}
	
	//carma
	NSArray *carmaNodes = [userPage searchWithXPathQuery:@"//*[@class='b-karma_value_inner']"];
	if (carmaNodes.count > 0) {
		TFHppleElement *carmaElement = [carmaNodes firstObject];
		self.profile.carma = carmaElement.firstChild.content;
	}
	
	//carmaChangeButtons
	NSArray *carmaButtonNodes = [userPage searchWithXPathQuery:@"//*[contains(@class,'b-karma_button')]"];
	if (carmaButtonNodes.count>0) {
		for (TFHppleElement *carmaButton in carmaButtonNodes) {
			NSString* class = carmaButton.attributes[@"class"];
			BOOL active = [class rangeOfString:@"active"].location != NSNotFound;
			if ([class rangeOfString:@"b-karma_button__left_plus"].location != NSNotFound) {
				self.profile.leftPlusEnabled = @(active);
			}
			if ([class rangeOfString:@"b-karma_button__right_plus"].location != NSNotFound) {
				self.profile.rightPlusEnabled = @(active);
			}
			
			if ([class rangeOfString:@"b-karma_button__left_minus"].location != NSNotFound) {
				self.profile.leftMinusEnabled = @(active);
			}
			if ([class rangeOfString:@"b-karma_button__right_minus"].location != NSNotFound) {
				self.profile.rightMinusEnabled = @(active);
			}
		}
	}
	
	//posts
	NSArray *postsNodes = [userPage searchWithXPathQuery:@"//*[@class='b-user_stat']"];
	if (postsNodes.count > 0) {
		TFHppleElement *postsElement = [postsNodes firstObject];
		NSString *posts = @"";
		for (TFHppleElement *child in postsElement.children) {
			if (child.isTextNode) {
				posts = [posts stringByAppendingFormat:@" %@", child.content];
			}
			if (![LepraGeneralHelper isEmpty:child.attributes[@"href"]]) {
				posts = [posts stringByAppendingFormat:@" %@", child.firstChild.content];
			}
		}
		posts = [posts stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		posts = [posts stringByReplacingOccurrencesOfString:@"\t" withString:@""];
		posts = [posts stringByReplacingOccurrencesOfString:@" ." withString:@"."];
		posts = [posts stringByReplacingOccurrencesOfString:@"  " withString:@" "];
		if ([posts hasPrefix:@" "]) {
			posts = [posts substringFromIndex:1];
		}
		self.profile.posts = posts;
	}
	
	//contacts
	NSArray *contactsNodes = [userPage searchWithXPathQuery:@"//*[@class='b-user_contacts']"];
	if (contactsNodes.count > 0) {
		TFHppleElement *contactsElement = [contactsNodes firstObject];
		self.profile.contactsTypes = [[NSMutableArray alloc] init];
		self.profile.contactsValues = [[NSMutableArray alloc] init];
		for (TFHppleElement *child in contactsElement.children) {
			if (child.isTextNode) {
				NSString* contactType = child.content;
				contactType = [contactType stringByReplacingOccurrencesOfString:@"\n" withString:@""];
				contactType = [contactType stringByReplacingOccurrencesOfString:@"\t" withString:@""];
				if (![LepraGeneralHelper isEmpty:contactType]) {
					[self.profile.contactsTypes addObject:contactType];
				}
			} else if ([child.tagName isEqualToString:@"a"]) {
				[self.profile.contactsValues addObject:child];
			} else if ([child.tagName isEqualToString:@"br"]) {
				while (self.profile.contactsValues.count<self.profile.contactsTypes.count) {
					[self.profile.contactsValues addObject:@""];
				}
			}
		}
		while (self.profile.contactsValues.count<self.profile.contactsTypes.count) {
			[self.profile.contactsValues addObject:@""];
		}
	}
	
	//userText
	NSArray *userTextNodes = [userPage searchWithXPathQuery:@"//*[@class='b-user_text']"];
	if (userTextNodes.count > 0) {
		//		self.userText = [userTextNodes firstObject];
		
		[self prepareUserTextString:[userTextNodes firstObject]];
	}
	[self.tableView reloadData];
}

- (void)prepareUserTextString:(TFHppleElement*)userText
{
	self.profile.userTextObjects = [[NSMutableArray alloc] init];
	self.profile.userTextLinks = [[NSMutableArray alloc] init];
	NSMutableAttributedString* userString = [[NSMutableAttributedString alloc] init];
	NSMutableArray* userLinks = [[NSMutableArray alloc] init];
	[self addStringForUserString:userString links:userLinks forNode:userText];
	if (![LepraGeneralHelper isEmpty:userString.string] && ![userString.string isEqualToString:@"\n"]) {
		[self.profile.userTextObjects addObject:userString];
		[self.profile.userTextLinks addObject:[userLinks mutableCopy]];
	}
}

- (void)addStringForUserString:(NSMutableAttributedString*)userString links:(NSMutableArray*)links forNode:(TFHppleElement*)node
{
	UIFont *font;
	UIColor *fontColor = [UIColor blackColor];
	if ([node.tagName isEqualToString:@"b"]) {
		font = TEXT_FONT_BOLD;
	} else if ([node.tagName isEqualToString:@"i"] || [node.attributes[@"class"] isEqualToString:@"irony"]) {
		font = TEXT_FONT_ITALIC;
	} else {
		font = TEXT_FONT;
	}
	if ([node.attributes[@"class"] isEqualToString:@"irony"]) {
		fontColor = [UIColor redColor];
	}
	
	
	for (TFHppleElement *child in node.children) {
		if (child.isTextNode) {
			[userString appendAttributedString:[[NSAttributedString alloc] initWithString:[self clearNodeText:child.content] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
		} else if ([child.tagName isEqualToString:@"br"]) {
			if (![LepraGeneralHelper isEmpty:userString.string]) {
				[userString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
			}
		} else if ([child.tagName isEqualToString:@"a"]) {
			LinkObject* linkObject = [[LinkObject alloc] init];
			linkObject.link = child.attributes[@"href"];
			if (child.firstTextChild) {
				[userString appendAttributedString:[[NSAttributedString alloc] initWithString:[self clearNodeText:child.firstTextChild.content] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
				linkObject.range = NSMakeRange(userString.length-child.firstTextChild.content.length, child.firstTextChild.content.length);
			} else {
				[userString appendAttributedString:[[NSAttributedString alloc] initWithString:[self clearNodeText:child.attributes[@"href"]] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
				linkObject.range = NSMakeRange(userString.length-[child.attributes[@"href"] length], [child.attributes[@"href"] length]);
			}
			[links addObject:linkObject];
		} else if ([child.tagName isEqualToString:@"b"]) {
			[self addStringForUserString:userString links:links forNode:child];
		} else if ([child.tagName isEqualToString:@"i"]) {
			[self addStringForUserString:userString links:links forNode:child];
		} else if ([child.attributes[@"class"] isEqualToString:@"irony"]) {
			[self addStringForUserString:userString links:links forNode:child];
		} else if ([child.tagName isEqualToString:@"img"]) {
			if (![LepraGeneralHelper isEmpty:userString.string] && ![userString.string isEqualToString:@"\n"]) {
				[self.profile.userTextObjects addObject:[userString mutableCopy]];
				[self.profile.userTextLinks addObject:[links mutableCopy]];
			}
			[self.profile.userTextObjects addObject:[NSURL URLWithString:child.attributes[@"src"]]];
			[self.profile.userTextLinks addObject:@[]];
			[userString replaceCharactersInRange:NSMakeRange(0, userString.length) withString:@""];
			[links removeAllObjects];
		} else {
			NSLog(@"UNKNOWN ELEMENT: %@", child);
		}
	}
}

- (NSString*)clearNodeText:(NSString*)nodeText {
	NSString* returnString = [nodeText mutableCopy];
	returnString = [returnString stringByReplacingOccurrencesOfString:@"\n\t" withString:@""];
	returnString = [returnString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	return returnString;
}

- (void)imageLoadedForCell:(LepraProfileImageCell *)cell withImageUrl:(NSURL *)imageUrl {
	[self.tableView reloadData];
}

- (void)cellAskForOpenGallery:(MHGalleryController *)gallery
{
	[self presentMHGalleryController:gallery animated:YES completion:nil];
}


//-----------------------------------------------------------------------------------------------------
#pragma mark - Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ([LepraGeneralHelper isNull:self.profile.carma]) {
		return 0;
	}
	return 1 + self.profile.contactsTypes.count + self.profile.userTextObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==0) {
		return 170.0;
	} else {
		if (indexPath.row > self.profile.contactsTypes.count) {
			id userTextObject = [self.profile.userTextObjects objectAtIndex:indexPath.row-(self.profile.contactsTypes.count+1)];
			if ([userTextObject isKindOfClass:[NSURL class]]) {
				return [LepraProfileImageCell cellHeightForImageUrl:userTextObject];
			} else {
				return [LepraProfileUserTextCell cellHeightForUserText:userTextObject width:tableView.frame.size.width];
			}
		} else {
			return 44.0;
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row==0) {
		LepraProfileInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraProfileInfoCell cellIdentifier]];
		[cell setProfile:self.profile];
		[cell setCellDelegate:self];
		return cell;
	} else {
		if (indexPath.row > self.profile.contactsTypes.count) {
			id userTextObject = [self.profile.userTextObjects objectAtIndex:indexPath.row-(self.profile.contactsTypes.count+1)];
			if ([userTextObject isKindOfClass:[NSURL class]]) {
				LepraProfileImageCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraProfileImageCell cellIdentifier]];
				[cell setCellDelegate:self];
				[cell setImageUrl:userTextObject];
				return cell;
			} else {
				LepraProfileUserTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraProfileUserTextCell cellIdentifier]];
				[cell setUserText:userTextObject links:[self.profile.userTextLinks objectAtIndex:indexPath.row-(self.profile.contactsTypes.count+1)]];
				return cell;
			}
		} else {
			LepraProfileContactCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraProfileContactCell cellIdentifier]];
			[cell setContactType:self.profile.contactsTypes[indexPath.row-1] contact:self.profile.contactsValues[indexPath.row-1]];
			return cell;
		}
	}
}

- (void)cellAskForLeftPlusForProfile:(LepraProfile *)profile
{
	self.profile.leftPlusEnabled = @(YES);
	self.profile.leftMinusEnabled = @(NO);
	[[LepraAPIManager sharedManager] setKarmaForUser:self.profile success:^(NSString *newKarma) {
		self.profile.carma = newKarma;
		[self.tableView reloadData];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (void)cellAskForRightPlusForProfile:(LepraProfile *)profile
{
	self.profile.rightPlusEnabled = @(YES);
	self.profile.rightMinusEnabled = @(NO);
	[[LepraAPIManager sharedManager] setKarmaForUser:self.profile success:^(NSString *newKarma) {
		self.profile.carma = newKarma;
		[self.tableView reloadData];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (void)cellAskForLeftMinusForProfile:(LepraProfile *)profile
{
	self.profile.leftPlusEnabled = @(NO);
	self.profile.leftMinusEnabled = @(YES);
	[[LepraAPIManager sharedManager] setKarmaForUser:self.profile success:^(NSString *newKarma) {
		self.profile.carma = newKarma;
		[self.tableView reloadData];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (void)cellAskForRightMinusForProfile:(LepraProfile *)profile
{
	self.profile.rightPlusEnabled = @(NO);
	self.profile.rightMinusEnabled = @(YES);
	[[LepraAPIManager sharedManager] setKarmaForUser:self.profile success:^(NSString *newKarma) {
		self.profile.carma = newKarma;
		[self.tableView reloadData];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

@end
