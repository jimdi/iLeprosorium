//
//  LepraAPIManager.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraAPIManager.h"
#import <AFHTTPRequestOperation.h>
#import <Foundation/NSURLResponse.h>
#import <TFHpple.h>
#import <AFJSONRequestOperation.h>

// API endpoints
#define API_ENDPOINT_AUTH						@"ajax/auth/login"
#define API_ENDPOINT_USERS						@"users/%@"
#define API_ENDPOINT_USERS_POSTS				@"users/%@/posts/pages/%zd"
#define API_ENDPOINT_USERS_COMMENTS				@"users/%@/comments/pages/%zd"
#define API_ENDPOINT_LOGIN						@"login"
#define API_ENDOINT_UNDERGROUND					@"underground"
#define API_ENDPOINT_ADD_TO_FAVOURITES			@"ajax/favourites/in"
#define API_ENDPOINT_REMOVE_FROM_FAVOURITES		@"ajax/favourites/out"
#define API_ENDPOINT_ADD_TO_MY_THINGS			@"ajax/interest/in"
#define API_ENDPOINT_REMOVE_FROM_MY_THINGS		@"ajax/interest/out"
#define API_ENDPOINT_USER_KARMA_VOTE			@"ajax/user/karma/vote"
#define API_ENDPOINT_POST_VOTE					@"ajax/vote/post"
#define API_ENDPOINT_COMMENT_VOTE				@"ajax/vote/comment"

#define API_ENDPOINT_POST_MARK_AS_READ			@"ajax/post_view"

#define API_ENDPOINT_FEED_SUBSCRIBE				@"ajax/feeds/domains/subscribe"
#define API_ENDPOINT_FEED_UNSUBSCRIBE			@"ajax/feeds/domains/unsubscribe"
#define API_ENDPOINT_MY_THINGS_SUBSCRIBE		@"ajax/my/subscribe_domain"
#define API_ENDPOINT_MY_THINGS_UNSUBSCRIBE		@"ajax/my/unsubscribe_domain"
#define API_ENDPOINT_BLOGS_SEARCH				@"ajax/blogs/search"


#define API_ENDPOINT_SEND_INBOX_COMMENT			@"ajax/inbox/comment/yarrr"
#define API_ENDPOINT_SEND_POST_COMMENT			@"ajax/comment/yarrr"

#define API_ENDPOINT_MEDIA						@"ajax/media"

#define API_ENDPOINT_INDEX_MOAR					@"ajax/index/moar"



#define LOGIN_TOKEN_KEY				@"csrf_token"
#define LOGIN_COOKIE_KEY			@"Set-Cookie"

@interface LepraAPIManager()

@property (strong, nonatomic) NSString *lastPath;

@end

@implementation LepraAPIManager

//------------------------------------------------------------------------
#pragma mark - Singleton

static LepraAPIManager *__sharedInstance;
static dispatch_once_t onceToken;

+ (instancetype)sharedManager
{
	dispatch_once(&onceToken, ^{
		__sharedInstance = [[LepraAPIManager alloc] init];
	});
	return __sharedInstance;
}


- (id)init
{
	self = [super init];
	if (self) {
		
		self.HTTPClient = [LepraHTTPClient sharedClient];
	}
	return self;
}

//------------------------------------------------------------------------
#pragma mark - Fun killer

- (void)stopLastRequest
{
	[self.HTTPClient cancelAllHTTPOperationsWithMethod:nil path:self.lastPath];
}


//------------------------------------------------------------------------
#pragma mark - Authorization / Registration

