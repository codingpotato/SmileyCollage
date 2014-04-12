//
//  CPFaceDetectOperation.m
//  Smiley
//
//  Created by wangyw on 3/25/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFaceDetectOperation.h"

#import "CPConfig.h"
#import "CPUtility.h"

#import "CPFace.h"
#import "CPFacesManager.h"
#import "CPPhoto.h"

@interface CPFaceDetectOperation ()

@property (strong, nonatomic) ALAsset *asset;

@end

@implementation CPFaceDetectOperation

- (id)initWithAsset:(ALAsset *)asset persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    self = [super initWithPersistentStoreCoordinator:persistentStoreCoordinator];
    if (self) {
        self.asset = asset;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        NSAssert(self.asset, @"");
        
        NSURL *assetURL = [self.asset valueForProperty:ALAssetPropertyAssetURL];
        CPPhoto *photo = [CPPhoto photoOfAssetURL:assetURL.absoluteString inManagedObjectContext:self.managedObjectContext];
        if (photo) {
            photo.timestamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
        } else {
            NSMutableDictionary *exifDictionary = [self.asset.defaultRepresentation.metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
            NSString *cameraOwnerName = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifCameraOwnerName];
            if (![cameraOwnerName isEqualToString:[CPFacesManager cameraOwnerName]]) {
                CPPhoto *photo = [self newPhotoByAssetURL:assetURL];
                
                CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
                NSDictionary *options = @{CIDetectorSmile: @(YES), CIDetectorEyeBlink: @(YES)};
                
                CGImageRef image = self.asset.defaultRepresentation.fullScreenImage;
                CGFloat width = CGImageGetWidth(image);
                CGFloat height = CGImageGetHeight(image);
                NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image] options:options];
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
                    
                    CPFace *face = [self newFaceWithPhoto:photo bounds:bounds];
                    [self writeThumbnailOfName:face.thumbnail fromImage:image bounds:bounds];
                }
            }
        }
        
        [self save];
    }
}

- (CPPhoto *)newPhotoByAssetURL:(NSURL *)assetURL {
    CPPhoto *photo = [CPPhoto createPhotoInManagedObjectContext:self.managedObjectContext];
    photo.timestamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
    photo.url = assetURL.absoluteString;
    
    return photo;
}

- (CPFace *)newFaceWithPhoto:(CPPhoto *)photo bounds:(CGRect)bounds {
    CPFace *face = [CPFace createFaceInManagedObjectContext:self.managedObjectContext];
    face.timestamp = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
    face.x = [NSNumber numberWithFloat:bounds.origin.x];
    face.y = [NSNumber numberWithFloat:bounds.origin.y];
    face.width = [NSNumber numberWithFloat:bounds.size.width];
    face.height = [NSNumber numberWithFloat:bounds.size.height];
    face.photo = photo;
    face.thumbnail = [[[NSUUID alloc] init].UUIDString stringByAppendingPathExtension:@"jpg"];
    [photo addFacesObject:face];
    
    return face;
}

- (void)writeThumbnailOfName:(NSString *)name fromImage:(CGImageRef)image bounds:(CGRect)bounds {
    CGImageRef faceImage = CGImageCreateWithImageInRect(image, bounds);
    CGFloat width = MIN(bounds.size.width, [CPConfig thumbnailSize]);
    UIImage *thumbnail = [UIImage imageWithCGImage:faceImage scale:width orientation:UIImageOrientationUp];
    CGImageRelease(faceImage);
    NSString *filePath = [[CPUtility thumbnailPath] stringByAppendingPathComponent:name];
    
    static const float compressionQuality = 0.5;
    [UIImageJPEGRepresentation(thumbnail, compressionQuality) writeToFile:filePath atomically:YES];
}

@end
