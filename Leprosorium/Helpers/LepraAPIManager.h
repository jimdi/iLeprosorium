//
//  LepraAPIManager.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LepraHTTPClient.h"
#import "LepraPost.h"
#import "LepraProfile.h"
#import "LepraComment.h"

#define API_BASE_URL                @"https://leprosorium.ru/"

#define GERTRUDA_LINK				@"GERTRUDA_LINK"
#define TAGLINE_TEXT				@"TAGLINE_TEXT"
#define MY_THINGS_COUNT				@"MY_THINGS_COUNT"
#define INBOX_COUNT					@"INBOX_COUNT"

@interface LepraAPIManager : NSObject

@property (nonatomic, strong) LepraHTTPClient *HTTPClient;

//------------------------------------------------------------------------
#pragma mark - Singleton

+ (instancetype)sharedManager;

//------------------------------------------------------------------------
#pragma mark - Authorization / Registration

- (void)loginWithLogin:(NSString *)login
			  password:(NSString *)password
	recaptchaChallenge:(NSString*)recaptchaChallenge
				capcha:(NSString*)capcha
			   success:(void (^)())successBlock
			   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)logout;

- (void)getLoginPageWithSuccess:(void (^)(NSString* loginPage))successBlock
					failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

//------------------------------------------------------------------------
#pragma mark - User

- (void)getUserByUserName:(NSString *)userName
				  success:(void (^)(NSString* userPage))successBlock
			   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)getPostsByUserName:(NSString *)userName
					  page:(NSInteger)page
				  success:(void (^)(NSString* postsPage))successBlock
			   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)getCommentsByUserName:(NSString *)userName
						 page:(NSInteger)page
					  success:(void (^)(NSString* commentsPage))successBlock
					  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)setKarmaForUser:(LepraProfile *)profile
				success:(void (^)(NSString* newKarma))successBlock
				failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

//------------------------------------------------------------------------
#pragma mark - Posts

- (void)getPostsFromPageLink:(NSString *)pageLink
						page:(NSInteger)page
					treshold:(NSString*)treshold
					 success:(void (^)(NSString* postsPage))successBlock
					 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)getPostsFromMainPage:(NSInteger)page
						type:(NSString*)type
					treshold:(NSString*)treshold
					 success:(void (^)(NSString* postsPage))successBlock
					 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)addPostToFavourites:(LepraPost*)post
				   success:(void (^)())successBlock
				   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)removePostFromFavourites:(LepraPost*)post
				   success:(void (^)())successBlock
				   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)addPostToMyThings:(LepraPost*)post
					success:(void (^)())successBlock
					failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)removePostFromMyThings:(LepraPost*)post
				   success:(void (^)())successBlock
				   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

//------------------------------------------------------------------------
#pragma mark - Post comments

- (void)getCommentsByPost:(LepraPost *)post
				  success:(void (^)(NSString* commentsPage))successBlock
				  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)setCommentsReadedForPost:(LepraPost *)post currentEpoche:(NSNumber*)epoche;

- (void)plusPostId:(NSString*)postID
		   success:(void (^)(NSString* newRating))successBlock
		   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)minusPostId:(NSString*)postID
		   success:(void (^)(NSString* newRating))successBlock
		   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)plusCommentId:(NSString*)commentID
		   success:(void (^)(NSString* newRating))successBlock
		   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)minusCommentId:(NSString*)commentID
			success:(void (^)(NSString* newRating))successBlock
			failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;


- (void)sendInboxCommentWithText:(NSString*)text
						 forPost:(LepraPost*)post
					  forComment:(LepraComment*)comment
						 mediaId:(NSString*)mediaId
						 success:(void (^)())successBlock
						 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)sendPostCommentWithText:(NSString*)text
						forPost:(LepraPost*)post
					 forComment:(LepraComment*)comment
						mediaId:(NSString*)mediaId
						success:(void (^)())successBlock
						failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)uploadPhoto:(UIImage*)photo
	  progressBlock:(void (^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
			success:(void (^)(NSString* mediaId))successBlock
			failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

//------------------------------------------------------------------------
#pragma mark - Underground

- (void)subscribeDomainId:(NSString*)domainId
				  success:(void (^)())successBlock
				  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;
- (void)unsubscribeDomainId:(NSString*)domainId
				  success:(void (^)())successBlock
				  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)subscribeMyThingsDomainId:(NSString*)domainId
				  success:(void (^)())successBlock
				  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;
- (void)unsubscribeMyThingsDomainId:(NSString*)domainId
					success:(void (^)())successBlock
					failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;

- (void)searchUndergroundWithQuery:(NSString*)query
						   success:(void (^)(NSDictionary *domains))successBlock
						   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;


@end
