//
//  CPMockupAssetsLibrary.h
//  Smiley
//
//  Created by wangyw on 3/20/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPAssetsLibraryProtocol.h"

@interface CPMockupEmptyAssetsLibrary : NSObject <CPAssetsLibraryProtocol>

- (NSUInteger)count;

- (NSString *)assetURLOfIndex:(NSUInteger)index;

- (NSMutableArray *)boundsOfFacesOfIndex:(NSUInteger)index;

- (NSMutableArray *)thumbnailsOfIndex:(NSUInteger)index;

@end

@interface CPMockupAssetsLibrary : CPMockupEmptyAssetsLibrary

- (id)initWithNumberOfAssets:(NSUInteger)numberOfAssets numbersOfFaces:(NSArray *)numbersOfFaces;

@end
