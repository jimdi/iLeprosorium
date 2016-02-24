//
//  LepraCommentHeaderCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 02.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommentHeaderCell.h"

@interface LepraCommentHeaderCell()

@property (strong, nonatomic) LepraComment* comment;

@property (weak, nonatomic) IBOutlet UILabel *userPrefixLabel;
@property (weak, nonatomic) IBOutlet UIButton *userNameButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOffsetConstraint;
@property (weak, nonatomic) IBOutlet UIView *leftOffsetView;

@property (nonatomic) CAGradientLayer *gradient;

@end

@implementation LepraCommentHeaderCell

- (UIEdgeInsets)layoutMargins
{
	return UIEdgeInsetsMake(0, 5000, 0, 0);
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru"]];
	[self.dateFormatter setDateFormat:@"d MMMM yyyy kk.mm"];
	
	self.gradient = [CAGradientLayer layer];
	self.gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.98 alpha:1.0] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
	self.gradient.locations = @[@(0.9), @(1.0)];
	[self.contentView.layer insertSublayer:self.gradient atIndex:0];
	
	[self.leftOffsetView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	
	[self setSeparatorInset:UIEdgeInsetsMake(0, 5000, 0, 0)];
}

+ (CGFloat)cellHeight
{
	return 72.0;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	self.gradient.frame = self.contentView.bounds;
}

- (void)setComment:(LepraComment *)comment
{
	[self setComment:comment withOffset:@(0)];
}

- (void)setComment:(LepraComment *)comment withOffset:(NSNumber *)offset
{
	_comment = comment;
	
	[self.userPrefixLabel setText:comment.authorPrefix];
	[self.userNameButton setTitle:comment.authorUserName forState:UIControlStateNormal];
	
	[self.dateLabel setText:[self.dateFormatter stringFromDate:comment.postDate]];
	
	self.leftOffsetConstraint.constant = (MIN(5, offset.integerValue) * 10);
	
	[self.contentView layoutIfNeeded];
}

- (IBAction)userNameButtonTap:(id)sender
{
	[self.cellDelegate cellAskForOpenProfile:self.comment.authorUserName];
}

- (IBAction)answerButtonTap:(id)sender
{
	[self.cellDelegate cellAskForAnswerComment:self.comment];
}


@end
