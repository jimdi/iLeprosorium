//
//  LepraProfileCommentsViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 24.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraProfileCommentsViewController.h"

#import "LepraSwipeViewController.h"
#import "LepraProfileViewController.h"
#import "LepraProfilePostsViewController.h"
#import "LepraPostDetailCommentsViewController.h"
#import "LepraPostDetailCommentsViewController.h"
#import "LepraMainPagePostsViewController.h"
#import "LepraPostHeaderCell.h"
#import "LepraInboxViewController.h"
#import "LepraWriteCommentViewController.h"
#import "LepraCommentFullCell.h"

@interface LepraProfileCommentsViewController () <LepraProfileImageCellDelegate, LepraProfileUserTextCellDelegate, LepraPostRatingCellDelegate, LepraCommentFullCellDelegate>

@end

@implementation LepraProfileCommentsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Комментарии";
	
	self.page = 1;
	
	
	if (self.navigationController.viewControllers.count==1) {
		[self addMenuButton];
	}
	
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl setTintColor:[UIColor blackColor]];
	[self.refreshControl addTarget:self action:@selector(updatePosts) forControlEvents:UIControlEventValueChanged];
	
	[self.tableView addSubview:self.refreshControl];
	
	[self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0)]];
	[self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0)]];
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	
	self.loadMoreView = [LepraLoadMoreView loadFromNib];
	[self.loadMoreView stopLoad];
	onceToken = 0;
	
	[self registerCellForId:[LepraCommentFullCell cellIdentifier]];
	
	[self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
	
	UINavigationController* navVC;
	if ([self.parentViewController isKindOfClass:[LepraSwipeViewController class]]) {
		navVC = self.parentViewController.navigationController;
	} else {
		navVC = self.navigationController;
	}
	if ([[navVC.viewControllers firstObject] isKindOfClass:[LepraInboxViewController class]]) {
		self.inbox = YES;
	} else {
		self.inbox = NO;
	}
}

- (void)updatePosts
{
	self.page = 1;
	
	[[LepraAPIManager sharedManager] getCommentsByUserName:[LepraGeneralHelper coalesce:self.userName with:DEFAULTS_OBJ(DEF_KEY_USER)[@"login"]] page:self.page success:^(NSString *commentsPage) {
		
		self.comments = [[NSMutableArray alloc] init];
		[self parseCommentsPage:commentsPage withSuccessBlock:nil];
		if (self.comments.count==0) {
			self.allLoaded = YES;
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self.refreshControl endRefreshing];
	}];
}

- (void)loadMorePosts
{
	if (!self.allLoaded && self.secondTryLoadMore) {
		self.page++;
		[self.loadMoreView startLoad];
		[[LepraAPIManager sharedManager] getCommentsByUserName:[LepraGeneralHelper coalesce:self.userName with:DEFAULTS_OBJ(DEF_KEY_USER)[@"login"]] page:self.page success:^(NSString *commentsPage) {
			[self parseCommentsPage:commentsPage withSuccessBlock:nil];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if (operation.response.statusCode == 404) {
				[self.loadMoreView allLoaded];
				self.allLoaded = YES;
				self.page--;
			}
		}];
	}
}

