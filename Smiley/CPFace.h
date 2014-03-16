//
//  CPFace.h
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPFace : NSManagedObject

@property (nonatomic, retain) NSNumber *x;
@property (nonatomic, retain) NSNumber *y;
@property (nonatomic, retain) NSNumber *width;
@property (nonatomic, retain) NSNumber *height;
@property (nonatomic, retain) NSString *thumbnail;
@property (nonatomic, retain) NSManagedObject *photo;

+ (CPFace *)createFaceInManagedObjectContext:(NSManagedObjectContext *)context;

@end
