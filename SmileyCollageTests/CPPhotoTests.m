//
//  CPPhotoTests.m
//  SmileyCollage
//
//  Created by wangyw on 4/13/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPUtility.h"

#import "CPPhoto.h"

@interface CPPhotoTests : XCTestCase

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CPPhotoTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPhotoWithURL {
    NSString *expectedURLString = @"file://expectedURL";
    NSTimeInterval expectedCreateTime = 1;
    NSTimeInterval expectedScanTime = 2;
    CPPhoto *photo = [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString] createTime:expectedCreateTime scanTime:expectedScanTime inManagedObjectContext:self.managedObjectContext];
    XCTAssertEqual(photo.url, expectedURLString, @"");
    XCTAssertEqual(photo.createTime.doubleValue, expectedCreateTime, @"");
    XCTAssertEqual(photo.scanTime.doubleValue, expectedScanTime, @"");
    XCTAssertEqual(photo.faces.count, 0, @"");
}

- (void)testPhotoOfURL {
    NSString *expectedURLString = @"file://expectedURL";
    NSTimeInterval expectedCreateTime = 1;
    NSTimeInterval expectedScanTime = 2;
    [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString] createTime:expectedCreateTime scanTime:expectedScanTime inManagedObjectContext:self.managedObjectContext];
    CPPhoto *photo = [CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString] inManagedObjectContext:self.managedObjectContext];
    XCTAssertEqual(photo.url, expectedURLString, @"");
    XCTAssertEqual(photo.createTime.doubleValue, expectedCreateTime, @"");
    XCTAssertEqual(photo.scanTime.doubleValue, expectedScanTime, @"");
    XCTAssertEqual(photo.faces.count, 0, @"");
}

- (void)testPhotosScannedBeforeTime {
    NSString *expectedURLString1 = @"file://expectedURL1";
    NSTimeInterval expectedCreateTime1 = 1;
    NSTimeInterval expectedScanTime1 = 100;
    [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString1] createTime:expectedCreateTime1 scanTime:expectedScanTime1 inManagedObjectContext:self.managedObjectContext];
    CPPhoto *photo1 = [CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString1] inManagedObjectContext:self.managedObjectContext];
    XCTAssertEqual(photo1.url, expectedURLString1, @"");
    XCTAssertEqual(photo1.createTime.doubleValue, expectedCreateTime1, @"");
    XCTAssertEqual(photo1.scanTime.doubleValue, expectedScanTime1, @"");
    XCTAssertEqual(photo1.faces.count, 0, @"");

    NSString *expectedURLString2 = @"file://expectedURL2";
    NSTimeInterval expectedCreateTime2 = 2;
    NSTimeInterval expectedScanTime2 = 200;
    [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString2] createTime:expectedCreateTime2 scanTime:expectedScanTime2 inManagedObjectContext:self.managedObjectContext];
    CPPhoto *photo2 = [CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString2] inManagedObjectContext:self.managedObjectContext];
    XCTAssertEqual(photo2.url, expectedURLString2, @"");
    XCTAssertEqual(photo2.createTime.doubleValue, expectedCreateTime2, @"");
    XCTAssertEqual(photo2.scanTime.doubleValue, expectedScanTime2, @"");
    XCTAssertEqual(photo2.faces.count, 0, @"");
    
    NSArray *photos = [CPPhoto photosScannedBeforeTime:200 inManagedObjectContext:self.managedObjectContext];
    XCTAssertEqual(photos.count, 1, @"");
    XCTAssertEqual([photos objectAtIndex:0], photo1, @"");
}

#pragma mark - lazy init

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SmileyCollage" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
            XCTFail(@"%@", error);
        }
    }
    return _persistentStoreCoordinator;
}

@end
