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

@interface CPPhotosViewController ()

@end

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
    cell.imageView.image = [UIImage imageWithCGImage:face.image];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPFace *face = [[CPFacesController defaultController].faces objectAtIndex:indexPath.row];
    return CGSizeMake(CGImageGetWidth(face.image), CGImageGetHeight(face.image));
}

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
