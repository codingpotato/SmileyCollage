//
//  CPPhoto.h
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPFace;

@interface CPPhoto : NSManagedObject

@property (nonatomic, retain) NSNumber *sequenceNumber;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSSet *faces;

@end

@interface CPPhoto (CoreDataGeneratedAccessors)

+ (CPPhoto *)createPhotoInManagedObjectContext:(NSManagedObjectContext *)context;

+ (CPPhoto *)photoOfURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)clearPhotosNotEqualSequenceNumber:(NSNumber *)sequenceNumber fromManagedObjectContext:(NSManagedObjectContext *)context;

- (void)addFacesObject:(CPFace *)value;
- (void)removeFacesObject:(CPFace *)value;
- (void)addFaces:(NSSet *)values;
- (void)removeFaces:(NSSet *)values;

@end
