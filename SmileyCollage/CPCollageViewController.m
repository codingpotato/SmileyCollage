//
//  CPCollageViewController.m
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCollageViewController.h"

#import "CPConfig.h"
#import "CPSettings.h"
#import "CPUtility.h"

#import "CPCollageCell.h"
#import "CPEditViewController.h"
#import "CPHelpViewManager.h"
#import "CPPopoverShopViewController.h"
#import "CPShopViewController.h"

#import "CPFaceEditInformation.h"
#import "CPFacesManager.h"
#import "CPFace.h"
#import "CPPhoto.h"

@interface CPCollageViewController () <UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) CPHelpViewManager *helpViewManager;

@property (strong, nonatomic) UIBarButtonItem *shopBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *actionBarButtonItem;

@property (strong, nonatomic) UIImage *watermarkImage;
@property (strong, nonatomic) UIImageView *watermarkImageView;

@property (nonatomic) NSUInteger maxColumns;
@property (strong, nonatomic) NSArray *numberOfColumnsInRows;
@property (strong, nonatomic) NSArray *sizeOfFaces;
@property (nonatomic) CGFloat widthHeightRatioOfImage;

@property (nonatomic) BOOL needImageLoadingAnimation;

@property (nonatomic) NSInteger selectedIndex;

@property (weak, nonatomic) UICollectionViewCell *draggedCell;
@property (strong, nonatomic) UIView *snapshotOfDraggedCell;

@property (strong, nonatomic) UIPopoverController *shopPopoverController;
@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture;

@end

@implementation CPCollageViewController

static const CGFloat g_animationDuration = 0.3;

static NSString * g_editViewControllerSegueName = @"CPEditViewControllerSegue";
static NSString * g_shopViewControllerSegueName = @"CPShopViewControllerSegue";

/*
 * in reverse order
 */
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
    
    self.needImageLoadingAnimation = YES;
    self.selectedIndex = -1;
    self.navigationItem.rightBarButtonItems = @[self.actionBarButtonItem, self.shopBarButtonItem];
    self.actionBarButtonItem.enabled = NO;

    [self showWatermarkImageView];
    [self calculateImageWidthHeightRatio];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self showHelpView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self dismissPopoverShopViewController];
    [self dismissActionSheet];
    [self hideHelpView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self hideHelpView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.navigationController.navigationBar sizeToFit];
    [self calculateSizeOfFaces];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self alignWatermarkImageView];
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
    } else if ([segue.identifier isEqualToString:g_shopViewControllerSegueName]) {
        CPShopViewController *shopViewController = (CPShopViewController *)segue.destinationViewController;
        shopViewController.dismissBlock = ^() {
            [self dismissShopViewController];
        };
    }
}

