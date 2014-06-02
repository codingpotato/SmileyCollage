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
#import "CPCollageCollectionViewLayout.h"
#import "CPEditViewController.h"
#import "CPHelpViewManager.h"
#import "CPPopoverShopViewController.h"
#import "CPShopViewController.h"

#import "CPFaceEditInformation.h"
#import "CPFacesManager.h"
#import "CPFace.h"
#import "CPPhoto.h"

@interface CPCollageViewController () <CPCollageCollectionViewLayoutDataSource, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) CPHelpViewManager *helpViewManager;

@property (strong, nonatomic) UIBarButtonItem *shopBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *actionBarButtonItem;

@property (strong, nonatomic) UIImage *watermarkImage;
@property (strong, nonatomic) UIImageView *watermarkImageView;

@property (nonatomic) BOOL needImageLoadingAnimation;

@property (nonatomic) NSInteger selectedIndex;

@property (weak, nonatomic) UICollectionViewCell *draggedCell;
@property (strong, nonatomic) UIView *snapshotOfDraggedCell;

@property (strong, nonatomic) UIPopoverController *shopPopoverController;
@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (nonatomic) NSUInteger maxColumns;
@property (nonatomic) CGFloat imageWidthHeightRatio;
@property (strong, nonatomic) NSArray *numberOfColumnsInRows;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet CPCollageCollectionViewLayout *collageCollectionViewLayout;

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

