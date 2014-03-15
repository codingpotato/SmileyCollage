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

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CPFacesManager

static NSString *g_albumNameOfSmileyPhotos = @"Smiley Photos";

static CPFacesManager *g_facesController = nil;
static dispatch_queue_t g_queue;

+ (CPFacesManager *)defaultManager {
    if (!g_facesController) {
        g_facesController = [[CPFacesManager alloc] init];
    }
    return g_facesController;
}

- (void)detectFaces {
    NSMutableArray *smileyPhotos = [[NSMutableArray alloc] init];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:g_albumNameOfSmileyPhotos]) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        [smileyPhotos addObject:[result valueForProperty:ALAssetPropertyAssetURL]];
                    } else {
                        *stop = YES;
                    }
                }];
            }
        } else {
            __block NSMutableArray *assets = [[NSMutableArray alloc] init];
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                        if (result) {
                            NSString *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
                            if (![smileyPhotos containsObject:assetURL]) {
                                [assets addObject:result];
                            }
                        }
                    }];
                } else {
                    [self detectFacesFromAssets:assets];
                }
            } failureBlock:nil];
        }
    } failureBlock:nil];
}

- (void)detectFacesFromAssets:(NSMutableArray *)assets {
    g_queue = dispatch_queue_create("codingpotato.SmileyQueue", NULL);
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    NSDictionary *options = @{CIDetectorSmile: @(YES), CIDetectorEyeBlink: @(YES)};
    
    CPConfig *config = [CPConfig configInManagedObjectContext:self.managedObjectContext];
    config.sequenceNumber = [NSNumber numberWithInteger:config.sequenceNumber.integerValue + 1];
    for (ALAsset *asset in assets) {
        dispatch_async(g_queue, ^{
            CPPhoto *photo = [CPPhoto photoOfURL:[asset valueForProperty:ALAssetPropertyAssetURL] inManagedObjectContext:self.managedObjectContext];
            if (photo) {
                photo.sequenceNumber = config.sequenceNumber;
            } else {
                photo = [CPPhoto createPhotoInManagedObjectContext:self.managedObjectContext];
                photo.sequenceNumber = config.sequenceNumber;
                CGImageRef image = asset.defaultRepresentation.fullScreenImage;
                CGFloat width = CGImageGetWidth(image);
                CGFloat height = CGImageGetHeight(image);
                NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image] options:options];
                NSUInteger index = 0;
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
                    face.index = [NSNumber numberWithInteger:index++];
                    face.photo = photo;
                    [photo addFacesObject:face];
                }
            }
        });
    }
    //[CPPhoto clearPhotosNotEqualSequenceNumber:config.sequenceNumber fromManagedObjectContext:self.managedObjectContext];
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

- (NSMutableDictionary *)facesCache {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.facesCachePath]) {
        return [NSKeyedUnarchiver unarchiveObjectWithFile:self.facesCachePath];
    } else {
        return [[NSMutableDictionary alloc] init];
    }
}

- (void)writeFacesCache {
    /*NSMutableDictionary *facesCache = [[NSMutableDictionary alloc] initWithCapacity:self.faces.count];
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
    [data writeToFile:self.facesCachePath atomically:YES];*/
}

- (NSString *)facesCachePath {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:@"facesCache.bin"];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
        request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"x" ascending:YES], nil];
        _facesController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"CPFaceCache"];
        [_facesController performFetch:nil];
    }
    return _facesController;
}

- (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
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
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Smiley.sqlite"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
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