- (void)parseCommentsPage:(NSString*)page withSuccessBlock:(void (^)())successBlock
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
	TFHpple *commentsPage = [TFHpple hppleWithHTMLData:[page dataUsingEncoding:NSUTF8StringEncoding]];
	NSArray *commentNodes = [commentsPage searchWithXPathQuery:@"//*[contains(@class,'comment ')]"];
	NSMutableArray *postsNodes = [[NSMutableArray alloc] init];
	NSMutableArray *footerNodes = [[NSMutableArray alloc] init];
	NSMutableArray *localComments = [[NSMutableArray alloc] init];
		
		NSRange currentEpocheRange = [page rangeOfString:@"commentsHandler.filter.init("];
		
		if (currentEpocheRange.location!=NSNotFound) {
			self.currentEpoche = @([[[[page substringFromIndex:currentEpocheRange.location+currentEpocheRange.length] componentsSeparatedByString:@","] firstObject] integerValue]);
		}
		
	for (TFHppleElement *commentNode in commentNodes) {
		NSString* class = commentNode.attributes[@"class"];
		NSRange offsetRange = [class rangeOfString:@"indent_"];
		LepraComment *comment = [[LepraComment alloc] init];
		if (offsetRange.location != NSNotFound) {
			NSString* offset = [class substringFromIndex:offsetRange.location + offsetRange.length];
			offset = [offset substringToIndex:[offset rangeOfString:@" "].location];
			[comment setCommentOffset:@(offset.integerValue)];
		} else {
			[comment setCommentOffset:@(0)];
		}
		if ([class rangeOfString:@"new"].location != NSNotFound) {
			[comment setIsNew:@(YES)];
		} else {
			[comment setIsNew:@(NO)];
		}
		
		if ([class rangeOfString:@"b-author_comment"].location != NSNotFound) {
			[comment setPostAuthor:@(YES)];
		} else {
			[comment setPostAuthor:@(NO)];
		}
		
		[localComments addObject:comment];
		for (TFHppleElement *commentChild in commentNode.children) {
			if ([commentChild.attributes[@"class"] isEqualToString:@"c_i"]) {
				for (TFHppleElement *child in commentChild.children) {
					if ([child.attributes[@"class"] isEqualToString:@"c_body"]) {
						[postsNodes addObject:child];
					} else if ([child.attributes[@"class"] isEqualToString:@"c_footer"]) {
						[footerNodes addObject:child];
					}
				}
			}
		}
		comment.commentId = commentNode.attributes[@"id"];
	}
	for (TFHppleElement* postNode in postsNodes) {
		LepraComment *comment = localComments[[postsNodes indexOfObject:postNode]];
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
		if (footerNodes.count > index) {
			TFHppleElement* footerNode = [footerNodes objectAtIndex:index];
			BOOL hasRating = NO;
			for (TFHppleElement *footerChild in footerNode.children) {
				if ([footerChild.attributes[@"class"] isEqualToString:@"ddi"]) {
					for (TFHppleElement* child in footerChild.children) {
						if ([child.tagName isEqualToString:@"a"] && [child.attributes[@"class"] isEqualToString:@"c_user"]) {
							comment.authorUserName = child.firstTextChild.content;
						} else if (child.isTextNode) {
							if ([LepraGeneralHelper isEmpty:comment.authorPrefix]) {
								comment.authorPrefix = [self clearNodeText:child.content];
								if ([comment.authorPrefix hasPrefix:@" "]) {
									comment.authorPrefix = [comment.authorPrefix substringFromIndex:1];
								}
							}
						} else if (child.attributes[@"data-epoch_date"]){
							NSInteger epoche = [child.attributes[@"data-epoch_date"] integerValue];
							comment.postDate = [NSDate dateWithTimeIntervalSince1970:epoche];
						}
					}
				} else if ([footerChild.attributes[@"class"] isEqualToString:@"vote c_vote"]) {
					NSString* userVote = footerChild.attributes[@"data-user_vote"];
					if (![LepraGeneralHelper isNull:userVote]) {
						comment.plusEnabled = @([userVote isEqualToString:@"1"]);
						comment.minusEnabled = @([userVote isEqualToString:@"-1"]);
					}
					for (TFHppleElement* child in footerChild.children) {
						if ([child.tagName isEqualToString:@"strong"]) {
							hasRating = YES;
							comment.rating = child.firstTextChild.content;
							break;
						}
					}
				}
			}
			if (!hasRating) {
				comment.rating = @"";
			}
		}
		
		comment.textObjects = postTextObjects;
		comment.textLinks = postLinks;
	}
	[self.comments addObjectsFromArray:localComments];
		if (self.reordered) {
			[self reorder];
		}
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
			[self.loadMoreView stopLoad];
			[self.refreshControl endRefreshing];
			if (successBlock) {
				successBlock();
			}
		});
	});
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

