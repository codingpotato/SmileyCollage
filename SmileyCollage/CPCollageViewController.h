//
//  CPCollageViewController.h
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPFacesManager;

@interface CPCollageViewController : UIViewController

@property (weak, nonatomic) CPFacesManager *facesManager;

@property (strong, nonatomic) NSMutableArray *collagedFaces;

+ (NSUInteger)maxNumberOfSmiley;

- (UICollectionViewCell *)selectedFace;

- (void)reloadSelectedFace;

@end
