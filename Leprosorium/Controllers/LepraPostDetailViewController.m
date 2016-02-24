//
//  LepraPostDetailViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 24.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraPostDetailViewController.h"

#import "LepraProfileUserTextCell.h"
#import "LepraProfileImageCell.h"
#import "LepraPostFooterCell.h"
#import "LepraPostRatingCell.h"
#import "LepraPostHeaderCell.h"

#import "LepraMainPagePostsViewController.h"
#import "LepraProfileViewController.h"
#import "LepraSwipeViewController.h"
#import "LepraProfileCommentsViewController.h"
#import "LepraProfilePostsViewController.h"

#import "LepraFullPostCell.h"

@interface LepraPostDetailViewController () <LepraProfileImageCellDelegate, LepraFullPostCellDelegate, SWTableViewCellDelegate>

@end

@implementation LepraPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Пост";
	
	[self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0)]];
	[self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0)]];
	
	[self registerCellForId:[LepraFullPostCell cellIdentifier]];
	
	[self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	[self.view setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	
	[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [LepraFullPostCell heightForPost:self.post withWidth:self.tableView.frame.size.width];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraFullPostCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraFullPostCell cellIdentifier]];
    [cell setPost:self.post];
    [cell setCellDelegate:self];
    [cell setDelegate:self];
    [cell setRightUtilityButtons:[self rightButtonsForIndexPath:indexPath]];
    return cell;
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
- (void)cellAskForOpenPost:(LepraPost *)post {
    
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
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"alarm"] withColor:[UIColor whiteColor]] title:@"Наябедничать"];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0] icon:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"menu_item_my_things"] withColor:[UIColor whiteColor]] title:self.post.myThings.integerValue == 1 ? @"Из моих вещей" : @"В мои вещи"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.5f green:0.5f blue:1.f alpha:1.0f] icon:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"menu_item_favourites"] withColor:[UIColor whiteColor]] title:self.post.favourites.integerValue==1 ? @"Из избранного" : @"В избранное"];
    
    return rightUtilityButtons;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    if (index==0) {
        NSLog(@"Настучать!");
    } else if (index==1) {
        [self cellAskToToggleMyThingsForPost:self.post];
    } else if (index==2) {
        [self cellAskToToggleFavouritesForPost:self.post];
    }
    
    [cell hideUtilityButtonsAnimated:YES];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x!=0) {
        [self.parentViewController.viewDeckController setEnabled:NO];
    } else {
        [self.parentViewController.viewDeckController setEnabled:YES];
    }
    NSInteger section = [self.tableView indexPathForCell:cell].section;
    for (int i=0;i<self.post.textObjects.count + 4;i++) {
        [(SWTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:section]] setScrollContentOffset:scrollView.contentOffset];
    }
}

@end
