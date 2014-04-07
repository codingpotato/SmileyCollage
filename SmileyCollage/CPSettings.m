//
//  CPSettings.m
//  SmileyCollage
//
//  Created by wangyw on 4/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSettings.h"

@implementation CPSettings

static NSString *g_isWatermarkRemoved = @"IsWatermarkRemoved";

+ (void)registerDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{g_isWatermarkRemoved: @(NO)}];
}

+ (void)reset {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isWatermarkRemoved];
}

+ (void)removeWatermark {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isWatermarkRemoved];
}

+ (BOOL)isWatermarkRemoved {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isWatermarkRemoved];
}

@end
