//
//  LepraProfileUserTextCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 10.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"
#import <TFHppleElement.h>

@interface LinkObject : NSObject

@property (nonatomic) NSRange range;
@property (strong, nonatomic) NSString* link;

@end

@protocol LepraProfileUserTextCellDelegate <NSObject>

- (void)cellAskForOpenProfile:(NSString*)userName;
- (void)cellAskForOpenPage:(NSString*)pageLink;

@end

@interface LepraProfileUserTextCell : LepraCommonTableViewCell

- (void)setUserText:(NSAttributedString*)userText links:(NSArray*)links;
- (void)setUserText:(NSAttributedString*)userText links:(NSArray*)links offset:(NSNumber*)offset;

+ (CGFloat)cellHeightForUserText:(NSAttributedString*)userText width:(CGFloat)width;
+ (CGFloat)cellHeightForUserText:(NSAttributedString*)userText width:(CGFloat)width offset:(NSNumber*)offset;

@property (weak, nonatomic) id<LepraProfileUserTextCellDelegate> cellDelegate;

@end
