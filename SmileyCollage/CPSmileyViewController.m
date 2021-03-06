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

@interface CPSmileyViewController () <NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) CPFacesManager *facesManager;

@property (strong, nonatomic) NSMutableDictionary *selectedFaces;

@property (strong, nonatomic) CPHelpViewManager *helpViewManager;

@property (strong, nonatomic) NSMutableArray *fetchedResultsChangedObjects;

@property (strong, nonatomic) UIBarButtonItem *cancelBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *confirmBarButtonItem;
@property (strong, nonatomic) UIButton *confirmButton;

@property (strong, nonatomic) UILabel *introductionLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;

@end

@implementation CPSmileyViewController

static NSString *g_collageViewControllerSegueName = @"CPCollageViewControllerSegue";

static const CGFloat g_animationDuration = 0.3;

static const CGFloat g_collectionViewSpacing = 1.0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];

    self.facesManager.facesController.delegate = self;
    [self updateTitle];
    
    [self hideToolbar];
    [self showToolbarWithAnimation];
    [self.facesManager scanFaces];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showSelectedFacesNumberOnConfirmButton];
    if (self.collectionView.visibleCells.count > 0) {
        [self showHelpView];
    } else {
        [self showIntroductionLabel];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self removeHelpView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.progressView.superview.frame;
    frame.size.width = self.toolbar.bounds.size.width - frame.origin.x * 2;
    self.progressView.superview.frame = frame;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:g_collageViewControllerSegueName]) {
        CPCollageViewController *collageViewController = (CPCollageViewController *)segue.destinationViewController;
        collageViewController.facesManager = self.facesManager;
        collageViewController.collagedFaces = [self.selectedFaces.allValues mutableCopy];
    }
}

- (void)handleApplicationDidBecomeActiveNotification:(NSNotification *)notification {
    [self.facesManager addObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfScannedPhotos)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    [self.facesManager addObserver:self forKeyPath:NSStringFromSelector(@selector(isScanning)) options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    if (self.facesManager.isScanCancelled) {
        [self showToolbarWithAnimation];
        // pop to smiley view controller to indicate user the scan status
        if (self.navigationController.topViewController != self) {
            [self.navigationController popToViewController:self animated:NO];
        }
        [self.facesManager scanFaces];
    }
}

- (void)handleApplicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self.facesManager removeObserver:self forKeyPath:NSStringFromSelector(@selector(numberOfScannedPhotos))];
    [self.facesManager removeObserver:self forKeyPath:NSStringFromSelector(@selector(isScanning))];
    
    [self hideToolbar];
    [self.facesManager stopScan];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(numberOfScannedPhotos))]) {
        NSNumber *oldValue = change[NSKeyValueChangeOldKey];
        NSNumber *newValue = change[NSKeyValueChangeNewKey];
        if (![oldValue isEqual:newValue]) {
            [self.progressView setProgress:newValue.floatValue / self.facesManager.numberOfTotalPhotos animated:YES];
            self.informationLabel.text = [NSString stringWithFormat:CPLocalizedString(@"CPScanStatus"), newValue.intValue, (int)self.facesManager.numberOfTotalPhotos];
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(isScanning))]) {
        NSNumber *oldValue = change[NSKeyValueChangeOldKey];
        NSNumber *newValue = change[NSKeyValueChangeNewKey];
        if (!oldValue.boolValue && newValue.boolValue) {
            [self showToolbarWithAnimation];
        } else if (oldValue.boolValue && !newValue.boolValue) {
            [self hideToolbarWithAnimation];
        }
    }
}

