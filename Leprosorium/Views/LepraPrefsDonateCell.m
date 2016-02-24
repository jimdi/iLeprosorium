//
//  LepraPrefsDonateCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 03.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraPrefsDonateCell.h"

@interface LepraPrefsDonateCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation LepraPrefsDonateCell

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setBackgroundColor:[LepraGeneralHelper blueColor]];
}

- (void)setTitle:(NSString*)title
{
	[self.titleLabel setText:title];
}

@end