//- (void)addStringForFooterString:(NSMutableAttributedString*)postString links:(NSMutableArray*)links objects:(NSMutableArray*)globalObjects globalLinks:(NSMutableArray*)gloabalLinks forNode:(TFHppleElement*)node
//{
//	UIFont *font = TEXT_FONT;
//	UIColor *fontColor = [UIColor blackColor];
//	
//	for (TFHppleElement *child in node.children) {
//		if (child.isTextNode) {
//			[postString appendAttributedString:[[NSAttributedString alloc] initWithString:[self clearNodeText:child.content] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
//		} else if ([child.tagName isEqualToString:@"a"]) {
//			if ([child.attributes[@"class"] isEqualToString:@"c_user"] || [child.attributes[@"class"] isEqualToString:@"c_domain"]) {
//				LinkObject* linkObject = [[LinkObject alloc] init];
//				linkObject.link = child.attributes[@"href"];
//				if (child.firstTextChild) {
//					[postString appendAttributedString:[[NSAttributedString alloc] initWithString:[self clearNodeText:child.firstTextChild.content] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
//					linkObject.range = NSMakeRange(postString.length-child.firstTextChild.content.length, child.firstTextChild.content.length);
//					[links addObject:linkObject];
//				}
//			}
//		} else if ([child.tagName isEqualToString:@"span"]) {
//			if (child.attributes[@"data-epoch_date"]){
//				NSDate* date = [NSDate dateWithTimeIntervalSince1970:[child.attributes[@"data-epoch_date"] integerValue]];
//				NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//				[dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru"]];
//				[dateFormatter setDateFormat:@"d MMMM yyyy kk.mm"];
//				[postString appendAttributedString:[[NSAttributedString alloc] initWithString:[dateFormatter stringFromDate:date] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
//			} else if ([child.attributes[@"class"] isEqualToString:@"b-post_comments_links"]) {
//				if ([child.firstChild.tagName isEqualToString:@"a"]) {
//					[postString appendAttributedString:[[NSAttributedString alloc] initWithString:[self clearNodeText:child.firstChild.firstTextChild.content] attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:fontColor}]];
//				}
//			}
//		}
//	}
//}

- (NSString*)clearNodeText:(NSString*)nodeText {
	NSString* returnString = [nodeText mutableCopy];
	NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\n\n*\t*" options:0 error:NULL];
	returnString = [re stringByReplacingMatchesInString:returnString options:0 range:NSMakeRange(0, returnString.length) withTemplate:@" "];
	returnString = [returnString stringByReplacingOccurrencesOfString:@" · " withString:@""];
	return returnString;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	if (section == self.comments.count) {
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
	if (section == self.comments.count) {
		return 30.0;
	}
	return 0.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.comments.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == self.comments.count) {
		return 0;
	}
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LepraComment *comment = self.comments[indexPath.section];
    return [LepraCommentFullCell heightForComment:comment withWidth:self.tableView.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	LepraComment *comment = self.comments[indexPath.section];
    
    LepraCommentFullCell* cell = [self.tableView dequeueReusableCellWithIdentifier:[LepraCommentFullCell cellIdentifier]];
    [cell setComment:comment];
    [cell setCellDelegate:self];
    [cell setDelegate:self];
    cell.parentVC = self;
    return cell;
}

- (void)imageLoadedForCell:(LepraProfileImageCell *)cell withImageUrl:(NSURL *)imageUrl {
	CGPoint contentOffset = self.tableView.contentOffset;
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	if (indexPath.section < [self.tableView.indexPathsForVisibleRows.lastObject section]) {
		CGFloat imageHeight = [LepraProfileImageCell cellHeightForImageUrl:imageUrl offset:[self.comments[indexPath.section] commentOffset]];
		CGFloat deltaHeights = imageHeight - 100.0;
		contentOffset.y += deltaHeights;
	}
	[self.tableView reloadData];
	[self.tableView setContentOffset:contentOffset];
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

- (void)cellAskToVotePlusForComment:(LepraComment *)comment
{
	[[LepraAPIManager sharedManager] plusCommentId:comment.commentId success:^(NSString *newRating) {
		comment.plusEnabled = @(YES);
		comment.minusEnabled = @(NO);
		comment.rating = newRating;
		[self.tableView reloadData];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (void)cellAskToVoteMinusForComment:(LepraComment *)comment
{
	[[LepraAPIManager sharedManager] minusCommentId:comment.commentId success:^(NSString *newRating) {
		comment.plusEnabled = @(NO);
		comment.minusEnabled = @(YES);
		comment.rating = newRating;
		[self.tableView reloadData];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
	}];
}

- (void)reorderComments
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.comments.count];
	NSEnumerator *enumerator = [self.comments reverseObjectEnumerator];
	for (id element in enumerator) {
		[array addObject:element];
	}
	self.comments = array;
	self.reordered = !self.reordered;
	[self.tableView reloadData];
}

- (void)reorder
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.comments.count];
	NSEnumerator *enumerator = [self.comments reverseObjectEnumerator];
	for (id element in enumerator) {
		[array addObject:element];
	}
	self.comments = array;
	[self.tableView reloadData];
}

@end