- (void)loginWithLogin:(NSString *)login
			  password:(NSString *)password
	recaptchaChallenge:(NSString*)recaptchaChallenge
				capcha:(NSString*)capcha
			   success:(void (^)())successBlock
			   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{	
	NSMutableDictionary *tokenParams = [[NSMutableDictionary alloc] initWithDictionary: @{@"username" : [login stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								  @"password" : [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
								  @"forever" : @"1"
								  }];
	
	if (![LepraGeneralHelper isEmpty:recaptchaChallenge]) {
		[tokenParams setObject:recaptchaChallenge forKey:@"recaptcha_challenge_field"];
		[tokenParams setObject:capcha forKey:@"recaptcha_response_field"];
	}
	
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_AUTH parameters:tokenParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSLog(@"HEADER FIELDS: %@", operation.response.allHeaderFields);
		NSLog(@"AUTH RESPONSE: %@", responseObject);
		
		if ([responseObject isKindOfClass:[NSDictionary class]]) {
			if (responseObject[@"errors"]) {
				NSArray *errors = responseObject[@"errors"];
				if ([errors.firstObject[@"code"] isEqualToString:@"captcha_required"]) {
					failureBlock(operation, [NSError errorWithDomain:@"captcha_required" code:0 userInfo:nil]);
				} else if ([errors.firstObject[@"code"] isEqualToString:@"invalid_password"]) {
					failureBlock(operation, [NSError errorWithDomain:@"invalid_password" code:0 userInfo:nil]);
				} else {
					failureBlock(operation, nil);
				}
			} else {
				NSDictionary *userData = responseObject[@"user"];
				NSMutableDictionary *userDict = [[NSMutableDictionary alloc] init];
				for (NSString *userKey in userData.allKeys) {
					if (![LepraGeneralHelper isNull:userData[userKey]]) {
						[userDict setObject:userData[userKey] forKey:userKey];
					}
				}
				
				NSString *token = responseObject[LOGIN_TOKEN_KEY];
				NSString *cookieString = operation.response.allHeaderFields[LOGIN_COOKIE_KEY];
				NSString *uid;
				NSString *sid;
				if ([cookieString rangeOfString:@"uid"].location != NSNotFound) {
					NSArray *uidArray = [[[cookieString componentsSeparatedByString:@";"] firstObject] componentsSeparatedByString:@"="];
					if (uidArray.count>1) {
						uid = uidArray[1];
					}
				}
				if ([cookieString rangeOfString:@"sid"].location != NSNotFound) {
					NSArray *sidArray = [[[cookieString componentsSeparatedByString:@";"] firstObject] componentsSeparatedByString:@"="];
					if (sidArray.count>1) {
						sid = sidArray[1];
					}
				}
				
				if (![LepraGeneralHelper isEmpty:token] && ![LepraGeneralHelper isEmpty:uid] && ![LepraGeneralHelper isEmpty:sid]) {
					[DEFAULTS setObject:token forKey:DEF_KEY_AUTH_TOKEN];
					[DEFAULTS setObject:uid forKey:DEF_KEY_AUTH_UID];
					[DEFAULTS setObject:sid forKey:DEF_KEY_AUTH_SID];
					[DEFAULTS setObject:userDict forKey:DEF_KEY_USER];
					[DEFAULTS setObject:login forKey:DEF_KEY_LOGIN_EMAIL];
					[DEFAULTS setObject:password forKey:DEF_KEY_LOGIN_PASSWORD];
					[self.HTTPClient setDefaultHeader:@"uid" value:uid];
					[self.HTTPClient setDefaultHeader:@"sid" value:sid];
					[DEFAULTS synchronize];
					successBlock();
				} else {
					failureBlock(operation, nil);
				}
			}
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"ERROR: %@", error);
		failureBlock(operation, nil);
	}];

}

- (void)logout
{
	for (NSString *key in KEYS_TO_CLEAN_AFTER_LOGOUT) {
		[DEFAULTS removeObjectForKey:key];
	}
	[self.HTTPClient setDefaultHeader:@"uid" value:@""];
	[self.HTTPClient setDefaultHeader:@"sid" value:@""];
	NSHTTPCookie *cookie;
	NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (cookie in [storage cookies]) {
		[storage deleteCookie:cookie];
	}
	[DEFAULTS synchronize];
}

