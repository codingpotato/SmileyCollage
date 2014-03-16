//
//  CPFacesManager.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFacesManager.h"

#import "CPConfig.h"
#import "CPFace.h"
#import "CPPhoto.h"

@interface CPFacesManager ()

@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (strong, nonatomic) NSNumber *sequenceNumber;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CPFacesManager

static NSString *g_albumNameOfSmileyPhotos = @"Smiley Photos";
static NSString *g_thumbnailDirectory = @"thumbnail";

static CPFacesManager *g_facesController = nil;

+ (CPFacesManager *)defaultManager {
    if (!g_facesController) {
        g_facesController = [[CPFacesManager alloc] init];
    }
    return g_facesController;
}

- (id)init {
    self = [super init];
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *thumbnailPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:g_thumbnailDirectory];
        if (![fileManager fileExistsAtPath:thumbnailPath]) {
            [fileManager createDirectoryAtPath:thumbnailPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)cleanup {
    [self.queue cancelAllOperations];
    [self.queue waitUntilAllOperationsAreFinished];

    [self removeExpiredPhotos];
    [self saveContext];
}

- (void)detectFaces {
    NSMutableArray *smileyPhotos = [[NSMutableArray alloc] init];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:g_albumNameOfSmileyPhotos]) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        NSURL *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
                        [smileyPhotos addObject:assetURL.absoluteString];
                    } else {
                        *stop = YES;
                    }
                }];
            }
        } else {
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            NSURL *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
                            if (![smileyPhotos containsObject:assetURL.absoluteString]) {
                                [self detectFacesFromAsset:result];
                            }
                        }
                    }];
                } else {
                    [self.queue addOperationWithBlock:^{
                        @autoreleasepool {
                            [self removeExpiredPhotos];
                            [self saveContext];
                        }
                    }];
                }
            } failureBlock:nil];
        }
    } failureBlock:nil];
}

- (void)detectFacesFromAsset:(ALAsset *)asset {
    [self.queue addOperationWithBlock:^{
        @autoreleasepool {
            CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
            NSDictionary *options = @{CIDetectorSmile: @(YES), CIDetectorEyeBlink: @(YES)};
            
            NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
            CPPhoto *photo = [CPPhoto photoOfURL:assetURL.absoluteString inManagedObjectContext:self.managedObjectContext];
            if (photo) {
                photo.sequenceNumber = self.sequenceNumber;
            } else {
                photo = [CPPhoto createPhotoInManagedObjectContext:self.managedObjectContext];
                photo.url = assetURL.absoluteString;
                photo.sequenceNumber = self.sequenceNumber;
                CGImageRef image = asset.defaultRepresentation.fullScreenImage;
                CGFloat width = CGImageGetWidth(image);
                CGFloat height = CGImageGetHeight(image);
                NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image] options:options];
                for (CIFeature *feature in features) {
                    CPFace *face = [CPFace createFaceInManagedObjectContext:self.managedObjectContext];
                    // reverse rectangle in y, because coordinate system of core image is different
                    CGRect bounds = CGRectMake(feature.bounds.origin.x, height - feature.bounds.origin.y - feature.bounds.size.height, feature.bounds.size.width, feature.bounds.size.height);
                    CGFloat enlargeSize = bounds.size.width / 3;
                    enlargeSize = MIN(enlargeSize, bounds.origin.x);
                    enlargeSize = MIN(enlargeSize, bounds.origin.y);
                    enlargeSize = MIN(enlargeSize, width - bounds.origin.x - bounds.size.width);
                    enlargeSize = MIN(enlargeSize, height - bounds.origin.y - bounds.size.height);
                    bounds = CGRectInset(bounds, -enlargeSize, -enlargeSize);
                    face.x = [NSNumber numberWithFloat:bounds.origin.x];
                    face.y = [NSNumber numberWithFloat:bounds.origin.y];
                    face.width = [NSNumber numberWithFloat:bounds.size.width];
                    face.height = [NSNumber numberWithFloat:bounds.size.height];
                    face.photo = photo;
                    [photo addFacesObject:face];
                    
                    CFUUIDRef uuid = CFUUIDCreate(NULL);
                    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
                    face.thumbnail = [NSString stringWithFormat:@"%@.jpg", uuidStr];
                    CFRelease(uuidStr);
                    CFRelease(uuid);
                    NSString *filePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:g_thumbnailDirectory] stringByAppendingPathComponent:face.thumbnail];
                    [self writeThumbnailToPath:filePath fromImage:image bounds:bounds];
                }
            }
        }
    }];
}

- (void)removeExpiredPhotos {
    NSArray *expiredPhotos = [CPPhoto expiredPhotosWithSequenceNumber:self.sequenceNumber fromManagedObjectContext:self.managedObjectContext];
    for (CPPhoto *photo in expiredPhotos) {
        for (CPFace *face in photo.faces) {
            NSString *filePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:g_thumbnailDirectory] stringByAppendingPathComponent:face.thumbnail];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [self.managedObjectContext deleteObject:photo];
    }
}

