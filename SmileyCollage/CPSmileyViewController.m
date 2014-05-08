//
//  CPSmileyViewController.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSmileyViewController.h"

#import "CPConfig.h"
#import "CPSettings.h"
#import "CPUtility.h"

#import "CPCollageViewController.h"
#import "CPHelpViewManager.h"
#import "CPPhotoCell.h"

#import "CPFace.h"
#import "CPFaceEditInformation.h"
#import "CPFacesManager.h"
#import "CPPhoto.h"

@interface CPSmileyViewController () <NSFetchedResultsControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) CPHelpViewManager *helpViewManager;

@property (strong, nonatomic) CPFacesManager *facesManager;

@property (strong, nonatomic) NSMutableArray *fetchedResultsChangedObjects;

@property (strong, nonatomic) NSMutableDictionary *selectedFaces;

@property (nonatomic) BOOL isScanCancelled;

@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *confirmBarButtonItem;
@property (strong, nonatomic) UIButton *confirmButton;

@property (strong, nonatomic) UILabel *noSmileyLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;

@end

@implementation CPSmileyViewController

static const CGFloat g_animationDuration = 0.3;

static const CGFloat g_collectionViewSpacing = 1.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    self.navigationItem.title = [NSString stringWithFormat:@"Smiley: %lu", (unsigned long)self.facesManager.facesController.fetchedObjects.count];

    self.isScanCancelled = NO;
    self.facesManager.facesController.delegate = self;
    [self hideToolbar];
    [self.facesManager scanFaces];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showToolbarWithAnimation];
    [self showSelectedFacesNumber];
    
    if (self.collectionView.visibleCells.count > 0) {
        [self showHelpView];
    } else {
        [self showNoSmileyLabel];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self hideToolbar];
    [self hideHelpView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self hideHelpView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if (self.facesManager.isScanning) {
        [self.facesManager stopScan];
        self.isScanCancelled = YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CPCollageViewControllerSegue"]) {
        CPCollageViewController *collageViewController = (CPCollageViewController *)segue.destinationViewController;
        collageViewController.facesManager = self.facesManager;
        collageViewController.collagedFaces = [self.selectedFaces.allValues mutableCopy];
    }
}

- (void)handleApplicationDidBecomeActiveNotification:(NSNotification *)notification {
    [self.facesManager addObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfScannedPhotos)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.facesManager addObserver:self forKeyPath:NSStringFromSelector(@selector(isScanning)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    if (self.isScanCancelled) {
        [self showToolbarWithAnimation];
        [self.facesManager scanFaces];
        self.isScanCancelled = NO;
    }
}

- (void)handleApplicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self.facesManager removeObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfScannedPhotos))];
    [self.facesManager removeObserver:self forKeyPath:NSStringFromSelector(@selector(isScanning))];
    
    [self hideToolbar];
    
    if (self.facesManager.isScanning) {
        [self.facesManager stopScan];
        self.isScanCancelled = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(numberOfScannedPhotos))]) {
        NSNumber *oldValue = change[NSKeyValueChangeOldKey];
        NSNumber *newValue = change[NSKeyValueChangeNewKey];
        if (![oldValue isEqual:newValue]) {
            self.progressView.progress = newValue.floatValue / self.facesManager.numberOfTotalPhotos;
            self.informationLabel.text = [NSString stringWithFormat:@"Scanned %d of %d photos", (int)self.facesManager.numberOfScannedPhotos, (int)self.facesManager.numberOfTotalPhotos];
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(isScanning))]) {
        NSNumber *oldValue = change[NSKeyValueChangeOldKey];
        NSNumber *newValue = change[NSKeyValueChangeNewKey];
        if (oldValue.boolValue && !newValue.boolValue) {
            [self hideToolbarWithAnimation];
        }
    }
}

- (void)showToolbarWithAnimation {
    self.progressView.progress = 0.0;
    self.informationLabel.text = @"Scanning photos......";
    self.toolbarBottomConstraint.constant = 0.0;
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)hideToolbar {
    self.toolbarBottomConstraint.constant = self.toolbar.bounds.size.height;
    [self.view layoutIfNeeded];
}

