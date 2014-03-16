//
//  CPConfig.h
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPConfig : NSManagedObject

@property (strong, nonatomic) NSNumber *nextFaceId;
@property (strong, nonatomic) NSNumber *sequenceNumber;

+ (CPConfig *)configInManagedObjectContext:(NSManagedObjectContext *)context;

- (void)increaseNextFaceId;

- (void)increaseSequenceNumber;

@end
