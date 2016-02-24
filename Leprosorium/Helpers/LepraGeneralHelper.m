//
//  LepraGeneralHelper.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraGeneralHelper.h"

#import <hpple/TFHpple.h>
#import "NSString+HTML.h"
#import "GAIDictionaryBuilder.h"

@implementation LepraGeneralHelper

+ (NSString *)dateStringFromDate:(NSDate *)date
{
	if (date) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"yyyy-MM-dd"];
		return [df stringFromDate:date];
	}
	return @"";
}

+ (NSString *)timeStringFromDate:(NSDate *)date
{
	if (date) {
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		[df setDateFormat:@"HH:mm"];
		return [df stringFromDate:date];
	}
	return @"";
}

+ (BOOL)isNull: (NSObject*)object
{
	if ((object == nil) || (object == NULL) || (object == [NSNull null]))
		return true;
	else
		return false;
}

+ (id)coalesce: (NSObject*)object with:(NSObject*)fallback
{
	if ([LepraGeneralHelper isNull:object]) {
		return fallback;
	}
	return object;
}

+ (NSInteger)randomWithMin:(NSInteger)min max:(NSInteger)max
{
	return min + arc4random_uniform((uint)max - (uint)min + 1);
}

+ (BOOL)isEmpty:(id)object
{
	if ([object isKindOfClass:[NSString class]]) {
		return ([LepraGeneralHelper isNull:object] || [object isEqualToString:@""]);
	} else if ([object isKindOfClass:[NSArray class]]) {
		return ([LepraGeneralHelper isNull:object] || [object count]==0);
	} else if ([object isKindOfClass:[NSDictionary class]]) {
		return ([LepraGeneralHelper isNull:object] || [(NSDictionary*)object allKeys].count==0);
	}
	return [LepraGeneralHelper isNull:object];
}

+ (NSInteger)effectiveIndexFromIndex:(NSInteger)index
{
	return index % 10 == 1 && index % 100 != 11 ? 0 : (index % 10 >= 2 && index % 10 <= 4 && (index % 100 < 10 || index % 100 >= 20) ? 1 : 2);
}

