//
//  CPFace.m
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFace.h"

@implementation CPFace

@dynamic id;
@dynamic x;
@dynamic y;
@dynamic width;
@dynamic height;
@dynamic thumbnail;
@dynamic photo;

+ (CPFace *)createFaceInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:@"CPFace" inManagedObjectContext:context];
}

+ (NSArray *)facesInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES], nil];
    return [context executeFetchRequest:request error:nil];
}

@end
