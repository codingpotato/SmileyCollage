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

static CPFacesController *g_facesController = nil;

+ (CPFacesController *)defaultController {
    if (!g_facesController) {
        g_facesController = [[CPFacesController alloc] init];
    }
    return g_facesController;
}

- (void)detectFacesWithRefreshBlock:(void (^)(void))refreshBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
        NSDictionary *options = @{CIDetectorSmile: @(YES), CIDetectorEyeBlink: @(YES)};
        
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    CGImageRef image = result.defaultRepresentation.fullScreenImage;
                    CGFloat height = CGImageGetHeight(image);
                    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image] options:options];
                    for (CIFeature *feature in features) {
                        CPFace *face = [[CPFace alloc] init];
                        face.asset = result;
                        
                        // reverse rectangle in y, because coordinate system of core image is different
                        CGRect bounds = CGRectMake(feature.bounds.origin.x, height - feature.bounds.origin.y - feature.bounds.size.height, feature.bounds.size.width, feature.bounds.size.height);
                        face.bounds = CGRectInset(bounds, -bounds.size.width / 3, -bounds.size.height / 3);
                        [self.faces addObject:face];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            refreshBlock();
                        });
                    }
                }
            }];
        } failureBlock:^(NSError *error) {
            NSLog(@"Error loading photos: %@", error);
        }];
        self.isFinished = YES;
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

- (void)saveImage:(UIImage *)image {
    [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
    }];
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
