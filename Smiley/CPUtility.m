//
//  CPUtility.m
//  Smiley
//
//  Created by wangyw on 3/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPUtility.h"

@implementation CPUtility

+ (NSString *)applicationDocumentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)thumbnailPath {
    return [[CPUtility applicationDocumentsPath] stringByAppendingPathComponent:@"thumbnail"];
}

@end
