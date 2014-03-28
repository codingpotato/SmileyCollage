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

#import "CPFaceEditInformation.h"
#import "CPFacesManager.h"
#import "CPFace.h"
#import "CPPhoto.h"


@interface CPStitchViewController ()

@property (nonatomic) NSInteger selectedIndex;

@property (strong, nonatomic) UICollectionViewCell *draggedCell;
@property (strong, nonatomic) UIView *snapshotOfDraggedCell;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture;

@end

@implementation CPStitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedIndex = -1;

    __block NSUInteger index = 0;
    for (CPFaceEditInformation *faceEditInformation in self.stitchedFaces) {
        faceEditInformation.userBounds = CGRectMake(faceEditInformation.face.x.floatValue, faceEditInformation.face.y.floatValue, faceEditInformation.face.width.floatValue, faceEditInformation.face.height.floatValue);
        NSURL *url = [[NSURL alloc] initWithString:faceEditInformation.face.photo.url];
        [self.facesManager assertForURL:url resultBlock:^(ALAsset *result) {
            faceEditInformation.asset = result;
            [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index++ inSection:0]]];
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

- (IBAction)actionBarButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save", @"Share", nil];
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
                NSObject *face1 = [self.stitchedFaces objectAtIndex:indexPath1.row];
                NSObject *face2 = [self.stitchedFaces objectAtIndex:indexPath2.row];
                [self.stitchedFaces setObject:face2 atIndexedSubscript:indexPath1.row];
                [self.stitchedFaces setObject:face1 atIndexedSubscript:indexPath2.row];
                
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView moveItemAtIndexPath:indexPath1 toIndexPath:indexPath2];
                    [self.collectionView moveItemAtIndexPath:indexPath2 toIndexPath:indexPath1];
                } completion:^(BOOL finished) {
                }];
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
    return self.stitchedFaces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPStitchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPStitchCell" forIndexPath:indexPath];
    CPFaceEditInformation *faceEditInformation = [self.stitchedFaces objectAtIndex:indexPath.row];
    NSAssert(faceEditInformation, @"");
    
    if (faceEditInformation.asset) {
        CGImageRef faceImage = CGImageCreateWithImageInRect(faceEditInformation.asset.defaultRepresentation.fullScreenImage, faceEditInformation.userBounds);
        cell.image = [UIImage imageWithCGImage:faceImage scale:faceEditInformation.userBounds.size.width / self.widthOfStitchCell orientation:UIImageOrientationUp];
        CGImageRelease(faceImage);
    }
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
    float rows = sqrtf(self.stitchedFaces.count);
    return ((NSUInteger)rows) == rows ? rows : rows + 1;
}

#pragma mark - UIActionSheetDelegate implement

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            // Save
            NSAssert(self.facesManager, @"");
            NSAssert(self.stitchedFaces, @"");
            UIImage *image = [self.facesManager imageOfStitchedFaces:self.stitchedFaces];
            [self.facesManager saveStitchedImage:image];
            break;
        }
        case 1: {
            // share
            NSString *sharedText = @"Shared from Smiley app";
            UIImage *sharedImage = [self.facesManager imageOfStitchedFaces:self.stitchedFaces];
            NSURL *sharedURL = [[NSURL alloc] initWithString:@"http://www.codingpotato.com"];
            UIActivityViewController *activityViewCOntroller = [[UIActivityViewController alloc] initWithActivityItems:@[sharedText, sharedImage, sharedURL] applicationActivities:nil];
            [self presentViewController:activityViewCOntroller animated:YES completion:nil];
            break;
        }
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

@end
