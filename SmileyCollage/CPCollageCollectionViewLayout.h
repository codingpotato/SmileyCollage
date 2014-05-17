//
//  CPCollageCollectionViewLayout.h
//  SmileyCollage
//
//  Created by wangyw on 5/17/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@protocol CPCollageCollectionViewLayoutDataSource <NSObject>

- (CGFloat)topInsetForCollectionView:(UICollectionView *)collectionView;

- (CGFloat)imageWidthHeightRatioForCollectionView:(UICollectionView *)collectionView;

- (NSArray *)numberOfColumnsInRowsForCollectionView:(UICollectionView *)collectionView;

@end

@interface CPCollageCollectionViewLayout : UICollectionViewLayout

- (CGRect)imageFrame;

@end
