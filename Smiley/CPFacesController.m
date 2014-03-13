//
//  CPFacesController.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFacesController.h"

#import "CPFace.h"

@interface CPFacesController ()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@end

@implementation CPFacesController

static NSString *g_albumNameOfSmileyImage = @"Smiley Images";

static CPFacesController *g_facesController = nil;

+ (CPFacesController *)defaultController {
    if (!g_facesController) {
        g_facesController = [[CPFacesController alloc] init];
    }
    return g_facesController;
}

- (void)detectFacesWithRefreshBlock:(void (^)(void))refreshBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.faces removeAllObjects];
        NSMutableDictionary *facesCache = self.facesCache;
        
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        NSDictionary *options = @{CIDetectorSmile: @(YES), CIDetectorEyeBlink: @(YES)};
        
        // collect asset URLs in Smiley Images album, and ignore them when searching smiley faces
        NSMutableArray *smileyImages = [NSMutableArray array];
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:g_albumNameOfSmileyImage]) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            [smileyImages addObject:[result valueForProperty:ALAssetPropertyAssetURL]];
                        }
                    }];
                }
            } else {
                // finish first round enumeration, start real enumeration for faces
                [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    if (group) {
                        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                            if (result) {
                                NSString *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
                                if (![smileyImages containsObject:assetURL]) {
                                    NSMutableArray *faceBounds = [facesCache objectForKey:assetURL];
                                    if (faceBounds) {
                                        for (NSValue *boundsValue in faceBounds) {
                                            CPFace *face = [[CPFace alloc] init];
                                            face.asset = result;
                                            face.bounds = boundsValue.CGRectValue;
                                            face.userBounds = CGRectZero;
                                            [self.faces addObject:face];
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                refreshBlock();
                                            });
                                        }
                                    } else {
                                        CGImageRef image = result.defaultRepresentation.fullScreenImage;
                                        CGFloat width = CGImageGetWidth(image);
                                        CGFloat height = CGImageGetHeight(image);
                                        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image] options:options];
                                        for (CIFeature *feature in features) {
                                            CPFace *face = [[CPFace alloc] init];
                                            face.asset = result;
                                            // reverse rectangle in y, because coordinate system of core image is different
                                            CGRect bounds = CGRectMake(feature.bounds.origin.x, height - feature.bounds.origin.y - feature.bounds.size.height, feature.bounds.size.width, feature.bounds.size.height);
                                            CGFloat changedSize = bounds.size.width / 3;
                                            changedSize = MIN(changedSize, bounds.origin.x);
                                            changedSize = MIN(changedSize, bounds.origin.y);
                                            changedSize = MIN(changedSize, width - bounds.origin.x - bounds.size.width);
                                            changedSize = MIN(changedSize, height - bounds.origin.y - bounds.size.height);
                                            face.bounds = CGRectInset(bounds, -changedSize, -changedSize);
                                            face.userBounds = CGRectZero;
                                            [self.faces addObject:face];
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                refreshBlock();
                                            });
                                        }
                                    }
                                }
                            }
                        }];
                    } else {
                        [self writeFacesCache];
                    }
                } failureBlock:nil];
            }
        } failureBlock:nil];
    });
}

- (void)selectFaceByIndex:(NSUInteger)index {
    if (index < self.faces.count) {
        CPFace * face = [self.faces objectAtIndex:index];
        face.isSelected = !face.isSelected;
        if (face.isSelected) {
            [self.selectedFaces addObject:face];
        } else {
            [self.selectedFaces removeObject:face];
        }
    }
}

- (void)exchangeSelectedFacesByIndex1:(NSUInteger)index1 withIndex2:(NSUInteger)index2 {
    NSObject *object1 = [self.selectedFaces objectAtIndex:index1];
    NSObject *object2 = [self.selectedFaces objectAtIndex:index2];
    [self.selectedFaces setObject:object1 atIndexedSubscript:index2];
    [self.selectedFaces setObject:object2 atIndexedSubscript:index1];
}

- (void)saveStitchedImage {
    [self.assetsLibrary writeImageToSavedPhotosAlbum:self.imageByStitchSelectedFaces.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [self.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                __block BOOL foundGroup = NO;
                [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    if (group) {
                        if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:g_albumNameOfSmileyImage]) {                            [group addAsset:asset];
                            foundGroup = YES;
                        }
                    } else {
                        if (!foundGroup) {
                            [self.assetsLibrary addAssetsGroupAlbumWithName:g_albumNameOfSmileyImage resultBlock:^(ALAssetsGroup *group) {
                                [group addAsset:asset];
                            } failureBlock:nil];
                        }
                    }
                } failureBlock:nil];
            } failureBlock:nil];
        }
    }];
}

- (UIImage *)imageByStitchSelectedFaces {
    CGFloat rowsFloat = sqrtf([CPFacesController defaultController].selectedFaces.count);
    NSUInteger rows = (NSUInteger)rowsFloat == rowsFloat ? rowsFloat : rowsFloat + 1;
    CGFloat widthOfEachFace = 512.0;
    CGFloat width = widthOfEachFace * rows;
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    
    int x = 0.0;
    int y = 0.0;
    for (CPFace *face in self.selectedFaces) {
        CGImageRef faceImage = CGImageCreateWithImageInRect(face.asset.defaultRepresentation.fullScreenImage, face.bounds);
        UIImage *image = [UIImage imageWithCGImage:faceImage scale:face.bounds.size.width / widthOfEachFace orientation:UIImageOrientationUp];
        CGImageRelease(faceImage);
        [image drawAtPoint:CGPointMake(x * widthOfEachFace, y * widthOfEachFace)];
        x++;
        if (x >= rows) {
            x = 0;
            y++;
        }
    }
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (NSMutableDictionary *)facesCache {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.facesCachePath]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:self.facesCachePath];
    } else {
        return [[NSMutableDictionary alloc] init];
    }
}

- (void)writeFacesCache {
    NSMutableDictionary *facesCache = [[NSMutableDictionary alloc] initWithCapacity:self.faces.count];
    for (CPFace *face in self.faces) {
        NSString *assetURL = [face.asset valueForProperty:ALAssetPropertyAssetURL];
        NSMutableArray *faceBounds = [facesCache objectForKey:assetURL];
        if (faceBounds) {
            [faceBounds addObject:[NSValue valueWithCGRect:face.bounds]];
        } else {
            faceBounds = [[NSMutableArray alloc] init];
            [faceBounds addObject:[NSValue valueWithCGRect:face.bounds]];
            [facesCache setObject:faceBounds forKey:assetURL];
        }
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:facesCache];
    [data writeToFile:self.facesCachePath atomically:YES];
}

- (NSString *)facesCachePath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:@"facesCache.bin"];
}

#pragma mark - lazy init

- (NSMutableArray *)faces {
    if (!_faces) {
        _faces = [[NSMutableArray alloc] init];
    }
    return _faces;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (NSMutableArray *)selectedFaces {
    if (!_selectedFaces) {
        _selectedFaces = [NSMutableArray array];
    }
    return _selectedFaces;
}

@end
