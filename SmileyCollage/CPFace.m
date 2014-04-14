//
//  CPFace.m
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFace.h"

#import "CPPhoto.h"

@implementation CPFace

@dynamic x;
@dynamic y;
@dynamic width;
@dynamic height;
@dynamic thumbnail;
@dynamic photo;

+ (CPFace *)faceWithPhoto:(CPPhoto *)photo bounds:(CGRect)bounds inManagedObjectContext:(NSManagedObjectContext *)context {
    NSAssert(photo, @"");
    NSAssert(context, @"");
    
    CPFace *face = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    face.x = [NSNumber numberWithFloat:bounds.origin.x];
    face.y = [NSNumber numberWithFloat:bounds.origin.y];
    face.width = [NSNumber numberWithFloat:bounds.size.width];
    face.height = [NSNumber numberWithFloat:bounds.size.height];
    face.thumbnail = [[[NSUUID alloc] init].UUIDString stringByAppendingPathExtension:@"jpg"];
    face.photo = photo;
    [photo addFacesObject:face];
    return face;
}

+ (NSFetchRequest *)fetchRequestForFacesInManagedObjectContext:(NSManagedObjectContext *)context {
    NSAssert(context, @"");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"photo.createTime" ascending:YES], nil];
    return request;
}

@end
