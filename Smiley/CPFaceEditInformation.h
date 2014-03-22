//
//  CPFaceEditInformation.h
//  Smiley
//
//  Created by wangyw on 3/22/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPFace;


@interface CPFaceEditInformation : NSObject

@property (strong, nonatomic) CPFace *face;

@property (strong, nonatomic) ALAsset *asset;

@property (nonatomic) CGRect userBounds;

@end
