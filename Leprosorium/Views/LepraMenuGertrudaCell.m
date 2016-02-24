//
//  LepraMenuGertrudaCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraMenuGertrudaCell.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface LepraMenuGertrudaCell()

@property (weak, nonatomic) IBOutlet UIImageView *gertrudaImageView;
@property (weak, nonatomic) IBOutlet UILabel *headerTaglineLabel;

@end

@implementation LepraMenuGertrudaCell

- (UIEdgeInsets)layoutMargins
{
	return UIEdgeInsetsZero;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0]];
}

+ (CGFloat)cellHeight
{
	return 400.0;
}

- (void)setGertruda:(NSString*)gertrudaLink tagline:(NSString*)tagline
{
	[self.gertrudaImageView setImageWithURL:[NSURL URLWithString:gertrudaLink] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self.headerTaglineLabel setText:tagline];
}

@end
