//
//  LepraPrefsViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 03.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraPrefsViewController.h"
#import "LepraPrefsToggleCell.h"
#import "LepraPrefsDonateCell.h"

@interface LepraPrefsViewController ()

@end

@implementation LepraPrefsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	if (self.navigationController.viewControllers.count==1) {
		[self addMenuButton];
	}
    self.title = @"Настройки";
	
	[self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
	[self.tableView setSeparatorColor:[[LepraGeneralHelper redColor] colorWithAlphaComponent:0.5]];
	[self.view setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self configureNavigationBarWithColor:[LepraGeneralHelper redColorLight] titleColor:[UIColor whiteColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section==1) {
		return 75.0;
	}
	return 44.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section==0) {
		return @"Включение данной опции может повредить вашу психику и показать различные непотребства\nВключая опцию вы подтверждаете, что вам 18 лет или больше\nИ еще картнки могут пожрать ваш мобильный траффик. Экономика должна быть экономной";
	}
	return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
	UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
	[header.textLabel setTextColor:[UIColor darkGrayColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		LepraPrefsToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraPrefsToggleCell cellIdentifier]];
		[cell setOn:[DEFAULTS_OBJ(DEF_KEY_PREFS_LOAD_IMAGE) boolValue] text:@"Загружать картинки"];
		return cell;
	} else {
		LepraPrefsDonateCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraPrefsDonateCell cellIdentifier]];
		[cell setTitle:@"Можете помочь разработчикам с оплатой аккаунта в AppStore. Только сегодня \%немношко рублей\%"];
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) {
		NSNumber* loadImages = DEFAULTS_OBJ(DEF_KEY_PREFS_LOAD_IMAGE);
		[DEFAULTS setObject:@(!loadImages.boolValue) forKey:DEF_KEY_PREFS_LOAD_IMAGE];
		[DEFAULTS synchronize];
		[tableView reloadData];
		
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
