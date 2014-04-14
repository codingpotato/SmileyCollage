//
//  CPPhoto.m
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFace.h"
#import "CPPhoto.h"

@implementation CPPhoto

@dynamic createTime;
@dynamic scanTime;
@dynamic url;
@dynamic faces;

+ (CPPhoto *)photoWithURL:(NSURL *)url createTime:(NSTimeInterval)createTime scanTime:(NSTimeInterval)scanTime inManagedObjectContext:(NSManagedObjectContext *)context {
    NSAssert(url, @"");
    NSAssert(context, @"");
    
    CPPhoto *photo = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    photo.createTime = [[NSNumber alloc] initWithDouble:createTime];
    photo.scanTime = [[NSNumber alloc] initWithDouble:scanTime];
    photo.url = url.absoluteString;
    return photo;
}

+ (CPPhoto *)photoOfURL:(NSURL *)url inManagedObjectContext:(NSManagedObjectContext *)context {
    NSAssert(url, @"");
    NSAssert(context, @"");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"url == %@", url.absoluteString];
    
    NSArray *array = [context executeFetchRequest:request error:nil];
    if (array.count > 0) {
        NSAssert(array.count == 1, @"");
        return [array objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (NSArray *)photosScannedBeforeTime:(NSTimeInterval)scanTime inManagedObjectContext:(NSManagedObjectContext *)context {
    NSAssert(context, @"");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"scanTime < %lf", scanTime];
    return [context executeFetchRequest:request error:nil];
}

@end
