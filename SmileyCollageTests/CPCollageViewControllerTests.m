//
//  CPStitchViewControllerTests.m
//  Smiley
//
//  Created by wangyw on 3/20/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPFaceEditInformation.h"
#import "CPCollageViewController.h"

@interface CPCollageViewController ()

- (NSArray *)numberOfColumnsInRows;

- (CGFloat)widthHeightRatioOfImage;

- (void)calculateImageWidthHeightRatio;

@end

@interface CPCollageViewControllerTests : XCTestCase

@end

@implementation CPCollageViewControllerTests

static const float g_floatAccuracy = 0.000001;

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNumberOfColumnsInRows {
    CPCollageViewController *stitchViewController = [self stitchViewControllerOfFacesNumber:1];
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
    CPCollageViewController *stitchViewController = [self stitchViewControllerOfFacesNumber:1];
    [stitchViewController calculateImageWidthHeightRatio];
    XCTAssertEqual(stitchViewController.widthHeightRatioOfImage, 1.0, @"");

    stitchViewController = [self stitchViewControllerOfFacesNumber:2];
    [stitchViewController calculateImageWidthHeightRatio];
    XCTAssertEqualWithAccuracy(stitchViewController.widthHeightRatioOfImage, 1.0 / 2.0, g_floatAccuracy, @"");
    
    stitchViewController = [self stitchViewControllerOfFacesNumber:3];
    [stitchViewController calculateImageWidthHeightRatio];
    XCTAssertEqualWithAccuracy(stitchViewController.widthHeightRatioOfImage, 2.0 / 3.0, g_floatAccuracy, @"");
}

- (CPCollageViewController *)stitchViewControllerOfFacesNumber:(NSUInteger)number {
    CPCollageViewController *stitchViewController = [[CPCollageViewController alloc] init];
    stitchViewController.collagedFaces = [[NSMutableArray alloc] init];
    for (NSUInteger j = 0; j < number; ++j) {
        [stitchViewController.collagedFaces addObject:[[CPFaceEditInformation alloc] init]];
    }
    return stitchViewController;
}

@end
