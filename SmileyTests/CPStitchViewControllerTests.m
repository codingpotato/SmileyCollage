//
//  CPStitchViewControllerTests.m
//  Smiley
//
//  Created by wangyw on 3/20/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPStitchViewController.h"

@interface CPStitchViewController ()

- (NSArray *)numberOfColumnsInRows;

- (CGFloat)ratioOfImageWidthHeight;

@end

@interface CPStitchViewControllerTests : XCTestCase

@end

@implementation CPStitchViewControllerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNumberOfColumnsInRows {
    for (NSUInteger i = 1; i <= 16; ++i) {
        CPStitchViewController *stitchViewController = [[CPStitchViewController alloc] init];
        stitchViewController.stitchedFaces = [[NSMutableArray alloc] init];
        for (NSUInteger j = 0; j < i; ++j) {
            [stitchViewController.stitchedFaces addObject:[NSNumber numberWithBool:YES]];
        }
        NSLog(@"%@", stitchViewController.numberOfColumnsInRows);
    }
}

- (void)testRatioOfImageWidthHeight {
    for (NSUInteger i = 1; i <= 16; ++i) {
        CPStitchViewController *stitchViewController = [[CPStitchViewController alloc] init];
        stitchViewController.stitchedFaces = [[NSMutableArray alloc] init];
        for (NSUInteger j = 0; j < i; ++j) {
            [stitchViewController.stitchedFaces addObject:[NSNumber numberWithBool:YES]];
        }
        NSLog(@"%f", stitchViewController.ratioOfImageWidthHeight);
    }
}

@end
