//
//  DODoneAccessoryView.h
//  DaOffice
//
//  Created by Roma Bakenbard on 20.11.14.
//  Copyright (c) 2014 millionagents. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LepraDoneAccessoryView : UIView
@property (weak, nonatomic) IBOutlet UIButton *buttonDone;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrev;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;

@property (weak, nonatomic) id viewAccessoryIsFor;

@end
