//
//  CPCollageViewController.m
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCollageViewController.h"

#import "CPSettings.h"
#import "CPUtility.h"

#import "CPCollageCell.h"
#import "CPEditViewController.h"
#import "CPHelpViewManager.h"
#import "CPShopViewController.h"

#import "CPFaceEditInformation.h"
#import "CPFacesManager.h"
#import "CPFace.h"
#import "CPPhoto.h"

@interface CPCollageViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) CPHelpViewManager *helpViewManager;

@property (strong, nonatomic) UIBarButtonItem *actionBarButtonItem;

@property (strong, nonatomic) UIImage *watermarkImage;
@property (strong, nonatomic) UIImageView *watermarkImageView;

@property (strong, nonatomic) NSArray *numberOfColumnsInRows;
@property (strong, nonatomic) NSArray *sizeOfFaces;
@property (nonatomic) NSUInteger maxColumns;
@property (nonatomic) CGFloat widthHeightRatioOfImage;

@property (nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) UICollectionViewCell *draggedCell;
@property (strong, nonatomic) UIView *snapshotOfDraggedCell;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture;

- (IBAction)cancelFromActionSheet:(UIStoryboardSegue *)segue;

- (IBAction)saveFromActionSheet:(UIStoryboardSegue *)segue;

- (IBAction)shareFromActionSheet:(UIStoryboardSegue *)segue;

@end

@implementation CPCollageViewController

static NSString * g_editViewControllerSegueName = @"CPEditViewControllerSegue";
static NSString * g_shopViewControllerSegueName = @"CPShopViewControllerSegue";
static NSString * g_actionViewControllerSegueName = @"CPActionViewControllerSegue";

static NSUInteger g_numberOfColumnsInRows[] = {
    1, 11, 21, 22, 32, 222, 322, 332, 333, 442,
    443, 3333, 4333, 4433, 4443, 4444, 53333, 54333, 54433, 54443,
    54444, 55444, 55544, 55554, 55555, 644444, 654444, 655444, 655544, 655554,
    655555, 665555, 666555, 666655, 666665, 666666
};

+ (NSUInteger)maxNumberOfCollagedFaces {
    return sizeof(g_numberOfColumnsInRows) / sizeof(NSUInteger);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    self.selectedIndex = -1;
    UIBarButtonItem *shop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(shopBarButtonPressed:)];
    self.actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBarButtonPressed:)];
    self.actionBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItems = @[self.actionBarButtonItem, shop];
    
    [self calculateImageWidthHeightRatio];
    
    if (![CPSettings isWatermarkRemovePurchased]) {
        [self showWatermarkImageView];
    }
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showHelpView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideHelpView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self hideHelpView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self calculateSizeOfFaces];
    [self.collectionView.collectionViewLayout invalidateLayout];
    if (![CPSettings isWatermarkRemovePurchased]) {
        [self alignWatermarkImageView];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:g_editViewControllerSegueName]) {
        NSAssert(self.selectedIndex >= 0 && self.selectedIndex < self.collagedFaces.count, @"");
        
        CPEditViewController *editViewController = (CPEditViewController *)segue.destinationViewController;
        editViewController.faceEditInformation = [self.collagedFaces objectAtIndex:self.selectedIndex];
    }
}

- (UIView *)selectedFace {
    NSAssert(self.selectedIndex >= 0 && self.selectedIndex < self.collagedFaces.count, @"");
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
}

- (void)reloadSelectedFace {
    if (self.selectedIndex >= 0 && self.selectedIndex < self.collagedFaces.count) {
        // disable animation for reload items
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedIndex inSection:0];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        [CATransaction commit];
    }
}

- (void)shopBarButtonPressed:(id)sender {
    [self performSegueWithIdentifier:g_shopViewControllerSegueName sender:nil];
}

- (void)actionBarButtonPressed:(id)sender {
    [self performSegueWithIdentifier:g_actionViewControllerSegueName sender:nil];
}

