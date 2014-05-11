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
