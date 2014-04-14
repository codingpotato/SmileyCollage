//
//  CPFace.h
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPPhoto;

@interface CPFace : NSManagedObject

@property (strong, nonatomic) NSNumber *x;
@property (strong, nonatomic) NSNumber *y;
@property (strong, nonatomic) NSNumber *width;
@property (strong, nonatomic) NSNumber *height;
@property (strong, nonatomic) NSString *thumbnail;
@property (strong, nonatomic) CPPhoto *photo;

+ (CPFace *)faceWithPhoto:(CPPhoto *)photo bounds:(CGRect)bounds inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSFetchRequest *)fetchRequestForFacesInManagedObjectContext:(NSManagedObjectContext *)context;

@end
