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

static NSString *g_albumNameOfSmileyPhotos = @"Smiley Photos";

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeContextChangesForNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
        
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
        
        [self enumerateSmileyPhotos];
    }
}

- (void)stopScan {
    if (self.isScanning) {
        [self.queue cancelAllOperations];
        [self.queue waitUntilAllOperationsAreFinished];

        [self removeExpiredPhotos];
    }
}

- (UIImage *)thumbnailOfFace:(CPFace *)face {
    NSString *filePath = [[CPUtility thumbnailPath] stringByAppendingPathComponent:face.thumbnail];
    return [UIImage imageWithContentsOfFile:filePath];
}

- (void)assertForURL:(NSURL *)assetURL resultBlock:(ALAssetsLibraryAssetForURLResultBlock)resultBlock {
    [self.assetsLibrary assetForURL:assetURL resultBlock:resultBlock failureBlock:nil];
}

- (UIImage *)imageOfStitchedFaces:(NSMutableArray *)stitchedFaces {
    CGFloat rowsFloat = sqrtf(stitchedFaces.count);
    // TODO: layout algorithm
    NSUInteger rows = (NSUInteger)rowsFloat == rowsFloat ? rowsFloat : rowsFloat + 1;
    // TODO: width of each face
    CGFloat widthOfEachFace = 512.0;
    CGFloat width = widthOfEachFace * rows;
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    
    int x = 0.0;
    int y = 0.0;
    for (CPFaceEditInformation *faceEditInformation in stitchedFaces) {
        CGRect faceBounds = faceEditInformation.userBounds;
        CGImageRef faceImage = CGImageCreateWithImageInRect(faceEditInformation.asset.defaultRepresentation.fullScreenImage, faceBounds);
        UIImage *image = [UIImage imageWithCGImage:faceImage scale:faceBounds.size.width / widthOfEachFace orientation:UIImageOrientationUp];
        CGImageRelease(faceImage);
        [image drawAtPoint:CGPointMake(x * widthOfEachFace, y * widthOfEachFace)];
        x++;
        if (x >= rows) {
            x = 0;
            y++;
        }
    }
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (void)saveStitchedImage:(UIImage *)image {
    [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [self.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                __block BOOL foundGroup = NO;
                [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                    if (group) {
                        if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:g_albumNameOfSmileyPhotos]) {
                            [group addAsset:asset];
                            foundGroup = YES;
                        }
                    } else {
                        if (!foundGroup) {
                            [self.assetsLibrary addAssetsGroupAlbumWithName:g_albumNameOfSmileyPhotos resultBlock:^(ALAssetsGroup *group) {
                                [group addAsset:asset];
                            } failureBlock:nil];
                        }
                    }
                } failureBlock:nil];
            } failureBlock:nil];
        }
    }];
}

- (void)enumerateSmileyPhotos {
    NSMutableArray *smileyPhotos = [[NSMutableArray alloc] init];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:g_albumNameOfSmileyPhotos]) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        NSURL *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
                        [smileyPhotos addObject:assetURL.absoluteString];
                    }
                }];
                // find Smiley Photo album, finish enumration
                *stop = YES;
            }
        } else {
            // finish enumerate Smiley Photos album
            [self enumerateAllPhotosExceptSmileyPhotos:smileyPhotos];
        }
    } failureBlock:nil];
}

- (void)enumerateAllPhotosExceptSmileyPhotos:(NSMutableArray *)smileyPhotos {
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos | ALAssetsGroupLibrary usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSURL *assetURL = [result valueForProperty:ALAssetPropertyAssetURL];
                    if (![smileyPhotos containsObject:assetURL.absoluteString]) {
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
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Smiley" withExtension:@"momd"];
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];

        NSURL *applicationDocumentsDirectoryURL = [NSURL fileURLWithPath:[CPUtility applicationDocumentsPath]];
        NSURL *storeURL = [applicationDocumentsDirectoryURL URLByAppendingPathComponent:@"Smiley.sqlite"];
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
