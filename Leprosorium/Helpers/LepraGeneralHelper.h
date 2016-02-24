//
//  LepraGeneralHelper.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFHTTPClient.h>
#import <TSMessage.h>
#import <Colours.h>

#define NEW_BUNDLE_VERSION_MAKES_RELOGIN YES

#define DEFAULTS [NSUserDefaults standardUserDefaults]
#define DEFAULTS_OBJ(__KEY__) [[NSUserDefaults standardUserDefaults] objectForKey:__KEY__]
#define SIGNUP_FOR_NOTIFICATION(__NAME__,__SELECTOR__) [[NSNotificationCenter defaultCenter] addObserver:self selector:__SELECTOR__ name:__NAME__ object:nil]
#define REMOVE_NOTIFICATION(__NAME__) [[NSNotificationCenter defaultCenter] removeObserver:self name:__NAME__ object:nil]
#define POST_NOTIFICATION(__NAME__) [[NSNotificationCenter defaultCenter] postNotificationName:__NAME__ object:nil userInfo:nil]
#define COLOR_FROM_HEX(__R__, __G__, __B__) [UIColor colorWithRed:1.*__R__/0xff green:1.*__G__/0xff blue:1.*__B__/0xff alpha:1.]
#define COLOR_FROM_GENERIC_HEX(__R__, __G__, __B__) [UIColor colorWithRed:1.*(__R__+0x10)/0xff green:1.*(__G__+0x17)/0xff blue:1.*(__B__+0xb)/0xff alpha:1.]
#define COLOR_FROM_HEX_ALPHA(__R__, __G__, __B__, __ALPHA__) [UIColor colorWithRed:1.*__R__/0xff green:1.*__G__/0xff blue:1.*__B__/0xff alpha:__ALPHA__]
#define COLOR_FROM_GENERIC_HEX_ALPHA(__R__, __G__, __B__, __ALPHA__) [UIColor colorWithRed:1.*(__R__+0x10)/0xff green:1.*(__G__+0x17)/0xff blue:1.*(__B__+0xb)/0xff alpha:__ALPHA__]

#define NSLS(__KEY__) NSLocalizedString(__KEY__, __KEY__)
#define DOCUMENTS_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Defaults keys
// after login
#define DEF_KEY_CURRENT_USER_ID                 @"DEF_KEY_CURRENT_USER_ID"
#define DEF_KEY_LOGIN_EMAIL						@"DEF_KEY_LOGIN_LOGIN"
#define DEF_KEY_LOGIN_PASSWORD					@"DEF_KEY_LOGIN_PASSWORD"
#define DEF_KEY_AUTH_TOKEN                      @"DEF_KEY_AUTH_TOKEN"
#define DEF_KEY_AUTH_UID						@"DEF_KEY_AUTH_UID"
#define DEF_KEY_AUTH_SID						@"DEF_KEY_AUTH_SID"

#define DEF_KEY_USER							@"DEF_KEY_USER"

#define KEYS_TO_CLEAN_AFTER_LOGOUT              @[DEF_KEY_AUTH_TOKEN, DEF_KEY_CURRENT_USER_ID, DEF_KEY_LOGIN_PASSWORD, DEF_KEY_AUTH_UID, DEF_KEY_AUTH_SID, DEF_KEY_USER]

// other
#define DEF_KEY_PUSH_NOTIFICATION				@"remoteNotification"
#define DEF_KEY_BUNDLE_VERSION					@"bundleVersion"
#define DEF_KEY_PUSH_DEVICE_TOKEN				@"pushDeviceToken"
#define DEF_KEY_SERVER_URL						@"DEF_KEY_SERVER_URL"

// Menu shit
#define kMenuItemKeyProfile						@"menu_item_profile"
#define kMenuItemKeyMain						@"menu_item_main"
#define kMenuItemKeyMyThings					@"menu_item_my_things"
#define kMenuItemKeyFavourites					@"menu_item_favourites"
#define kMenuItemKeyInbox						@"menu_item_inbox"
#define kMenuItemKeyUnderground					@"menu_item_underground"
#define kMenuItemKeyPrefs						@"menu_item_prefs"
#define kMenuItemKeyAbout						@"menu_item_about"
#define kMenuItemKeyLogout						@"menu_item_logout"
#define kMenuItemKeyHeader						@"kMenuItemKeyHeader"