- (void)userDefaultsChanged:(NSNotification *)notification {
    if ([CPSettings isWatermarkRemovePurchased] && self.watermarkImageView) {
        [self.watermarkImageView removeFromSuperview];
        self.watermarkImageView = nil;
    }
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    [CPSettings acknowledgeCollageDragHelp];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (!self.draggedCell) {
            CGPoint location = [panGesture locationInView:self.collectionView];
            NSIndexPath *indexPathOfDraggedCell = [self.collectionView indexPathForItemAtPoint:location];
            if (indexPathOfDraggedCell) {
                self.draggedCell = [self.collectionView cellForItemAtIndexPath:indexPathOfDraggedCell];
                self.snapshotOfDraggedCell = [self.draggedCell snapshotViewAfterScreenUpdates:YES];
                self.snapshotOfDraggedCell.frame = self.draggedCell.frame;
                self.snapshotOfDraggedCell.layer.shadowColor = [UIColor blackColor].CGColor;
                self.snapshotOfDraggedCell.layer.shadowOffset = CGSizeMake(5.0, 5.0);
                self.snapshotOfDraggedCell.layer.shadowOpacity = 0.8;
                [self.collectionView addSubview:self.snapshotOfDraggedCell];
                self.draggedCell.hidden = YES;
                self.watermarkImageView.hidden = YES;
            }
        }
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        if (self.draggedCell) {
            CGPoint translation = [panGesture translationInView:self.collectionView];
            CGPoint center = self.snapshotOfDraggedCell.center;
            center.x += translation.x;
            center.y += translation.y;
            self.snapshotOfDraggedCell.center = center;
            [panGesture setTranslation:CGPointZero inView:self.collectionView];
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        NSIndexPath *indexPathOfDroppedCell = [self.collectionView indexPathForItemAtPoint:self.snapshotOfDraggedCell.center];
        UICollectionViewCell *droppedCell = [self.collectionView cellForItemAtIndexPath:indexPathOfDroppedCell];
        
        if (droppedCell) {
            NSIndexPath *indexPath1 = [self.collectionView indexPathForCell:self.draggedCell];
            NSIndexPath *indexPath2 = [self.collectionView indexPathForCell:droppedCell];
            NSAssert(indexPath1 && indexPath2, @"");
            
            NSObject *face1 = [self.collagedFaces objectAtIndex:indexPath1.row];
            NSObject *face2 = [self.collagedFaces objectAtIndex:indexPath2.row];
            [self.collagedFaces setObject:face2 atIndexedSubscript:indexPath1.row];
            [self.collagedFaces setObject:face1 atIndexedSubscript:indexPath2.row];
            
            [UIView animateWithDuration:0.3 animations:^{
                self.snapshotOfDraggedCell.frame = droppedCell.frame;
            } completion:nil];

            [self.collectionView performBatchUpdates:^{
                [self.collectionView moveItemAtIndexPath:indexPath1 toIndexPath:indexPath2];
                [self.collectionView moveItemAtIndexPath:indexPath2 toIndexPath:indexPath1];
            } completion:^(BOOL finished) {
                [self.snapshotOfDraggedCell removeFromSuperview];
                self.snapshotOfDraggedCell = nil;
                self.draggedCell.hidden = NO;
                self.watermarkImageView.hidden = NO;
                self.draggedCell = nil;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                self.snapshotOfDraggedCell.frame = self.draggedCell.frame;
            } completion:^(BOOL finished) {
                [self.snapshotOfDraggedCell removeFromSuperview];
                self.snapshotOfDraggedCell = nil;
                self.draggedCell.hidden = NO;
                self.watermarkImageView.hidden = NO;
                self.draggedCell = nil;
            }];
        }
    }
}

- (void)cancelFromActionSheet:(UIStoryboardSegue *)segue {
}

- (void)saveFromActionSheet:(UIStoryboardSegue *)segue {
    NSAssert(self.facesManager, @"");
    NSAssert(self.collagedFaces, @"");
    [self.facesManager saveStitchedImage:[self collagedImage]];
}

- (void)shareFromActionSheet:(UIStoryboardSegue *)segue {
    NSString *sharedText = @"Shared from Smiley app";
    NSURL *sharedURL = [[NSURL alloc] initWithString:@"http://www.codingpotato.com"];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[sharedText, [self collagedImage], sharedURL] applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (UIImage *)collagedImage {
    NSAssert(self.maxColumns > 0, @"");
    
    CGFloat width = 256.0 * self.maxColumns;
    CGFloat height = width / self.widthHeightRatioOfImage;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));

    CGFloat x = 0.0;
    CGFloat y = 0.0;
    NSUInteger index = 0;
    NSUInteger row = 0;
    NSNumber *numberOfColumns = [self.numberOfColumnsInRows objectAtIndex:row];
    NSUInteger items = numberOfColumns.integerValue;
    for (CPFaceEditInformation *faceEditInformation in self.collagedFaces) {
        CGRect faceBounds = faceEditInformation.frame;
        CGImageRef faceImage = CGImageCreateWithImageInRect(faceEditInformation.asset.defaultRepresentation.fullScreenImage, faceBounds);
        CGFloat widthOfFace = width / numberOfColumns.integerValue;
        UIImage *image = [UIImage imageWithCGImage:faceImage scale:faceBounds.size.width / widthOfFace orientation:UIImageOrientationUp];
        CGImageRelease(faceImage);
        [image drawAtPoint:CGPointMake(x, y)];
        x += widthOfFace;
        index++;
        if (index >= items && index < self.collagedFaces.count) {
            x = 0.0;
            y += widthOfFace;
            row++;
            numberOfColumns = [self.numberOfColumnsInRows objectAtIndex:row];
            items += numberOfColumns.integerValue;
        }
    }
    
    if (![CPSettings isWatermarkRemovePurchased]) {
        CGFloat watermarkHeight = width / self.watermarkImage.size.width * self.watermarkImage.size.height;
        CGRect watermarkFrame = CGRectMake(0.0, height - watermarkHeight, width, watermarkHeight);
        [self.watermarkImage drawInRect:watermarkFrame blendMode:kCGBlendModeNormal alpha:1.0];
    }
    
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