+ (NSUInteger)maxNumberOfSmiley {
    return sizeof(g_numberOfColumnsInRows) / sizeof(NSUInteger);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    self.needImageLoadingAnimation = YES;
    self.selectedIndex = -1;
    self.navigationItem.rightBarButtonItems = @[self.actionBarButtonItem, self.shopBarButtonItem];
    self.actionBarButtonItem.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self showWatermarkImageView];
    [self showHelpView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self dismissPopoverShopViewController];
    [self dismissActionSheet];
    [self removeWatermarkView];
    [self removeHelpView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
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

/*
 * reload selected face while transite back from edit view controller, if the selected area is changed
 * only called by CPEditViewControllerTransition
 */
- (void)reloadSelectedFace {
    if (self.selectedIndex >= 0 && self.selectedIndex < self.collagedFaces.count) {
        // relayout if the devide is rotated
        [self.collageCollectionViewLayout invalidateLayout];
        [self.collectionView layoutIfNeeded];
        
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
    
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:CPLocalizedString(@"CPCancel") destructiveButtonTitle:nil otherButtonTitles:CPLocalizedString(@"CPSave"), CPLocalizedString(@"CPShare"), nil];
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
        [self removeWatermarkView];
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
        
        if (droppedCell && droppedCell != self.draggedCell) {
            UIView *snapshotOfDroppedCell = [droppedCell snapshotViewAfterScreenUpdates:NO];
            snapshotOfDroppedCell.frame = droppedCell.frame;
            [self.collectionView insertSubview:snapshotOfDroppedCell belowSubview:self.snapshotOfDraggedCell];
            droppedCell.hidden = YES;
            
            [UIView animateWithDuration:g_animationDuration animations:^{
                self.snapshotOfDraggedCell.frame = droppedCell.frame;
                snapshotOfDroppedCell.frame = self.draggedCell.frame;
            } completion:^(BOOL finished) {
                [self.snapshotOfDraggedCell removeFromSuperview];
                self.snapshotOfDraggedCell = nil;
                [snapshotOfDroppedCell removeFromSuperview];
            }];
            
            NSIndexPath *indexPath1 = [self.collectionView indexPathForCell:self.draggedCell];
            NSIndexPath *indexPath2 = indexPathOfDroppedCell;
            NSAssert(indexPath1 && indexPath2, @"");

            NSObject *face1 = [self.collagedFaces objectAtIndex:indexPath1.row];
            NSObject *face2 = [self.collagedFaces objectAtIndex:indexPath2.row];
            [self.collagedFaces setObject:face2 atIndexedSubscript:indexPath1.row];
            [self.collagedFaces setObject:face1 atIndexedSubscript:indexPath2.row];
            
            [self.collectionView performBatchUpdates:^{
                [self.collectionView moveItemAtIndexPath:indexPath1 toIndexPath:indexPath2];
                [self.collectionView moveItemAtIndexPath:indexPath2 toIndexPath:indexPath1];
            } completion:^(BOOL finished) {
                self.draggedCell.hidden = NO;
                self.draggedCell = nil;
                droppedCell.hidden = NO;
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
    NSAssert(self.maxColumns > 0, @"maxColumn should be calculated before");
    
    CGFloat width = 256.0 * self.maxColumns;
    CGFloat height = width / self.imageWidthHeightRatio;
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

- (UIImage *)imageOfFace:(CPFaceEditInformation *)faceEditInformation {
    CGImageRef faceImage = CGImageCreateWithImageInRect(faceEditInformation.asset.defaultRepresentation.fullScreenImage, faceEditInformation.frame);
    UIImage *image = [UIImage imageWithCGImage:faceImage];
    CGImageRelease(faceImage);
    return image;
}

- (CGFloat)topInset {
    [self.navigationController.navigationBar sizeToFit];
    
    UIApplication *application = [UIApplication sharedApplication];
    CGFloat statusBarHeight = UIInterfaceOrientationIsPortrait(application.statusBarOrientation) ? application.statusBarFrame.size.height : application.statusBarFrame.size.width;
    return statusBarHeight + self.navigationController.navigationBar.bounds.size.height;
}

- (BOOL)allFacesHaveAsset {
    for (CPFaceEditInformation *faceEditInformation in self.collagedFaces) {
        if (!faceEditInformation.asset) {
            return NO;
        }
    }
    return YES;
}

- (UIView *)showActivityIndicatorView {
    UIView *panel = [[UIView alloc] init];
    panel.clipsToBounds = YES;
    panel.layer.cornerRadius = 5.0;
    panel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:panel];
    [self.view addConstraints:[CPUtility constraintsWithView:panel centerAlignToView:self.view]];
    [panel addConstraint:[CPUtility constraintWithView:panel width:100.0]];
    [panel addConstraint:[CPUtility constraintWithView:panel height:100.0]];
    
    UIView *panelMask = [[UIView alloc] init];
    panelMask.alpha = 0.95;
    panelMask.backgroundColor = [UIColor grayColor];
    panelMask.translatesAutoresizingMaskIntoConstraints = NO;
    [panel addSubview:panelMask];
    [panel addConstraints:[CPUtility constraintsWithView:panelMask edgesAlignToView:panel]];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [panel addSubview:activityIndicatorView];
    [panel addConstraints:[CPUtility constraintsWithView:activityIndicatorView centerAlignToView:panel]];
    [activityIndicatorView startAnimating];
    
    return panel;
}

#pragma mark - handle watermark view

- (void)showWatermarkImageView {
    if (![CPSettings isWatermarkRemovePurchased] && !self.watermarkImageView) {
        self.watermarkImageView = [[UIImageView alloc] initWithImage:self.watermarkImage];
        self.watermarkImageView.alpha = 0.0;
        [self.view addSubview:self.watermarkImageView];
        
        [UIView animateWithDuration:0.0 delay:g_animationDuration options:UIViewAnimationOptionTransitionNone animations:^{
            self.watermarkImageView.alpha = 1.0;
        } completion:nil];
    }
}

- (void)alignWatermarkImageView {
    if (![CPSettings isWatermarkRemovePurchased] && self.watermarkImageView) {
        [self.navigationController.navigationBar sizeToFit];
        
        CGRect frame = self.collageCollectionViewLayout.imageFrame;
        frame.origin.y += [self topInset];
        CGFloat height = frame.size.width / self.watermarkImage.size.width * self.watermarkImage.size.height;
        self.watermarkImageView.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - height, frame.size.width, height);
    }
}

- (void)removeWatermarkView {
    if (self.watermarkImageView) {
        [self.watermarkImageView removeFromSuperview];
        self.watermarkImageView = nil;
    }
}

#pragma mark - handle help view

- (void)showHelpView {
    if (!self.helpViewManager) {
        self.helpViewManager = [[CPHelpViewManager alloc] init];
        [self.helpViewManager showCollageHelpInSuperview:self.view];
    }
}

- (void)removeHelpView {
    if (self.helpViewManager) {
        [self.helpViewManager removeHelpView];
        self.helpViewManager = nil;
    }
}

#pragma mark - CPCollageCollectionViewLayoutDataSource implement

- (CGFloat)topInsetForCollectionView:(UICollectionView *)collectionView {
    return [self topInset];
}

- (CGFloat)imageWidthHeightRatioForCollectionView:(UICollectionView *)collectionView {
    return self.imageWidthHeightRatio;
}

- (NSArray *)numberOfColumnsInRowsForCollectionView:(UICollectionView *)collectionView {
    return self.numberOfColumnsInRows;
}

#pragma mark - UIActionSheetDelegate implement

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: /* Save */ {
            NSAssert(self.facesManager, @"");
            NSAssert(self.collagedFaces.count > 0, @"");

            UIView *activityIndicatorView = [self showActivityIndicatorView];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.facesManager saveStitchedImage:[self collagedImage]];

                [activityIndicatorView removeFromSuperview];
            });
            break;
        }
        case 1: /* Share */ {
            NSAssert(self.facesManager, @"");
            NSAssert(self.collagedFaces.count > 0, @"");
            
            UIView *activityIndicatorView = [self showActivityIndicatorView];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *sharedText = CPLocalizedString(@"CPSharedText");
                NSURL *sharedURL = [[NSURL alloc] initWithString:@"http://codingpotato.bl.ee"];
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[sharedText, [self collagedImage], sharedURL] applicationActivities:nil];
                activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList];
                [self presentViewController:activityViewController animated:YES completion:nil];
                
                [activityIndicatorView removeFromSuperview];
            });
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
    NSAssert(self.collagedFaces.count <= [CPCollageViewController maxNumberOfSmiley], @"");
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

