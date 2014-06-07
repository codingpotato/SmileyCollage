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
    return 16.0;
}

+ (UIEdgeInsets)confirmButtonTitleEdgeInsetsForOneDigit {
    return UIEdgeInsetsMake(-3.5, -19.5, 0.0, 0.0);
}

+ (UIEdgeInsets)confirmButtonTitleEdgeInsetsForTwoDigits {
    return UIEdgeInsetsMake(-3.5, -28.0, 0.0, 0.0);
}

+ (NSString *)helpFontName {
    return @"ArialRoundedMTBold";
}

+ (CGFloat)helpFontSize {
    if ([self isIPhone]) {
        return 18.0;
    } else {
        return 25.0;
    }
}

+ (CGFloat)introductionLabelWidth {
    if ([self isIPhone]) {
        return 270.0;
    } else {
        return 380.0;
    }
}

+ (CGFloat)introductionLineSpacing {
    if ([self isIPhone]) {
        return 5.0;
    } else {
        return 10.0;
    }
}

+ (CGFloat)introductionTitleFontSize {
    if ([self isIPhone]) {
        return 25.0;
    } else {
        return 35.0;
    }
}

+ (CGFloat)introductionTextFontSize {
    if ([self isIPhone]) {
        return 18.0;
    } else {
        return 25.0;
    }
}

@end
