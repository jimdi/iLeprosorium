//
//  LepraCommentFullCell.m
//  Leprosorium
//
//  Created by Roma Bakenbard on 25.07.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommentFullCell.h"
#import "LepraProfileUserTextCell.h"
#import "LepraProfileImageCell.h"
#import "LepraPostFooterCell.h"
#import "LepraPostHeaderCell.h"
#import "LepraPostRatingCell.h"
#import "LepraPostDetailCommentsViewController.h"
#import <Masonry.h>

#define POST_AUTHOR_VIEW_TAG 99999

@interface LepraCommentFullCell() <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LepraCommentFullCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setClipsToBounds:YES];
    
    [self registerCellForId:[LepraProfileUserTextCell cellIdentifier]];
    [self registerCellForId:[LepraProfileImageCell cellIdentifier]];
    [self registerCellForId:[LepraPostFooterCell cellIdentifier]];
    [self registerCellForId:[LepraPostRatingCell cellIdentifier]];
    [self registerCellForId:[LepraPostHeaderCell cellIdentifier]];
    
    [self.tableView setBackgroundColor:[LepraGeneralHelper tableViewColor]];
    [self setBackgroundColor:[LepraGeneralHelper tableViewColor]];
}

- (void)registerCellForId:(NSString*)reuseId
{
    [self.tableView registerNib:[UINib nibWithNibName:reuseId bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseId];
}

- (void)setComment:(LepraComment *)comment {
    _comment = comment;
    [self.tableView reloadData];
}

+ (CGFloat)heightForComment:(LepraComment *)comment withWidth:(CGFloat)width {
    if ([LepraGeneralHelper isNull:comment]) {
        return 0.0;
    } else {
        CGFloat height = [LepraPostHeaderCell cellHeight];
        NSArray *postObjects = comment.textObjects;
        NSNumber *offset = comment.commentOffset;
        for (id userTextObject in postObjects) {
            if ([userTextObject isKindOfClass:[NSURL class]]) {
                height += [LepraProfileImageCell cellHeightForImageUrl:userTextObject offset:offset];
            } else {
                height += [LepraProfileUserTextCell cellHeightForUserText:userTextObject width:width offset:offset];
            }
        }
        
        height += 5.0;
        height += [LepraPostRatingCell cellHeight];
        
        return height;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *postObjects = [self.comment textObjects];
    return postObjects.count + 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraComment *comment = self.comment;
    NSArray *postObjects = comment.textObjects;
    NSNumber *offset = comment.commentOffset;
    
    if (indexPath.row==0) {
        return [LepraPostHeaderCell cellHeight];
    } else if (indexPath.row == postObjects.count+2) {
        return 5.0;
    } else if (indexPath.row == postObjects.count+1) {
        return [LepraPostRatingCell cellHeight];
    } else {
        id userTextObject = [postObjects objectAtIndex:indexPath.row-1];
        if ([userTextObject isKindOfClass:[NSURL class]]) {
            return [LepraProfileImageCell cellHeightForImageUrl:userTextObject offset:offset];
        } else {
            return [LepraProfileUserTextCell cellHeightForUserText:userTextObject width:tableView.frame.size.width offset:offset];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraComment *comment = self.comment;
    NSArray *postObjects = comment.textObjects;
    NSArray *linksObjects = comment.textLinks;
    NSNumber *offset = @(0);
    if ([self.parentVC isKindOfClass:[LepraPostDetailCommentsViewController class]]) {
        offset = comment.commentOffset;
    }
    
    UITableViewCell *cellToReturn;
    
    if (indexPath.row == 0) {
        LepraPostHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraPostHeaderCell cellIdentifier]];
        [cell setPost:comment offset:offset];
        if ([self isKindOfClass:[LepraPostDetailCommentsViewController class]]) {
            [cell setAuthorComment:comment.postAuthor];
        }
        cellToReturn = cell;
    } else if (indexPath.row == postObjects.count + 2) {
        LepraPostFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraPostFooterCell cellIdentifier]];
        [cell setOffset:offset];
        cellToReturn = cell;
    } else if (indexPath.row == postObjects.count + 1) {
        LepraPostRatingCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraPostRatingCell cellIdentifier]];
        [cell setPost:(LepraPost*)comment offset:offset];
        [cell setCellDelegate:self.cellDelegate];
        cellToReturn = cell;
    } else {
        id userTextObject = [postObjects objectAtIndex:indexPath.row-1];
        NSArray* links = [linksObjects objectAtIndex:indexPath.row-1];
        if ([userTextObject isKindOfClass:[NSURL class]]) {
            LepraProfileImageCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraProfileImageCell cellIdentifier]];
            [cell setCellDelegate:self.cellDelegate];
            [cell setImageUrl:userTextObject offset:offset];
            cell.tapLink = [[links firstObject] link];
            cellToReturn = cell;
        } else {
            LepraProfileUserTextCell *cell = [tableView dequeueReusableCellWithIdentifier:[LepraProfileUserTextCell cellIdentifier]];
            [cell setCellDelegate:self.cellDelegate];
            [cell setUserText:userTextObject links:links offset:offset];
            cellToReturn = cell;
        }
    }
    
    for (UIView *subview in cellToReturn.contentView.subviews) {
        if (subview.tag == POST_AUTHOR_VIEW_TAG) {
            [subview removeFromSuperview];
        }
    }
    
    if (comment.isNew.boolValue) {
        [cellToReturn.contentView setBackgroundColor:COLOR_FROM_HEX(0xff, 0xf0, 0xf0)];
    } else {
        [cellToReturn.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    if (indexPath.row>0) {
        [cellToReturn setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    if (![LepraGeneralHelper isNull:self.post] && [self.post.authorUserName isEqualToString:comment.authorUserName]) {
        UIView* postAuthorView = [[UIView alloc] init];
        [postAuthorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [postAuthorView setBackgroundColor:[LepraGeneralHelper redColor]];
        [postAuthorView setTag:POST_AUTHOR_VIEW_TAG];
        [cellToReturn.contentView addSubview:postAuthorView];
        [postAuthorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(1.0/[UIScreen mainScreen].scale));
            make.top.equalTo(cellToReturn.contentView.mas_top);
            make.bottom.equalTo(cellToReturn.contentView.mas_bottom);
            make.left.equalTo(cellToReturn.contentView.mas_left).with.offset(offset.floatValue * 8.0);
        }];
    }
    
    return cellToReturn;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LepraComment *comment = self.comment;
    if (indexPath.row==0) {
        [self.cellDelegate cellAskForOpenProfile:comment.authorUserName];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
