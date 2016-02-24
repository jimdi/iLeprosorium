//
//  LepraFullPostCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 25.07.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LepraCommonTableViewCell.h"

@protocol LepraFullPostCellDelegate

- (void)cellAskForOpenProfile:(NSString*)userName;
- (void)cellAskForOpenPage:(NSString*)underground;
- (void)cellAskForOpenPost:(LepraPost*)post;

@end

@interface LepraFullPostCell : LepraCommonTableViewCell

@property (strong, nonatomic) LepraPost *post;

+ (CGFloat)heightForPost:(LepraPost*)post withWidth:(CGFloat)width;

@property (weak, nonatomic) id <LepraFullPostCellDelegate> cellDelegate;

@end
