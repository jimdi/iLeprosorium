//
//  DODoneAccessoryView.m
//  DaOffice
//
//  Created by Roma Bakenbard on 20.11.14.
//  Copyright (c) 2014 millionagents. All rights reserved.
//

#import "LepraDoneAccessoryView.h"

@interface LepraDoneAccessoryView()

@property (strong, nonatomic) UIView *viewTopSeparator;

@end

@implementation LepraDoneAccessoryView

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.viewTopSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1.0/[UIScreen mainScreen].scale)];
	[self.viewTopSeparator setBackgroundColor:[[LepraGeneralHelper redColor] colorWithAlphaComponent:0.5]];
	[self.viewTopSeparator setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin)];
	[self addSubview:self.viewTopSeparator];
}

@end
