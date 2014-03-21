//
//  CPFacesManagerTests.m
//  Smiley
//
//  Created by wangyw on 3/20/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPFacesManager.h"
#import "CPMockupAssetsLibrary.h"

@interface CPFacesManagerTests : XCTestCase

@end

@implementation CPFacesManagerTests

- (void)setUp {
    [super setUp];
    
    [self removeCacheFiles];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testScanEmptyFace {
    CPMockupAssetsLibrary *assetsLibrary = [[CPMockupAssetsLibrary alloc] init];
    assetsLibrary.assetsProvider = [[CPEmptyAssetsProvider alloc] init];
    CPFacesManager *facesManager = [[CPFacesManager alloc] initWithAssetsLibrary:assetsLibrary];
    
    [facesManager scanFaces];
    XCTAssertEqual(facesManager.photosController.fetchedObjects.count, 0, @"");
    XCTAssertEqual(facesManager.facesController.fetchedObjects.count, 0, @"");
    XCTAssertEqual(self.numberOfThumbnails, 0, @"");
}

- (void)testScanOneAssetOneFace {
    CPMockupAssetsLibrary *assetsLibrary = [[CPMockupAssetsLibrary alloc] init];
    assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:@[@"TestAssert_1"] numbersOfFaces:@[[NSNumber numberWithInteger:1]]];
    CPFacesManager *facesManager = [[CPFacesManager alloc] initWithAssetsLibrary:assetsLibrary];
    
    [facesManager scanFaces];
    XCTAssertEqual(facesManager.photosController.fetchedObjects.count, 1, @"");
    XCTAssertEqual(facesManager.facesController.fetchedObjects.count, 1, @"");
    XCTAssertEqual(self.numberOfThumbnails, 1, @"");
}

- (void)testScanOneAssetTwoFaces {
    CPMockupAssetsLibrary *assetsLibrary = [[CPMockupAssetsLibrary alloc] init];
    assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:@[@"TestAssert_1"] numbersOfFaces:@[[NSNumber numberWithInteger:2]]];
    CPFacesManager *facesManager = [[CPFacesManager alloc] initWithAssetsLibrary:assetsLibrary];
    
    [facesManager scanFaces];
    XCTAssertEqual(facesManager.photosController.fetchedObjects.count, 1, @"");
    XCTAssertEqual(facesManager.facesController.fetchedObjects.count, 2, @"");
    XCTAssertEqual(self.numberOfThumbnails, 2, @"");
}

- (void)testScanTwoAssetsTwoFaces {
    CPMockupAssetsLibrary *assetsLibrary = [[CPMockupAssetsLibrary alloc] init];
    assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:@[@"TestAssert_1", @"TestAsset_2"] numbersOfFaces:@[[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2]]];
    CPFacesManager *facesManager = [[CPFacesManager alloc] initWithAssetsLibrary:assetsLibrary];
    
    [facesManager scanFaces];
    XCTAssertEqual(facesManager.photosController.fetchedObjects.count, 2, @"");
    XCTAssertEqual(facesManager.facesController.fetchedObjects.count, 3, @"");
    XCTAssertEqual(self.numberOfThumbnails, 3, @"");
}

- (void)testScanAddedAssets {
    CPMockupAssetsLibrary *assetsLibrary = [[CPMockupAssetsLibrary alloc] init];
    assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:@[@"TestAssert_1"] numbersOfFaces:@[[NSNumber numberWithInteger:1]]];
    CPFacesManager *facesManager = [[CPFacesManager alloc] initWithAssetsLibrary:assetsLibrary];
    
    [facesManager scanFaces];
    XCTAssertEqual(facesManager.photosController.fetchedObjects.count, 1, @"");
    XCTAssertEqual(facesManager.facesController.fetchedObjects.count, 1, @"");
    XCTAssertEqual(self.numberOfThumbnails, 1, @"");

    assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:@[@"TestAssert_2", @"TestAsset_3"] numbersOfFaces:@[[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:2]]];
    
    [facesManager scanFaces];
    XCTAssertEqual(facesManager.photosController.fetchedObjects.count, 3, @"");
    XCTAssertEqual(facesManager.facesController.fetchedObjects.count, 4, @"");
    XCTAssertEqual(self.numberOfThumbnails, 4, @"");
}

- (void)removeCacheFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsPath error:nil];
    for (NSString *file in files) {
        [fileManager removeItemAtPath:[documentsPath stringByAppendingPathComponent:file] error:nil];
    }
}

- (NSUInteger)numberOfThumbnails {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSArray *thumbnails = [fileManager contentsOfDirectoryAtPath:[documentsPath stringByAppendingPathComponent:@"thumbnail"] error:nil];
    return thumbnails.count;
}

@end