- (UICollectionViewCell *)selectedFace {
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
    [self dismissActionSheet];
    [self dismissPopoverShopViewController];
    
    if ([CPConfig isIPhone]) {
        [self performSegueWithIdentifier:g_shopViewControllerSegueName sender:nil];
    } else {
        CPPopoverShopViewController *popoverShopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CPPopoverShopViewController"];
        popoverShopViewController.dismissBlock = ^() {
            [self dismissPopoverShopViewController];
        };
        self.shopPopoverController = [[UIPopoverController alloc] initWithContentViewController:popoverShopViewController];
        [self.shopPopoverController presentPopoverFromBarButtonItem:self.shopBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

- (void)dismissShopViewController {
    NSAssert([self.navigationController.topViewController isMemberOfClass:[CPShopViewController class]], @"");
    [self.navigationController popToViewController:self animated:YES];
}

- (void)dismissPopoverShopViewController {
    if (self.shopPopoverController) {
        [self.shopPopoverController dismissPopoverAnimated:YES];
        self.shopPopoverController = nil;
    }
}

- (void)actionBarButtonPressed:(id)sender {
    [self dismissActionSheet];
    [self dismissPopoverShopViewController];
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Share", nil];
    [self.actionSheet showFromBarButtonItem:self.actionBarButtonItem animated:YES];
}

- (void)dismissActionSheet {
    if (self.actionSheet) {
        [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:YES];
        self.actionSheet = nil;
    }
}

- (void)userDefaultsChanged:(NSNotification *)notification {
    if ([CPSettings isWatermarkRemovePurchased]) {
        [self hideWatermarkView];
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
                self.snapshotOfDraggedCell = [self.draggedCell snapshotViewAfterScreenUpdates:NO];
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
            NSIndexPath *indexPath2 = indexPathOfDroppedCell;
            NSAssert(indexPath1 && indexPath2, @"");
            
            NSObject *face1 = [self.collagedFaces objectAtIndex:indexPath1.row];
            NSObject *face2 = [self.collagedFaces objectAtIndex:indexPath2.row];
            [self.collagedFaces setObject:face2 atIndexedSubscript:indexPath1.row];
            [self.collagedFaces setObject:face1 atIndexedSubscript:indexPath2.row];
            
            [UIView animateWithDuration:g_animationDuration animations:^{
                self.snapshotOfDraggedCell.frame = droppedCell.frame;
            } completion:nil];

            [self.collectionView performBatchUpdates:^{
                [self.collectionView moveItemAtIndexPath:indexPath1 toIndexPath:indexPath2];
                [self.collectionView moveItemAtIndexPath:indexPath2 toIndexPath:indexPath1];
            } completion:^(BOOL finished) {
                [self.snapshotOfDraggedCell removeFromSuperview];
                self.snapshotOfDraggedCell = nil;
                self.draggedCell.hidden = NO;
                self.draggedCell = nil;
                self.watermarkImageView.hidden = NO;
            }];
        } else {
            [UIView animateWithDuration:g_animationDuration animations:^{
                self.snapshotOfDraggedCell.frame = self.draggedCell.frame;
            } completion:^(BOOL finished) {
                [self.snapshotOfDraggedCell removeFromSuperview];
                self.snapshotOfDraggedCell = nil;
                self.draggedCell.hidden = NO;
                self.draggedCell = nil;
                self.watermarkImageView.hidden = NO;
            }];
        }
    }
}

- (UIImage *)collagedImage {
    NSAssert(self.maxColumns > 0, @"calculateImageWidthHeightRatio() should be called before this method");
    
    CGFloat width = 256.0 * self.maxColumns;
    CGFloat height = width / self.widthHeightRatioOfImage;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));

    CGFloat x = 0.0;
    CGFloat y = 0.0;
    NSUInteger index = 0;
    NSUInteger row = 0;
    NSNumber *numberOfColumns = [self.numberOfColumnsInRows objectAtIndex:row];
    NSUInteger faces = numberOfColumns.integerValue;
    for (CPFaceEditInformation *faceEditInformation in self.collagedFaces) {
        CGRect faceBounds = faceEditInformation.frame;
        CGImageRef faceImage = CGImageCreateWithImageInRect(faceEditInformation.asset.defaultRepresentation.fullScreenImage, faceBounds);
        CGFloat widthOfFace = width / numberOfColumns.integerValue;
        UIImage *image = [UIImage imageWithCGImage:faceImage];
        CGImageRelease(faceImage);
        [image drawInRect:CGRectMake(x, y, widthOfFace, widthOfFace)];
        
        x += widthOfFace;
        index++;
        if (index >= faces && index < self.collagedFaces.count) {
            x = 0.0;
            y += widthOfFace;
            row++;
            numberOfColumns = [self.numberOfColumnsInRows objectAtIndex:row];
            faces += numberOfColumns.integerValue;
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
        NSUInteger rowHeight = 0;
        if (row < self.numberOfColumnsInRows.count - 1) {
            rowHeight = roundf([self widthOfCollagedImage] / number.floatValue);
            height -= rowHeight;
        } else {
            // use remain height, not calculated height
            rowHeight = height;
        }
        NSUInteger width = [self widthOfCollagedImage];
        for (NSUInteger column = 0; column < number.integerValue; ++column) {
            NSUInteger faceWidth = 0;
            if (column < number.integerValue - 1) {
                faceWidth = roundf(width / (number.floatValue - column));
                width -= faceWidth;
            } else {
                // use remain width, not calculated width
                faceWidth = width;
            }
            [sizeOfFaces addObject:[NSValue valueWithCGSize:CGSizeMake(faceWidth, rowHeight)]];
        }
    }
    self.sizeOfFaces = [sizeOfFaces copy];
}

- (CGFloat)adjustInset {
    UIApplication *application = [UIApplication sharedApplication];
    CGFloat statusBarHeight = UIInterfaceOrientationIsPortrait(application.statusBarOrientation) ? application.statusBarFrame.size.height : application.statusBarFrame.size.width;
    return statusBarHeight + self.navigationController.navigationBar.bounds.size.height;
}

- (CGSize)contentSizeOfCollectionView {
    return CGSizeMake(self.collectionView.bounds.size.width, self.collectionView.bounds.size.height - [self adjustInset]);
}

- (CGFloat)widthHeightRatioOfCollectionView {
    return [self contentSizeOfCollectionView].width / [self contentSizeOfCollectionView].height;
}

- (NSUInteger)widthOfCollagedImage {
    if (self.widthHeightRatioOfCollectionView < self.widthHeightRatioOfImage) {
        return roundf([self contentSizeOfCollectionView].width);
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

- (UIImage *)imageOfFace:(CPFaceEditInformation *)faceEditInformation {
    CGImageRef faceImage = CGImageCreateWithImageInRect(faceEditInformation.asset.defaultRepresentation.fullScreenImage, faceEditInformation.frame);
    UIImage *image = [UIImage imageWithCGImage:faceImage];
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

#pragma mark - handle watermark view

- (void)showWatermarkImageView {
    if (![CPSettings isWatermarkRemovePurchased]) {
        NSAssert(!self.watermarkImageView, @"");
        
        self.watermarkImageView = [[UIImageView alloc] initWithImage:self.watermarkImage];
        [self.view addSubview:self.watermarkImageView];
    }
}

- (void)alignWatermarkImageView {
    if (![CPSettings isWatermarkRemovePurchased] && self.watermarkImageView) {
        CGRect frame = CGRectZero;
        if (self.widthHeightRatioOfCollectionView < self.widthHeightRatioOfImage) {
            NSUInteger topSpace = roundf(([self contentSizeOfCollectionView].height - [self heightOfCollagedImage]) / 2 + [self adjustInset]);
            frame = CGRectMake(0.0, topSpace, [self widthOfCollagedImage], [self heightOfCollagedImage]);
        } else {
            NSUInteger leftSpace = roundf(([self contentSizeOfCollectionView].width - [self widthOfCollagedImage]) / 2);
            frame = CGRectMake(leftSpace, [self adjustInset], [self widthOfCollagedImage], [self heightOfCollagedImage]);
        }
        CGFloat height = [self widthOfCollagedImage] / self.watermarkImage.size.width * self.watermarkImage.size.height;
        self.watermarkImageView.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - height, frame.size.width, height);
    }
}

- (void)hideWatermarkView {
    if (self.watermarkImageView) {
        [self.watermarkImageView removeFromSuperview];
        self.watermarkImageView = nil;
    }
}

#pragma mark - handle help view

- (void)showHelpView {
    if (self.collectionView.visibleCells.count > 0) {
        NSUInteger index = arc4random_uniform((u_int32_t)self.collectionView.visibleCells.count);
        UICollectionViewCell *cell = [self.collectionView.visibleCells objectAtIndex:index];
        NSAssert(cell, @"");
        CGRect rect = [self.view convertRect:cell.frame fromView:self.collectionView];
        
        self.helpViewManager = [[CPHelpViewManager alloc] init];
        [self.helpViewManager showCollageHelpInView:self.view rect:rect];
    }
}

- (void)hideHelpView {
    if (self.helpViewManager) {
        [self.helpViewManager removeHelpView];
        self.helpViewManager = nil;
    }
}

#pragma mark - UIActionSheetDelegate implement

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: /* Save */
            NSAssert(self.facesManager, @"");
            NSAssert(self.collagedFaces.count > 0, @"");
            [self.facesManager saveStitchedImage:[self collagedImage]];
            break;
        case 1: /* Share */ {
            NSString *sharedText = @"Shared from Smiley app";
            NSURL *sharedURL = [[NSURL alloc] initWithString:@"http://www.codingpotato.com"];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[sharedText, [self collagedImage], sharedURL] applicationActivities:nil];
            activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
            [self presentViewController:activityViewController animated:YES completion:nil];
            break;
        }
        case 2: /* Cancel */
            break;
        default:
            NSAssert(NO, @"");
            break;
    }
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert(self.collagedFaces.count <= [CPCollageViewController maxNumberOfCollagedFaces], @"");
    return self.collagedFaces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPCollageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPCollageCell" forIndexPath:indexPath];
    if (self.needImageLoadingAnimation) {
        [cell showActivityIndicatorView];
    }
    
    CPFaceEditInformation *faceEditInformation = [self.collagedFaces objectAtIndex:indexPath.row];
    NSAssert(faceEditInformation, @"");
    
    if (faceEditInformation.asset) {
        if (self.needImageLoadingAnimation) {
            // execute later, not block animation
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell showImage:[self imageOfFace:faceEditInformation] animated:YES];
                if ([self allFacesHaveAsset]) {
                    self.actionBarButtonItem.enabled = YES;
                    self.needImageLoadingAnimation = NO;
                }
            });
        } else {
            [cell showImage:[self imageOfFace:faceEditInformation] animated:NO];
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
                        self.needImageLoadingAnimation = NO;
                    }
                });
            });
        }];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [CPSettings acknowledgeCollageTapHelp];
    
    self.selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:g_editViewControllerSegueName sender:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSValue *size = [self.sizeOfFaces objectAtIndex:indexPath.row];
    return size.CGSizeValue;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    NSAssert(section == 0, @"");
    if (self.widthHeightRatioOfCollectionView < self.widthHeightRatioOfImage) {
        NSUInteger topSpace = roundf(([self contentSizeOfCollectionView].height - [self heightOfCollagedImage]) / 2);
        NSUInteger bottomSpace = [self contentSizeOfCollectionView].height - topSpace - [self heightOfCollagedImage];
        return UIEdgeInsetsMake(topSpace, 0.0, bottomSpace, 0.0);
    } else {
        NSUInteger leftSpace = roundf(([self contentSizeOfCollectionView].width - [self widthOfCollagedImage]) / 2);
        NSUInteger rightSpace = [self contentSizeOfCollectionView].width - leftSpace - [self widthOfCollagedImage];
        return UIEdgeInsetsMake(0.0, leftSpace, 0.0, rightSpace);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - lazy init

- (UIBarButtonItem *)shopBarButtonItem {
    if (!_shopBarButtonItem) {
        _shopBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(shopBarButtonPressed:)];
    }
    return _shopBarButtonItem;
}

- (UIBarButtonItem *)actionBarButtonItem {
    if (!_actionBarButtonItem) {
        _actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBarButtonPressed:)];
    }
    return _actionBarButtonItem;
}

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