- (void)showToolbarWithAnimation {
    self.progressView.progress = 0.0;
    self.informationLabel.text = CPLocalizedString(@"CPScanning");
    self.toolbarBottomConstraint.constant = 0.0;
    [UIView animateWithDuration:g_animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideToolbarWithAnimation {
    self.toolbarBottomConstraint.constant = self.toolbar.bounds.size.height;
    [UIView animateWithDuration:g_animationDuration delay:10.0 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)hideToolbar {
    self.toolbarBottomConstraint.constant = self.toolbar.bounds.size.height;
    [self.view layoutIfNeeded];
}

- (void)showSelectedFacesNumberOnConfirmButton {
    [self.confirmButton setTitle:[[NSString alloc] initWithFormat:@"%d", (int)self.selectedFaces.count] forState:UIControlStateNormal];
    if (self.selectedFaces.count > 9) {
        [self.confirmButton setImage:[UIImage imageNamed:@"confirm-2.png"] forState:UIControlStateNormal];
        self.confirmButton.titleEdgeInsets = [CPConfig confirmButtonTitleEdgeInsetsForTwoDigits];
    } else {
        [self.confirmButton setImage:[UIImage imageNamed:@"confirm-1.png"] forState:UIControlStateNormal];
        self.confirmButton.titleEdgeInsets = [CPConfig confirmButtonTitleEdgeInsetsForOneDigit];
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

- (void)cancelBarButtonItemPressed:(id)sender {
    self.selectedFaces = nil;
    [self hideBarButtonItems];
    [self.collectionView reloadData];
}

- (void)confirmButtonPressed:(id)sender {
    [self performSegueWithIdentifier:g_collageViewControllerSegueName sender:nil];
}

- (void)updateTitle {
    self.navigationItem.title = [NSString stringWithFormat:@"%@: %lu", CPLocalizedString(@"CPSmileyViewControllerTitle"), (unsigned long)self.facesManager.facesController.fetchedObjects.count];
}

- (void)showReachSelectLimitationAlert {
    NSString *title = [[NSString alloc] initWithFormat:CPLocalizedString(@"CPReachSelectLimitation"), (int)[CPCollageViewController maxNumberOfSmiley]];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:CPLocalizedString(@"CPOK"), nil];
    [alertView show];
}

#pragma mark - handle introduction label

- (void)showIntroductionLabel {
    if (!self.introductionLabel) {
        self.introductionLabel = [[UILabel alloc] init];
        
        NSString *title = CPLocalizedString(@"CPIntroductionTitle");
        NSString *labelText = [title stringByAppendingString:CPLocalizedString(@"CPIntroductionText")];
        NSRange titleRange = [labelText rangeOfString:title];
        
        NSMutableParagraphStyle *allParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        allParagraphStyle.alignment = NSTextAlignmentNatural;
        allParagraphStyle.lineSpacing = [CPConfig introductionLineSpacing];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{ NSFontAttributeName: [UIFont fontWithName:[CPConfig helpFontName] size:[CPConfig introductionTextFontSize]],NSForegroundColorAttributeName: [UIColor lightGrayColor], NSParagraphStyleAttributeName: allParagraphStyle}];
        
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:[CPConfig helpFontName] size:[CPConfig introductionTitleFontSize]] range:titleRange];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:titleRange];
        
        self.introductionLabel.attributedText = attributedString;
        self.introductionLabel.numberOfLines = 0;
        self.introductionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.introductionLabel sizeToFit];
        [self.view addSubview:self.introductionLabel];
        [self.view addConstraints:[CPUtility constraintsWithView:self.introductionLabel centerAlignToView:self.view]];
        [self.introductionLabel addConstraint:[CPUtility constraintWithView:self.introductionLabel width:[CPConfig introductionLabelWidth]]];
        
        self.introductionLabel.alpha = 0.0;
        [UIView animateWithDuration:g_animationDuration animations:^{
            self.introductionLabel.alpha = 1.0;
        }];
    }    
}

- (void)removeIntroductionLabel {
    if (self.introductionLabel) {
        [UIView animateWithDuration:g_animationDuration animations:^{
            self.introductionLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.introductionLabel removeFromSuperview];
            self.introductionLabel = nil;
        }];
    }
}

