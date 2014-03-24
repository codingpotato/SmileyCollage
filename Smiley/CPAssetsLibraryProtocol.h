//
//  CPAssetsLibraryProtocol.h
//  Smiley
//
//  Created by wangyw on 3/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

typedef BOOL (^skipAssetBlock)(NSString *assetURL);

typedef void (^scanResultBlock)(NSString *assetURL, NSMutableArray *boundsOfFaces, NSMutableArray *thumbnails);

typedef void (^scanCompletionBlock)();

typedef void (^assetResultBlock)(ALAsset *asset);


@protocol CPAssetsLibraryProtocol <NSObject>

- (void)scanFacesBySkipAssetBlock:(skipAssetBlock)skipAssetBlock resultBlock:(scanResultBlock)resultBlock completionBlock:(scanCompletionBlock)completionBlock;

- (NSUInteger)numberOfTotalPhotos;

- (void)stopScan;

- (void)assetForURL:(NSURL *)url resultBlock:(assetResultBlock)resultBlock;

- (void)saveStitchedImage:(UIImage *)image;

@end
