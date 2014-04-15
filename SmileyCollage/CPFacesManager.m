//
//  CPFacesManager.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPFacesManager.h"

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

+ (NSString *)cameraOwnerName {
    return @"SmileyCollage @ Codingpotato";
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContextChangesForNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAssetsLibraryChangeForNotification:) name:ALAssetsLibraryChangedNotification object:nil];
        
        self.isScanning = NO;
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
    [exifDictionary setObject:[CPFacesManager cameraOwnerName] forKey:(NSString *)kCGImagePropertyExifCameraOwnerName];
    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    [metadata setObject:exifDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage metadata:metadata completionBlock:nil];
}

- (void)scanAllPhotos {
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    self.numberOfTotalPhotos++;
                    CPFaceDetectOperation *faceDetectOperation = [[CPFaceDetectOperation alloc] initWithAsset:result persistentStoreCoordinator:self.persistentStoreCoordinator];
                    faceDetectOperation.completionBlock = ^() {
                        // inform ui thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.numberOfScannedPhotos++;
                        });
                    };
                    [self.queue addOperation:faceDetectOperation];
                }
            }];
        } else {
            // finish scanning all photos
            [self removeExpiredPhotos];
        }
    } failureBlock:nil];
}

- (void)removeExpiredPhotos {
    CPCleanupOperation *cleanupOperation = [[CPCleanupOperation alloc] initWithScanTime:self.scanStartTime persistentStoreCoordinator:self.persistentStoreCoordinator];
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
        NSFetchRequest * fetechRequest = [CPFace fetchRequestForFacesInManagedObjectContext:self.managedObjectContext];
        _facesController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetechRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"CPFaceCache"];
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
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        _managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (!_persistentStoreCoordinator) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SmileyCollage" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

        NSString *applicationDocumentsPath = [CPUtility applicationDocumentsPath];
        NSURL *applicationDocumentsDirectoryURL = [NSURL fileURLWithPath:applicationDocumentsPath];
        NSURL *storeURL = [applicationDocumentsDirectoryURL URLByAppendingPathComponent:@"SmileyCollage.sqlite"];
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES, NSInferMappingModelAutomaticallyOption: @YES};
        NSError *error = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            // remove SQLite and thumbnail files
            NSFileManager *fileManager = [NSFileManager defaultManager];
            for (NSString *filename in [fileManager contentsOfDirectoryAtPath:applicationDocumentsPath error:nil]) {
                [fileManager removeItemAtPath:[applicationDocumentsPath stringByAppendingPathComponent:filename] error:&error];
            }
            
            // re-create the persistent store
            [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error];
        }
    }
    return _persistentStoreCoordinator;
}

@end
