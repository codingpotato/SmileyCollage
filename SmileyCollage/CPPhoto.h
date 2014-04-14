//
//  CPPhoto.h
//  Smiley
//
//  Created by wangyw on 3/15/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPFace;

@interface CPPhoto : NSManagedObject

@property (strong, nonatomic) NSNumber *createTime;
@property (strong, nonatomic) NSNumber *scanTime;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSSet *faces;

+ (CPPhoto *)photoWithURL:(NSURL *)url createTime:(NSTimeInterval)createTime scanTime:(NSTimeInterval)scanTime  inManagedObjectContext:(NSManagedObjectContext *)context;

+ (CPPhoto *)photoOfURL:(NSURL *)url inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)photosScannedBeforeTime:(NSTimeInterval)scanTime inManagedObjectContext:(NSManagedObjectContext *)context;

@end

@interface CPPhoto (CoreDataGeneratedAccessors)

- (void)addFacesObject:(CPFace *)value;
- (void)removeFacesObject:(CPFace *)value;
- (void)addFaces:(NSSet *)values;
- (void)removeFaces:(NSSet *)values;

@end
