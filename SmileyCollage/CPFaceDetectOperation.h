//
//  CPFaceDetectOperation.h
//  Smiley
//
//  Created by wangyw on 3/25/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCoreDataOperation.h"

@interface CPFaceDetectOperation : CPCoreDataOperation

- (id)initWithAsset:(ALAsset *)asset persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end
