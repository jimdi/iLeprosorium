//
//  LepraLoginCell.h
//  Leprosorium
//
//  Created by Roma Bakenbard on 26.12.14.
//  Copyright (c) 2014 Roma Bakenbard. All rights reserved.
//

#import "LepraCommonTableViewCell.h"

@interface LepraLoginCell : LepraCommonTableViewCell

@property (weak, nonatomic) IBOutlet UITextField *loginField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *capchaField;
@property (weak, nonatomic) IBOutlet UIImageView *capchaImageView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

- (void)updateCapcha:(NSString*)capchaLink;

@end
