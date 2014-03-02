//
//  CPPhotosViewController.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPhotosViewController.h"

#import "CPPhotoCell.h"
#import "CPSmileDetector.h"

@interface CPPhotosViewController ()

@property (strong, nonatomic) NSArray *asserts;
@property (strong, nonatomic) NSArray *faces;

@end

@implementation CPPhotosViewController

+ (ALAssetsLibrary *)defaultAssertsLibrary {
    static ALAssetsLibrary *library = nil;
    if (!library) {
        library = [[ALAssetsLibrary alloc] init];
    }
    return library;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __block NSMutableArray *tempAsserts = [NSMutableArray array];
    __block NSMutableArray *tempFaces = [NSMutableArray array];
    ALAssetsLibrary *assertsLibrary = [CPPhotosViewController defaultAssertsLibrary];
    [assertsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    CGImageRef fullScreenImage = result.defaultRepresentation.fullScreenImage;
                    CGImageRef thumbnail = result.thumbnail;
                    CGPoint ratio = CGPointMake((CGFloat)CGImageGetWidth(thumbnail) / CGImageGetWidth(fullScreenImage), (CGFloat)CGImageGetHeight(thumbnail) / CGImageGetHeight(fullScreenImage));
                    NSArray *faces = [CPSmileDetector facesInImage:thumbnail];
                    CGFloat height = CGImageGetHeight(thumbnail);
                    for (NSValue *face in faces) {
                        CGRect faceRect = face.CGRectValue;
                        CGRect newFaceRect = CGRectMake(faceRect.origin.x, height - faceRect.origin.y - faceRect.size.height, faceRect.size.width, faceRect.size.height);
                        [tempAsserts addObject:result];
                        [tempFaces addObject:[NSValue valueWithCGRect:newFaceRect]];
                    }
                }
            }];
        } else {
            self.asserts = [tempAsserts copy];
            self.faces = [tempFaces copy];
            NSAssert(self.asserts.count == self.faces.count, @"");
            
            [self.collectionView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"Error loading photos: %@", error);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.asserts.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    cell.assert = [self.asserts objectAtIndex:indexPath.row];
    cell.face = ((NSValue *)[self.faces objectAtIndex:indexPath.row]).CGRectValue;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *asset = [self.asserts objectAtIndex:indexPath.row];
    return CGSizeMake(CGImageGetWidth(asset.thumbnail), CGImageGetHeight(asset.thumbnail));
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
