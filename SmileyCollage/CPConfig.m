//
//  CPConfig.m
//  Smiley
//
//  Created by wangyw on 3/29/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPConfig.h"

@implementation CPConfig

+ (BOOL)isIPhone {
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
}

+ (CGFloat)thumbnailSize {
    if ([self isIPhone]) {
        return 64.0;
    } else {
        return 100.0;
    }
}

+ (CGFloat)confirmButtonTitleFontSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale == 1.0) {
        return 12.0;
    } else if (scale == 2.0) {
        return 11.0;
    } else {
        NSAssert(NO, @"");
        return 0.0;
    }
}

+ (UIEdgeInsets)confirmButtonTitleEdgeInsetsForOneDigit {
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale == 1.0) {
        return UIEdgeInsetsMake(-5.0, -15.5, 0.0, 0.0);
    } else if (scale == 2.0) {
        return UIEdgeInsetsMake(-6.0, -14.0, 0.0, 0.0);
    } else {
        NSAssert(NO, @"");
        return UIEdgeInsetsZero;
    }
}

+ (UIEdgeInsets)confirmButtonTitleEdgeInsetsForTwoDigits {
    CGFloat scale = [UIScreen mainScreen].scale;
    if (scale == 1.0) {
        return UIEdgeInsetsMake(-5.0, -19.0, 0.0, 0.0);
    } else if (scale == 2.0) {
        return UIEdgeInsetsMake(-6.0, -18.0, 0.0, 0.0);
    } else {
        NSAssert(NO, @"");
        return UIEdgeInsetsZero;
    }
}

+ (NSString *)helpFontName {
    return @"ArialRoundedMTBold";
}

+ (CGFloat)noSmileyLabelFontSize {
    if ([self isIPhone]) {
        return 18.0;
    } else {
        return 22.0;
    }
}

+ (CGFloat)helpFontSize {
    if ([self isIPhone]) {
        return 18.0;
    } else {
        return 22.0;
    }
}

@end
