//
//  CPFacesManager.h
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@protocol CPAssetsLibraryProtocol;

@class CPFace;

@interface CPFacesManager : NSObject

@property (strong, nonatomic) NSFetchedResultsController *facesController;

@property (strong, nonatomic) NSMutableArray *selectedFaces;

- (id)initWithAssetsLibrary:(id<CPAssetsLibraryProtocol>)assetsLibrary;

- (void)scanFaces;

- (UIImage *)thumbnailByIndex:(NSUInteger)index;

- (void)selectFaceByIndex:(NSUInteger)index;

- (BOOL)isFaceSlectedByIndex:(NSUInteger)index;

- (void)assertOfSelectedFaceByIndex:(NSUInteger)index resultBlock:(void (^)(ALAsset *asset))resultBlock;

- (void)exchangeSelectedFacesByIndex1:(NSUInteger)index1 withIndex2:(NSUInteger)index2;

- (void)saveStitchedImage;

@end
