//
//  LepraUndergroundCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraUndergroundCell.h"
#import <UIImageView+UIActivityIndicatorForSDWebImage.h>

@interface LepraUndergroundCell()

@property (weak, nonatomic) IBOutlet UIImageView *undergroundLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *undergroundLabel;
@property (weak, nonatomic) IBOutlet UILabel *undergroundLinkLabel;

@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;
@property (weak, nonatomic) IBOutlet UIButton *ownerButton;

@property (weak, nonatomic) IBOutlet UIButton *inMainButton;
@property (weak, nonatomic) IBOutlet UILabel *inMainLabel;
@property (weak, nonatomic) IBOutlet UILabel *inLeftMenuLabel;
@property (weak, nonatomic) IBOutlet UIButton *inMyThingsButton;
@property (weak, nonatomic) IBOutlet UILabel *inMyThingsLabel;
@property (weak, nonatomic) IBOutlet UIButton *inLeftMenuButton;


@property (strong, nonatomic) LepraUnderground* domain;

@end

@implementation LepraUndergroundCell

- (UIEdgeInsets)layoutMargins
{
	return UIEdgeInsetsZero;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self.inMainLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inMainButtonTap:)]];
	[self.inMyThingsLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inMyThingsButtonTap:)]];
	[self.inLeftMenuLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inLeftMenuButtonTap:)]];
}

+ (CGFloat)cellHeight
{
	return 245.0;
}

- (void)setDomain:(LepraUnderground*)domain
{
	_domain = domain;
	[self.undergroundLogoImageView setImageWithURL:[NSURL URLWithString:domain.logoLink] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
		if ([LepraGeneralHelper isNull:image]) {
			[self.undergroundLogoImageView setImage:[LepraGeneralHelper imageWithColor:[UIColor blackColor]]];
		}
	} usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[self.undergroundLabel setText:domain.title];
	[self.undergroundLinkLabel setText:domain.link];
	
	[self.ownerLabel setText:domain.ownerTitle];
	[self.ownerButton setAttributedTitle:[[NSAttributedString alloc] initWithString:domain.authorUserName attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0], NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)}] forState:UIControlStateNormal];
	
	if (domain.inMyThings.boolValue) {
		[self.inMyThingsButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"checked"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateNormal];
	} else {
		[self.inMyThingsButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"unchecked"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateNormal];
	}
	
	if (domain.inMain.boolValue) {
		[self.inMainButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"checked"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateNormal];
	} else {
		[self.inMainButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"unchecked"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateNormal];
	}
	
	NSDictionary *favoritesUnergrounds = DEFAULTS_OBJ(DEF_KEY_MENU_UNDERGROUNDS);
	NSArray *favoritesUnergroundsLink = favoritesUnergrounds[kUndergroundItemKeyLink];
	if ([favoritesUnergroundsLink containsObject:self.domain.link]) {
		[self.inLeftMenuButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"checked"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateNormal];
	} else {
		[self.inLeftMenuButton setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:@"unchecked"] withColor:[LepraGeneralHelper blueColor]] forState:UIControlStateNormal];
	}
	
}

- (IBAction)ownerButtonTap:(id)sender
{
	[self.cellDelegate cellAskForOpenProfile:self.domain.authorUserName];
}
- (IBAction)inMainButtonTap:(id)sender
{
	[self.cellDelegate cellAskForSubscribe:self.domain];
}
- (IBAction)inMyThingsButtonTap:(id)sender
{
	[self.cellDelegate cellAskForSubscribeMyThings:self.domain];
}
- (IBAction)inLeftMenuButtonTap:(id)sender {
	[self.cellDelegate cellAskForLeftMenu:self.domain];
}
@end
