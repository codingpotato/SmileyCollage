//
//  CPFacesManager.h
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPAssetsLibraryProtocol.h"

@class CPConfig;
@class CPFace;


@interface CPFacesManager : NSObject

@property (nonatomic) BOOL isScanning;

@property (strong, nonatomic) CPConfig *config;

@property (strong, nonatomic) NSFetchedResultsController *facesController;

- (id)initWithAssetsLibrary:(id<CPAssetsLibraryProtocol>)assetsLibrary;

- (void)scanFaces;

- (void)stopScan;

- (NSArray *)photos;

- (NSArray *)faces;

- (UIImage *)thumbnailOfFace:(CPFace *)face;

- (void)assertForURL:(NSURL *)url resultBlock:(assetResultBlock)resultBlock;

- (void)saveImageByStitchedFaces:(NSMutableArray *)stitchedFaces;

@end
