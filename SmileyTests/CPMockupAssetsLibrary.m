//
//  CPMockupAssetsLibrary.m
//  Smiley
//
//  Created by wangyw on 3/20/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPMockupAssetsLibrary.h"

@implementation CPEmptyAssetsProvider

- (NSUInteger)count {
    return 0;
}

- (NSString *)assetURLOfIndex:(NSUInteger)index {
    return nil;
}

- (NSMutableArray *)boundsOfFacesOfIndex:(NSUInteger)index {
    return nil;
}

- (NSMutableArray *)thumbnailsOfIndex:(NSUInteger)index {
    return nil;
}

@end


@interface CPAssetsProvider ()

@property (nonatomic) NSArray *assetURLs;

@property (strong, nonatomic) NSArray *numbersOfFaces;

@end

@implementation CPAssetsProvider

- (id)initWithAssetURLs:(NSArray *)assetURLs numbersOfFaces:(NSArray *)numbersOfFaces {
    self = [super init];
    if (self) {
        NSAssert(numbersOfFaces.count == assetURLs.count, @"count of assetURLs and numbersOfFaces should be the same");
        
        self.assetURLs = assetURLs;
        self.numbersOfFaces = numbersOfFaces;
    }
    return self;
}

- (NSUInteger)count {
    return self.assetURLs.count;
}

- (NSString *)assetURLOfIndex:(NSUInteger)index {
    return [self.assetURLs objectAtIndex:index];
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
        CGSize size = CGSizeMake(100.0, 100.0);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [result addObject:image];
    }
    return result;
}

@end


@implementation CPMockupAssetsLibrary

- (void)scanFacesBySkipAssetBlock:(skipAssetBlock)skipAssetBlock resultBlock:(scanResultBlock)resultBlock completionBlock:(scanCompletionBlock)completionBlock {
    for (NSUInteger i = 0; i < [self.assetsProvider count]; ++i) {
        NSString *assetURL = [self.assetsProvider assetURLOfIndex:i];
        if (!skipAssetBlock(assetURL)) {
            resultBlock(assetURL, [self.assetsProvider boundsOfFacesOfIndex:i], [self.assetsProvider thumbnailsOfIndex:i]);
        }
    }
    completionBlock();
}

- (NSUInteger)numberOfTotalPhotos {
    return self.assetsProvider.count;
}

- (void)stopScan {
}

- (void)assetForURL:(NSURL *)url resultBlock:(assetResultBlock)resultBlock {
}

- (void)saveStitchedImage:(UIImage *)image {    
}

@end
