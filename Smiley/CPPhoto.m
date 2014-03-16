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

@dynamic sequenceNumber;
@dynamic url;
@dynamic faces;

+ (CPPhoto *)createPhotoInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
}

+ (CPPhoto *)photoOfURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context {
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NSStringFromClass(self.class) inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", url];
    [request setPredicate:predicate];
    
    NSArray *array = [context executeFetchRequest:request error:nil];
    if (array.count > 0) {
        return [array objectAtIndex:0];
    } else {
        return nil;
    }
}

+ (void)clearPhotosNotEqualSequenceNumber:(NSNumber *)sequenceNumber fromManagedObjectContext:(NSManagedObjectContext *)context {
}

@end