- (void)hideToolbarWithAnimation {
    self.toolbarBottomConstraint.constant = self.toolbar.bounds.size.height;
    [UIView animateWithDuration:0.3 delay:5.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)showSelectedFacesNumber {
    [self.confirmButton setTitle:[[NSString alloc] initWithFormat:@"%d", (int)self.selectedFaces.count] forState:UIControlStateNormal];
    if (self.selectedFaces.count > 9) {
        [self.confirmButton setImage:[UIImage imageNamed:@"confirm_1.png"] forState:UIControlStateNormal];
        self.confirmButton.titleEdgeInsets = UIEdgeInsetsMake(-10.0, -16.0, 0.0, 0.0);
    } else {
        [self.confirmButton setImage:[UIImage imageNamed:@"confirm.png"] forState:UIControlStateNormal];
        self.confirmButton.titleEdgeInsets = UIEdgeInsetsMake(-10.0, -11.0, 0.0, 0.0);
    }
}

- (void)showBarButtonItems {
    self.navigationItem.rightBarButtonItem = self.confirmBarButtonItem;
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
}

- (void)hideBarButtonItems {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)helpBarButtonItemPressed:(id)sender {
}

- (void)cancelBarButtonItemPressed:(id)sender {
    self.selectedFaces = nil;
    [self hideBarButtonItems];
    [self.collectionView reloadData];
}

- (void)confirmButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"CPCollageViewControllerSegue" sender:nil];
}

- (void)showNoSmileyLabel {
    self.noSmileyLabel.alpha = 0.0;
    [self.view addSubview:self.noSmileyLabel];
    [self.view addConstraints:[CPUtility constraintsWithView:self.noSmileyLabel centerAlignToView:self.view]];
    [self.view addConstraint:[CPUtility constraintWithView:self.noSmileyLabel alignToView:self.view attribute:NSLayoutAttributeWidth]];

    [UIView animateWithDuration:g_animationDuration animations:^{
        self.noSmileyLabel.alpha = 1.0;
    }];
}

- (void)hideNoSmileyLabel {
    [UIView animateWithDuration:g_animationDuration animations:^{
        self.noSmileyLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.noSmileyLabel removeFromSuperview];
    }];
}

- (void)showHelpView {
    NSAssert(self.collectionView.visibleCells.count > 0, @"");
    
    NSUInteger index = arc4random_uniform((u_int32_t)self.collectionView.visibleCells.count);
    UICollectionViewCell *cell = [self.collectionView.visibleCells objectAtIndex:index];
    NSAssert(cell, @"");
    CGRect rect = [self.view convertRect:cell.frame fromView:self.collectionView];
    
    self.helpViewManager = [[CPHelpViewManager alloc] init];
    [self.helpViewManager showSmileyHelpInView:self.view rect:rect];
}

- (void)hideHelpView {
    [self.helpViewManager removeHelpView];
}

