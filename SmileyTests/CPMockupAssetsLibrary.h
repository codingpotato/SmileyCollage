//
//  CPMockupAssetsLibrary.h
//  Smiley
//
//  Created by wangyw on 3/20/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPAssetsLibraryProtocol.h"

@protocol CPAssetsProviderProtocol <NSObject>

- (NSUInteger)count;

- (NSString *)assetURLOfIndex:(NSUInteger)index;

- (NSMutableArray *)boundsOfFacesOfIndex:(NSUInteger)index;

- (NSMutableArray *)thumbnailsOfIndex:(NSUInteger)index;

@end

@interface CPEmptyAssetsProvider : NSObject <CPAssetsProviderProtocol>

@end

@interface CPAssetsProvider : NSObject <CPAssetsProviderProtocol>

- (id)initWithAssetURLs:(NSArray *)assetURLs numbersOfFaces:(NSArray *)numbersOfFaces;

@end

@interface CPMockupAssetsLibrary : NSObject <CPAssetsLibraryProtocol>

@property (strong, nonatomic) id<CPAssetsProviderProtocol> assetsProvider;

@end
