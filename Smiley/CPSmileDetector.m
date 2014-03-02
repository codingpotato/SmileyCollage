//
//  CPSmileDetector.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSmileDetector.h"

@implementation CPSmileDetector

+ (NSArray *)facesInImage:(CGImageRef)image {
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSDictionary *options = @{CIDetectorSmile: @(NO), CIDetectorEyeBlink: @(NO)};
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image] options:options];
    
    NSMutableArray *faces = [NSMutableArray array];
    for (CIFeature *feature in features) {
        [faces addObject:[NSValue valueWithCGRect:feature.bounds]];
    }
    
    return [faces copy];
}

@end
