//
//  CPConfig.h
//  Smiley
//
//  Created by wangyw on 3/29/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPConfig : NSObject

+ (BOOL)isIPhone;

+ (CGFloat)thumbnailSize;

+ (CGFloat)confirmButtonTitleFontSize;

+ (UIEdgeInsets)confirmButtonTitleEdgeInsetsForOneDigit;

+ (UIEdgeInsets)confirmButtonTitleEdgeInsetsForTwoDigits;

+ (NSString *)helpFontName;

+ (CGFloat)helpFontSize;

+ (CGFloat)introductionLabelWidth;

+ (CGFloat)introductionLineSpacing;

+ (CGFloat)introductionTitleFontSize;

+ (CGFloat)introductionTextFontSize;

@end
