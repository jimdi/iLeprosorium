//
//  LepraProfilePostsViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 23.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewController.h"
#import "LepraLoadMoreView.h"
#import <AFHTTPRequestOperation.h>
#import "LepraPost.h"

@interface LepraProfilePostsViewController : LepraCommonTableViewController

@property (strong, nonatomic) NSString* userName;
@property (nonatomic) NSInteger page;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *posts;
//@property (strong, nonatomic) NSMutableArray *postsTextObjects;
//@property (strong, nonatomic) NSMutableArray *postsTextLinks;
//@property (strong, nonatomic) NSMutableArray *postsRatings;
//@property (strong, nonatomic) NSMutableArray *postCommentsLinks;

@property (strong, nonatomic) LepraLoadMoreView *loadMoreView;

@property (nonatomic) BOOL allLoaded;
@property (nonatomic) BOOL secondTryLoadMore;

- (void)parsePostsPage:(NSString*)page;

@end
