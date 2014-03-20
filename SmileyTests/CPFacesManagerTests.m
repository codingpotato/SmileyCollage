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

@property (strong, nonatomic) CPFacesManager *facesManager;

@end

@implementation CPFacesManagerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    self.facesManager = [[CPFacesManager alloc] initWithAssetsLibrary:[[CPMockupEmptyAssetsLibrary alloc] init]];
    [self.facesManager scanFaces];
    XCTAssertEqual(0, self.facesManager.facesController.fetchedObjects.count, @"");
}

@end
