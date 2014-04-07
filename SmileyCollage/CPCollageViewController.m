//
//  CPStitchViewController.m
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCollageViewController.h"

#import "CPSettings.h"
#import "CPUtility.h"

#import "CPEditViewController.h"
#import "CPStitchCell.h"

#import "CPFaceEditInformation.h"
#import "CPFacesManager.h"
#import "CPFace.h"
#import "CPPhoto.h"


@interface CPCollageViewController ()

@property (strong, nonatomic) UIImage *watermarkImage;
@property (strong, nonatomic) UIImageView *watermarkImageView;

@property (strong, nonatomic) NSArray *numberOfColumnsInRows;
@property (strong, nonatomic) NSArray *sizeOfFaces;
@property (nonatomic) NSUInteger maxColumns;
@property (nonatomic) CGFloat widthHeightRatioOfImage;

@property (nonatomic) NSInteger selectedIndex;
@property (strong, nonatomic) UICollectionViewCell *draggedCell;
@property (strong, nonatomic) UIView *snapshotOfDraggedCell;

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIActionSheet *shopActionSheet;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture;

@end

@implementation CPCollageViewController

static NSUInteger g_numberOfColumnsInRows[] = {
    1, 11, 21, 22, 32, 222, 322, 332, 333, 442,
    443, 3333, 4333, 4433, 4443, 4444, 53333, 54333, 54433, 54443,
    54444, 55444, 55544, 55554, 55555, 644444, 654444, 655444, 655544, 655554,
    655555, 665555, 666555, 666655, 666665, 666666
};

+ (NSUInteger)maxNumberOfStitchedFaces {
    return sizeof(g_numberOfColumnsInRows) / sizeof(NSUInteger);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedIndex = -1;
    UIBarButtonItem *shop = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(shopBarButtonPressed:)];
    UIBarButtonItem *action = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBarButtonPressed:)];
    self.navigationItem.rightBarButtonItems = @[action, shop];
    
    [self calculateImageWidthHeightRatio];
    
    __block NSUInteger index = 0;
    for (CPFaceEditInformation *faceEditInformation in self.stitchedFaces) {
        faceEditInformation.frame = CGRectMake(faceEditInformation.face.x.floatValue, faceEditInformation.face.y.floatValue, faceEditInformation.face.width.floatValue, faceEditInformation.face.height.floatValue);
        NSURL *url = [[NSURL alloc] initWithString:faceEditInformation.face.photo.url];
        [self.facesManager assertForURL:url resultBlock:^(ALAsset *result) {
            faceEditInformation.asset = result;
            if (++index == self.stitchedFaces.count) {
                [self.collectionView reloadData];
                if (![CPSettings isWatermarkRemoved]) {
                    [self showWatermarkImageView];
                    [self alignWatermarkImageView];
                }
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.selectedIndex != -1) {
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]]];
        self.selectedIndex = -1;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self calculateSizeOfFaces];
    [self.collectionView.collectionViewLayout invalidateLayout];
    if (![CPSettings isWatermarkRemoved]) {
        [self alignWatermarkImageView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CPEditViewControllerSegue"]) {
        NSAssert(self.selectedIndex >= 0 && self.selectedIndex < self.stitchedFaces.count, @"");
        
        CPEditViewController *editViewController = (CPEditViewController *)segue.destinationViewController;
        editViewController.faceEditInformation = [self.stitchedFaces objectAtIndex:self.selectedIndex];
    }
}

- (CGRect)frameOfSelectedCell {
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
    return [self.view convertRect:attributes.frame fromView:self.collectionView];
}

- (void)shopBarButtonPressed:(id)sender {
    self.shopActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Purchase Remove Watermark", @"Re-download purchased items", nil];
    [self.shopActionSheet showFromBarButtonItem:sender animated:YES];
}

