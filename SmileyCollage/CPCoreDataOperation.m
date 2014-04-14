//
//  CPCoreDataOperation.m
//  Smiley
//
//  Created by wangyw on 3/25/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCoreDataOperation.h"

@interface CPCoreDataOperation ()

@property (weak, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CPCoreDataOperation

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    self = [super init];
    if (self) {
        self.persistentStoreCoordinator = persistentStoreCoordinator;
    }
    return self;
}

#pragma mark - lazy init

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        NSAssert(self.persistentStoreCoordinator, @"");
        
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _managedObjectContext;
}

- (void)save {
    NSAssert(self.managedObjectContext, @"");
    
    if ([self.managedObjectContext hasChanges]) {
        [self.managedObjectContext save:nil];
    }
}

@end
