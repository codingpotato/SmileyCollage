//
//  CPIAPViewManager.m
//  SmileyCollage
//
//  Created by wangyw on 4/24/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPIAPViewManager.h"

#import <StoreKit/StoreKit.h>

#import "CPIAPCell.h"
#import "CPUtility.h"

@interface CPIAPViewManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UIView *view;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (weak, nonatomic) id<CPIAPViewManagerDelegate> delegate;

@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) SKProductsRequest *productsRequest;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation CPIAPViewManager

static NSString *g_collectionViewCellIdentifier = @"IAPCollectionViewCell";

- (id)initWithSuperview:(UIView *)superview delegate:(id<CPIAPViewManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self loadViewInSuperview:superview];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        self.productsRequest.delegate = self;
        [self.productsRequest start];
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.collectionView addSubview:self.refreshControl];
        [self.refreshControl beginRefreshing];
    }
    return self;
}

- (void)unloadView {
    [self.view removeFromSuperview];
    [self.delegate iapViewManagerUnloaded:self];
}

- (void)loadViewInSuperview:(UIView *)superview {
    self.view = [[UIView alloc] init];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [superview addSubview:self.view];
    [superview addConstraints:[CPUtility constraintsWithView:self.view edgesAlignToView:superview]];
    
    UIView *mask = [[UIView alloc] init];
    mask.backgroundColor = [UIColor blackColor];
    mask.alpha = 0.6;
    mask.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mask];
    [self.view addConstraints:[CPUtility constraintsWithView:mask edgesAlignToView:self.view]];
    
    [mask addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)]];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.collectionView registerClass:[CPIAPCell class] forCellWithReuseIdentifier:g_collectionViewCellIdentifier];
    [self.view addSubview:self.collectionView];
    [self.view addConstraints:[CPUtility constraintsWithView:self.collectionView alignToView:self.view attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom, NSLayoutAttributeNotAnAttribute]];
    [self.collectionView addConstraint:[CPUtility constraintWithView:self.collectionView height:100.0]];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    [self unloadView];
}

- (void)buyButtonTapped:(id)sender {
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = self.products[buyButton.tag];
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - UICollectionViewDataSource implement

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPIAPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:g_collectionViewCellIdentifier forIndexPath:indexPath];
    SKProduct * product = (SKProduct *)self.products[indexPath.row];
    cell.text = product.localizedTitle;
    
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    priceFormatter.formatterBehavior = NSNumberFormatterBehavior10_4;
    priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    priceFormatter.locale = product.priceLocale;
     //cell.detailTextLabel.text = [_priceFormatter stringFromNumber:product.price];*/
     
     /*if ([[RageIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
     cell.accessoryType = UITableViewCellAccessoryCheckmark;
     cell.accessoryView = nil;
     } else {*/
    UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buyButton.translatesAutoresizingMaskIntoConstraints = NO;
    buyButton.frame = CGRectMake(0, 0, 72, 37);
    [buyButton setTitle:[priceFormatter stringFromNumber:product.price] forState:UIControlStateNormal];
    [buyButton sizeToFit];
    buyButton.tag = indexPath.row;
    [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:buyButton];
    [cell.contentView addConstraint:[CPUtility constraintWithView:buyButton alignToView:cell.contentView attribute:NSLayoutAttributeCenterY]];
    [cell.contentView addConstraint:[CPUtility constraintWithView:buyButton alignToView:cell.contentView attribute:NSLayoutAttributeRight constant:-8.0]];
    //cell.accessoryType = UITableViewCellAccessoryNone;
    //cell.accessoryView = buyButton;
     //}

    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout implement

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.bounds.size.width, 100.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

#pragma mark - SKPaymentTransactionObserver implement

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                //[_purchasedProductIdentifiers addObject:productIdentifier];
                //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

#pragma mark - SKProductsRequestDelegate implement

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    [self.refreshControl endRefreshing];
    [self.collectionView reloadData];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self.refreshControl endRefreshing];
}

#pragma mark - lazy init

- (SKProductsRequest *)productsRequest {
    if (!_productsRequest) {
        NSSet *productIdentifiers = [[NSSet alloc] initWithObjects: @"codingpotato.SmileyCollage.RemoveWatermark", nil];
        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    }
    return _productsRequest;
}

@end
