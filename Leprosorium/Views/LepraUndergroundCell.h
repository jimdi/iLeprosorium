//
//  LepraUndergroundCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"
#import "LepraUnderground.h"

@protocol LepraUndergroundCellDelegate <NSObject>

- (void)cellAskForOpenProfile:(NSString*)userName;
- (void)cellAskForSubscribe:(LepraUnderground*)domain;
- (void)cellAskForSubscribeMyThings:(LepraUnderground*)domain;
- (void)cellAskForLeftMenu:(LepraUnderground*)domain;

@end

@interface LepraUndergroundCell : LepraCommonTableViewCell

- (void)setDomain:(LepraUnderground*)domain;

@property (weak, nonatomic) id<LepraUndergroundCellDelegate> cellDelegate;

@end
