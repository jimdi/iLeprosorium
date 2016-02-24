//
//  LepraMenuProfileCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraMenuProfileCell.h"

@interface LepraMenuProfileCell()

@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation LepraMenuProfileCell

- (UIEdgeInsets)layoutMargins
{
	return UIEdgeInsetsZero;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	self.photoView.layer.cornerRadius = 6.0;
	[self.photoView setImage:[UIImage imageNamed:@"groups"]];
	
	[self setBackgroundColor:[UIColor whiteColor]];
	UIView *selectedView = [[UIView alloc] init];
	[selectedView setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
	[self setSelectedBackgroundView:selectedView];
}

- (void)setName:(NSString*)name
{
	[self.photoView setImage:[UIImage imageNamed:@"menu_item_profile"]];
	[self.nameLabel setText:name];
	[self.nameLabel setTextColor:[UIColor darkGrayColor]];
}

+ (CGFloat)cellHeight
{
	return [UIApplication sharedApplication].statusBarFrame.size.height + 44.0;
}

@end
