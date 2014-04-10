//
//  CPFacesManager.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFacesManager.h"

#import <ImageIO/ImageIO.h>

#import "CPUtility.h"

#import "CPCleanupOperation.h"
#import "CPFaceDetectOperation.h"

#import "CPFace.h"
#import "CPFaceEditInformation.h"
#import "CPPhoto.h"

@interface CPFacesManager ()

@property (strong, nonatomic) NSOperationQueue *queue;

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) NSTimeInterval scanStartTime;

@end

@implementation CPFacesManager

static NSString *g_cameraOwnerName = @"SmileyCollage @ Codingpotato";

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContextChangesForNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAssetsLibraryChangeForNotification:) name:ALAssetsLibraryChangedNotification object:nil];
        
        self.isScanning = NO;

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *thumbnailPath = [CPUtility thumbnailPath];
        if (![fileManager fileExistsAtPath:thumbnailPath]) {
            [fileManager createDirectoryAtPath:thumbnailPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scanFaces {
    if (!self.isScanning) {
        self.numberOfScannedPhotos = 0;
        self.numberOfTotalPhotos = 0;
        self.isScanning = YES;
        self.scanStartTime = [NSDate timeIntervalSinceReferenceDate];
        
        [self scanAllPhotos];
    }
}

- (void)stopScan {
    if (self.isScanning) {
        [self.queue cancelAllOperations];
        [self.queue waitUntilAllOperationsAreFinished];
        self.isScanning = NO;
    }
}

- (UIImage *)thumbnailOfFace:(CPFace *)face {
    NSString *filePath = [[CPUtility thumbnailPath] stringByAppendingPathComponent:face.thumbnail];
    return [UIImage imageWithContentsOfFile:filePath];
}

- (void)assertForURL:(NSURL *)assetURL resultBlock:(ALAssetsLibraryAssetForURLResultBlock)resultBlock {
    [self.assetsLibrary assetForURL:assetURL resultBlock:resultBlock failureBlock:nil];
}

- (void)saveStitchedImage:(UIImage *)image {
    NSMutableDictionary *exifDictionary = [[NSMutableDictionary alloc] init];
    [exifDictionary setObject:g_cameraOwnerName forKey:(NSString *)kCGImagePropertyExifCameraOwnerName];
    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    [metadata setObject:exifDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage metadata:metadata completionBlock:nil];
}

- (void)scanAllPhotos {
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSLog(@"%@", result.defaultRepresentation.metadata);
                    NSMutableDictionary *exifDictionary = [result.defaultRepresentation.metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                    NSString *cameraOwnerName = [exifDictionary objectForKey:(NSString *)kCGImagePropertyExifCameraOwnerName];
                    if (![cameraOwnerName isEqualToString:g_cameraOwnerName]) {
                        self.numberOfTotalPhotos++;
                        CPFaceDetectOperation *faceDetecOperation = [[CPFaceDetectOperation alloc] initWithAsset:result persistentStoreCoordinator:self.persistentStoreCoordinator];
                        faceDetecOperation.completionBlock = ^() {
                            // inform ui thread
                            dispatch_async(dispatch_get_main_queue(), ^{
                                self.numberOfScannedPhotos++;
                            });
                        };
                        [self.queue addOperation:faceDetecOperation];
                    }
                }
            }];
        } else {
            // finish enumerate all photos
            [self removeExpiredPhotos];
        }
    } failureBlock:nil];
}

- (void)removeExpiredPhotos {
    CPCleanupOperation *cleanupOperation = [[CPCleanupOperation alloc] initWithScanStartTime:self.scanStartTime persistentStoreCoordinator:self.persistentStoreCoordinator];
    cleanupOperation.completionBlock = ^() {
        self.isScanning = NO;
    };
    [self.queue addOperation:cleanupOperation];
}

- (void)mergeContextChangesForNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

- (void)handleAssetsLibraryChangeForNotification:(NSNotification *)notification {
    [self scanFaces];
}

#pragma mark - lazy init

- (NSFetchedResultsController *)facesController {
    if (!_facesController) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:NSStringFromClass([CPFace class]) inManagedObjectContext:self.managedObjectContext];
        request.sortDescriptors = [[NSArray alloc] initWithObjects:[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES], nil];
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

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SmileyCollage" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

        NSURL *applicationDocumentsDirectoryURL = [NSURL fileURLWithPath:[CPUtility applicationDocumentsPath]];
        NSURL *storeURL = [applicationDocumentsDirectoryURL URLByAppendingPathComponent:@"SmileyCollage.sqlite"];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        NSError *error = nil;
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