+ (NSString *)applicationVersion
{
	return [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
}

+ (NSString *)buildVersion
{
	return [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

+ (NSString *)deviceID
{
	NSString *UUID =  [[[UIDevice currentDevice] identifierForVendor] UUIDString];
	return UUID;
}

+ (NSString *)screenResolutionString
{
	return [NSString stringWithFormat:@"%.0fx%.0f@%.0f", [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].scale];
}

+ (void)updateCrashlyticsAndGAIValues
{
	if ([self userIsAuthorized]) {
//		User *profile = [[DOAPIManager sharedManager] fetchOwnProfile];
//		
//		NSString *userIdString = [NSString stringWithFormat:@"%@", DEFAULTS_OBJ(DEF_KEY_CURRENT_USER_ID)];
//		NSString *authToken = [NSString stringWithFormat:@"%@", DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)];
//		NSString *companyTitle = [NSString stringWithFormat:@"%@", DEFAULTS_OBJ(DEF_KEY_COMPANY_TITLE)];
//		NSString *userName = [NSString stringWithFormat:@"%@", profile.fullName];
//		NSString *userEmail = [NSString stringWithFormat:@"%@", DEFAULTS_OBJ(DEF_KEY_LOGIN_EMAIL)];
//		NSString *baseURL = DEFAULTS_OBJ(DEF_KEY_SERVER_URL);
//		
//		Crashlytics *crashlytics = [Crashlytics sharedInstance];
//		[crashlytics setUserIdentifier:userIdString];
//		[crashlytics setUserName:userName];
//		[crashlytics setUserEmail:userEmail];
//		
//		[crashlytics setObjectValue:authToken forKey:@"authentication_token"];
//		[crashlytics setObjectValue:companyTitle forKey:@"company_title"];
//		[crashlytics setObjectValue:baseURL forKey:@"base_url"];
//		
//		id<GAITracker> defaultTracker = [[GAI sharedInstance] defaultTracker];
//		[defaultTracker set:@"&uid" value:userIdString];
//		[defaultTracker set:@"authentication_token" value:authToken];
//		[defaultTracker set:@"company_title" value:companyTitle];
//		[defaultTracker set:@"base_url" value:baseURL];
	}
}

+ (BOOL)userIsAuthorized
{
	if (DEFAULTS_OBJ(DEF_KEY_AUTH_TOKEN)) {
		return YES;
	}
	return NO;
}

+ (NSString *)apiBase
{
	NSString *savedBase = DEFAULTS_OBJ(DEF_KEY_SERVER_URL);
	return savedBase? savedBase : @"";
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
	});
}

+ (void)showFrameOfView:(UIView *)view withColor:(UIColor *)color
{
	view.layer.borderColor = [color CGColor];
	view.layer.borderWidth = 1.0/[UIScreen mainScreen].scale;
}

+ (void)setOriginY:(CGFloat)originY forView:(UIView *)view
{
	CGRect viewsFrame = view.frame;
	viewsFrame.origin.y = originY;
	[view setFrame:viewsFrame];
}

+ (void)setOriginX:(CGFloat)originX forView:(UIView *)view;
{
	CGRect viewsFrame = view.frame;
	viewsFrame.origin.x = originX;
	[view setFrame:viewsFrame];
}

+ (void)setCenterY:(CGFloat)centerY forView:(UIView *)view
{
	CGPoint viewsCenter = view.center;
	viewsCenter.y = centerY;
	[view setCenter:viewsCenter];
}

+ (void)setCenterX:(CGFloat)centerX forView:(UIView *)view
{
	CGPoint viewsCenter = view.center;
	viewsCenter.x = centerX;
	[view setCenter:viewsCenter];
}

+ (UIImageView *)findHairlineImageViewUnder:(UIView *)view
{
	if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
		return (UIImageView *)view;
	}
	for (UIView *subview in view.subviews) {
		UIImageView *imageView = [LepraGeneralHelper findHairlineImageViewUnder:subview];
		if (imageView) {
			return imageView;
		}
	}
	return nil;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

+ (UIImage *)tintImage:(UIImage *)image withColor:(UIColor *)color
{
	UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0, image.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	CGContextClipToMask(context, rect, image.CGImage);
	[color setFill];
	CGContextFillRect(context, rect);
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

+ (UIColor *)redColor
{
	return COLOR_FROM_GENERIC_HEX(0xb1, 0x0c, 0x20);
}

+ (UIColor *)redColorLight
{
	return COLOR_FROM_HEX(0xd8, 0x86, 0x90);
}

+ (UIColor *)blueColor
{
	return COLOR_FROM_HEX(0x32, 0x6c, 0xcd);
}

+ (UIColor *)tableViewColor
{
	return [UIColor colorWithWhite:0.95 alpha:1.0];
//	return COLOR_FROM_GENERIC_HEX(0x39, 0x45, 0x5c);
}

+ (NSArray *)parseText:(NSString *)text
{
	if (!text) {
		return [NSArray array];
	}
	
	text = [text stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
	text = [text stringByDecodingHTMLEntities];
	
	TFHpple *parser = [TFHpple hppleWithHTMLData:[text dataUsingEncoding:NSUTF8StringEncoding]];
	NSArray *nodes = [parser searchWithXPathQuery:@"/*"];
	
	if (nodes.count==0) {
		return [NSArray array];
	}
	TFHppleElement *bodyNode = [nodes firstObject];
	while (bodyNode.children.count &&
		   ([[(TFHppleElement *)bodyNode.children[0] tagName] isEqualToString:@"html"] ||
			[[(TFHppleElement *)bodyNode.children[0] tagName] isEqualToString:@"body"] ||
			[[(TFHppleElement *)bodyNode.children[0] tagName] isEqualToString:@"p"])) {
			   bodyNode = bodyNode.children[0];
		   }
	
	NSMutableArray *content = [NSMutableArray array];
	
	// iterate through all the nodes and
	for (TFHppleElement *node in bodyNode.children) {
		
		//            node.tagName node.attributes node.children
		[content addObject:node];
	}
	return [content copy];
}

+ (NSAttributedString *)addFacebookParagraphToString:(NSAttributedString *)string
{
	NSMutableAttributedString* mString = [string mutableCopy];
	
	NSMutableParagraphStyle* paragraph = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	[paragraph setLineSpacing:2];
	[mString addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, mString.length)];
	
	return mString;
}

+ (void)sendEventWithCategory:(NSString *)category
					   action:(NSString *)action
						label:(NSString *)label
						value:(NSNumber *)value;
{
//	id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
//														  action:action
//														   label:label
//														   value:value] build]];
}


@end

@implementation UIView(Additions)
+ (id)loadFromNib;
{
	id view = [[[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil] objectAtIndex:0];
	return view;
}
@end

@implementation NSString(Additions)
- (BOOL)isValid
{
	return (self && ![self isEqualToString:@""]);
}
@end


@implementation NSAttributedString(Additions)
- (BOOL)isValid
{
	return (self && ![self isEqualToAttributedString:[[NSAttributedString alloc] initWithString:@""]]);
}
@end

@implementation AFHTTPClient(Additions)
- (void)removeDefaultHeader:(NSString *)header
{
	NSMutableDictionary *defaultHeaders = [self valueForKey:@"defaultHeaders"];
	[defaultHeaders removeObjectForKey:header];
}
@end