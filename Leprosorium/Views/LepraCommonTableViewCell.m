//
//  LepraCommonTableViewCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"

@implementation LepraCommonTableViewCell

+ (NSString *)cellIdentifier
{
	return [self nibName];
}

+ (NSString *)nibName
{
	return [NSString stringWithFormat:@"%@", [self class]];
}

- (NSString *)reuseIdentifier
{
	return [self.class cellIdentifier];
}

+ (CGFloat)cellHeight
{
	NSLog(@"WARNING: cellHeight returns 0 in MACommonTableViewCell");
	return 0;
}

+ (CGFloat)heightForContent:(id)content width:(CGFloat)width
{
	NSLog(@"WARNING: heightDForContent:width: returns 0 in MACommonTableViewCell");
	return 0;
}

- (id<UITableViewDataSource>)tableViewController
{
	UIView *view = self;
	while (!(view == nil || [view isKindOfClass:[UITableView class]])) {
		view = view.superview;
	}
	
	return ((UITableView *)view).dataSource;
}

@end