#pragma mark - NSFetchedResultsControllerDelegate implement

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            NSAssert(newIndexPath, @"");
            [self.fetchedResultsChangedObjects addObject:@{@(type): newIndexPath}];
            break;
        case NSFetchedResultsChangeDelete:
            NSAssert(indexPath, @"");
            [self.fetchedResultsChangedObjects addObject:@{@(type): indexPath}];
            break;
        case NSFetchedResultsChangeUpdate:
            NSAssert(indexPath, @"");
            [self.fetchedResultsChangedObjects addObject:@{@(type): indexPath}];
            break;
        case NSFetchedResultsChangeMove:
            NSAssert(indexPath, @"");
            NSAssert(newIndexPath, @"");
            [self.fetchedResultsChangedObjects addObject:@{@(type): @[indexPath, newIndexPath]}];
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary *change in self.fetchedResultsChangedObjects) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = ((NSNumber *)key).integerValue;
                switch (type) {
                    case NSFetchedResultsChangeInsert:
                        NSAssert([obj isMemberOfClass:[NSIndexPath class]], @"");
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        NSAssert([obj isMemberOfClass:[NSIndexPath class]], @"");
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        NSAssert([obj isMemberOfClass:[NSIndexPath class]], @"");
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeMove: {
                        NSAssert([obj isMemberOfClass:[NSArray class]], @"");
                        NSArray *parameters = (NSArray *)obj;
                        NSAssert(parameters.count == 2, @"");
                        [self.collectionView moveItemAtIndexPath:[parameters objectAtIndex:0] toIndexPath:[parameters objectAtIndex:1]];
                        break;
                    }
                    default:
                        NSAssert(NO, @"");
                        break;
                }
            }];
        }
    } completion:nil];
    [self.fetchedResultsChangedObjects removeAllObjects];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Smiley: %d", (int)controller.fetchedObjects.count];
    if (controller.fetchedObjects.count == 0) {
        [self showNoSmileyLabel];
    } else {
        [self hideNoSmileyLabel];
    }
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.facesManager.facesController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPPhotoCell" forIndexPath:indexPath];
    [cell initCell];
    
    CPFace *face = [self.facesManager.facesController.fetchedObjects objectAtIndex:indexPath.row];
    [cell showImage:[self.facesManager thumbnailOfFace:face]];
    cell.isSelected = [self.selectedFaces objectForKey:face.objectID] != nil;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [CPSettings acknowledgeSmileyTapHelp];
    
    CPFace *face = [self.facesManager.facesController.fetchedObjects objectAtIndex:indexPath.row];
    NSAssert(face, @"");

    if ([self.selectedFaces objectForKey:face.objectID]) {
        [self.selectedFaces removeObjectForKey:face.objectID];
        if (self.selectedFaces.count == 0) {
            [self hideBarButtonItems];
        }
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } else {
        if (self.selectedFaces.count < [CPCollageViewController maxNumberOfCollagedFaces]) {
            CPFaceEditInformation *faceEditInformation = [[CPFaceEditInformation alloc] init];
            faceEditInformation.face = face;
            faceEditInformation.asset = nil;
            faceEditInformation.frame = CGRectMake(face.x.floatValue, face.y.floatValue, face.width.floatValue, face.height.floatValue);
            [self.selectedFaces setObject:faceEditInformation forKey:face.objectID];
            
            [self showBarButtonItems];
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"Cannot select more that %lu faces", (unsigned long)[CPCollageViewController maxNumberOfCollagedFaces]];
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Information" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }
    [self showSelectedFacesNumber];
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int number = collectionView.bounds.size.width / [CPConfig thumbnailSize];
    CGFloat width = (collectionView.bounds.size.width - (number + 1) * g_collectionViewSpacing) / number;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(g_collectionViewSpacing, g_collectionViewSpacing, g_collectionViewSpacing, g_collectionViewSpacing);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return g_collectionViewSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return g_collectionViewSpacing;
}

#pragma mark - lazy init

- (CPFacesManager *)facesManager {
    if (!_facesManager) {
        _facesManager = [[CPFacesManager alloc] init];
    }
    return _facesManager;
}

- (NSMutableArray *)fetchedResultsChangedObjects {
    if (!_fetchedResultsChangedObjects) {
        _fetchedResultsChangedObjects = [[NSMutableArray alloc] init];
    }
    return _fetchedResultsChangedObjects;
}

- (NSMutableDictionary *)selectedFaces {
    if (!_selectedFaces) {
        _selectedFaces = [[NSMutableDictionary alloc] initWithCapacity:[CPCollageViewController maxNumberOfCollagedFaces]];
    }
    return _selectedFaces;
}

- (UIBarButtonItem *)cancelBarButtonItem {
    if (!_cancelBarButtonItem) {
        _cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelBarButtonItemPressed:)];
    }
    return _cancelBarButtonItem;
}

- (UIBarButtonItem *)confirmBarButtonItem {
    if (!_confirmBarButtonItem) {
        _confirmBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.confirmButton];
    }
    return _confirmBarButtonItem;
}

- (UIButton *)confirmButton {
	if (!_confirmButton) {
		_confirmButton = [[UIButton alloc] init];
        _confirmButton.frame = CGRectMake(0.0, 0.0, 22.0, 22.0);
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:10.0];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[_confirmButton addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _confirmButton;
}

- (UILabel *)noSmileyLabel {
    if (!_noSmileyLabel) {
        _noSmileyLabel = [[UILabel alloc] init];
        _noSmileyLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:[CPConfig noSmileyLabelFontSize]];
        _noSmileyLabel.numberOfLines = 0;
        _noSmileyLabel.text = @"No Smiley Face in your Album\n\nTake photos for your Smiley Faces\nor\nimport photos from itunes";
        _noSmileyLabel.textAlignment = NSTextAlignmentCenter;
        _noSmileyLabel.textColor = [UIColor lightGrayColor];
        _noSmileyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_noSmileyLabel sizeToFit];
    }
    return _noSmileyLabel;
}

@end
