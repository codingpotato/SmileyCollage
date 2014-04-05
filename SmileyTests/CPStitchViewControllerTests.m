//
//  CPStitchViewControllerTests.m
//  Smiley
//
//  Created by wangyw on 3/20/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPFaceEditInformation.h"
#import "CPStitchViewController.h"

@interface CPStitchViewController ()

- (NSArray *)numberOfColumnsInRows;

- (CGFloat)widthHeightRatioOfImage;

- (void)calculateImageWidthHeightRatio;

@end

@interface CPStitchViewControllerTests : XCTestCase

@end

@implementation CPStitchViewControllerTests

static const float g_floatAccuracy = 0.000001;

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNumberOfColumnsInRows {
    CPStitchViewController *stitchViewController = [self stitchViewControllerOfFacesNumber:1];
    [stitchViewController calculateImageWidthHeightRatio];
    NSArray *expectNumberOfColumnsInRows = @[@1];
    XCTAssertEqual(stitchViewController.numberOfColumnsInRows.count, 1, @"");

    stitchViewController = [self stitchViewControllerOfFacesNumber:2];
    [stitchViewController calculateImageWidthHeightRatio];
    expectNumberOfColumnsInRows = @[@1, @1];
    XCTAssertEqualObjects(stitchViewController.numberOfColumnsInRows, expectNumberOfColumnsInRows, @"");
    
    stitchViewController = [self stitchViewControllerOfFacesNumber:3];
    [stitchViewController calculateImageWidthHeightRatio];
    expectNumberOfColumnsInRows = @[@1, @2];
    XCTAssertEqualObjects(stitchViewController.numberOfColumnsInRows, expectNumberOfColumnsInRows, @"");
}

- (void)testRatioOfImageWidthHeight {
    CPStitchViewController *stitchViewController = [self stitchViewControllerOfFacesNumber:1];
    [stitchViewController calculateImageWidthHeightRatio];
    XCTAssertEqual(stitchViewController.widthHeightRatioOfImage, 1.0, @"");

    stitchViewController = [self stitchViewControllerOfFacesNumber:2];
    [stitchViewController calculateImageWidthHeightRatio];
    XCTAssertEqualWithAccuracy(stitchViewController.widthHeightRatioOfImage, 1.0 / 2.0, g_floatAccuracy, @"");
    
    stitchViewController = [self stitchViewControllerOfFacesNumber:3];
    [stitchViewController calculateImageWidthHeightRatio];
    XCTAssertEqualWithAccuracy(stitchViewController.widthHeightRatioOfImage, 2.0 / 3.0, g_floatAccuracy, @"");
}

- (CPStitchViewController *)stitchViewControllerOfFacesNumber:(NSUInteger)number {
    CPStitchViewController *stitchViewController = [[CPStitchViewController alloc] init];
    stitchViewController.stitchedFaces = [[NSMutableArray alloc] init];
    for (NSUInteger j = 0; j < number; ++j) {
        [stitchViewController.stitchedFaces addObject:[[CPFaceEditInformation alloc] init]];
    }
    return stitchViewController;
}

@end
