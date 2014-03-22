//
//  CPStitchViewController.m
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPStitchViewController.h"

#import "CPEditViewController.h"
#import "CPStitchCell.h"

#import "CPAssetsLibrary.h"
#import "CPFacesManager.h"
#import "CPFace.h"
#import "CPPhoto.h"

@interface CPStitchViewController ()

@property (nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) NSMutableArray *userBounds;

@property (strong, nonatomic) UICollectionViewCell *draggedCell;
@property (strong, nonatomic) UIView *snapshotOfDraggedCell;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture;

@end

@implementation CPStitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedIndex = -1;
    
    [self.userBounds removeAllObjects];
    for (CPFace *face in self.selectedFaces) {
        [self.userBounds addObject:[NSValue valueWithCGRect:CGRectMake(face.x.floatValue, face.y.floatValue, face.width.floatValue, face.height.floatValue)]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.selectedIndex != -1) {
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]]];
        self.selectedIndex = -1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CPEditViewControllerSegue"]) {
        // NSAssert(self.selectedIndex >= 0 && self.selectedIndex < [CPFacesManager defaultManager].selectedFaces.count, @"");
        
        CPEditViewController *editViewController = (CPEditViewController *)segue.destinationViewController;
        // editViewController.face = [[CPFacesManager defaultManager].selectedFaces objectAtIndex:self.selectedIndex];
        editViewController.userBound = [self.userBounds objectAtIndex:self.selectedIndex];
    }
}

- (IBAction)actionBarButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save Photo", nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (CGRect)frameOfSelectedCell {
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndex inSection:0]];
    return [self.view convertRect:cell.frame fromView:self.collectionView];
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
            if (indexPath1 && indexPath2) {
                // [[CPFacesManager defaultManager] exchangeSelectedFacesByIndex1:indexPath1.row withIndex2:indexPath2.row];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath1, indexPath2]];
            }
        }
        
        [self.snapshotOfDraggedCell removeFromSuperview];
        self.snapshotOfDraggedCell = nil;
        self.draggedCell.hidden = NO;
        self.draggedCell = nil;        
    }
}

#pragma mark - UICollectionViewDataSource and UICollectionViewDelegate implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedFaces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPStitchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPStitchCell" forIndexPath:indexPath];
    CPFace *face = [self.selectedFaces objectAtIndex:indexPath.row];
    NSAssert(face, @"");
    
    NSURL *url = [[NSURL alloc] initWithString:face.photo.url];
    [self.assetsLibrary assertForURL:url resultBlock:^(ALAsset *result) {
        CGRect bounds = ((NSValue *)[self.userBounds objectAtIndex:indexPath.row]).CGRectValue;
        CGImageRef faceImage = CGImageCreateWithImageInRect(result.defaultRepresentation.fullScreenImage, bounds);
        cell.image = [UIImage imageWithCGImage:faceImage scale:bounds.size.width / self.widthOfStitchCell orientation:UIImageOrientationUp];
        CGImageRelease(faceImage);
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.widthOfStitchCell;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [self performSegueWithIdentifier:@"CPEditViewControllerSegue" sender:nil];
}

- (CGFloat)widthOfStitchCell {
    return self.collectionView.bounds.size.width / self.rowsOfStitchCell;
}

- (NSUInteger)rowsOfStitchCell {
    // TODO: layout algorithm
    float rows = sqrtf(self.selectedFaces.count);
    return ((NSUInteger)rows) == rows ? rows : rows + 1;
}

#pragma mark - UIActionSheetDelegate implement

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            // [[CPFacesManager defaultManager] saveStitchedImage];
            break;
        default:
            break;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - lazy init

- (NSMutableArray *)userBounds {
    if (!_userBounds) {
        _userBounds = [[NSMutableArray alloc] init];
    }
    return _userBounds;
}

@end
