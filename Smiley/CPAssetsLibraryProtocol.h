//
//  CPAssetsLibraryProtocol.h
//  Smiley
//
//  Created by wangyw on 3/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

typedef BOOL (^skipAssetBlock)(NSString *assetURL);
typedef void (^resultBlock)(NSString *assetURL, NSMutableArray *boundsOfFaces);
typedef void (^completionBlock)();

@protocol CPAssetsLibraryProtocol <NSObject>

- (void)detectFacesBySkipAssetBlock:(skipAssetBlock)skipAssetBlock resultBlock:(resultBlock)resultBlock completionBlock:(completionBlock)completionBlock;

@end
