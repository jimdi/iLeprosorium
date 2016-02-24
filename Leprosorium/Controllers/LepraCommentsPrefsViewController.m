//
//  LepraCommentsPrefsViewController.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 15.06.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommentsPrefsViewController.h"
#import "LepraPrefsToggleCell.h"
#import <MZFormSheetController.h>

@interface LepraCommentsPrefsViewController() <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray* commentTypeArray;
@property (strong, nonatomic) NSArray* commentContentArray;
@property (strong, nonatomic) NSArray* commentSortArray;

@property (strong, nonatomic) NSString* selectedType;
@property (strong, nonatomic) NSMutableArray* selectedContent;
@property (strong, nonatomic) NSString* selectedSort;

@end

@implementation LepraCommentsPrefsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedType = @"";
    self.selectedContent = [[NSMutableArray alloc] init];
    self.selectedSort = @"";
    
    self.commentTypeArray = @[@"", @"unread"];
    self.commentContentArray = @[@"links", @"images", @"videos"];
    self.commentSortArray = @[@"", @"rating"];

    
    [self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
    self.tableView.layer.cornerRadius = 6.0;
    [self.view setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self.delegate needReloadFeed];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.commentTypeArray.count;
        case 1:
            return self.commentContentArray.count;
        case 2:
            return self.commentSortArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraPrefsToggleCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraPrefsToggleCell cellIdentifier]];
    if (indexPath.section == 0) {
        NSString *commentsType = self.commentTypeArray[indexPath.row];
        NSString *title;
        if ([commentsType isEqualToString:@""]) {
            title = @"Все комментарии";
        } else {
            title = @"Новые";
        }
        [cell setOn:[self.selectedType isEqualToString:commentsType] text:title];
    } else if (indexPath.section == 1) {
        NSString *commentsContent = self.commentContentArray[indexPath.row];
        NSString *title;
        if ([commentsContent isEqualToString:@"links"]) {
            title = @"Ссылки";
        } else if ([commentsContent isEqualToString:@"images"]) {
            title = @"Картинки";
        } else {
            title = @"Видео";
        }
        [cell setOn:[self.selectedContent containsObject:commentsContent] text:title];
    } else {
        NSString *commentsSort = self.commentSortArray[indexPath.row];
        NSString *title;
        if ([commentsSort isEqualToString:@""]) {
            title = @"По времени";
        } else {
            title = @"По рейтингу";
        }
        [cell setOn:[self.selectedSort isEqualToString:commentsSort] text:title];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