- (UIImage *)thumbnailByIndex:(NSUInteger)index {
    CPFace *face = [self.facesController.fetchedObjects objectAtIndex:index];
    NSString *filePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:g_thumbnailDirectory] stringByAppendingPathComponent:face.thumbnail];
    return [UIImage imageWithContentsOfFile:filePath];
}

- (void)writeThumbnailToPath:(NSString *)filePath fromImage:(CGImageRef)image bounds:(CGRect)bounds {
    CGImageRef faceImage = CGImageCreateWithImageInRect(image, bounds);
    // TODO: scale the image to 100.0
    CGFloat width = MIN(bounds.size.width, 100.0);
    UIImage *thumbnail = [UIImage imageWithCGImage:faceImage scale:width orientation:UIImageOrientationUp];
    CGImageRelease(faceImage);
    NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
    [imageData writeToFile:filePath atomically:YES];
}

- (void)selectFaceByIndex:(NSUInteger)index {
    /*if (index < self.faces.count) {
        CPFace * face = [self.faces objectAtIndex:index];
        face.isSelected = !face.isSelected;
        if (face.isSelected) {
            [self.selectedFaces addObject:face];
        } else {
            [self.selectedFaces removeObject:face];
        }
    }*/
}

- (void)exchangeSelectedFacesByIndex1:(NSUInteger)index1 withIndex2:(NSUInteger)index2 {
    /*NSObject *object1 = [self.selectedFaces objectAtIndex:index1];
    NSObject *object2 = [self.selectedFaces objectAtIndex:index2];
    [self.selectedFaces setObject:object1 atIndexedSubscript:index2];
    [self.selectedFaces setObject:object2 atIndexedSubscript:index1];*/
}

- (void)saveStitchedImage {
    /*[self.assetsLibrary writeImageToSavedPhotosAlbum:self.imageByStitchSelectedFaces.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [self.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                __block BOOL foundGroup = NO;
                [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    if (group) {
                        if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:g_albumNameOfSmileyImage]) {
                            [group addAsset:asset];
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
    }];*/
}

- (UIImage *)imageByStitchSelectedFaces {
    /*CGFloat rowsFloat = sqrtf([CPFacesController defaultController].selectedFaces.count);
    NSUInteger rows = (NSUInteger)rowsFloat == rowsFloat ? rowsFloat : rowsFloat + 1;
    CGFloat widthOfEachFace = 512.0;
    CGFloat width = widthOfEachFace * rows;
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    
    int x = 0.0;
    int y = 0.0;
    for (CPFace *face in self.selectedFaces) {
        CGRect faceBounds = CGRectEqualToRect(face.userBounds, CGRectZero) ? face.bounds : face.userBounds;
        CGImageRef faceImage = CGImageCreateWithImageInRect(face.asset.defaultRepresentation.fullScreenImage, faceBounds);
        UIImage *image = [UIImage imageWithCGImage:faceImage scale:faceBounds.size.width / widthOfEachFace orientation:UIImageOrientationUp];
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
    return result;*/
    return  nil;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             TODO: MAY ABORT! Handle the error appropriately when saving context.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - lazy init

- (NSFetchedResultsController *)facesController {
    if (!_facesController) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:NSStringFromClass([CPFace class]) inManagedObjectContext:self.managedObjectContext];
        request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"photo.url" ascending:YES], nil];
        _facesController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"CPFaceCache"];
        [_facesController performFetch:nil];
    }
    return _facesController;
}

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

- (NSNumber *)sequenceNumber {
    if (!_sequenceNumber) {
        CPConfig *config = [CPConfig configInManagedObjectContext:self.managedObjectContext];
        config.sequenceNumber = [NSNumber numberWithInteger:config.sequenceNumber.integerValue + 1];
        _sequenceNumber = config.sequenceNumber;
    }
    return _sequenceNumber;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (!_managedObjectContext) {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        if (coordinator) {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (!_managedObjectModel) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Smiley" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *applicationDocumentsDirectoryURL = [NSURL fileURLWithPath:self.applicationDocumentsDirectory];
        NSURL *storeURL = [applicationDocumentsDirectoryURL URLByAppendingPathComponent:@"Smiley.sqlite"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            /*
             TODO: MAY ABORT! Handle the error appropriately when initializing persistent store coordinator.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             
             Typical reasons for an error here include:
             * The persistent store is not accessible;
             * The schema for the persistent store is incompatible with current managed object model.
             Check the error message to determine what the actual problem was.
             
             
             If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
             
             If you encounter schema incompatibility errors during development, you can reduce their frequency by:
             * Simply deleting the existing store:
             [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
             
             * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
             @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
             
             Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
             
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    return _persistentStoreCoordinator;
}

@end
