//
//  LepraProfileCommentsViewController.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 24.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewController.h"
#import <TFHpple.h>
#import "LepraProfileUserTextCell.h"
#import "LepraProfileImageCell.h"
#import "LepraPostFooterCell.h"
#import "LepraPostRatingCell.h"

#import "LepraLoadMoreView.h"
#import <AFHTTPRequestOperation.h>

#import "LepraComment.h"

@interface LepraProfileCommentsViewController : LepraCommonTableViewController

@property (strong, nonatomic) NSString* userName;
@property (nonatomic) NSInteger page;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *comments;

@property (strong, nonatomic) LepraLoadMoreView *loadMoreView;

@property (nonatomic) BOOL allLoaded;
@property (nonatomic) BOOL secondTryLoadMore;

@property (nonatomic) BOOL reordered;

- (void)parseCommentsPage:(NSString*)page withSuccessBlock:(void (^)())successBlock;

- (void)reorderComments;

@property (nonatomic) BOOL inbox;

@property (strong, nonatomic) NSNumber* currentEpoche;

@end
