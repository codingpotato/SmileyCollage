//
//  CPConfig.h
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPConfig : NSManagedObject

@property (nonatomic, retain) NSNumber *sequenceNumber;

+ (CPConfig *)configInManagedObjectContext:(NSManagedObjectContext *)context;

@end
