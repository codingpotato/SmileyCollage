//
//  CPMockupAssetsLibrary.m
//  Smiley
//
//  Created by wangyw on 3/20/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPMockupAssetsLibrary.h"

@implementation CPMockupEmptyAssetsLibrary

- (void)scanFacesBySkipAssetBlock:(skipAssetBlock)skipAssetBlock resultBlock:(resultBlock)resultBlock completionBlock:(completionBlock)completionBlock {
    for (NSUInteger i = 0; i < self.count; ++i) {
        NSString *assetURL = [self assetURLOfIndex:i];
        if (skipAssetBlock(assetURL)) {
            NSMutableArray *boundsOfFaces = [self boundsOfFacesOfIndex:i];
            NSMutableArray *thumbnails = [self thumbnailsOfIndex:i];
            
            NSAssert(boundsOfFaces.count == thumbnails.count, @"");
            
            for (NSUInteger j = 0; j < boundsOfFaces.count; ++j) {
                resultBlock(assetURL, [boundsOfFaces objectAtIndex:j], [thumbnails objectAtIndex:j]);
            }
        }
    }
    completionBlock();
}

- (NSUInteger)count {
    return 0;
}

- (NSString *)assetURLOfIndex:(NSUInteger)index {
    return nil;
}

- (NSMutableArray *)boundsOfFacesOfIndex:(NSUInteger)index {
    return nil;
}

- (NSString *)thumbnailsOfIndex:(NSUInteger)index {
    return nil;
}

@end

@interface CPMockupAssetsLibrary ()

@property (nonatomic) NSUInteger numberOfAssets;
@property (strong, nonatomic) NSArray *numbersOfFaces;

@end

@implementation CPMockupAssetsLibrary

- (id)initWithNumberOfAssets:(NSUInteger)numberOfAssets numbersOfFaces:(NSArray *)numbersOfFaces {
    self = [super init];
    if (self) {
        self.numberOfAssets = numberOfAssets;
        self.numbersOfFaces = numbersOfFaces;
    }
    return self;
}

- (NSUInteger)count {
    return self.numberOfAssets;
}

- (NSString *)assetURLOfIndex:(NSUInteger)index {
    return [[NSString alloc] initWithFormat:@"TestAsset%d", index];
}

- (NSMutableArray *)boundsOfFacesOfIndex:(NSUInteger)index {
    NSUInteger numberOfFaces = ((NSNumber *)[self.numbersOfFaces objectAtIndex:index]).intValue;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:numberOfFaces];
    for (NSUInteger i = 0; i < numberOfFaces; ++i) {
        [result addObject:[NSValue valueWithCGRect:CGRectMake(i, i, 10.0, 10.0)]];
    }
    return result;
}

- (NSMutableArray *)thumbnailsOfIndex:(NSUInteger)index {
    NSUInteger numberOfFaces = ((NSNumber *)[self.numbersOfFaces objectAtIndex:index]).intValue;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:numberOfFaces];
    for (NSUInteger i = 0; i < numberOfFaces; ++i) {
        [result addObject:[[UIImage alloc] init]];
    }
    return result;
}

@end