- (void)getLoginPageWithSuccess:(void (^)(NSString* loginPage))successBlock
						failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self logout];
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[self.HTTPClient getPath:API_ENDPOINT_LOGIN parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString* loginPageString = operation.responseString;
		successBlock(loginPageString);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

//------------------------------------------------------------------------
#pragma mark - User

- (void)getUserByUserName:(NSString *)userName
				  success:(void (^)(NSString* userPage))successBlock
			   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock {
	
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[self.HTTPClient getPath:[NSString stringWithFormat:API_ENDPOINT_USERS, userName] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString* userPageString = operation.responseString;
		[self updateGertrudaAndTagline:userPageString];
		successBlock(userPageString);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)getPostsByUserName:(NSString *)userName
					  page:(NSInteger)page
				   success:(void (^)(NSString* postsPage))successBlock
				   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[self.HTTPClient getPath:[NSString stringWithFormat:API_ENDPOINT_USERS_POSTS, userName, page] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString* postsPageString = operation.responseString;
		[self updateGertrudaAndTagline:postsPageString];
		successBlock(postsPageString);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)getCommentsByUserName:(NSString *)userName
						 page:(NSInteger)page
					  success:(void (^)(NSString* commentsPage))successBlock
					  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[self.HTTPClient getPath:[NSString stringWithFormat:API_ENDPOINT_USERS_COMMENTS, userName, page] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString* postsPageString = operation.responseString;
		[self updateGertrudaAndTagline:postsPageString];
		successBlock(postsPageString);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)setKarmaForUser:(LepraProfile *)profile
				   success:(void (^)(NSString* newKarma))successBlock
				   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	NSInteger karmaValue = 0;
	if (profile.leftPlusEnabled.boolValue) {
		karmaValue +=1;
	}
	if (profile.rightPlusEnabled.boolValue) {
		karmaValue +=1;
	}
	if (profile.leftMinusEnabled.boolValue) {
		karmaValue -=1;
	}
	if (profile.rightMinusEnabled.boolValue) {
		karmaValue -=1;
	}
	[self.HTTPClient postPath:API_ENDPOINT_USER_KARMA_VOTE parameters:@{@"user":profile.userId, @"karma_value": @(karmaValue), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock([responseObject[@"karma"] stringValue]);
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

//------------------------------------------------------------------------
#pragma mark - Posts

// treshold =	"disabled"	// NIGHTMARE (ВСЁ)
//				"-25"		// HARDCORE
//				"-5"		// HARD
//				"0"			// NORMAL
//				"5"			// MEDIUM
//				"25"		// EASY

- (void)getPostsFromPageLink:(NSString *)pageLink
						page:(NSInteger)page
					treshold:(NSString*)treshold
					 success:(void (^)(NSString* postsPage))successBlock
					 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[self.HTTPClient getPath:[NSString stringWithFormat:@"https://%@", pageLink] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString* postsPageString = operation.responseString;
		[self updateGertrudaAndTagline:postsPageString];
	} failure:nil];
	
	NSDictionary *params = @{ @"csrf_token": DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN),
							  @"offset" : @((page-1)*42),
							  @"sorting" : @"last_activity",
							  @"threshold" : treshold};
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:[NSString stringWithFormat:@"https://%@/%@", pageLink, API_ENDPOINT_INDEX_MOAR] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		successBlock(responseObject[@"template"]);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

// type =	"mixed"
//			"main"
//			"personal"
// treshold =	"disabled"	// NIGHTMARE (ВСЁ)
//				"0"			// HARDCORE
//				"50"		// HARD
//				"250"		// NORMAL
//				"500"		// MEDIUM
//				"1000"		// EASY

- (void)getPostsFromMainPage:(NSInteger)page
						type:(NSString*)type
					treshold:(NSString*)treshold
					 success:(void (^)(NSString* postsPage))successBlock
					 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[self.HTTPClient getPath:[NSString stringWithFormat:@"https://%@", MAIN_PAGE_LINK] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString* postsPageString = operation.responseString;
		[self updateGertrudaAndTagline:postsPageString];
	} failure:nil];
	
	NSDictionary *params = @{ @"csrf_token": DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN),
							  @"offset" : @((page-1)*42),
							  @"sorting" : @"last_activity",
							  @"feed_type" : type,
							  @"threshold" : treshold};
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_INDEX_MOAR parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		successBlock(responseObject[@"template"]);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)addPostToFavourites:(LepraPost*)post
					success:(void (^)())successBlock
					failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	NSString *postId = [[post.link componentsSeparatedByString:@"/"] lastObject];
	[self.HTTPClient postPath:API_ENDPOINT_ADD_TO_FAVOURITES parameters:@{@"post":postId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)removePostFromFavourites:(LepraPost*)post
				   success:(void (^)())successBlock
				   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	NSString *postId = [[post.link componentsSeparatedByString:@"/"] lastObject];
	[self.HTTPClient postPath:API_ENDPOINT_REMOVE_FROM_FAVOURITES parameters:@{@"post":postId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)addPostToMyThings:(LepraPost*)post
				  success:(void (^)())successBlock
				  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	NSString *postId = [[post.link componentsSeparatedByString:@"/"] lastObject];
	[self.HTTPClient postPath:API_ENDPOINT_ADD_TO_MY_THINGS parameters:@{@"post":postId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)removePostFromMyThings:(LepraPost*)post
					   success:(void (^)())successBlock
					   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	NSString *postId = [[post.link componentsSeparatedByString:@"/"] lastObject];
	[self.HTTPClient postPath:API_ENDPOINT_REMOVE_FROM_MY_THINGS parameters:@{@"post":postId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

//------------------------------------------------------------------------
#pragma mark - Post comments

- (void)getCommentsByPost:(LepraPost *)post
					  success:(void (^)(NSString* commentsPage))successBlock
					  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"text/hmtl"];
	[self.HTTPClient getPath:post.link parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSString* postsPageString = operation.responseString;
		[self updateGertrudaAndTagline:postsPageString];
		successBlock(postsPageString);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)setCommentsReadedForPost:(LepraPost *)post currentEpoche:(NSNumber*)epoche {
	if (![LepraGeneralHelper isNull:epoche]) {
		[self.HTTPClient setDefaultHeader:@"Accept" value:@"text/hmtl"];
		[self.HTTPClient postPath:API_ENDPOINT_POST_MARK_AS_READ parameters:@{@"post_id" : post.remoteId, @"timestamp" : epoche, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSString* postsPageString = operation.responseString;
			[self updateGertrudaAndTagline:postsPageString];
	//		successBlock(postsPageString);
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSLog(@"ERROR");
	//		failureBlock(operation, error);
		}];
	}
}

- (void)plusPostId:(NSString*)postID
		   success:(void (^)(NSString* newRating))successBlock
		   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_POST_VOTE parameters:@{@"doc":postID, @"vote":@(1), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock([responseObject[@"rating"] stringValue]);
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)minusPostId:(NSString*)postID
			success:(void (^)(NSString* newRating))successBlock
			failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_POST_VOTE parameters:@{@"doc":postID, @"vote":@(-1), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock([responseObject[@"rating"] stringValue]);
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)plusCommentId:(NSString*)commentID
		   success:(void (^)(NSString* newRating))successBlock
		   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_COMMENT_VOTE parameters:@{@"doc":commentID, @"vote":@(1), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock([responseObject[@"rating"] stringValue]);
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)minusCommentId:(NSString*)commentID
			   success:(void (^)(NSString* newRating))successBlock
			   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_COMMENT_VOTE parameters:@{@"doc":commentID, @"vote":@(-1), @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock([responseObject[@"rating"] stringValue]);
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)sendInboxCommentWithText:(NSString*)text
						 forPost:(LepraPost*)post
					  forComment:(LepraComment*)comment
						 mediaId:(NSString*)mediaId
						 success:(void (^)())successBlock
						 failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	NSString *postId = [[post.link componentsSeparatedByString:@"/"] lastObject];
	[self.HTTPClient postPath:API_ENDPOINT_SEND_INBOX_COMMENT parameters:@{@"parent":[LepraGeneralHelper coalesce:comment.commentId with:@""], @"post":postId, @"body":text, @"media":mediaId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)sendPostCommentWithText:(NSString*)text
						forPost:(LepraPost*)post
					 forComment:(LepraComment*)comment
						mediaId:(NSString*)mediaId
						success:(void (^)())successBlock
						failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	NSString *postId = [[post.link componentsSeparatedByString:@"/"] lastObject];
	[self.HTTPClient postPath:API_ENDPOINT_SEND_POST_COMMENT parameters:@{@"parent":[LepraGeneralHelper coalesce:comment.commentId with:@""], @"post":postId, @"body":text, @"media":mediaId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)uploadPhoto:(UIImage*)photo
	  progressBlock:(void (^)(long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock
			success:(void (^)(NSString* mediaId))successBlock
			failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock;
{
	NSMutableURLRequest *request = [self.HTTPClient multipartFormRequestWithMethod:@"POST" path:API_ENDPOINT_MEDIA parameters:@{@"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
		
		NSData *imageToUpload = UIImageJPEGRepresentation(photo, 1.0);
		if (imageToUpload)
		{
			[formData appendPartWithFileData:imageToUpload name:@"file" fileName:[[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".jpeg"] mimeType:@"image/jpeg"];
		}
	}];
	
	[request setValue:@"utf-8" forHTTPHeaderField:@"Content-Encoding"];
	
	AFJSONRequestOperation *operation = [[AFJSONRequestOperation alloc] initWithRequest:request];
	
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
		
		if (responseObject[@"status"] && [responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock(responseObject[@"media_id"]);
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
	
	[operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
		progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
	}];
	
	[operation start];
}

//------------------------------------------------------------------------
#pragma mark - Underground

- (void)subscribeDomainId:(NSString*)domainId
				  success:(void (^)())successBlock
				  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_FEED_SUBSCRIBE parameters:@{@"domain":domainId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)unsubscribeDomainId:(NSString*)domainId
					success:(void (^)())successBlock
					failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_FEED_UNSUBSCRIBE parameters:@{@"domain":domainId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)subscribeMyThingsDomainId:(NSString*)domainId
						  success:(void (^)())successBlock
						  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_MY_THINGS_SUBSCRIBE parameters:@{@"domain":domainId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)unsubscribeMyThingsDomainId:(NSString*)domainId
							success:(void (^)())successBlock
							failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_MY_THINGS_UNSUBSCRIBE parameters:@{@"domain":domainId, @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock();
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

- (void)searchUndergroundWithQuery:(NSString*)query
						   success:(void (^)(NSDictionary *domains))successBlock
						   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failureBlock
{
	[self.HTTPClient setDefaultHeader:@"Accept" value:@"application/json"];
	[self.HTTPClient postPath:API_ENDPOINT_BLOGS_SEARCH parameters:@{@"offset":@(0), @"query" : [query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"csrf_token":DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
		if ([responseObject[@"status"] isEqualToString:@"OK"]) {
			successBlock(responseObject);
		} else {
			failureBlock(operation, nil);
		}
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		failureBlock(operation, error);
	}];
}

//------------------------------------------------------------------------
#pragma mark - Other

- (void)updateGertrudaAndTagline:(NSString*)page
{
	TFHpple *pageNode = [TFHpple hppleWithHTMLData:[page dataUsingEncoding:NSUTF8StringEncoding]];
	NSArray *gertrudaNodes = [pageNode searchWithXPathQuery:@"//*[@class='b-gertruda']//img"];
	NSArray *taglineNodes = [pageNode searchWithXPathQuery:@"//*[@class='b-header_tagline']"];
	NSArray *myThingsCount = [pageNode searchWithXPathQuery:@"//*[@id='js-header_nav_my_things']"];
	NSArray *inboxCount = [pageNode searchWithXPathQuery:@"//*[@id='js-header_nav_inbox']"];
	
	if (gertrudaNodes.count>0) {
		[DEFAULTS setObject:[(TFHppleElement*)gertrudaNodes.firstObject attributes][@"src"] forKey:GERTRUDA_LINK];
	}
	if (taglineNodes.count>0) {
		TFHppleElement *taglineElement = [taglineNodes firstObject];
		NSMutableString* taglineString = [[NSMutableString alloc] init];
		for (TFHppleElement *child in taglineElement.children) {
			if (child.isTextNode) {
				[taglineString appendString:[self clearNodeText:child.content]];
			} else if ([child.tagName isEqualToString:@"a"]) {
				[taglineString appendString:[self clearNodeText:child.firstTextChild.content]];
			}
		}
		[DEFAULTS setObject:taglineString forKey:TAGLINE_TEXT];
	}
	
	if (myThingsCount.count>0) {
		TFHppleElement *myThingsCountElement = [myThingsCount firstObject];
		NSString* myThings = myThingsCountElement.firstChild.firstTextChild.content;
		myThings = [myThings stringByReplacingOccurrencesOfString:@"мои вещи" withString:@""];
		while ([myThings hasSuffix:@" "]) {
			myThings = [myThings substringToIndex:myThings.length-1];
		}
		while ([myThings hasPrefix:@" "]) {
			myThings = [myThings substringFromIndex:1];
		}
		[DEFAULTS setObject:myThings forKey:MY_THINGS_COUNT];
	}
	
	if (inboxCount.count>0) {
		TFHppleElement *inboxCountElement = [inboxCount firstObject];
		NSString* inbox = [inboxCountElement.children.lastObject firstTextChild].content;
		while ([inbox hasSuffix:@" "]) {
			inbox = [inbox substringToIndex:inbox.length-1];
		}
		while ([inbox hasPrefix:@" "]) {
			inbox = [inbox substringFromIndex:1];
		}
		[DEFAULTS setObject:inbox forKey:INBOX_COUNT];
	}
	
	[DEFAULTS synchronize];
}

- (NSString*)clearNodeText:(NSString*)nodeText {
	NSString* returnString = [nodeText mutableCopy];
	NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\n\n*\t*" options:0 error:NULL];
	returnString = [re stringByReplacingMatchesInString:returnString options:0 range:NSMakeRange(0, returnString.length) withTemplate:@""];
	returnString = [returnString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	return returnString;
}

@end