//
//  LepraPostHeaderCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 01.02.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"

@protocol LepraPostHeaderCellDelegate <NSObject>

- (void)cellAskForOpenProfile:(NSString*)userName;
- (void)cellAskForOpenPage:(NSString*)pageLink;

@end

@interface LepraPostHeaderCell : LepraCommonTableViewCell

- (void)setPost:(LepraPost*)post;
- (void)setPost:(LepraPost*)post offset:(NSNumber*)offset;
- (void)setAuthorComment:(NSNumber*)authorComment;

@property (weak, nonatomic) id<LepraPostHeaderCellDelegate> cellDelegate;

@end
