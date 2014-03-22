//
//  CPFacesManager.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFacesManager.h"

#import "CPAssetsLibraryProtocol.h"

#import "CPConfig.h"
#import "CPFace.h"
#import "CPPhoto.h"

@interface CPFacesManager ()

@property (strong, nonatomic) id<CPAssetsLibraryProtocol> assetsLibrary;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CPFacesManager

static NSString *g_thumbnailDirectoryName = @"thumbnail";

- (id)initWithAssetsLibrary:(id<CPAssetsLibraryProtocol>)assetsLibrary {
    self = [super init];
    if (self) {
        self.isScanning = NO;
        self.assetsLibrary = assetsLibrary;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *thumbnailPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:g_thumbnailDirectoryName];
        if (![fileManager fileExistsAtPath:thumbnailPath]) {
            [fileManager createDirectoryAtPath:thumbnailPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)scanFaces {
    if (!self.isScanning) {
        self.isScanning = YES;
        [self.config increaseCurrentScanId];
        
        [self.assetsLibrary scanFacesBySkipAssetBlock:^BOOL(NSString *assetURL) {
            CPPhoto *photo = [CPPhoto photoOfURL:assetURL inManagedObjectContext:self.managedObjectContext];
            if (photo) {
                photo.scanId = self.config.currentScanId;
                return YES;
            } else {
                return NO;
            }
        } resultBlock:^(NSString *assetURL, NSMutableArray *boundsOfFaces, NSMutableArray *thumbnails) {
            NSAssert(boundsOfFaces.count == thumbnails.count, @"");
            
            CPPhoto *photo = [CPPhoto createPhotoInManagedObjectContext:self.managedObjectContext];
            photo.url = assetURL;
            photo.scanId = self.config.currentScanId;
            
            for (NSUInteger index = 0; index < boundsOfFaces.count; ++index) {
                CPFace *face = [CPFace createFaceInManagedObjectContext:self.managedObjectContext];
                face.id = self.config.nextFaceId;
                [self.config increaseNextFaceId];
                CGRect bounds = ((NSValue *)[boundsOfFaces objectAtIndex:index]).CGRectValue;
                face.x = [NSNumber numberWithFloat:bounds.origin.x];
                face.y = [NSNumber numberWithFloat:bounds.origin.y];
                face.width = [NSNumber numberWithFloat:bounds.size.width];
                face.height = [NSNumber numberWithFloat:bounds.size.height];
                face.photo = photo;
                [photo addFacesObject:face];
                
                face.thumbnail = [NSString stringWithFormat:@"face_%d.jpg", face.id.integerValue];
                NSString *filePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:g_thumbnailDirectoryName] stringByAppendingPathComponent:face.thumbnail];
                UIImage *image = [thumbnails objectAtIndex:index];
                [UIImageJPEGRepresentation(image, 0.5) writeToFile:filePath atomically:YES];
            }
        } completionBlock:^{
            [self removeExpiredPhotos];
            [self saveContext];
            self.isScanning = NO;
        }];
    }
}

- (void)stopScan {
    [self.assetsLibrary stopScan];
    [self removeExpiredPhotos];
    [self saveContext];
}

- (NSArray *)photos {
    return [CPPhoto photosInManagedObjectContext:self.managedObjectContext];
}

- (NSArray *)faces {
    return [CPFace facesInManagedObjectContext:self.managedObjectContext];
}

- (UIImage *)thumbnailOfFace:(CPFace *)face {
    NSString *filePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:g_thumbnailDirectoryName] stringByAppendingPathComponent:face.thumbnail];
    return [UIImage imageWithContentsOfFile:filePath];
}

- (void)assertForURL:(NSURL *)url resultBlock:(assetResultBlock)resultBlock {
    [self.assetsLibrary assertForURL:url resultBlock:resultBlock];
}

/*- (UIImage *)imageByStitchSelectedFaces {
    CGFloat rowsFloat = sqrtf([CPFacesController defaultController].selectedFaces.count);
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
    return result;
}

- (void)saveStitchedImage {
    [self.assetsLibrary writeImageToSavedPhotosAlbum:self.imageByStitchSelectedFaces.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
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
    }];
}*/

- (void)removeExpiredPhotos {
    NSArray *expiredPhotos = [CPPhoto expiredPhotosWithScanId:self.config.currentScanId fromManagedObjectContext:self.managedObjectContext];
    for (CPPhoto *photo in expiredPhotos) {
        for (CPFace *face in photo.faces) {
            NSString *filePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:g_thumbnailDirectoryName] stringByAppendingPathComponent:face.thumbnail];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        [self.managedObjectContext deleteObject:photo];
    }
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

- (CPConfig *)config {
    if (!_config) {
        _config = [CPConfig configInManagedObjectContext:self.managedObjectContext];
    }
    return _config;
}

- (NSFetchedResultsController *)facesController {
    if (!_facesController) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:NSStringFromClass([CPFace class]) inManagedObjectContext:self.managedObjectContext];
        request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES], nil];
        _facesController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"CPFaceCache"];
        [_facesController performFetch:nil];
    }
    return _facesController;
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
