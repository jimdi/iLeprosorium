//
//  LepraMenuElementCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraMenuElementCell.h"

@interface LepraMenuElementCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) NSString *key;

@property (strong, nonatomic) NSDictionary *titleKeys;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *countBackground;

@end

@implementation LepraMenuElementCell

- (UIEdgeInsets)layoutMargins
{
	return UIEdgeInsetsZero;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setBackgroundColor:[UIColor whiteColor]];
	UIView *selectedView = [[UIView alloc] init];
	[selectedView setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
	[self setSelectedBackgroundView:selectedView];
	
	self.titleKeys = @{kMenuItemKeyProfile:DEFAULTS_OBJ(DEF_KEY_USER),
					   kMenuItemKeyMyThings:@"Мои вещи",
					   kMenuItemKeyFavourites:@"Избранное",
					   kMenuItemKeyInbox:@"Инбокс",
					   kMenuItemKeyUnderground:@"Блоги империи",
					   kMenuItemKeyPrefs:@"Настройки", 
					   kMenuItemKeyAbout:@"О приложении",
					   kMenuItemKeyLogout:@"Logout"};
	
	self.countBackground.clipsToBounds = YES;
	self.countBackground.layer.cornerRadius = 25.0/2.0;
	[self.countBackground setImage:[LepraGeneralHelper imageWithColor:[UIColor lightGrayColor]]];
}

- (void)setMenuItemKey:(NSString*)key
{
	self.key = key;
	[self.titleLabel setTextColor:[UIColor darkGrayColor]];
	
	NSDictionary *favoritesUnergrounds = DEFAULTS_OBJ(DEF_KEY_MENU_UNDERGROUNDS);
	NSArray *favoritesUnergroundsTitles = favoritesUnergrounds[kUndergroundItemKeyLink];
	if ([favoritesUnergroundsTitles containsObject:key]) {
		NSInteger index = [favoritesUnergroundsTitles indexOfObject:key];
		[self.iconView sd_setImageWithURL:[NSURL URLWithString:favoritesUnergrounds[kUndergroundItemKeyImageLink][index]]];
		[self.iconView setContentMode:UIViewContentModeScaleAspectFill];
		[self.titleLabel setText:[[self.key componentsSeparatedByString:@"."] firstObject]];
	} else {
		[self.iconView setImage:[LepraGeneralHelper tintImage:[UIImage imageNamed:self.key] withColor:[UIColor darkGrayColor]]];
		[self.titleLabel setText:self.titleKeys[self.key]];
		[self.iconView setContentMode:UIViewContentModeCenter];
	}
}

- (void)setCount:(NSString*)count
{
	if (![LepraGeneralHelper isEmpty:count]) {
		self.countLabel.hidden = NO;
		self.countBackground.hidden = NO;
		[self.countLabel setText:count];
	} else {
		[self.countLabel setText:@""];
		self.countLabel.hidden = YES;
		self.countBackground.hidden = YES;
	}
}

+ (CGFloat)cellHeight
{
	return 50.0;
}

@end