- (void)calculateImageWidthHeightRatio {
    self.maxColumns = 0;
    for (NSNumber *numberOfColumns in self.numberOfColumnsInRows) {
        if (numberOfColumns.integerValue > self.maxColumns) {
            self.maxColumns = numberOfColumns.integerValue;
        }
    }
    CGFloat width = self.maxColumns, height = 0.0;
    for (NSNumber *numberOfColumns in self.numberOfColumnsInRows) {
        height += width / numberOfColumns.integerValue;
    }
    self.widthHeightRatioOfImage = width / height;
}

- (void)calculateSizeOfFaces {
    NSMutableArray *sizeOfFaces = [[NSMutableArray alloc] initWithCapacity:self.collagedFaces.count];
    NSUInteger height = [self heightOfCollagedImage];
    for (NSUInteger row = 0; row < self.numberOfColumnsInRows.count; ++row) {
        NSNumber *number = [self.numberOfColumnsInRows objectAtIndex:row];
        NSUInteger rowHeight = 0.0;
        if (row < self.numberOfColumnsInRows.count - 1) {
            rowHeight = roundf([self widthOfCollagedImage] / number.floatValue);
            height -= rowHeight;
        } else {
            rowHeight = height;
        }
        NSUInteger width = [self widthOfCollagedImage];
        for (NSUInteger column = 0; column < number.integerValue; ++column) {
            NSUInteger faceWidth = roundf(width / (number.floatValue - column));
            width -= faceWidth;
            [sizeOfFaces addObject:[NSValue valueWithCGSize:CGSizeMake(faceWidth, rowHeight)]];
        }
    }
    
    self.sizeOfFaces = [sizeOfFaces copy];
}

- (CGSize)contentSizeOfCollectionView {
    return CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
}

- (CGFloat)widthHeightRatioOfCollectionView {
    return [self contentSizeOfCollectionView].width / [self contentSizeOfCollectionView].height;
}

- (NSUInteger)widthOfCollagedImage {
    if (self.widthHeightRatioOfCollectionView < self.widthHeightRatioOfImage) {
        return roundf(self.collectionView.bounds.size.width);
    } else {
        return roundf([self contentSizeOfCollectionView].height * self.widthHeightRatioOfImage);
    }
}

- (NSUInteger)heightOfCollagedImage {
    if (self.widthHeightRatioOfCollectionView < self.widthHeightRatioOfImage) {
        return roundf([self contentSizeOfCollectionView].width / self.widthHeightRatioOfImage);
    } else {
        return roundf([self contentSizeOfCollectionView].height);
    }
}

- (void)showWatermarkImageView {
    NSAssert(!self.watermarkImageView, @"");
    
    self.watermarkImageView = [[UIImageView alloc] initWithImage:self.watermarkImage];
    [self.view addSubview:self.watermarkImageView];
}

- (void)alignWatermarkImageView {
    if (self.watermarkImageView) {
        CGRect frame = CGRectZero;
        if (self.widthHeightRatioOfCollectionView < self.widthHeightRatioOfImage) {
            NSUInteger inset = roundf(([self contentSizeOfCollectionView].height - [self heightOfCollagedImage]) / 2);
            frame = [self.view convertRect:CGRectMake(0.0, inset, [self widthOfCollagedImage], [self heightOfCollagedImage]) fromView:self.collectionView];
        } else {
            NSUInteger inset = roundf(([self contentSizeOfCollectionView].width - [self widthOfCollagedImage]) / 2);
            frame = [self.view convertRect:CGRectMake(inset, 0.0, [self widthOfCollagedImage], [self heightOfCollagedImage]) fromView:self.collectionView];
        }
        CGFloat height = [self widthOfCollagedImage] / self.watermarkImage.size.width * self.watermarkImage.size.height;
        self.watermarkImageView.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - height, frame.size.width, height);
    }
}

