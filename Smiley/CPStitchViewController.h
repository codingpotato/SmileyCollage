//
//  CPStitchViewController.h
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPFacesManager;

@interface CPStitchViewController : UIViewController <UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) CPFacesManager *facesManager;

@property (strong, nonatomic) NSMutableArray *stitchedFaces;

- (CGRect)frameOfSelectedCell;

@end
