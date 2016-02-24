//
//  LepraProfileContactCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 10.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"
#import <TFHppleElement.h>

@interface LepraProfileContactCell : LepraCommonTableViewCell

- (void)setContactType:(NSString*)contactType contact:(TFHppleElement*)contact;

@end
