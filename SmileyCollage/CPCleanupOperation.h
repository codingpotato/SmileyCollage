//
//  CPCleanupOperation.h
//  Smiley
//
//  Created by wangyw on 3/27/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCoreDataOperation.h"

@interface CPCleanupOperation : CPCoreDataOperation

- (id)initWithScanTime:(NSTimeInterval)scanTime persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end
