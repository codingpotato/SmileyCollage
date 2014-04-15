//
//  CPCoreDataTestHelper.m
//  SmileyCollage
//
//  Created by wangyw on 4/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCoreDataTestHelper.h"

@interface CPCoreDataTestHelper ()

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CPCoreDataTestHelper

#pragma mark - lazy init

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SmileyCollage" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:&error]) {
            NSLog(@"in memory persistent store create failed");
        }
    }
    return _persistentStoreCoordinator;
}

@end
