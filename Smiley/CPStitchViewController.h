//
//  CPStitchViewController.h
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPFacesManager;


@interface CPStitchViewController : UICollectionViewController <UIActionSheetDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) CPFacesManager *facesManager;

@property (weak, nonatomic) NSMutableArray *selectedFaces;

- (CGRect)frameOfSelectedCell;

@end
