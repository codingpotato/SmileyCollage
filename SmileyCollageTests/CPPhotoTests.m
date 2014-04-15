//
//  CPPhotoTests.m
//  SmileyCollage
//
//  Created by wangyw on 4/13/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPCoreDataTestHelper.h"

#import "CPPhoto.h"

@interface CPPhotoTests : XCTestCase

@property (strong, nonatomic) CPCoreDataTestHelper *coreDataTestHelper;

@end

@implementation CPPhotoTests

- (void)setUp {
    [super setUp];
    self.coreDataTestHelper = [[CPCoreDataTestHelper alloc] init];
}

- (void)tearDown {
    self.coreDataTestHelper = nil;
    [super tearDown];
}

- (void)testPhotoWithURL {
    NSString *expectedURLString = @"file://expectedURL";
    NSTimeInterval expectedCreateTime = 1;
    NSTimeInterval expectedScanTime = 2;
    CPPhoto *photo = [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString] createTime:expectedCreateTime scanTime:expectedScanTime inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photo.url, expectedURLString, @"");
    XCTAssertEqual(photo.createTime.doubleValue, expectedCreateTime, @"");
    XCTAssertEqual(photo.scanTime.doubleValue, expectedScanTime, @"");
    XCTAssertEqual(photo.faces.count, 0, @"");
}

- (void)testPhotoOfURL {
    NSString *expectedURLString = @"file://expectedURL";
    NSTimeInterval expectedCreateTime = 1;
    NSTimeInterval expectedScanTime = 2;
    [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString] createTime:expectedCreateTime scanTime:expectedScanTime inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CPPhoto *photo = [CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString] inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photo.url, expectedURLString, @"");
    XCTAssertEqual(photo.createTime.doubleValue, expectedCreateTime, @"");
    XCTAssertEqual(photo.scanTime.doubleValue, expectedScanTime, @"");
    XCTAssertEqual(photo.faces.count, 0, @"");

    photo = [CPPhoto photoOfURL:[NSURL URLWithString:@"file://unknown"] inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertNil(photo, @"");
}

- (void)testPhotosScannedBeforeTimeOne {
    NSString *expectedURLString1 = @"file://expectedURL1";
    NSTimeInterval expectedCreateTime1 = 1;
    NSTimeInterval expectedScanTime1 = 100;
    [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString1] createTime:expectedCreateTime1 scanTime:expectedScanTime1 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CPPhoto *photo1 = [CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString1] inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photo1.url, expectedURLString1, @"");
    XCTAssertEqual(photo1.createTime.doubleValue, expectedCreateTime1, @"");
    XCTAssertEqual(photo1.scanTime.doubleValue, expectedScanTime1, @"");
    XCTAssertEqual(photo1.faces.count, 0, @"");

    NSString *expectedURLString2 = @"file://expectedURL2";
    NSTimeInterval expectedCreateTime2 = 2;
    NSTimeInterval expectedScanTime2 = 200;
    [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString2] createTime:expectedCreateTime2 scanTime:expectedScanTime2 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CPPhoto *photo2 = [CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString2] inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photo2.url, expectedURLString2, @"");
    XCTAssertEqual(photo2.createTime.doubleValue, expectedCreateTime2, @"");
    XCTAssertEqual(photo2.scanTime.doubleValue, expectedScanTime2, @"");
    XCTAssertEqual(photo2.faces.count, 0, @"");
    
    NSArray *photos = [CPPhoto photosScannedBeforeTime:200 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photos.count, 1, @"");
    XCTAssertEqual([photos objectAtIndex:0], photo1, @"");
}

- (void)testPhotosScannedBeforeTimeTwo {
    NSString *expectedURLString1 = @"file://expectedURL1";
    NSTimeInterval expectedCreateTime1 = 1;
    NSTimeInterval expectedScanTime1 = 100;
    [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString1] createTime:expectedCreateTime1 scanTime:expectedScanTime1 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CPPhoto *photo1 = [CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString1] inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photo1.url, expectedURLString1, @"");
    XCTAssertEqual(photo1.createTime.doubleValue, expectedCreateTime1, @"");
    XCTAssertEqual(photo1.scanTime.doubleValue, expectedScanTime1, @"");
    XCTAssertEqual(photo1.faces.count, 0, @"");
    
    NSString *expectedURLString2 = @"file://expectedURL2";
    NSTimeInterval expectedCreateTime2 = 2;
    NSTimeInterval expectedScanTime2 = 200;
    [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString2] createTime:expectedCreateTime2 scanTime:expectedScanTime2 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CPPhoto *photo2 = [CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString2] inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photo2.url, expectedURLString2, @"");
    XCTAssertEqual(photo2.createTime.doubleValue, expectedCreateTime2, @"");
    XCTAssertEqual(photo2.scanTime.doubleValue, expectedScanTime2, @"");
    XCTAssertEqual(photo2.faces.count, 0, @"");
    
    NSString *expectedURLString3 = @"file://expectedURL3";
    NSTimeInterval expectedCreateTime3 = 3;
    NSTimeInterval expectedScanTime3 = 300;
    [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString3] createTime:expectedCreateTime3 scanTime:expectedScanTime3 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CPPhoto *photo3 = [CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString3] inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photo3.url, expectedURLString3, @"");
    XCTAssertEqual(photo3.createTime.doubleValue, expectedCreateTime3, @"");
    XCTAssertEqual(photo3.scanTime.doubleValue, expectedScanTime3, @"");
    XCTAssertEqual(photo3.faces.count, 0, @"");
    
    NSArray *photos = [CPPhoto photosScannedBeforeTime:150 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photos.count, 1, @"");
    XCTAssertEqual([photos objectAtIndex:0], photo1, @"");
    photos = [CPPhoto photosScannedBeforeTime:300 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(photos.count, 2, @"");
    XCTAssertTrue([photos containsObject:photo1], @"");
    XCTAssertTrue([photos containsObject:photo2], @"");
}

@end
