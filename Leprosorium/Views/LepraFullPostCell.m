//
//  LepraFullPostCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 25.07.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraFullPostCell.h"
#import "LepraProfileUserTextCell.h"
#import "LepraProfileImageCell.h"
#import "LepraPostFooterCell.h"
#import "LepraPostRatingCell.h"
#import "LepraPostHeaderCell.h"
#import "LepraPostUndergroundCell.h"

@interface LepraFullPostCell() <UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LepraFullPostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setClipsToBounds:YES];
    
    [self registerCellForId:[LepraProfileUserTextCell cellIdentifier]];
    [self registerCellForId:[LepraProfileImageCell cellIdentifier]];
    [self registerCellForId:[LepraPostFooterCell cellIdentifier]];
    [self registerCellForId:[LepraPostRatingCell cellIdentifier]];
    [self registerCellForId:[LepraPostHeaderCell cellIdentifier]];
    [self registerCellForId:[LepraPostUndergroundCell cellIdentifier]];
    
    [self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
    [self setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

- (void)registerCellForId:(NSString*)reuseId
{
    [self.tableView registerNib:[UINib nibWithNibName:reuseId bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseId];
}

- (void)setPost:(LepraPost *)post {
    _post = post;
    [self.tableView reloadData];
}

+ (CGFloat)heightForPost:(LepraPost*)post withWidth:(CGFloat)width {
    if ([LepraGeneralHelper isNull:post]) {
        return 0.0;
    } else {
        CGFloat height = [LepraPostHeaderCell cellHeight];
        height += [LepraPostUndergroundCell cellHeightForPost:post];
        
//        NSString *rating = post.rating;
//        if ([LepraGeneralHelper isEmpty:rating]) {
//            height += 0.0;
//        } else {
            height += [LepraPostRatingCell cellHeight];
//        }
        height += [LepraPostFooterCell cellHeight];
        for (id userTextObject in post.textObjects) {
            if ([userTextObject isKindOfClass:[NSURL class]]) {
                height += [LepraProfileImageCell cellHeightForImageUrl:userTextObject];
            } else {
                height += [LepraProfileUserTextCell cellHeightForUserText:userTextObject width:width];
            }
        }
        return height;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.post.textObjects.count + 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraPost *post = self.post;
    if (indexPath.row==0) {
        return [LepraPostHeaderCell cellHeight];
    } else if (indexPath.row==1) {
        return [LepraPostUndergroundCell cellHeightForPost:post];
    } else if (indexPath.row == post.textObjects.count+3) {
        return [LepraPostFooterCell cellHeight];
    } else if (indexPath.row == post.textObjects.count + 2) {
//        NSString *rating = post.rating;
//        if ([LepraGeneralHelper isEmpty:rating]) {
//            return 0.0;
//        } else {
            return [LepraPostRatingCell cellHeight];
//        }
    } else {
        id userTextObject = [post.textObjects objectAtIndex:indexPath.row-2];
        if ([userTextObject isKindOfClass:[NSURL class]]) {
            return [LepraProfileImageCell cellHeightForImageUrl:userTextObject];
        } else {
            return [LepraProfileUserTextCell cellHeightForUserText:userTextObject width:tableView.frame.size.width];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraPost *post = self.post;
    NSArray *postObjects = post.textObjects;
    NSArray *linksObjects = post.textLinks;
    
    SWTableViewCell* cellToReturn;
    
    if (indexPath.row == 0) {
        LepraPostHeaderCell* cell = [tableView dequeueReusableCellWithIdentifier:[LepraPostHeaderCell cellIdentifier]];
        [cell setPost:post];
        [cell setCellDelegate:self.cellDelegate];
        cellToReturn = cell;
    } else if (indexPath.row == 1) {
        LepraPostUndergroundCell* cell = [tableView dequeueReusableCellWithIdentifier:[LepraPostUndergroundCell cellIdentifier]];
        [cell setPost:post];
        cellToReturn = cell;
    } else if (indexPath.row == postObjects.count + 3) {
        LepraPostFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraPostFooterCell cellIdentifier]];
        cellToReturn = cell;
    } else if (indexPath.row == postObjects.count + 2) {
        LepraPostRatingCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraPostRatingCell cellIdentifier]];
        [cell setPost:post];
        [cell setCellDelegate:self.cellDelegate];
        cellToReturn = cell;
    } else {
        id userTextObject = [postObjects objectAtIndex:indexPath.row-2];
        NSArray* links = [linksObjects objectAtIndex:indexPath.row-2];
        if ([userTextObject isKindOfClass:[NSURL class]]) {
            LepraProfileImageCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraProfileImageCell cellIdentifier]];
            [cell setCellDelegate:self.cellDelegate];
            [cell setImageUrl:userTextObject];
            cell.tapLink = [[links firstObject] link];
            cellToReturn = cell;
        } else {
            LepraProfileUserTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraProfileUserTextCell cellIdentifier]];
            [cell setCellDelegate:self.cellDelegate];
            [cell setUserText:userTextObject links:links];
            cellToReturn = cell;
        }
    }
    
    [cellToReturn setDelegate:self];
    return cellToReturn;
}

- (void)didHighlightSwipeableTableViewCell:(SWTableViewCell *)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    LepraPost *post = self.post;
    if (indexPath.row>1) {
        for (int i=2;i<post.textObjects.count+4;i++) {
            [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]] setHighlighted:YES animated:NO];
        }
    }
}

- (void)didUnhighlightSwipeableTableViewCell:(SWTableViewCell *)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    LepraPost *post = self.post;
    if (indexPath.row>1) {
        for (int i=2;i<post.textObjects.count+4;i++) {
            [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section]] setHighlighted:NO animated:NO];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraPost *post = self.post;
    if (indexPath.row>1) {
        for (int i=2;i<post.textObjects.count+4;i++) {
            [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section] animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraPost *post = self.post;
    
    for (int i=0;i<post.textObjects.count+4;i++) {
        [tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:indexPath.section] animated:YES];
    }
    
    if (indexPath.row==0) {
        [self.cellDelegate cellAskForOpenProfile:post.authorUserName];
    } else if (indexPath.row==1) {
        [self.cellDelegate cellAskForOpenPage:post.undergroundLink];
    } else {
        [self.cellDelegate cellAskForOpenPost:post];
    }
}


@end