- (void)actionBarButtonPressed:(id)sender {
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Share", nil];
    [self.actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
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
            
            NSObject *face1 = [self.stitchedFaces objectAtIndex:indexPath1.row];
            NSObject *face2 = [self.stitchedFaces objectAtIndex:indexPath2.row];
            [self.stitchedFaces setObject:face2 atIndexedSubscript:indexPath1.row];
            [self.stitchedFaces setObject:face1 atIndexedSubscript:indexPath2.row];
            
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

- (UIImage *)stitchedImage {
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
    for (CPFaceEditInformation *faceEditInformation in self.stitchedFaces) {
        CGRect faceBounds = faceEditInformation.frame;
        CGImageRef faceImage = CGImageCreateWithImageInRect(faceEditInformation.asset.defaultRepresentation.fullScreenImage, faceBounds);
        CGFloat widthOfFace = width / numberOfColumns.integerValue;
        UIImage *image = [UIImage imageWithCGImage:faceImage scale:faceBounds.size.width / widthOfFace orientation:UIImageOrientationUp];
        CGImageRelease(faceImage);
        [image drawAtPoint:CGPointMake(x, y)];
        x += widthOfFace;
        index++;
        if (index >= items && index < self.stitchedFaces.count) {
            x = 0.0;
            y += widthOfFace;
            row++;
            numberOfColumns = [self.numberOfColumnsInRows objectAtIndex:row];
            items += numberOfColumns.integerValue;
        }
    }
    
    CGFloat watermarkHeight = width / self.watermarkImage.size.width * self.watermarkImage.size.height;
    CGRect watermarkFrame = CGRectMake(0.0, height - watermarkHeight, width, watermarkHeight);
    [self.watermarkImage drawInRect:watermarkFrame blendMode:kCGBlendModeNormal alpha:1.0];
    
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
    NSMutableArray *sizeOfFaces = [[NSMutableArray alloc] initWithCapacity:self.stitchedFaces.count];
    NSUInteger height = self.heightOfStitchedImage;
    for (NSUInteger row = 0; row < self.numberOfColumnsInRows.count; ++row) {
        NSNumber *number = [self.numberOfColumnsInRows objectAtIndex:row];
        NSUInteger rowHeight = 0.0;
        if (row < self.numberOfColumnsInRows.count - 1) {
            rowHeight = roundf(self.widthOfStitchedImage / number.floatValue);
            height -= rowHeight;
        } else {
            rowHeight = height;
        }
        NSUInteger width = self.widthOfStitchedImage;
        for (NSUInteger column = 0; column < number.integerValue; ++column) {
            NSUInteger faceWidth = roundf(width / (number.floatValue - column));
            width -= faceWidth;
            [sizeOfFaces addObject:[NSValue valueWithCGSize:CGSizeMake(faceWidth, rowHeight)]];
        }
    }
    
    self.sizeOfFaces = [sizeOfFaces copy];
}

- (CGFloat)widthHeightRatioOfCollectionView {
    return self.collectionView.bounds.size.width / self.collectionView.bounds.size.height;
}

- (NSUInteger)widthOfStitchedImage {
    if (self.widthHeightRatioOfCollectionView < self.widthHeightRatioOfImage) {
        return roundf(self.collectionView.bounds.size.width);
    } else {
        return self.collectionView.bounds.size.height * self.widthHeightRatioOfImage;
    }
}

- (NSUInteger)heightOfStitchedImage {
    if (self.widthHeightRatioOfCollectionView < self.widthHeightRatioOfImage) {
        return roundf(self.collectionView.bounds.size.width / self.widthHeightRatioOfImage);
    } else {
        return roundf(self.collectionView.bounds.size.height);
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
            NSUInteger inset = roundf((self.collectionView.bounds.size.height - self.heightOfStitchedImage) / 2);
            frame = [self.view convertRect:CGRectMake(0.0, inset, self.widthOfStitchedImage, self.heightOfStitchedImage) fromView:self.collectionView];
        } else {
            NSUInteger inset = roundf((self.collectionView.bounds.size.width - self.widthOfStitchedImage) / 2);
            frame = [self.view convertRect:CGRectMake(inset, 0.0, self.widthOfStitchedImage, self.heightOfStitchedImage) fromView:self.collectionView];
        }
        CGFloat height = self.widthOfStitchedImage / self.watermarkImage.size.width * self.watermarkImage.size.height;
        self.watermarkImageView.frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - height, frame.size.width, height);
    }
}

#pragma mark - UIActionSheetDelegate implement

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.actionSheet) {
        switch (buttonIndex) {
            case 0: {
                // Save
                NSAssert(self.facesManager, @"");
                NSAssert(self.stitchedFaces, @"");
                [self.facesManager saveStitchedImage:self.stitchedImage];
                break;
            }
            case 1: {
                // share
                NSString *sharedText = @"Shared from Smiley app";
                NSURL *sharedURL = [[NSURL alloc] initWithString:@"http://www.codingpotato.com"];
                UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[sharedText, self.stitchedImage, sharedURL] applicationActivities:nil];
                [self presentViewController:activityViewController animated:YES completion:nil];
                break;
            }
            default:
                break;
        }
    } else if (actionSheet == self.shopActionSheet) {
        switch (buttonIndex) {
            case 0:
                // Purchase Remove Watermark
                [CPSettings removeWatermark];
                break;
            default:
                break;
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.actionSheet) {
        self.actionSheet = nil;
    } else if (actionSheet == self.shopActionSheet) {
        self.shopActionSheet = nil;
    }
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSAssert(self.stitchedFaces.count <= [CPCollageViewController maxNumberOfStitchedFaces], @"");
    return self.stitchedFaces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPStitchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPStitchCell" forIndexPath:indexPath];
    CPFaceEditInformation *faceEditInformation = [self.stitchedFaces objectAtIndex:indexPath.row];
    NSAssert(faceEditInformation, @"");
    
    if (faceEditInformation.asset) {
        CGImageRef faceImage = CGImageCreateWithImageInRect(faceEditInformation.asset.defaultRepresentation.fullScreenImage, faceEditInformation.frame);
        cell.image = [UIImage imageWithCGImage:faceImage scale:1.0 orientation:UIImageOrientationUp];
        CGImageRelease(faceImage);
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
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
        NSUInteger insetTop = roundf((collectionView.bounds.size.height - self.heightOfStitchedImage) / 2);
        NSUInteger insetBottom = self.collectionView.bounds.size.height - insetTop - self.heightOfStitchedImage;
        return UIEdgeInsetsMake(insetTop, 0.0, insetBottom, 0.0);
    } else {
        NSUInteger insetLeft = roundf((collectionView.bounds.size.width - self.widthOfStitchedImage) / 2);
        NSUInteger insetRight = self.collectionView.bounds.size.width - insetLeft - self.widthOfStitchedImage;
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
        NSAssert(self.stitchedFaces.count > 0 && self.stitchedFaces.count < [CPCollageViewController maxNumberOfStitchedFaces], @"");

        NSMutableArray *numberOfColumnsInRows = [[NSMutableArray alloc] init];
        NSUInteger numbers = g_numberOfColumnsInRows[self.stitchedFaces.count - 1];
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