#pragma mark - handle help view

- (void)showHelpView {
    if (!self.helpViewManager) {
        self.helpViewManager = [[CPHelpViewManager alloc] init];
        [self.helpViewManager showSmileyHelpInSuperview:self.view];
    }
}

- (void)removeHelpView {
    if (self.helpViewManager) {
        [self.helpViewManager removeHelpView];
        self.helpViewManager = nil;
    }
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
    
    // check and remove selected faces
    for (NSManagedObjectID *objectID in [self.selectedFaces allKeys]) {
        if (![self.facesManager isObjectExisting:objectID]) {
            [self.selectedFaces removeObjectForKey:objectID];
            if (self.navigationController.topViewController != self) {
                [self.navigationController popToViewController:self animated:NO];
            }
        }
    }
    if (self.selectedFaces.count > 0) {
        [self showSelectedFacesNumberOnConfirmButton];
    } else {
        [self hideBarButtonItems];
    }

    [self updateTitle];
    if (controller.fetchedObjects.count == 0) {
        [self showIntroductionLabel];
        [self removeHelpView];
    } else {
        [self removeIntroductionLabel];
        [self showHelpView];
    }
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.facesManager.facesController.fetchedObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CPPhotoCell" forIndexPath:indexPath];
    
    CPFace *face = [self.facesManager.facesController.fetchedObjects objectAtIndex:indexPath.row];
    [cell showImage:[self.facesManager thumbnailOfFace:face]];
    if ([self.selectedFaces objectForKey:face.objectID]) {
        [cell select];
    } else {
        [cell unselect];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate implement

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [CPSettings acknowledgeSmileyTapHelp];
    
    NSAssert(indexPath.row >= 0 && indexPath.row < self.facesManager.facesController.fetchedObjects.count, @"");
    CPFace *face = [self.facesManager.facesController.fetchedObjects objectAtIndex:indexPath.row];
    NSAssert(face, @"");

    if ([self.selectedFaces objectForKey:face.objectID]) {
        [self.selectedFaces removeObjectForKey:face.objectID];
        if (self.selectedFaces.count == 0) {
            [self hideBarButtonItems];
        }
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } else {
        if (self.selectedFaces.count == 0) {
            [self showBarButtonItems];
        }
        if (self.selectedFaces.count < [CPCollageViewController maxNumberOfSmiley]) {
            CPFaceEditInformation *faceEditInformation = [[CPFaceEditInformation alloc] init];
            faceEditInformation.face = face;
            faceEditInformation.asset = nil;
            faceEditInformation.frame = CGRectMake(face.x.floatValue, face.y.floatValue, face.width.floatValue, face.height.floatValue);
            [self.selectedFaces setObject:faceEditInformation forKey:face.objectID];
            
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        } else {
            [self showReachSelectLimitationAlert];
        }
    }
    [self showSelectedFacesNumberOnConfirmButton];
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

- (NSMutableDictionary *)selectedFaces {
    if (!_selectedFaces) {
        _selectedFaces = [[NSMutableDictionary alloc] initWithCapacity:[CPCollageViewController maxNumberOfSmiley]];
    }
    return _selectedFaces;
}

- (NSMutableArray *)fetchedResultsChangedObjects {
    if (!_fetchedResultsChangedObjects) {
        _fetchedResultsChangedObjects = [[NSMutableArray alloc] init];
    }
    return _fetchedResultsChangedObjects;
}

- (UIBarButtonItem *)cancelBarButtonItem {
    if (!_cancelBarButtonItem) {
        _cancelBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CPLocalizedString(@"CPCancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelBarButtonItemPressed:)];
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
        _confirmButton.frame = CGRectMake(0.0, 0.0, 32.0, 25.0);
        _confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:[CPConfig confirmButtonTitleFontSize]];
        [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[_confirmButton addTarget:self action:@selector(confirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	}
	return _confirmButton;
}

@end
