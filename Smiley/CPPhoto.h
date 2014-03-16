//
//  CPPhoto.h
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPFace;

@interface CPPhoto : NSManagedObject

@property (strong, nonatomic) NSNumber *sequenceNumber;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSSet *faces;

+ (CPPhoto *)createPhotoInManagedObjectContext:(NSManagedObjectContext *)context;

+ (CPPhoto *)photoOfURL:(NSString *)url inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)expiredPhotosWithSequenceNumber:(NSNumber *)sequenceNumber fromManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface CPPhoto (CoreDataGeneratedAccessors)

- (void)addFacesObject:(CPFace *)value;
- (void)removeFacesObject:(CPFace *)value;
- (void)addFaces:(NSSet *)values;
- (void)removeFaces:(NSSet *)values;

@end
