//
//  CPFacesManager.h
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPFacesManager : NSObject

@property (strong, nonatomic) NSFetchedResultsController *facesController;

+ (CPFacesManager *)defaultManager;

- (void)cleanup;

- (void)detectFaces;

- (UIImage *)thumbnailByIndex:(NSUInteger)index;

- (void)selectFaceByIndex:(NSUInteger)index;

- (void)exchangeSelectedFacesByIndex1:(NSUInteger)index1 withIndex2:(NSUInteger)index2;

- (void)saveStitchedImage;

@end
