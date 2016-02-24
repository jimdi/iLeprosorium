//
//  LepraProfileUserTextCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 10.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraProfileUserTextCell.h"
#import <TTTAttributedLabel.h>

@implementation LinkObject
@end

@interface LepraProfileUserTextCell() <TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *userTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOffsetConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftOffsetView;


@end

@implementation LepraProfileUserTextCell

- (UIEdgeInsets)layoutMargins
{
	return UIEdgeInsetsMake(0, 5000, 0, 0);
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self.userTextLabel setLinkAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor],
											NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
	[self.userTextLabel setActiveLinkAttributes:@{NSForegroundColorAttributeName : [UIColor darkGrayColor],
											NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
	
	[self.leftOffsetView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

#define LEFT_RIGHT_OFFSET 8.0
#define BOTTOM_OFFSET 10.0

+ (CGFloat)cellHeightForUserText:(NSAttributedString *)userText width:(CGFloat)width
{
	return [self cellHeightForUserText:userText width:width offset:@(0)];
}

+ (CGFloat)cellHeightForUserText:(NSAttributedString*)userText width:(CGFloat)width offset:(NSNumber*)offset
{
	userText = [self clearAttributedString:userText];
	if ([LepraGeneralHelper isNull:userText]) {
		return 0.0;
	} else {
		CGFloat height = 0.0;
		CGFloat cellWidth = width - (LEFT_RIGHT_OFFSET * 2.0);
		cellWidth -= MIN(5, offset.integerValue) * LEFT_RIGHT_OFFSET;
		
		height += [TTTAttributedLabel sizeThatFitsAttributedString:userText withConstraints:CGSizeMake(cellWidth, CGFLOAT_MAX) limitedToNumberOfLines:0].height;
		height += BOTTOM_OFFSET;
		height += 1.0;
		return height;
	}
}

- (void)setUserText:(NSAttributedString*)userText links:(NSArray*)links
{
	[self setUserText:userText links:links offset:@(0)];
}

- (void)setUserText:(NSAttributedString*)userText links:(NSArray*)links offset:(NSNumber*)offset
{
	links = [LepraProfileUserTextCell clearLinks:links forString:userText];
	userText = [LepraProfileUserTextCell clearAttributedString:userText];
	[self.userTextLabel setText:userText.string];
	[self.userTextLabel setAttributedText:userText];
	[self.userTextLabel setDelegate:self];
	if (links) {
		for (LinkObject *link in links) {
			if (link.range.location!=NSNotFound) {
				[self.userTextLabel addLinkToURL:[NSURL URLWithString:link.link] withRange:link.range];
			}
		}
	}
	self.leftOffsetConstraint.constant = (MIN(5, offset.integerValue) * LEFT_RIGHT_OFFSET);
	[self.contentView layoutIfNeeded];
	[self setSeparatorInset:UIEdgeInsetsMake(0, 5000, 0, 0)];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
	NSString *link = url.absoluteString;
	if ([link rangeOfString:@"/users/"].location != NSNotFound) {
		NSRange userNameRange = [link rangeOfString:@"/users/"];
		NSString* userName = [link substringFromIndex:userNameRange.location + userNameRange.length];
		[self.cellDelegate cellAskForOpenProfile:userName];
	} else if ([link rangeOfString:@".leprosorium.ru"].location != NSNotFound) {
		NSString* undergroundName = [link stringByReplacingOccurrencesOfString:@"//" withString:@""];
		[self.cellDelegate cellAskForOpenPage:undergroundName];
	}
	[[UIApplication sharedApplication] openURL:url];
}

+ (NSAttributedString*)clearAttributedString:(NSAttributedString*)string
{
	NSMutableAttributedString *mutableString = [string mutableCopy];
	while ([mutableString.mutableString hasPrefix:@"\t"] || [mutableString.mutableString hasPrefix:@" "]) {
		[mutableString.mutableString replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
	}
	return mutableString;
}

+ (NSArray*)clearLinks:(NSArray*)links forString:(NSAttributedString*)string
{
	NSMutableArray *mutableLinks = [[NSMutableArray alloc] init];
	for (LinkObject *link in links) {
		LinkObject *linkNew = [[LinkObject alloc] init];
		linkNew.range = link.range;
		linkNew.link = link.link;
		[mutableLinks addObject:linkNew];
	}
	
	NSMutableAttributedString *mutableString = [string mutableCopy];
	while ([mutableString.mutableString hasPrefix:@"\t"] || [mutableString.mutableString hasPrefix:@" "]) {
		[mutableString.mutableString replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
		for (LinkObject *link in mutableLinks) {
			link.range = NSMakeRange(link.range.location-1, link.range.length);
		}
	}
	return [mutableLinks copy];
}

@end
