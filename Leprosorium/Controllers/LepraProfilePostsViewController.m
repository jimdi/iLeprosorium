//
//  LepraProfilePostsViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 23.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraProfilePostsViewController.h"
#import "LepraProfileViewController.h"
#import "LepraPostDetailCommentsViewController.h"

#import <TFHpple.h>
#import "LepraFullPostCell.h"
#import "LepraProfileUserTextCell.h"
#import "LepraProfileImageCell.h"
#import "LepraPostFooterCell.h"
#import "LepraPostRatingCell.h"
#import "LepraPostHeaderCell.h"
#import "LepraPostUndergroundCell.h"

#import "LepraSwipeViewController.h"
#import "LepraPostDetailViewController.h"
#import "LepraPostDetailCommentsViewController.h"
#import "LepraMainPagePostsViewController.h"


@interface LepraProfilePostsViewController () <LepraProfileImageCellDelegate, LepraProfileUserTextCellDelegate, LepraPostRatingCellDelegate, LepraPostHeaderCellDelegate, SWTableViewCellDelegate, LepraFullPostCellDelegate>

@end

@implementation LepraProfilePostsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Посты";
	
	self.page = 1;
	
	
	if (self.navigationController.viewControllers.count==1) {
		[self addMenuButton];
	}
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl setTintColor:[UIColor blackColor]];
	[self.refreshControl addTarget:self action:@selector(updatePosts) forControlEvents:UIControlEventValueChanged];
	
	[self.tableView addSubview:self.refreshControl];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	[self.tableView setTableFooterView:[UIView new]];
	[self.tableView setAllowsMultipleSelection:YES];
	[self.tableView.tableFooterView setFrame:CGRectZero];
	
	self.loadMoreView = [LepraLoadMoreView loadFromNib];
	[self.loadMoreView stopLoad];
	onceToken = 0;
	
	[self registerCellForId:[LepraFullPostCell cellIdentifier]];
//	[self registerCellForId:[LepraProfileImageCell cellIdentifier]];
//	[self registerCellForId:[LepraPostFooterCell cellIdentifier]];
//	[self registerCellForId:[LepraPostRatingCell cellIdentifier]];
//	[self registerCellForId:[LepraPostHeaderCell cellIdentifier]];
//	[self registerCellForId:[LepraPostUndergroundCell cellIdentifier]];
	
	[self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	[self.view setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

static dispatch_once_t onceToken;

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self configureNavigationBarWithColor:[LepraGeneralHelper redColorLight] titleColor:[UIColor whiteColor]];
	
	dispatch_once(&onceToken, ^{
		[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
		[self.refreshControl beginRefreshing];
		[self updatePosts];
	});
}

- (void)updatePosts
{
	self.page = 1;
	
	[[LepraAPIManager sharedManager] getPostsByUserName:[LepraGeneralHelper coalesce:self.userName with:DEFAULTS_OBJ(DEF_KEY_USER)[@"login"]] page:self.page success:^(NSString *postsPage) {
		self.posts = [[NSMutableArray alloc] init];
//		self.postsTextLinks = [[NSMutableArray alloc] init];
//		self.postsTextObjects = [[NSMutableArray alloc] init];
//		self.postsRatings = [[NSMutableArray alloc] init];
//		self.postCommentsLinks = [[NSMutableArray alloc] init];
		[self parsePostsPage:postsPage];
		if (self.posts.count==0) {
			self.allLoaded = YES;
		}
		[self.refreshControl endRefreshing];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self.refreshControl endRefreshing];
	}];
}

