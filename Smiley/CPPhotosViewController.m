//
//  CPPhotosViewController.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPhotosViewController.h"

#import "CPFace.h"
#import "CPFacesController.h"
#import "CPPhotoCell.h"

@implementation CPPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[CPFacesController defaultController] detectFacesWithRefreshBlock:^{
        [self.collectionView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [CPFacesController defaultController].faces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    CPFace *face = [[CPFacesController defaultController].faces objectAtIndex:indexPath.row];
    CGImageRef faceImage = CGImageCreateWithImageInRect(face.asset.defaultRepresentation.fullResolutionImage, face.bounds);
    // TODO: scale the image to 100.0
    cell.imageView.image = [UIImage imageWithCGImage:faceImage scale:face.bounds.size.width / 100.0 orientation:UIImageOrientationUp];
    CGImageRelease(faceImage);
    
    cell.selectedIndicator.hidden = face.isSelected ? NO : YES;
    cell.selectedIndicator.layer.cornerRadius = 5.0;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: 5 images each line
    const int number = 5;
    CGFloat width = (collectionView.bounds.size.width - (number + 1) * 1.0) / number;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[CPFacesController defaultController] selectFaceByIndex:indexPath.row];
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

@end
