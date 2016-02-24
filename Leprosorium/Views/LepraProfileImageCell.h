//
//  LepraProfileImageCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 12.01.15.
//  Copyright (c) 2015 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"
#import <MHGallery.h>

@class LepraProfileImageCell;

@protocol LepraProfileImageCellDelegate

- (void)imageLoadedForCell:(LepraProfileImageCell*)cell withImageUrl:(NSURL*)imageUrl;
- (void)cellAskForOpenGallery:(MHGalleryController*)gallery;

@end

@interface LepraProfileImageCell : LepraCommonTableViewCell

@property (strong, nonatomic) NSString* tapLink;

- (void)setImageUrl:(NSURL*)imageURL;
- (void)setImageUrl:(NSURL*)imageURL offset:(NSNumber*)offset;

+ (CGFloat)cellHeightForImageUrl:(NSURL *)imageURL;
+ (CGFloat)cellHeightForImageUrl:(NSURL *)imageURL offset:(NSNumber*)offset;

@property (weak, nonatomic) id<LepraProfileImageCellDelegate> cellDelegate;

@end
