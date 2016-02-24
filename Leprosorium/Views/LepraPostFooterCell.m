//
//  LepraPostFooterCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 24.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraPostFooterCell.h"

@interface LepraPostFooterCell()
@property (weak, nonatomic) IBOutlet UIView *bottomSeparator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSeparatorHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOffsetConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftOffsetView;

@end

@implementation LepraPostFooterCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self.bottomSeparator setBackgroundColor:[[LepraGeneralHelper redColor] colorWithAlphaComponent:0.5]];
	self.bottomSeparatorHeight.constant = 1.0/[UIScreen mainScreen].scale;
	
	[self.leftOffsetView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

+ (CGFloat)cellHeight
{
	return 1.0;
}

- (void)setOffset:(NSNumber*)offset
{
	self.leftOffsetConstraint.constant = MIN(5, offset.integerValue) * 8;
	
	[self.contentView layoutIfNeeded];
}

@end