// GAI LOGGER
#define GAI_CATEGORY_WARNINGS					@"WARNINGS"

// PREFS
#define DEF_KEY_PREFS_LOAD_IMAGE				@"DEF_KEY_PREFS_LOAD_IMAGE"

#define MAIN_PAGE_LINK							@"leprosorium.ru"
#define DEF_KEY_TRESHOLD_DICT					@"DEF_KEY_TRESHOLD_DICT"
#define DEF_KEY_MAIN_PAGE_TYPE					@"DEF_KEY_MAIN_PAGE_TYPE"
#define DEF_KEY_MENU_UNDERGROUNDS				@"DEF_KEY_MENU_UNDERGROUNDS"

#define DEF_KEY_MY_THINGS_DICT					@"DEF_KEY_MY_THINGS_DICT"
#define kMyThingsDictSort						@"kMyThingsDictSort"
#define kMyThingsDictPeriod						@"kMyThingsDictPeriod"
#define kMyThingsDictUnread						@"kMyThingsDictUnread"
#define DEF_KEY_FAVOURITE_SORT					@"DEF_KEY_FAVOURITE_SORT"

#define kUndergroundItemKeyImageLink			@"kUndergroundItemKeyImageLink"
#define kUndergroundItemKeyLink					@"kUndergroundItemKeyLink"

// NOTIFICATION
#define NOTIFICATION_NEED_RELOAD_COMMENTS		@"NOTIFICATION_NEED_RELOAD_COMMENTS"


#if TARGET_IPHONE_SIMULATOR
#define IS_SIMULATOR YES
#else
#define IS_SIMULATOR NO
#endif

#define TEXT_FONT [UIFont fontWithName:@"Verdana" size:12.0]
#define TEXT_FONT_BOLD [UIFont fontWithName:@"Verdana-Bold" size:12.0]
#define TEXT_FONT_ITALIC [UIFont fontWithName:@"Verdana-Italic" size:12.0]

@interface LepraGeneralHelper : NSObject

+ (NSString *)dateStringFromDate:(NSDate *)date;
+ (NSString *)timeStringFromDate:(NSDate *)date;

+ (BOOL)isNull:(id)object;
+ (BOOL)isEmpty:(id)object;
+ (id)coalesce: (NSObject*)object with:(NSObject*)fallback;

+ (NSInteger)randomWithMin:(NSInteger)min max:(NSInteger)max;

+ (NSInteger)effectiveIndexFromIndex:(NSInteger)index;
+ (NSString *)applicationVersion;
+ (NSString *)buildVersion;
+ (NSString *)deviceID;
+ (NSString *)screenResolutionString;
+ (void)updateCrashlyticsAndGAIValues;
+ (BOOL)userIsAuthorized;

+ (NSString *)apiBase;
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message;

// frames shit
+ (void)showFrameOfView:(UIView *)view withColor:(UIColor *)color;

+ (void)setOriginY:(CGFloat)originY forView:(UIView *)view;
+ (void)setOriginX:(CGFloat)originX forView:(UIView *)view;;

+ (void)setCenterY:(CGFloat)centerY forView:(UIView *)view;
+ (void)setCenterX:(CGFloat)centerX forView:(UIView *)view;

+ (UIImageView *)findHairlineImageViewUnder:(UIView *)view;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color;
+ (UIColor *)redColor;
+ (UIColor *)redColorLight;
+ (UIColor *)blueColor;
+ (UIColor *)tableViewColor;

+ (NSArray *)parseText:(NSString *)text;

+ (NSAttributedString *)addFacebookParagraphToString:(NSAttributedString *)string;

+ (void)sendEventWithCategory:(NSString *)category
action:(NSString *)action
						label:(NSString *)label
						value:(NSNumber *)value;

@end

@interface UIView(Additions)
+ (id)loadFromNib;
@end

@interface NSString(Additions)
- (BOOL)isValid;
@end

@interface NSAttributedString(Additions)
- (BOOL)isValid;
@end

@interface AFHTTPClient(Additions)
- (void)removeDefaultHeader:(NSString *)header;
@end
