//
//  CPConfig.m
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPConfig.h"

@implementation CPConfig

@dynamic nextFaceId;
@dynamic currentScanId;

+ (CPConfig *)configInManagedObjectContext:(NSManagedObjectContext *)context {
    NSString *entityName = NSStringFromClass(self.class);
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];

    NSArray *array = [context executeFetchRequest:request error:nil];
    CPConfig *config = nil;
    if (array.count == 0) {
        config = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        config.nextFaceId = [NSNumber numberWithInteger:0];
        config.currentScanId = [NSNumber numberWithInteger:-1];
    } else if (array.count == 1) {
        config = [array objectAtIndex:0];
    } else {
        NSAssert(NO, @"");
    }
    return config;
}

- (void)increaseNextFaceId {
    self.nextFaceId = [NSNumber numberWithInteger:self.nextFaceId.integerValue + 1];
}

- (void)increaseCurrentScanId {
    self.currentScanId = [NSNumber numberWithInteger:self.currentScanId.integerValue + 1];
}

@end
