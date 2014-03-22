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

#import "CPConfig.h"
#import "CPFace.h"
#import "CPPhoto.h"

@interface CPFacesManagerTests : XCTestCase

@property (strong, nonatomic) CPMockupAssetsLibrary *assetsLibrary;

@property (strong, nonatomic) CPFacesManager *facesManager;

@end

@implementation CPFacesManagerTests

- (void)setUp {
    [super setUp];
    
    [self removeCacheFiles];

    self.assetsLibrary = [[CPMockupAssetsLibrary alloc] init];
    self.facesManager = [[CPFacesManager alloc] initWithAssetsLibrary:self.assetsLibrary];
}

- (void)tearDown {
    self.assetsLibrary = nil;
    self.facesManager = nil;
    
    [super tearDown];
}

- (void)testScanEmptyFace {
    self.assetsLibrary.assetsProvider = [[CPEmptyAssetsProvider alloc] init];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 0, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 0, @"");
    XCTAssertEqual(self.facesManager.photos.count, 0, @"");
    XCTAssertEqual(self.facesManager.faces.count, 0, @"");
    XCTAssertEqual(self.numberOfThumbnails, 0, @"");
}

- (void)testScanOneAssetOneFace {
    NSString *url = @"TestAssert_1";
    self.assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:@[url] numbersOfFaces:@[[NSNumber numberWithInteger:1]]];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 0, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 1, @"");
    XCTAssertEqual(self.facesManager.photos.count, 1, @"");
    XCTAssertEqual(self.facesManager.faces.count, 1, @"");
    XCTAssertEqual(self.numberOfThumbnails, 1, @"");
    
    for (CPPhoto *photo in self.facesManager.photos) {
        XCTAssertEqual(photo.url, url, @"");
        XCTAssertEqual(photo.scanId, self.facesManager.config.currentScanId, @"");
        XCTAssertEqual(photo.faces.count, 1, @"");
        
        CPFace *face = [photo.faces anyObject];
        XCTAssertEqual(face.id.integerValue, 0, @"");
        XCTAssertEqual(face.photo, photo, @"");
    }
}

- (void)testScanOneAssetTwoFaces {
    NSString *url = @"TestAssert_1";
    self.assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:@[url] numbersOfFaces:@[[NSNumber numberWithInteger:2]]];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 0, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 2, @"");
    XCTAssertEqual(self.facesManager.photos.count, 1, @"");
    XCTAssertEqual(self.facesManager.faces.count, 2, @"");
    XCTAssertEqual(self.numberOfThumbnails, 2, @"");

    for (CPPhoto *photo in self.facesManager.photos) {
        XCTAssertEqual(photo.url, url, @"");
        XCTAssertEqual(photo.scanId, self.facesManager.config.currentScanId, @"");
        XCTAssertEqual(photo.faces.count, 2, @"");
        
        for (CPFace *face in photo.faces) {
            XCTAssertEqual(face.photo, photo, @"");
        }
    }
}

- (void)testScanTwoAssetsTwoFaces {
    NSArray *urls = @[@"TestAssert_1", @"TestAsset_2"];
    NSArray *numbersOfFaces = @[[NSNumber numberWithInteger:3], [NSNumber numberWithInteger:2]];
    self.assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:urls numbersOfFaces:numbersOfFaces];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 0, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 5, @"");
    XCTAssertEqual(self.facesManager.photos.count, 2, @"");
    XCTAssertEqual(self.facesManager.faces.count, 5, @"");
    XCTAssertEqual(self.numberOfThumbnails, 5, @"");
    
    NSLog(@"testScanTwoAssetsTwoFaces :%@", self.facesManager.config);
    NSLog(@"testScanTwoAssetsTwoFaces: %@", self.facesManager.photos);
    NSLog(@"testScanTwoAssetsTwoFaces: %@", self.facesManager.faces);
    NSUInteger photoIndex = 0;
    for (CPPhoto *photo in self.facesManager.photos) {
        XCTAssertEqual(photo.url, [urls objectAtIndex:photoIndex], @"");
        XCTAssertEqual(photo.scanId, self.facesManager.config.currentScanId, @"");
        XCTAssertEqual(photo.faces.count, ((NSNumber *)[numbersOfFaces objectAtIndex:photoIndex++]).integerValue, @"");
        
        for (CPFace *face in photo.faces) {
            XCTAssertEqual(face.photo, photo, @"");
        }
    }
}

