//
//  CPPhotosViewController.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPhotosViewController.h"

#import "CPPhotoCell.h"

@interface CPPhotosViewController ()

@property (strong, nonatomic) NSArray *asserts;

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
    ALAssetsLibrary *assertsLibrary = [CPPhotosViewController defaultAssertsLibrary];
    [assertsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [tempAsserts addObject:result];
                }
            }];
        } else {
            self.asserts = [tempAsserts copy];
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
    
    return cell;
}

@end
