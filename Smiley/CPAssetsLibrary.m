//
//  CPAssetsLibrary.m
//  Smiley
//
//  Created by wangyw on 3/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPAssetsLibrary.h"

@interface CPAssetsLibrary ()

@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@end

@implementation CPAssetsLibrary

static NSString *g_albumNameOfSmileyPhotos = @"Smiley Photos";

- (void)detectFacesBySkipAssetBlock:(skipAssetBlock)skipAssetBlock resultBlock:(resultBlock)resultBlock completionBlock:(completionBlock)completionBlock {
    [self enumerateSmileyPhotosBySkipAssetBlock:skipAssetBlock resultBlock:resultBlock completionBlock:completionBlock];
}

- (void)enumerateSmileyPhotosBySkipAssetBlock:(skipAssetBlock)skipAssetBlock resultBlock:(resultBlock)resultBlock completionBlock:(completionBlock)completionBlock {
    NSMutableArray *smileyPhotos = [[NSMutableArray alloc] init];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:g_albumNameOfSmileyPhotos]) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        NSURL *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
                        [smileyPhotos addObject:assetURL.absoluteString];
                    } else {
                        // finish Smiley Photos album
                        *stop = YES;
                    }
                }];
            }
        } else {
            // finish enumerate Smiley Photos album
            [self enumerateAllPhotosExceptSmileyPhotos:smileyPhotos skipAssetBlock:skipAssetBlock resultBlock:resultBlock completionBlock:completionBlock];
        }
    } failureBlock:nil];
}

- (void)enumerateAllPhotosExceptSmileyPhotos:(NSMutableArray *)smileyPhotos skipAssetBlock:(skipAssetBlock)skipAssetBlock resultBlock:(resultBlock)resultBlock completionBlock:(completionBlock)completionBlock {
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSURL *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
                    if (![smileyPhotos containsObject:assetURL.absoluteString] && !skipAssetBlock(assetURL.absoluteString)) {
                        [self detectFacesFromAsset:result resultBlock:resultBlock];
                    }
                }
            }];
        } else {
            // finish enumerate all photos
            [self.queue addOperationWithBlock:^{
                @autoreleasepool {
                    completionBlock();
                }
            }];
        }
    } failureBlock:nil];
}

- (void)detectFacesFromAsset:(ALAsset *)asset resultBlock:(resultBlock)resultBlock {
    [self.queue addOperationWithBlock:^{
        @autoreleasepool {
            CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
            NSDictionary *options = @{CIDetectorSmile: @(YES), CIDetectorEyeBlink: @(YES)};
            
            CGImageRef image = asset.defaultRepresentation.fullScreenImage;
            CGFloat width = CGImageGetWidth(image);
            CGFloat height = CGImageGetHeight(image);
            NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image] options:options];
            NSMutableArray *boundsOfFaces = [[NSMutableArray alloc] initWithCapacity:features.count];
            for (CIFeature *feature in features) {
                // reverse rectangle in y, because coordinate system of core image is different
                CGRect bounds = CGRectMake(feature.bounds.origin.x, height - feature.bounds.origin.y - feature.bounds.size.height, feature.bounds.size.width, feature.bounds.size.height);
                // enlarge maximum 1/3 bounds
                CGFloat enlargeSize = bounds.size.width / 3;
                enlargeSize = MIN(enlargeSize, bounds.origin.x);
                enlargeSize = MIN(enlargeSize, bounds.origin.y);
                enlargeSize = MIN(enlargeSize, width - bounds.origin.x - bounds.size.width);
                enlargeSize = MIN(enlargeSize, height - bounds.origin.y - bounds.size.height);
                bounds = CGRectInset(bounds, -enlargeSize, -enlargeSize);
                [boundsOfFaces addObject:[NSValue valueWithCGRect:bounds]];
            }
            NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
            resultBlock(assetURL.absoluteString, boundsOfFaces);
        }
    }];
}

#pragma mark - lazy init

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

@end
