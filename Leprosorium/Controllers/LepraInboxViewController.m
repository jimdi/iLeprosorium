//
//  LepraInboxViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 30.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraInboxViewController.h"

@interface LepraInboxViewController ()

@end

@implementation LepraInboxViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Инбокс";
}

- (void)updatePosts
{
	[[LepraHTTPClient sharedClient] setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[[LepraHTTPClient sharedClient] postPath:@"ajax/inbox/moar" parameters:@{@"offset":@(0), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN), @"sort":@(3), @"unread":@(0)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		self.posts = [[NSMutableArray alloc] init];
		NSDictionary *object = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
		NSString* html = object[@"template"];
		if (![LepraGeneralHelper isEmpty:html]) {
			if ([html rangeOfString:@"b-no_posts"].location==NSNotFound) {
				[self parsePostsPage:object[@"template"]];
			} else {
				[self.loadMoreView allLoaded];
				self.allLoaded = YES;
			}
		}
		[self.refreshControl endRefreshing];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"FAIL");
		[self.refreshControl endRefreshing];
		[self.loadMoreView stopLoad];
	}];
}

- (void)loadMorePosts
{
	if (!self.allLoaded && self.secondTryLoadMore) {
		self.page++;
		[self.loadMoreView startLoad];
		[[LepraHTTPClient sharedClient] setDefaultHeader:@"Accept" value:@"text/hmtl"];
		[[LepraHTTPClient sharedClient] postPath:@"ajax/inbox/moar" parameters:@{@"offset":@(self.posts.count), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSDictionary *object = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
			NSString* html = object[@"template"];
			if (![LepraGeneralHelper isEmpty:html]) {
				if ([html rangeOfString:@"b-no_posts"].location==NSNotFound) {
					[self parsePostsPage:object[@"template"]];
				} else {
					[self.loadMoreView allLoaded];
					self.allLoaded = YES;
				}
			}
            for (LepraPost *post in self.posts) {
                post.link = [NSString stringWithFormat:@"my/inbox/%zd", post.remoteId.integerValue];
            }
			[self.loadMoreView stopLoad];
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			if (operation.response.statusCode == 404) {
				[self.loadMoreView allLoaded];
				self.allLoaded = YES;
			}
		}];
	}
}

@end