- (void)loadMorePosts
{
	if (!self.allLoaded && self.secondTryLoadMore) {
		self.page++;
		[self.loadMoreView startLoad];
		[[LepraAPIManager sharedManager] getPostsByUserName:[LepraGeneralHelper coalesce:self.userName with:DEFAULTS_OBJ(DEF_KEY_USER)[@"login"]] page:self.page success:^(NSString *postsPage) {
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

- (void)parsePostsPage:(NSString*)page
{
	TFHpple *postsPage = [TFHpple hppleWithHTMLData:[page dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSArray *postParentNodes = [postsPage searchWithXPathQuery:@"//*[contains(@class,'post u')]"];
	NSArray *postsNodes = [postsPage searchWithXPathQuery:@"//*[@class='dt']"];
	NSArray *footerNodes = [postsPage searchWithXPathQuery:@"//*[@class='dd']"];
	for (TFHppleElement* postNode in postsNodes) {
		LepraPost *post = [[LepraPost alloc] init];
		NSMutableAttributedString* postString = [[NSMutableAttributedString alloc] init];
		NSMutableArray* postLinks = [[NSMutableArray alloc] init];
		NSMutableArray* postTextObjects = [[NSMutableArray alloc] init];
		NSMutableArray* localLinks = [[NSMutableArray alloc] init];
		[self addStringForPostString:postString links:localLinks objects:postTextObjects globalLinks:postLinks forNode:postNode];
		if (![LepraGeneralHelper isEmpty:postString.string] && ![postString.string isEqualToString:@"\n"]) {
			[postTextObjects addObject:[postString mutableCopy]];
			[postLinks addObject:[localLinks mutableCopy]];
		}
		
		[postString replaceCharactersInRange:NSMakeRange(0, postString.length) withString:@""];
		[localLinks removeAllObjects];
		
		NSInteger index = [postsNodes indexOfObject:postNode];
		if (postParentNodes.count > index) {
			TFHppleElement* postParentNode = [postParentNodes objectAtIndex:index];
			if (![LepraGeneralHelper isEmpty:postParentNode.attributes[@"id"]]) {
				post.remoteId = @([[postParentNode.attributes[@"id"] stringByReplacingOccurrencesOfString:@"p" withString:@""] integerValue]);
				post.link = [NSString stringWithFormat:@"comments/%zd", post.remoteId.integerValue];
			}
		}
		if (footerNodes.count > index) {
			TFHppleElement* footerNode = [footerNodes objectAtIndex:index];
			BOOL hasRating = NO;
			for (TFHppleElement *footerChild in footerNode.children) {
//				if ([footerChild.attributes[@"class"] isEqualToString:@"ddi"]) {
//					[self addStringForFooterString:postString links:localLinks objects:postTextObjects globalLinks:postLinks forNode:footerChild forPost:post];
//					if (![LepraGeneralHelper isEmpty:postString.string] && ![postString.string isEqualToString:@"\n"]) {
//						[postTextObjects addObject:postString];
//						[postLinks addObject:localLinks];
//					}
//				} else
				if ([footerChild.attributes[@"class"] isEqualToString:@"vote"]) {
					for (TFHppleElement* child in footerChild.children) {
						if ([child.tagName isEqualToString:@"strong"]) {
							hasRating = YES;
							post.rating = child.firstTextChild.content;
						} else if ([child.tagName isEqualToString:@"a"]) {
							NSString* class = child.attributes[@"class"];
							BOOL voted = [class rangeOfString:@"vote_voted"].location != NSNotFound;
							if ([class rangeOfString:@"vote_button_plus"].location != NSNotFound) {
								post.plusEnabled = @(voted);
							}
							if ([class rangeOfString:@"vote_button_minus"].location != NSNotFound) {
								post.minusEnabled = @(voted);
							}
						}
					}
				} else if ([footerChild.attributes[@"class"] isEqualToString:@"ddi"]) {
					for (TFHppleElement* child in footerChild.children) {
						if ([child.tagName isEqualToString:@"a"] && [child.attributes[@"class"] isEqualToString:@"c_user"]) {
							post.authorUserName = child.firstTextChild.content;
						} else if (child.isTextNode) {
							if ([LepraGeneralHelper isEmpty:post.authorPrefix]) {
								post.authorPrefix = [self clearNodeText:child.content];
								if ([post.authorPrefix hasPrefix:@" "]) {
									post.authorPrefix = [post.authorPrefix substringFromIndex:1];
								}
							}
						} else if (child.attributes[@"data-epoch_date"]){
							post.postDate = [NSDate dateWithTimeIntervalSince1970:[child.attributes[@"data-epoch_date"] integerValue]];
						} else if ([child.attributes[@"class"] isEqualToString:@"b-post_domain"]) {
							post.undergroundLink = child.attributes[@"href"];
							while ([post.undergroundLink hasPrefix:@"/"]) {
								post.undergroundLink = [post.undergroundLink substringFromIndex:1];
							}
							while ([post.undergroundLink hasSuffix:@"/"]) {
								post.undergroundLink = [post.undergroundLink substringToIndex:post.undergroundLink.length-1];
							}
						} else if ([child.attributes[@"class"] isEqualToString:@"b-post_comments_links"]) {
							for (TFHppleElement *commentsChild in child.children) {
								if ([commentsChild.tagName isEqualToString:@"a"]) {
									if ([commentsChild.attributes[@"href"] rangeOfString:@"?unread=on"].location != NSNotFound || (commentsChild.hasChildren && [commentsChild.firstChild.tagName isEqualToString:@"strong"])) {
										post.commentsNewCount = @([commentsChild.firstChild.firstTextChild.content integerValue]);
									} else if ([commentsChild.attributes[@"href"] rangeOfString:@"comments"].location != NSNotFound || [commentsChild.attributes[@"href"] rangeOfString:@"inbox"].location != NSNotFound) {
										post.commentsCount = @([commentsChild.firstTextChild.content integerValue]);
									}
								}
							}
						} else if ([child.attributes[@"class"] isEqualToString:@"b-post_controls"]) {
							for (TFHppleElement *button in child.children) {
								NSString* class = button.attributes[@"class"];
								BOOL hidden = [class rangeOfString:@"hidden"].location != NSNotFound;
								if ([class rangeOfString:@"in_interest"].location!=NSNotFound && !hidden) {
									post.myThings = @(NO);
								} else if ([class rangeOfString:@"out_interest"].location!=NSNotFound && !hidden) {
									post.myThings = @(YES);
								}
								if ([class rangeOfString:@"in_favourites"].location!=NSNotFound && !hidden) {
									post.favourites = @(NO);
								} else if ([class rangeOfString:@"out_favourites"].location!=NSNotFound && !hidden) {
									post.favourites = @(YES);
								}
							}
						}
					}
				}
			}
			if (!hasRating) {
				post.rating = @"";
			}
		}
		for (int i=0;i<postTextObjects.count;i++) {
			NSMutableAttributedString* postString = [postTextObjects objectAtIndex:i];
			if ([postString isKindOfClass:[NSAttributedString class]]) {
				while ([postString.string hasSuffix:@" "]) {
					[postString.mutableString replaceCharactersInRange:NSMakeRange(postString.string.length-1, 1) withString:@""];
				}
				while ([postString.string hasSuffix:@"\n"]) {
					[postString.mutableString replaceCharactersInRange:NSMakeRange(postString.string.length-1, 1) withString:@""];
				}
				if ([LepraGeneralHelper isEmpty:postString.string]) {
					[postTextObjects removeObjectAtIndex:i];
					[postLinks removeObjectAtIndex:i];
				}
			}
		}
		
		post.textObjects = postTextObjects;
		post.textLinks = postLinks;
		[self.posts addObject:post];
//		[self.postsTextObjects addObject:postTextObjects];
//		[self.postsTextLinks addObject:postLinks];
	}
	
	[self.tableView reloadData];
}

- (void)addStringForPostString:(NSMutableAttributedString*)postString links:(NSMutableArray*)links objects:(NSMutableArray*)globalObjects globalLinks:(NSMutableArray*)gloabalLinks forNode:(TFHppleElement*)node
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
	if ([node.tagName isEqualToString:@"h2"]) {
		fontColor = [LepraGeneralHelper blueColor];
	}
	
	
	for (TFHppleElement *child in node.children) {
		if (child.isTextNode) {
			[postString appendAttributedString:[[NSAttributedString alloc] initWithString:[self clearNodeText:child.content] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
		} else if ([child.tagName isEqualToString:@"br"]) {
			if (![LepraGeneralHelper isEmpty:postString.string]) {
				[postString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
			}
		} else if ([child.tagName isEqualToString:@"a"]) {
			LinkObject* linkObject = [[LinkObject alloc] init];
			linkObject.link = child.attributes[@"href"];
			if (child.firstTextChild) {
				[postString appendAttributedString:[[NSAttributedString alloc] initWithString:[self clearNodeText:child.firstTextChild.content] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
				linkObject.range = NSMakeRange(postString.length-child.firstTextChild.content.length, child.firstTextChild.content.length);
			} else if ([child.firstChild.tagName isEqualToString:@"img"]) {
				[self addStringForPostString:postString links:links objects:globalObjects globalLinks:gloabalLinks forNode:child];
			} else {
				[postString appendAttributedString:[[NSAttributedString alloc] initWithString:[self clearNodeText:child.attributes[@"href"]] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
				linkObject.range = NSMakeRange(postString.length-[child.attributes[@"href"] length], [child.attributes[@"href"] length]);
			}
			[links addObject:linkObject];
		} else if ([child.tagName isEqualToString:@"b"]) {
			[self addStringForPostString:postString links:links objects:globalObjects globalLinks:gloabalLinks forNode:child];
		} else if ([child.tagName isEqualToString:@"i"]) {
			[self addStringForPostString:postString links:links objects:globalObjects globalLinks:gloabalLinks forNode:child];
		} else if ([child.attributes[@"class"] isEqualToString:@"irony"]) {
			[self addStringForPostString:postString links:links objects:globalObjects globalLinks:gloabalLinks forNode:child];
		} else if ([child.tagName isEqualToString:@"img"]) {
			if (![LepraGeneralHelper isEmpty:postString.string] && ![postString.string isEqualToString:@"\n"]) {
				[globalObjects addObject:[postString mutableCopy]];
				[gloabalLinks addObject:[links mutableCopy]];
			}
			NSURL *imageSrc = [NSURL URLWithString:child.attributes[@"src"]];
			if (![LepraGeneralHelper isNull:imageSrc]) {
				[globalObjects addObject:imageSrc];
			}
			if ([child.parent.tagName isEqualToString:@"a"]) {
				LinkObject* linkObject = [[LinkObject alloc] init];
				linkObject.link = child.parent.attributes[@"href"];
				[gloabalLinks addObject:@[linkObject]];
			} else {
				[gloabalLinks addObject:@[]];
			}
			[postString replaceCharactersInRange:NSMakeRange(0, postString.length) withString:@""];
			[links removeAllObjects];
		} else if (child.attributes[@"data-epoch_date"]){
			NSDate* date = [NSDate dateWithTimeIntervalSince1970:[child.attributes[@"data-epoch_date"] integerValue]];
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru"]];
			[dateFormatter setDateFormat:@"d MMMM yyyy kk.mm"];
			[postString appendAttributedString:[[NSAttributedString alloc] initWithString:[dateFormatter stringFromDate:date] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
		} else {
			[self addStringForPostString:postString links:links objects:globalObjects globalLinks:gloabalLinks forNode:child];
		}
	}
}

- (NSString*)clearNodeText:(NSString*)nodeText {
	NSString* returnString = [nodeText mutableCopy];
	NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\n\n*\t*" options:0 error:NULL];
	returnString = [re stringByReplacingMatchesInString:returnString options:0 range:NSMakeRange(0, returnString.length) withTemplate:@" "];
	returnString = [returnString stringByReplacingOccurrencesOfString:@" · " withString:@"\n"];
	return returnString;
}

- (NSString*)clearFooterString:(NSString*)nodeText {
	NSString* returnString = [self clearNodeText:nodeText];
	returnString = [returnString stringByReplacingOccurrencesOfString:@"[" withString:@""];
	returnString = [returnString stringByReplacingOccurrencesOfString:@"]" withString:@""];
	return returnString;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if (section == self.posts.count) {
		[self loadMorePosts];
		if (!self.secondTryLoadMore) {
			self.secondTryLoadMore = YES;
		}
		if (self.allLoaded) {
			[self.loadMoreView allLoaded];
		}
		return self.loadMoreView;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (section == self.posts.count) {
		return 30.0;
	}
	return 0.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.posts.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == self.posts.count) {
		return 0;
	}
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LepraPost *post = self.posts[indexPath.section];
    return [LepraFullPostCell heightForPost:post withWidth:self.tableView.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LepraPost *post = self.posts[indexPath.section];
    
    LepraFullPostCell* cell = [tableView dequeueReusableCellWithIdentifier:[LepraFullPostCell cellIdentifier]];
    [cell setPost:post];
    [cell setCellDelegate:self];
    [cell setDelegate:self];
    [cell setRightUtilityButtons:[self rightButtonsForIndexPath:indexPath]];
    return cell;
}

- (void)cellAskForOpenPost:(LepraPost *)post {
    LepraPostDetailViewController *postVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraPostDetailViewController storyboardID]];
    postVC.post = post;
    
    LepraPostDetailCommentsViewController *commentsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraPostDetailCommentsViewController storyboardID]];
    commentsVC.postCommentLink = post.link;
    commentsVC.post = post;
    
    LepraSwipeViewController *swipeController = [[LepraSwipeViewController alloc] initWithViewControllers:@[postVC, commentsVC]];
    swipeController.title = @"Пост";
    if ([self.parentViewController isKindOfClass:[LepraSwipeViewController class]]) {
        [self.parentViewController.navigationController pushViewController:swipeController animated:YES];
    } else {
        [self.navigationController pushViewController:swipeController animated:YES];
    }
}

- (void)imageLoadedForCell:(LepraProfileImageCell *)cell withImageUrl:(NSURL *)imageUrl {
	[self.tableView reloadData];
}

- (void)cellAskForOpenGallery:(MHGalleryController *)gallery
{
	[self presentMHGalleryController:gallery animated:YES completion:nil];
}

- (void)cellAskForOpenProfile:(NSString *)userName
{
	LepraProfileViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfileViewController storyboardID]];
	profileVC.userName = userName;
	LepraProfilePostsViewController *profilePostsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfilePostsViewController storyboardID]];
	profilePostsVC.userName = userName;
	LepraProfileCommentsViewController *profileCommentsVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraProfileCommentsViewController storyboardID]];
	profileCommentsVC.userName = userName;
	
	LepraSwipeViewController *swipeController = [[LepraSwipeViewController alloc] initWithViewControllers:@[profileVC, profilePostsVC, profileCommentsVC]];
	swipeController.title = userName;
	if ([self.parentViewController isKindOfClass:[LepraSwipeViewController class]]) {
		[self.parentViewController.navigationController pushViewController:swipeController animated:YES];
	} else {
		[self.navigationController pushViewController:swipeController animated:YES];
	}
}

- (void)cellAskForOpenPage:(NSString *)pageLink
{
	LepraMainPagePostsViewController *pageVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraMainPagePostsViewController storyboardID]];
	pageVC.pageLink = pageLink;
	if ([self.parentViewController isKindOfClass:[LepraSwipeViewController class]]) {
		[self.parentViewController.navigationController pushViewController:pageVC animated:YES];
	} else {
		[self.navigationController pushViewController:pageVC animated:YES];
	}
}

- (void)cellAskToToggleFavouritesForPost:(LepraPost *)post
{
	if (!post.favourites.boolValue) {
		[[LepraAPIManager sharedManager] addPostToFavourites:post success:^{
			post.favourites = @(!post.favourites.boolValue);
			[self.tableView reloadData];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [hud setMode:MBProgressHUDModeCustomView];
            [hud setCustomView:[[UIImageView alloc] initWithImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"menu_item_favourites"] withColor:[UIColor whiteColor]]]];
            [hud setLabelText:@"Добавлено в избранное!"];
            [hud hide:YES afterDelay:1.0];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		}];
	} else {
		[[LepraAPIManager sharedManager] removePostFromFavourites:post success:^{
			post.favourites = @(!post.favourites.boolValue);
			[self.tableView reloadData];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [hud setMode:MBProgressHUDModeCustomView];
            [hud setCustomView:[[UIImageView alloc] initWithImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"menu_item_favourites"] withColor:[UIColor whiteColor]]]];
            [hud setLabelText:@"Удалено из избранного!"];
            [hud hide:YES afterDelay:1.0];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		}];
	}
}

