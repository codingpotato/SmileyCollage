//
//  CPPhotosViewController.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPhotosViewController.h"

#import "CPFace.h"
#import "CPFacesManager.h"
#import "CPPhotoCell.h"

@implementation CPPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CPFacesManager *facesManager = [CPFacesManager defaultManager];
    facesManager.facesController.delegate = self;
    [facesManager detectFaces];
    self.navigationItem.title = @"Smiles Searching: 0";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [CPFacesManager defaultManager].facesController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPPhotoCell" forIndexPath:indexPath];
    /*CPFace *face = [[CPFacesController defaultController].faces objectAtIndex:indexPath.row];
    CGImageRef faceImage = CGImageCreateWithImageInRect(face.asset.defaultRepresentation.fullScreenImage, face.bounds);
    // TODO: scale the image to 100.0
    cell.imageView.image = [UIImage imageWithCGImage:faceImage scale:face.bounds.size.width / 100.0 orientation:UIImageOrientationUp];
    CGImageRelease(faceImage);
    
    cell.selectedIndicator.hidden = face.isSelected ? NO : YES;
    cell.selectedIndicator.layer.cornerRadius = 5.0;*/
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: 5 images each line
    const int number = 5;
    CGFloat width = (collectionView.bounds.size.width - (number + 1) * 1.0) / number;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[CPFacesManager defaultManager] selectFaceByIndex:indexPath.row];
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - NSFetchedResultsControllerDelegate implement

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    self.navigationItem.title = [NSString stringWithFormat:@"Smiles Searching: %d", controller.fetchedObjects.count];
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