- (void)testScanAssetsAdding {
    NSArray *urls1 = @[@"TestAssert_1"];
    NSArray *numbersOfFaces1 = @[[NSNumber numberWithInteger:3]];
    NSArray *urls2 = @[@"TestAssert_1", @"TestAsset_2"];
    NSArray *numbersOfFaces2 = @[[NSNumber numberWithInteger:3], [NSNumber numberWithInteger:5]];
    self.assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:urls1 numbersOfFaces:numbersOfFaces1];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 0, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 3, @"");
    XCTAssertEqual(self.facesManager.photos.count, 1, @"");
    XCTAssertEqual(self.facesManager.faces.count, 3, @"");
    XCTAssertEqual(self.numberOfThumbnails, 3, @"");

    NSLog(@"testScanAssetsAdding before adding: %@", self.facesManager.config);
    NSLog(@"testScanAssetsAdding before adding: %@", self.facesManager.photos);
    NSLog(@"testScanAssetsAdding before adding: %@", self.facesManager.faces);
    NSUInteger photoIndex = 0;
    for (CPPhoto *photo in self.facesManager.photos) {
        XCTAssertEqual(photo.url, [urls1 objectAtIndex:photoIndex], @"");
        XCTAssertEqual(photo.scanId, self.facesManager.config.currentScanId, @"");
        XCTAssertEqual(photo.faces.count, ((NSNumber *)[numbersOfFaces1 objectAtIndex:photoIndex++]).integerValue, @"");
        
        for (CPFace *face in photo.faces) {
            XCTAssertEqual(face.photo, photo, @"");
        }
    }

    self.assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:urls2 numbersOfFaces:numbersOfFaces2];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 1, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 8, @"");
    XCTAssertEqual(self.facesManager.photos.count, 2, @"");
    XCTAssertEqual(self.facesManager.faces.count, 8, @"");
    XCTAssertEqual(self.numberOfThumbnails, 8, @"");
    
    NSLog(@"testScanAssetsAdding after adding: %@", self.facesManager.config);
    NSLog(@"testScanAssetsAdding after adding: %@", self.facesManager.photos);
    NSLog(@"testScanAssetsAdding after adding: %@", self.facesManager.faces);
    photoIndex = 0;
    for (CPPhoto *photo in self.facesManager.photos) {
        XCTAssertEqual(photo.url, [urls2 objectAtIndex:photoIndex], @"");
        XCTAssertEqual(photo.scanId, self.facesManager.config.currentScanId, @"");
        XCTAssertEqual(photo.faces.count, ((NSNumber *)[numbersOfFaces2 objectAtIndex:photoIndex++]).integerValue, @"");
        
        for (CPFace *face in photo.faces) {
            XCTAssertEqual(face.photo, photo, @"");
        }
    }
}

- (void)testScanAssetsRemoving {
    NSArray *urls1 = @[@"TestAssert_1", @"TestAsset_2"];
    NSArray *numbersOfFaces1 = @[[NSNumber numberWithInteger:3], [NSNumber numberWithInteger:5]];
    NSArray *urls2 = @[@"TestAssert_1"];
    NSArray *numbersOfFaces2 = @[[NSNumber numberWithInteger:3]];
    self.assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:urls1 numbersOfFaces:numbersOfFaces1];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 0, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 8, @"");
    XCTAssertEqual(self.facesManager.photos.count, 2, @"");
    XCTAssertEqual(self.facesManager.faces.count, 8, @"");
    XCTAssertEqual(self.numberOfThumbnails, 8, @"");
    
    NSLog(@"testScanAssetsAdding before removing: %@", self.facesManager.config);
    NSLog(@"testScanAssetsAdding before removing: %@", self.facesManager.photos);
    NSLog(@"testScanAssetsAdding before removing: %@", self.facesManager.faces);
    NSUInteger photoIndex = 0;
    for (CPPhoto *photo in self.facesManager.photos) {
        XCTAssertEqual(photo.url, [urls1 objectAtIndex:photoIndex], @"");
        XCTAssertEqual(photo.scanId, self.facesManager.config.currentScanId, @"");
        XCTAssertEqual(photo.faces.count, ((NSNumber *)[numbersOfFaces1 objectAtIndex:photoIndex++]).integerValue, @"");
        
        for (CPFace *face in photo.faces) {
            XCTAssertEqual(face.photo, photo, @"");
        }
    }
    
    self.assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:urls2 numbersOfFaces:numbersOfFaces2];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 1, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 8, @"");
    XCTAssertEqual(self.facesManager.photos.count, 1, @"");
    XCTAssertEqual(self.facesManager.faces.count, 3, @"");
    XCTAssertEqual(self.numberOfThumbnails, 3, @"");
    
    NSLog(@"testScanAssetsAdding after removing:%@", self.facesManager.config);
    NSLog(@"testScanAssetsAdding after removing: %@", self.facesManager.photos);
    NSLog(@"testScanAssetsAdding after removing: %@", self.facesManager.faces);
    photoIndex = 0;
    for (CPPhoto *photo in self.facesManager.photos) {
        XCTAssertEqual(photo.url, [urls2 objectAtIndex:photoIndex], @"");
        XCTAssertEqual(photo.scanId, self.facesManager.config.currentScanId, @"");
        XCTAssertEqual(photo.faces.count, ((NSNumber *)[numbersOfFaces2 objectAtIndex:photoIndex++]).integerValue, @"");
        
        for (CPFace *face in photo.faces) {
            XCTAssertEqual(face.photo, photo, @"");
        }
    }
}