#pragma mark - lazy init

- (UIBarButtonItem *)shopBarButtonItem {
    if (!_shopBarButtonItem) {
        _shopBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"shop.png"] style:UIBarButtonItemStylePlain target:self action:@selector(shopBarButtonPressed:)];
    }
    return _shopBarButtonItem;
}

- (UIBarButtonItem *)actionBarButtonItem {
    if (!_actionBarButtonItem) {
        _actionBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBarButtonPressed:)];
    }
    return _actionBarButtonItem;
}

- (UIImage *)watermarkImage {
    if (!_watermarkImage) {
        _watermarkImage = [UIImage imageNamed:@"watermark.png"];
    }
    return _watermarkImage;
}

- (NSUInteger)maxColumns {
    if (_maxColumns == 0) {
        [self imageWidthHeightRatio];
    }
    return _maxColumns;
}

- (CGFloat)imageWidthHeightRatio {
    if (_imageWidthHeightRatio == 0.0) {
        _maxColumns = 0;
        for (NSNumber *numberOfColumns in self.numberOfColumnsInRows) {
            if (numberOfColumns.integerValue > _maxColumns) {
                _maxColumns = numberOfColumns.integerValue;
            }
        }
        CGFloat width = _maxColumns, height = 0.0;
        for (NSNumber *numberOfColumns in self.numberOfColumnsInRows) {
            height += width / numberOfColumns.integerValue;
        }
        _imageWidthHeightRatio = width / height;
    }
    return _imageWidthHeightRatio;
}

- (NSArray *)numberOfColumnsInRows {
    if (!_numberOfColumnsInRows) {
        NSAssert(self.collagedFaces.count > 0 && self.collagedFaces.count <= [CPCollageViewController maxNumberOfSmiley], @"");
        
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

@end