- (void)cellAskToToggleMyThingsForPost:(LepraPost *)post
{
	if (!post.myThings.boolValue) {
		[[LepraAPIManager sharedManager] addPostToMyThings:post success:^{
			post.myThings = @(!post.myThings.boolValue);
			[self.tableView reloadData];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [hud setMode:MBProgressHUDModeCustomView];
            [hud setCustomView:[[UIImageView alloc] initWithImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"menu_item_my_things"] withColor:[UIColor whiteColor]]]];
            [hud setLabelText:@"Добавлено в мои вещи!"];
            [hud hide:YES afterDelay:1.0];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		}];
	} else {
		[[LepraAPIManager sharedManager] removePostFromMyThings:post success:^{
			post.myThings = @(!post.myThings.boolValue);
			[self.tableView reloadData];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [hud setMode:MBProgressHUDModeCustomView];
            [hud setCustomView:[[UIImageView alloc] initWithImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"menu_item_my_things"] withColor:[UIColor whiteColor]]]];
            [hud setLabelText:@"Удалено из моих вещей!"];
            [hud hide:YES afterDelay:1.0];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		}];
	}
}

- (void)cellAskToVotePlusForPost:(LepraPost *)post
{
	NSString *postId = [[post.link componentsSeparatedByString:@"/"] lastObject];
	[[LepraAPIManager sharedManager] plusPostId:postId success:^(NSString *newRating) {
		post.plusEnabled = @(YES);
		post.minusEnabled = @(NO);
		post.rating = newRating;
		[self.tableView reloadData];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (void)cellAskToVoteMinusForPost:(LepraPost *)post
{
	NSString *postId = [[post.link componentsSeparatedByString:@"/"] lastObject];
	[[LepraAPIManager sharedManager] minusPostId:postId success:^(NSString *newRating) {
		post.plusEnabled = @(NO);
		post.minusEnabled = @(YES);
		post.rating = newRating;
		[self.tableView reloadData];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (NSArray *)rightButtonsForIndexPath:(NSIndexPath*)indexPath;
{
    LepraPost *post = self.posts[indexPath.section];
	NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"alarm"] withColor:[UIColor whiteColor]] title:@"Наябедничать"];
    
	[rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0] icon:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"menu_item_my_things"] withColor:[UIColor whiteColor]] title:post.myThings.integerValue == 1 ? @"Из моих вещей" : @"В мои вещи"];
	[rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.5f green:0.5f blue:1.f alpha:1.0f] icon:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"menu_item_favourites"] withColor:[UIColor whiteColor]] title:post.favourites.integerValue==1 ? @"Из избранного" : @"В избранное"];
	
	return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if (index==0) {
        NSLog(@"Настучать!");
    } else if (index==1) {
        [self cellAskToToggleMyThingsForPost:self.posts[[self.tableView indexPathForCell:cell].section]];
    } else if (index==2) {
        [self cellAskToToggleFavouritesForPost:self.posts[[self.tableView indexPathForCell:cell].section]];
    }
    
    [cell hideUtilityButtonsAnimated:YES];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didScroll:(UIScrollView *)scrollView
{
	if (scrollView.contentOffset.x!=0) {
		[self.viewDeckController setEnabled:NO];
	} else {
		[self.viewDeckController setEnabled:YES];
	}
	NSInteger section = [self.tableView indexPathForCell:cell].section;
	LepraPost *post = self.posts[section];
	for (int i=0;i<post.textObjects.count + 4;i++) {
		[(SWTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]] setScrollContentOffset:scrollView.contentOffset];
	}
}

@end
