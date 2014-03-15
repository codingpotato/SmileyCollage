//
//  CPFace.m
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFace.h"

@implementation CPFace

@dynamic index;
@dynamic x;
@dynamic y;
@dynamic width;
@dynamic height;
@dynamic photo;

+ (CPFace *)createFaceInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"CPFace" inManagedObjectContext:context];
}

@end
