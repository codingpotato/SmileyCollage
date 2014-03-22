//
//  CPStitchViewController.h
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@protocol CPAssetsLibraryProtocol;


@interface CPStitchViewController : UICollectionViewController <UIActionSheetDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) id<CPAssetsLibraryProtocol> assetsLibrary;

@property (weak, nonatomic) NSMutableArray *selectedFaces;

- (CGRect)frameOfSelectedCell;

@end
