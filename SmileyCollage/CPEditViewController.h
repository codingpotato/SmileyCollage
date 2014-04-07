//
//  CPEditViewController.h
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPFaceEditInformation;

@interface CPEditViewController : UIViewController

@property (strong, nonatomic) CPFaceEditInformation *faceEditInformation;

- (CGRect)faceIndicatorFrame;

- (UIView *)faceSnapshot;

@end
