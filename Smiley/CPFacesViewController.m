//
//  CPFacesViewController.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFacesViewController.h"

#import "CPAssetsLibrary.h"
#import "CPFace.h"
#import "CPFacesManager.h"
#import "CPPhotoCell.h"
#import "CPStitchViewController.h"

@interface CPFacesViewController ()

@property (strong, nonatomic) id<CPAssetsLibraryProtocol> assertLibrary;

@property (strong, nonatomic) CPFacesManager *faceManager;

@property (strong, nonatomic) NSMutableArray *selectedFaces;

@end

@implementation CPFacesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.faceManager.facesController.delegate = self;
    self.navigationItem.title = [NSString stringWithFormat:@"Smiles Searching: %d", self.faceManager.facesController.fetchedObjects.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.faceManager stopScan];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CPStitchViewControllerSegue"]) {
        CPStitchViewController *stitchViewController = (CPStitchViewController *)segue.destinationViewController;
        stitchViewController.assetsLibrary = self.assertLibrary;
        stitchViewController.selectedFaces = self.selectedFaces;
    }
}

- (void)handleApplicationDidBecomeActiveNotification:(NSNotification *)notification {
    [self.faceManager scanFaces];
}

- (void)handleApplicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self.faceManager stopScan];
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.faceManager.facesController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPPhotoCell" forIndexPath:indexPath];
    CPFace *face = [self.faceManager.facesController.fetchedObjects objectAtIndex:indexPath.row];
    cell.image = [self.faceManager thumbnailOfFace:face];
    cell.isSelected = [self.selectedFaces containsObject:face];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: 5 images each line
    const int number = 5;
    CGFloat width = (collectionView.bounds.size.width - (number + 1) * 1.0) / number;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CPFace *face = [self.faceManager.facesController.fetchedObjects objectAtIndex:indexPath.row];
    NSAssert(face, @"");
    if ([self.selectedFaces containsObject:face]) {
        [self.selectedFaces removeObject:face];
    } else {
        [self.selectedFaces addObject:face];
    }
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

- (id<CPAssetsLibraryProtocol>)assertLibrary {
    if (!_assertLibrary) {
        _assertLibrary = [[CPAssetsLibrary alloc] init];
    }
    return _assertLibrary;
}

- (CPFacesManager *)faceManager {
    if (!_faceManager) {
        _faceManager = [[CPFacesManager alloc] initWithAssetsLibrary:self.assertLibrary];
    }
    return _faceManager;
}

- (NSMutableArray *)selectedFaces {
    if (!_selectedFaces) {
        _selectedFaces = [[NSMutableArray alloc] init];
    }
    return _selectedFaces;
}

@end
