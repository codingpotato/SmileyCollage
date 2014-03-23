//
//  CPFacesViewController.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFacesViewController.h"

#import "CPPhotoCell.h"
#import "CPStitchViewController.h"

#import "CPAssetsLibrary.h"
#import "CPFace.h"
#import "CPFaceEditInformation.h"
#import "CPFacesManager.h"
#import "CPPhoto.h"

@interface CPFacesViewController ()

@property (strong, nonatomic) CPFacesManager *facesManager;

@property (strong, nonatomic) NSMutableArray *selectedFaces;

@end

@implementation CPFacesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.facesManager.facesController.delegate = self;
    self.navigationItem.title = [NSString stringWithFormat:@"Smiles Searching: %d", self.facesManager.facesController.fetchedObjects.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self.facesManager stopScan];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CPStitchViewControllerSegue"]) {
        CPStitchViewController *stitchViewController = (CPStitchViewController *)segue.destinationViewController;
        stitchViewController.facesManager = self.facesManager;
        
        stitchViewController.stitchedFaces = [[NSMutableArray alloc] initWithCapacity:self.selectedFaces.count];
        for (CPFace *face in self.selectedFaces) {
            CPFaceEditInformation *stitchedFace = [[CPFaceEditInformation alloc] init];
            stitchedFace.face = face;
            stitchedFace.asset = nil;
            [stitchViewController.stitchedFaces addObject:stitchedFace];
        }
    }
}

- (void)handleApplicationDidBecomeActiveNotification:(NSNotification *)notification {
    [self.facesManager scanFaces];
}

- (void)handleApplicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self.facesManager stopScan];
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.facesManager.facesController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPPhotoCell" forIndexPath:indexPath];
    CPFace *face = [self.facesManager.facesController.fetchedObjects objectAtIndex:indexPath.row];
    cell.image = [self.facesManager thumbnailOfFace:face];
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
    CPFace *face = [self.facesManager.facesController.fetchedObjects objectAtIndex:indexPath.row];
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

- (CPFacesManager *)facesManager {
    if (!_facesManager) {
        _facesManager = [[CPFacesManager alloc] initWithAssetsLibrary:[[CPAssetsLibrary alloc] init]];
    }
    return _facesManager;
}

- (NSMutableArray *)selectedFaces {
    if (!_selectedFaces) {
        _selectedFaces = [[NSMutableArray alloc] init];
    }
    return _selectedFaces;
}

@end
