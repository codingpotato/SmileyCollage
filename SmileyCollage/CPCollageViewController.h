//
//  CPCollageViewController.h
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPCollageCell;
@class CPFacesManager;

@interface CPCollageViewController : UIViewController <UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) CPFacesManager *facesManager;

@property (strong, nonatomic) NSMutableArray *collagedFaces;

+ (NSUInteger)maxNumberOfCollagedFaces;

- (UIView *)selectedFace;

- (void)reloadSelectedFace;

@end
