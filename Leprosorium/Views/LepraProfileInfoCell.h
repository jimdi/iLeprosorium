//
//  LepraProfileInfoCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 10.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"
#import "LepraProfile.h"

@protocol LepraProfileInfoCellDelegate <NSObject>

- (void)cellAskForLeftPlusForProfile:(LepraProfile*)profile;
- (void)cellAskForRightPlusForProfile:(LepraProfile*)profile;
- (void)cellAskForLeftMinusForProfile:(LepraProfile*)profile;
- (void)cellAskForRightMinusForProfile:(LepraProfile*)profile;

@end

@interface LepraProfileInfoCell : LepraCommonTableViewCell

- (void)setProfile:(LepraProfile*)profile;

@property (weak, nonatomic) id<LepraProfileInfoCellDelegate> cellDelegate;

@end
