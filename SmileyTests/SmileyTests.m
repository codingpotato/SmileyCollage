//
//  SmileyTests.m
//  SmileyTests
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPAssetsLibrary.h"

@interface SmileyTests : XCTestCase

@end

@implementation SmileyTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testExample {
    __block BOOL completion = NO;
    CPAssetsLibrary *assetsLibrary = [[CPAssetsLibrary alloc] init];
    [assetsLibrary detectFacesBySkipAssetBlock:^BOOL(NSString *assetURL) {
        return NO;
    } resultBlock:^(NSString *assetURL, NSMutableArray *boundsOfFaces) {
        NSLog(@"[%@] - %@", assetURL, boundsOfFaces);
    } completionBlock:^{
        NSLog(@"Finished!");
        completion = YES;
    }];
    
    while (!completion) {
    }
}

@end
