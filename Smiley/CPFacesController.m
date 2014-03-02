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
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
        NSDictionary *options = @{CIDetectorSmile: @(YES), CIDetectorEyeBlink: @(YES)};
        
        //__block NSMutableArray *tempFaces = [NSMutableArray array];
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    CGImageRef image = result.defaultRepresentation.fullResolutionImage;
                    CGFloat height = CGImageGetHeight(image);
                    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image] options:options];
                    for (CIFeature *feature in features) {
                        CPFace *face = [[CPFace alloc] init];
                        face.asset = result;
                        
                        // reverse rectangle in y, because core image coordinate system is different
                        CGRect bounds = CGRectMake(feature.bounds.origin.x, height - feature.bounds.origin.y - feature.bounds.size.height, feature.bounds.size.width, feature.bounds.size.height);
                        face.bounds = CGRectInset(bounds, -bounds.size.width / 3, -bounds.size.height / 3);
                        face.image = CGImageCreateWithImageInRect(image, face.bounds);
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
    });
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

@end
