//
//  LepraPostDetailCommentsViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 24.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraPostDetailCommentsViewController.h"
#import "LepraSwipeViewController.h"
#import <DKToolbar.h>
#import "LepraInboxViewController.h"
#import "LepraWriteCommentViewController.h"
#import "LepraCommentHeaderCell.h"
#import "LepraCommentFullCell.h"

@interface LepraPostDetailCommentsViewController () <DKToolbarDelegate>

@property (strong, nonatomic) DKToolbar *toolbar;
@property (strong, nonatomic) DKToolbarItem *itemNext;
@property (strong, nonatomic) DKToolbarItem *itemPrevious;
@property (strong, nonatomic) DKToolbarItem *itemReorder;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;

@property (nonatomic) NSInteger currentCommentIndex;

@end

@implementation LepraPostDetailCommentsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
		self.toolbar = [[DKToolbar alloc] initInView:self.view withDelegate:self];
		[self.toolbar setBackgroundColor:[LepraGeneralHelper redColorLight]];
		[self.toolbar setItemBackgroundColor:[LepraGeneralHelper redColorLight]];
		
		self.itemPrevious = [[DKToolbarItem alloc] initWithTitle:@"Предыдущий\nновый" image:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"previous"] withColor:[UIColor whiteColor]] selectedImage:nil];
		self.itemNext = [[DKToolbarItem alloc] initWithTitle:@"Следующий\nновый" image:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"next"] withColor:[UIColor whiteColor]] selectedImage:nil];
		self.itemReorder = [[DKToolbarItem alloc] initWithTitle:@"От новых\nк старым" image:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"reorder"] withColor:[UIColor whiteColor]] selectedImage:nil];
	
	if (self.post.commentsNewCount.integerValue>0) {
		[self.toolbar setItems:@[self.itemPrevious, self.itemNext, self.itemReorder]];
	} else {
		[self.toolbar setItems:@[self.itemReorder]];
	}
//	[self.view addSubview:self.toolbar];
	
	self.currentCommentIndex = -1;
	
	SIGNUP_FOR_NOTIFICATION(NOTIFICATION_NEED_RELOAD_COMMENTS, @selector(newComment));
}

- (void)dealloc
{
	REMOVE_NOTIFICATION(NOTIFICATION_NEED_RELOAD_COMMENTS);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	UINavigationController* navVC;
	UINavigationItem* navItem;
	if ([self.parentViewController isKindOfClass:[LepraSwipeViewController class]]) {
		navVC = self.parentViewController.navigationController;
		navItem = self.parentViewController.navigationItem;
	} else {
		navVC = self.navigationController;
		navItem = self.navigationItem;
	}
	
//	if ([[navVC.viewControllers firstObject] isKindOfClass:[LepraInboxViewController class]]) {
		[navItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(writeComment)]];
//	} else {
//		[navItem setRightBarButtonItem:nil];
//	}
}

- (void)writeComment
{
	UINavigationController* navVC;
	if ([self.parentViewController isKindOfClass:[LepraSwipeViewController class]]) {
		navVC = self.parentViewController.navigationController;
	} else {
		navVC = self.navigationController;
	}
	LepraWriteCommentViewController* commentVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraWriteCommentViewController storyboardID]];
	commentVC.post = self.post;
	commentVC.inbox = self.inbox;
	[navVC pushViewController:commentVC animated:YES];
}

- (void)cellAskForAnswerComment:(LepraComment *)comment
{
	UINavigationController* navVC;
	if ([self.parentViewController isKindOfClass:[LepraSwipeViewController class]]) {
		navVC = self.parentViewController.navigationController;
	} else {
		navVC = self.navigationController;
	}
	LepraWriteCommentViewController* commentVC = [self.storyboard instantiateViewControllerWithIdentifier:[LepraWriteCommentViewController storyboardID]];
	commentVC.inbox = self.inbox;
	commentVC.post = self.post;
	commentVC.comment = comment;
	[navVC pushViewController:commentVC animated:YES];
}

- (void)newComment
{
	[self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
	[self.refreshControl beginRefreshing];
	[self updatePosts];
}

- (void)updatePosts
{
	[[LepraAPIManager sharedManager] getCommentsByPost:self.post success:^(NSString *commentsPage) {
		self.comments = [[NSMutableArray alloc] init];
		[self parseCommentsPage:commentsPage withSuccessBlock:^{
			[[LepraAPIManager sharedManager] setCommentsReadedForPost:self.post currentEpoche:self.currentEpoche];
		}];
//		[[LepraAPIManager sharedManager] setCommentsReadedForPost:self.post currentEpoche:self.currentEpoche];
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		[self.refreshControl endRefreshing];
	}];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraComment *comment = self.comments[indexPath.section];
    
    LepraCommentFullCell* cell = [self.tableView dequeueReusableCellWithIdentifier:[LepraCommentFullCell cellIdentifier]];
    [cell setPost:self.post];
    [cell setComment:comment];
    [cell setCellDelegate:self];
    [cell setDelegate:self];
    cell.parentVC = self;
    return cell;
}

- (void)toolbarItemClickedAtIndex:(NSInteger)index
{
	DKToolbarItem *item = self.toolbar.items[index];
	if ([item isEqual:self.itemReorder]) {
		[self reorderComments];
		if (self.reordered) {
			[self.itemReorder.label setText:@"От старых\nк новым"];
		} else {
			[self.itemReorder.label setText:@"От новых\nк старым"];
		}
	} else if ([item isEqual:self.itemNext]) {
		for (int i=(int)self.currentCommentIndex+1;i<self.comments.count;i++) {
			LepraComment *comment = self.comments[i];
			if (comment.isNew.boolValue) {
				self.currentCommentIndex = i;
				[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.currentCommentIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
				break;
			}
		}
	} else if ([item isEqual:self.itemPrevious]) {
		for (int i=(int)self.currentCommentIndex-1;i>0;i--) {
			LepraComment *comment = self.comments[i];
			if (comment.isNew.boolValue) {
				self.currentCommentIndex = i;
				[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.currentCommentIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
				break;
			}
		}
	}
}

@end
