//
//  CPCoreDataOperation.h
//  Smiley
//
//  Created by wangyw on 3/25/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPCoreDataOperation : NSOperation

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (void)save;

@end
