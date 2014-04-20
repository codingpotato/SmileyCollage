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

@interface CPSmileyViewController ()

@property (strong, nonatomic) CPHelpViewManager *helpViewManager;

@property (strong, nonatomic) CPFacesManager *facesManager;

@property (strong, nonatomic) NSMutableDictionary *selectedFaces;

@property (nonatomic) BOOL isScanCancelled;

@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *confirmBarButtonItem;
@property (strong, nonatomic) UIButton *confirmButton;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *notificationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notificationViewBottomConstraint;

@end

@implementation CPSmileyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    self.navigationItem.title = [NSString stringWithFormat:@"Smiley: %lu", (unsigned long)self.facesManager.facesController.fetchedObjects.count];
    
    self.isScanCancelled = NO;
    self.facesManager.facesController.delegate = self;
    [self showNotificationViewWithAnimation];
    [self.facesManager scanFaces];
    
    if (self.facesManager.facesController.fetchedObjects.count > 0) {
        [self.helpViewManager showSmileyHelpWithDelayInView:self.view];
    } else {
        [self.helpViewManager showSmileyNotFoundHelpWithDelayInView:self.view];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showSelectedFacesNumber];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.helpViewManager = nil;
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
        [self showNotificationViewWithAnimation];
        [self.facesManager scanFaces];
        self.isScanCancelled = NO;
    }
}

- (void)handleApplicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self.facesManager removeObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfScannedPhotos))];
    [self.facesManager removeObserver:self forKeyPath:NSStringFromSelector(@selector(isScanning))];
    
    [self hideNotificationView];
    
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
            self.message.text = [NSString stringWithFormat:@"Scanned %d of %d photos", (int)self.facesManager.numberOfScannedPhotos, (int)self.facesManager.numberOfTotalPhotos];
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(isScanning))]) {
        NSNumber *oldValue = change[NSKeyValueChangeOldKey];
        NSNumber *newValue = change[NSKeyValueChangeNewKey];
        if (oldValue.boolValue && !newValue.boolValue) {
            [self hideNotificationViewWithAnimation];
        }
    }
}

- (void)showNotificationViewWithAnimation {
    self.progressView.progress = 0.0;
    self.message.text = @"Scanning photos......";
    self.notificationViewBottomConstraint.constant = 0.0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideNotificationView {
    self.notificationViewBottomConstraint.constant = self.notificationView.bounds.size.height;
    [self.view layoutIfNeeded];
}

- (void)hideNotificationViewWithAnimation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
        self.notificationViewBottomConstraint.constant = self.notificationView.bounds.size.height;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    });
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

#pragma mark - NSFetchedResultsControllerDelegate implement

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    self.navigationItem.title = [NSString stringWithFormat:@"Smiley: %d", (int)controller.fetchedObjects.count];
    [self.collectionView reloadData];
    
    if (controller.fetchedObjects.count > 0) {
        [self.helpViewManager removeSmileyNotFoundHelp];
    } else {
        [self.helpViewManager showSmileyNotFoundHelpWithDelayInView:self.view];
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
    cell.isSelected = [self.selectedFaces objectForKey:face.objectID];
    
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
    CGFloat width = (collectionView.bounds.size.width - (number + 1) * 1.0) / number;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(1.0, 1.0, 1.0, 1.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0;
}

#pragma mark - lazy init

- (CPHelpViewManager *)helpViewManager {
    if (!_helpViewManager) {
        _helpViewManager = [[CPHelpViewManager alloc] init];
    }
    return _helpViewManager;
}

- (CPFacesManager *)facesManager {
    if (!_facesManager) {
        _facesManager = [[CPFacesManager alloc] init];
    }
    return _facesManager;
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

@end
