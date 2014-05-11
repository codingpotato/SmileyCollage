//
//  CPSettingTests.m
//  SmileyCollage
//
//  Created by wangyw on 4/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPSettings.h"

@interface CPSettingTests : XCTestCase

@end

@implementation CPSettingTests

- (void)setUp {
    [super setUp];
    [CPSettings reset];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testDefault {
    XCTAssertEqual([CPSettings isWatermarkRemovePurchased], NO, @"");
}

- (void)testRemoveWatermark {
    [CPSettings purchaseRemoveWatermark];
    XCTAssertEqual([CPSettings isWatermarkRemovePurchased], YES, @"");
}

@end
