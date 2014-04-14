//
//  CPCleanupOperation.m
//  Smiley
//
//  Created by wangyw on 3/27/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCleanupOperation.h"

#import "CPUtility.h"

#import "CPFace.h"
#import "CPPhoto.h"

@interface CPCleanupOperation ()

@property (nonatomic) NSTimeInterval scanTime;

@end

@implementation CPCleanupOperation

- (id)initWithScanTime:(NSTimeInterval)scanTime persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    self = [super initWithPersistentStoreCoordinator:persistentStoreCoordinator];
    if (self) {
        self.scanTime = scanTime;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        NSArray *expiredPhotos = [CPPhoto photosScannedBeforeTime:self.scanTime inManagedObjectContext:self.managedObjectContext];
        for (CPPhoto *photo in expiredPhotos) {
            for (CPFace *face in photo.faces) {
                NSString *filePath = [[CPUtility thumbnailPath] stringByAppendingPathComponent:face.thumbnail];
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            [self.managedObjectContext deleteObject:photo];
        }

        [self save];
    }
}

@end
