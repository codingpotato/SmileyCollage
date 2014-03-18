//
//  CPFacesViewController.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFacesViewController.h"

#import "CPFace.h"
#import "CPFacesManager.h"
#import "CPPhotoCell.h"

#import "CPAssetsLibrary.h"

@interface CPFacesViewController ()

@property (strong, nonatomic) CPAssetsLibrary *assetsLibrary;

@end

@implementation CPFacesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*CPFacesManager *faceManager = [CPFacesManager defaultManager];
    faceManager.facesController.delegate = self;
    self.navigationItem.title = [NSString stringWithFormat:@"Smiles Searching: %d", faceManager.facesController.fetchedObjects.count];*/
    [self.assetsLibrary detectFacesBySkipAssetBlock:^BOOL(NSString *assetURL) {
        return NO;
    } resultBlock:^(NSString *assetURL, NSMutableArray *boundsOfFaces) {
        NSLog(@"[%@] - %@", assetURL, boundsOfFaces);
    } completionBlock:^{
        NSLog(@"Finished!");
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [CPFacesManager defaultManager].facesController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPPhotoCell" forIndexPath:indexPath];
    cell.imageView.image = [[CPFacesManager defaultManager] thumbnailByIndex:indexPath.row];
    cell.selectedIndicator.hidden = ![[CPFacesManager defaultManager] isFaceSlectedByIndex:indexPath.row];
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
    [[CPFacesManager defaultManager] selectFaceByIndex:indexPath.row];
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

#pragma mark - NSFetchedResultsControllerDelegate implement

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    self.navigationItem.title = [NSString stringWithFormat:@"Smiles Searching: %d", controller.fetchedObjects.count];
    [self.collectionView reloadData];
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

#pragma mark - lazy init

- (CPAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[CPAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

@end