- (UIImage *)imageOfFace:(CPFaceEditInformation *)faceEditInformation {
    CGImageRef faceImage = CGImageCreateWithImageInRect(faceEditInformation.asset.defaultRepresentation.fullScreenImage, faceEditInformation.frame);
    UIImage *image = [UIImage imageWithCGImage:faceImage scale:1.0 orientation:UIImageOrientationUp];
    CGImageRelease(faceImage);
    return image;
}

- (BOOL)allFacesHaveAsset {
    for (CPFaceEditInformation *faceEditInformation in self.collagedFaces) {
        if (!faceEditInformation.asset) {
            return NO;
        }
    }
    return YES;
}

- (void)showHelpView {
    NSAssert(self.collectionView.visibleCells.count > 0, @"");
    
    NSUInteger index = arc4random_uniform((u_int32_t)self.collectionView.visibleCells.count);
    UICollectionViewCell *cell = [self.collectionView.visibleCells objectAtIndex:index];
    NSAssert(cell, @"");
    CGRect rect = [self.view convertRect:cell.frame fromView:self.collectionView];
    
    self.helpViewManager = [[CPHelpViewManager alloc] init];
    [self.helpViewManager showCollageHelpInView:self.view rect:rect];
}

- (void)hideHelpView {
    [self.helpViewManager removeHelpView];
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert(self.collagedFaces.count <= [CPCollageViewController maxNumberOfCollagedFaces], @"");
    return self.collagedFaces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPCollageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPCollageCell" forIndexPath:indexPath];
    [cell initCell];
    
    CPFaceEditInformation *faceEditInformation = [self.collagedFaces objectAtIndex:indexPath.row];
    NSAssert(faceEditInformation, @"");
    
    if (faceEditInformation.asset) {
        [cell showImage:[self imageOfFace:faceEditInformation] animated:NO];
        if ([self allFacesHaveAsset]) {
            self.actionBarButtonItem.enabled = YES;
        }
    } else {
        [self.facesManager assertForURL:[[NSURL alloc] initWithString:faceEditInformation.face.photo.url] resultBlock:^(ALAsset *result) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                faceEditInformation.asset = result;
                UIImage *image = [self imageOfFace:faceEditInformation];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell showImage:image animated:YES];
                    if ([self allFacesHaveAsset]) {
                        self.actionBarButtonItem.enabled = YES;
                    }
                });
            });
        }];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [CPSettings acknowledgeCollageTapHelp];
    
    self.selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"CPEditViewControllerSegue" sender:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSValue *size = [self.sizeOfFaces objectAtIndex:indexPath.row];
    return size.CGSizeValue;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSAssert(section == 0, @"");
    if (self.widthHeightRatioOfCollectionView < self.widthHeightRatioOfImage) {
        NSUInteger insetTop = roundf(([self contentSizeOfCollectionView].height - [self heightOfCollagedImage]) / 2);
        NSUInteger insetBottom = [self contentSizeOfCollectionView].height - insetTop - [self heightOfCollagedImage];
        return UIEdgeInsetsMake(insetTop, 0.0, insetBottom, 0.0);
    } else {
        NSUInteger insetLeft = roundf(([self contentSizeOfCollectionView].width - [self widthOfCollagedImage]) / 2);
        NSUInteger insetRight = [self contentSizeOfCollectionView].width - insetLeft - [self widthOfCollagedImage];
        return UIEdgeInsetsMake(0.0, insetLeft, 0.0, insetRight);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - lazy init

- (NSArray *)numberOfColumnsInRows {
    if (!_numberOfColumnsInRows) {
        NSAssert(self.collagedFaces.count > 0 && self.collagedFaces.count <= [CPCollageViewController maxNumberOfCollagedFaces], @"");

        NSMutableArray *numberOfColumnsInRows = [[NSMutableArray alloc] init];
        NSUInteger numbers = g_numberOfColumnsInRows[self.collagedFaces.count - 1];
        while (numbers > 0) {
            [numberOfColumnsInRows addObject:[NSNumber numberWithInteger:numbers % 10]];
            numbers /= 10;
        }
        _numberOfColumnsInRows = [numberOfColumnsInRows copy];
    }
    return _numberOfColumnsInRows;
}

- (UIImage *)watermarkImage {
    if (!_watermarkImage) {
        _watermarkImage = [UIImage imageNamed:@"watermark.png"];
    }
    return _watermarkImage;
}

@end
