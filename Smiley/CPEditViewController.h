//
//  CPEditViewController.h
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPFace;
@class CPFacesManager;


@interface CPEditViewController : UIViewController

@property (weak, nonatomic) CPFacesManager *facesManager;

@property (weak, nonatomic) CPFace *face;

@property (weak, nonatomic) NSValue *userBounds;

@end