- (void)testScanAssetsAddingRemovingEmpty {
    NSArray *urls1 = @[@"TestAssert_1", @"TestAsset_2"];
    NSArray *numbersOfFaces1 = @[[NSNumber numberWithInteger:3], [NSNumber numberWithInteger:5]];
    NSArray *urls2 = @[@"TestAssert_1", @"TestAsset_3"];
    NSArray *numbersOfFaces2 = @[[NSNumber numberWithInteger:3], [NSNumber numberWithInteger:2]];
    self.assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:urls1 numbersOfFaces:numbersOfFaces1];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 0, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 8, @"");
    XCTAssertEqual(self.facesManager.photos.count, 2, @"");
    XCTAssertEqual(self.facesManager.faces.count, 8, @"");
    XCTAssertEqual(self.numberOfThumbnails, 8, @"");
    
    NSLog(@"testScanAssetsAdding before adding and removing: %@", self.facesManager.config);
    NSLog(@"testScanAssetsAdding before adding and removing: %@", self.facesManager.photos);
    NSLog(@"testScanAssetsAdding before adding and removing: %@", self.facesManager.faces);
    NSUInteger photoIndex = 0;
    for (CPPhoto *photo in self.facesManager.photos) {
        XCTAssertEqual(photo.url, [urls1 objectAtIndex:photoIndex], @"");
        XCTAssertEqual(photo.scanId, self.facesManager.config.currentScanId, @"");
        XCTAssertEqual(photo.faces.count, ((NSNumber *)[numbersOfFaces1 objectAtIndex:photoIndex++]).integerValue, @"");
        
        for (CPFace *face in photo.faces) {
            XCTAssertEqual(face.photo, photo, @"");
        }
    }
    
    self.assetsLibrary.assetsProvider = [[CPAssetsProvider alloc] initWithAssetURLs:urls2 numbersOfFaces:numbersOfFaces2];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 1, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 10, @"");
    XCTAssertEqual(self.facesManager.photos.count, 2, @"");
    XCTAssertEqual(self.facesManager.faces.count, 5, @"");
    XCTAssertEqual(self.numberOfThumbnails, 5, @"");
    
    NSLog(@"testScanAssetsAdding after adding and removing:%@", self.facesManager.config);
    NSLog(@"testScanAssetsAdding after adding and removing: %@", self.facesManager.photos);
    NSLog(@"testScanAssetsAdding after adding and removing: %@", self.facesManager.faces);
    photoIndex = 0;
    for (CPPhoto *photo in self.facesManager.photos) {
        XCTAssertEqual(photo.url, [urls2 objectAtIndex:photoIndex], @"");
        XCTAssertEqual(photo.scanId, self.facesManager.config.currentScanId, @"");
        XCTAssertEqual(photo.faces.count, ((NSNumber *)[numbersOfFaces2 objectAtIndex:photoIndex++]).integerValue, @"");
        
        for (CPFace *face in photo.faces) {
            XCTAssertEqual(face.photo, photo, @"");
        }
    }

    self.assetsLibrary.assetsProvider = [[CPEmptyAssetsProvider alloc] init];
    
    [self.facesManager scanFaces];
    XCTAssertEqual(self.facesManager.config.currentScanId.integerValue, 2, @"");
    XCTAssertEqual(self.facesManager.config.nextFaceId.integerValue, 10, @"");
    XCTAssertEqual(self.facesManager.photos.count, 0, @"");
    XCTAssertEqual(self.facesManager.faces.count, 0, @"");
    XCTAssertEqual(self.numberOfThumbnails, 0, @"");
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
