//
//  CPFaceTests.m
//  SmileyCollage
//
//  Created by wangyw on 4/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPCoreDataTestHelper.h"
#import "CPFace.h"
#import "CPPhoto.h"

@interface CPFaceTests : XCTestCase

@property (strong, nonatomic) CPCoreDataTestHelper *coreDataTestHelper;

@end

@implementation CPFaceTests

- (void)setUp {
    [super setUp];
    self.coreDataTestHelper = [[CPCoreDataTestHelper alloc] init];
}

- (void)tearDown {
    self.coreDataTestHelper = nil;
    [super tearDown];
}

- (void)testFaceWithPhoto {
    NSString *expectedURLString = @"file://expectedURL";
    NSTimeInterval expectedCreateTime = 1;
    NSTimeInterval expectedScanTime = 2;
    CPPhoto *photo = [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString] createTime:expectedCreateTime scanTime:expectedScanTime inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    
    CGRect bound = CGRectMake(1.0, 2.0, 3.0, 4.0);
    CPFace *face = [CPFace faceWithPhoto:photo bounds:bound inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    XCTAssertEqual(face.x.floatValue, bound.origin.x, @"");
    XCTAssertEqual(face.y.floatValue, bound.origin.y, @"");
    XCTAssertEqual(face.width.floatValue, bound.size.width, @"");
    XCTAssertEqual(face.height.floatValue, bound.size.height, @"");
    XCTAssertEqual(face.photo, photo, @"");
    XCTAssertEqual(photo.faces.count, 1, @"");
    XCTAssert([photo.faces containsObject:face], @"");
}

- (void)testFetchRequestForFacesInManagedObjectContext {
    NSString *expectedURLString1 = @"file://expectedURL1";
    NSTimeInterval expectedCreateTime1 = 1;
    NSTimeInterval expectedScanTime1 = 100;
    CPPhoto *photo1 = [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString1] createTime:expectedCreateTime1 scanTime:expectedScanTime1 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    
    CGRect bound1 = CGRectMake(1.0, 2.0, 3.0, 4.0);
    CPFace *face1 = [CPFace faceWithPhoto:photo1 bounds:bound1 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CGRect bound2 = CGRectMake(5.0, 6.0, 7.0, 8.0);
    CPFace *face2 = [CPFace faceWithPhoto:photo1 bounds:bound2 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];

    NSString *expectedURLString2 = @"file://expectedURL2";
    NSTimeInterval expectedCreateTime2 = 2;
    NSTimeInterval expectedScanTime2 = 200;
    CPPhoto *photo2 = [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString2] createTime:expectedCreateTime2 scanTime:expectedScanTime2 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    
    CGRect bound3 = CGRectMake(9.0, 10.0, 11.0, 12.0);
    CPFace *face3 = [CPFace faceWithPhoto:photo2 bounds:bound3 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CGRect bound4 = CGRectMake(13.0, 14.0, 15.0, 16.0);
    CPFace *face4 = [CPFace faceWithPhoto:photo2 bounds:bound4 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CGRect bound5 = CGRectMake(17.0, 18.0, 19.0, 20.0);
    CPFace *face5 = [CPFace faceWithPhoto:photo2 bounds:bound5 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];

    NSFetchRequest *fetechRequest = [CPFace fetchRequestForFacesInManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    NSArray *faces = [self.coreDataTestHelper.managedObjectContext executeFetchRequest:fetechRequest error:nil];
    XCTAssertEqual(faces.count, 5, @"");
    XCTAssertTrue([faces containsObject:face1], @"");
    XCTAssertTrue([faces containsObject:face2], @"");
    XCTAssertTrue([faces containsObject:face3], @"");
    XCTAssertTrue([faces containsObject:face4], @"");
    XCTAssertTrue([faces containsObject:face5], @"");
    XCTAssertTrue([faces indexOfObject:face1] < [faces indexOfObject:face3], @"");
    XCTAssertTrue([faces indexOfObject:face1] < [faces indexOfObject:face4], @"");
    XCTAssertTrue([faces indexOfObject:face1] < [faces indexOfObject:face5], @"");
    XCTAssertTrue([faces indexOfObject:face2] < [faces indexOfObject:face3], @"");
    XCTAssertTrue([faces indexOfObject:face2] < [faces indexOfObject:face4], @"");
    XCTAssertTrue([faces indexOfObject:face2] < [faces indexOfObject:face5], @"");
}

- (void)testRemovePhoto {
    NSString *expectedURLString1 = @"file://expectedURL1";
    NSTimeInterval expectedCreateTime1 = 1;
    NSTimeInterval expectedScanTime1 = 100;
    CPPhoto *photo1 = [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString1] createTime:expectedCreateTime1 scanTime:expectedScanTime1 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    
    CGRect bound1 = CGRectMake(1.0, 2.0, 3.0, 4.0);
    [CPFace faceWithPhoto:photo1 bounds:bound1 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CGRect bound2 = CGRectMake(5.0, 6.0, 7.0, 8.0);
    [CPFace faceWithPhoto:photo1 bounds:bound2 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    
    NSString *expectedURLString2 = @"file://expectedURL2";
    NSTimeInterval expectedCreateTime2 = 2;
    NSTimeInterval expectedScanTime2 = 200;
    CPPhoto *photo2 = [CPPhoto photoWithURL:[NSURL URLWithString:expectedURLString2] createTime:expectedCreateTime2 scanTime:expectedScanTime2 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    
    CGRect bound3 = CGRectMake(9.0, 10.0, 11.0, 12.0);
    CPFace *face3 = [CPFace faceWithPhoto:photo2 bounds:bound3 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CGRect bound4 = CGRectMake(13.0, 14.0, 15.0, 16.0);
    CPFace *face4 = [CPFace faceWithPhoto:photo2 bounds:bound4 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    CGRect bound5 = CGRectMake(17.0, 18.0, 19.0, 20.0);
    CPFace *face5 = [CPFace faceWithPhoto:photo2 bounds:bound5 inManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    
    [self.coreDataTestHelper.managedObjectContext deleteObject:photo1];
    XCTAssertNil([CPPhoto photoOfURL:[NSURL URLWithString:expectedURLString1] inManagedObjectContext:self.coreDataTestHelper.managedObjectContext], @"");
    
    NSFetchRequest *fetechRequest = [CPFace fetchRequestForFacesInManagedObjectContext:self.coreDataTestHelper.managedObjectContext];
    NSArray *faces = [self.coreDataTestHelper.managedObjectContext executeFetchRequest:fetechRequest error:nil];
    XCTAssertEqual(faces.count, 3, @"");
    XCTAssertTrue([faces containsObject:face3], @"");
    XCTAssertTrue([faces containsObject:face4], @"");
    XCTAssertTrue([faces containsObject:face5], @"");
}

@end
