//
//  CPAssetsLibraryProtocol.h
//  Smiley
//
//  Created by wangyw on 3/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

typedef BOOL (^skipAssetBlock)(NSString *assetURL);
typedef void (^scanResultBlock)(NSString *assetURL, NSMutableArray *boundsOfFaces, NSMutableArray *thumbnails);
typedef void (^completionBlock)();

typedef void (^assetResultBlock)(ALAsset *result);

@protocol CPAssetsLibraryProtocol <NSObject>

- (void)scanFacesBySkipAssetBlock:(skipAssetBlock)skipAssetBlock resultBlock:(scanResultBlock)resultBlock completionBlock:(completionBlock)completionBlock;

- (void)stopScan;

- (void)assertForURL:(NSURL *)url resultBlock:(assetResultBlock)resultBlock;

@end
