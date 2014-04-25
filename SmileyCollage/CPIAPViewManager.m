//
//  CPIAPViewManager.m
//  SmileyCollage
//
//  Created by wangyw on 4/24/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPIAPViewManager.h"

#import <StoreKit/StoreKit.h>

#import "CPSettings.h"
#import "CPUtility.h"

@interface CPMaskView : UIView

@property (weak, nonatomic) NSObject *target;

@property (nonatomic) SEL action;

- (id)initWithTarget:(NSObject *)target action:(SEL)action;

@end

@implementation CPMaskView

- (id)initWithTarget:(NSObject *)target action:(SEL)action {
    self = [super init];
    if (self) {
        self.alpha = 0.8;
        self.backgroundColor = [UIColor blackColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.target = target;
        self.action = action;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // remove warning by add after delay parameter
    // because ARC doesn't know if the returned id has a +1 retain count or not
    // and therefore can't properly manage the memory of the returned object.
    [self.target performSelector:self.action withObject:nil afterDelay:0];
}

@end

@interface CPIAPViewManager () <SKPaymentTransactionObserver, SKProductsRequestDelegate, UITableViewDataSource>

@property (weak, nonatomic) id<CPIAPViewManagerDelegate> delegate;

@property (strong, nonatomic) UIView *view;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) SKProductsRequest *productsRequest;

@end

@implementation CPIAPViewManager

static NSString *g_collectionViewCellIdentifier = @"IAPCollectionViewCell";

- (id)initWithSuperview:(UIView *)superview delegate:(id<CPIAPViewManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        [self loadViewInSuperview:superview];
        
        [self.refreshControl beginRefreshing];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        self.productsRequest.delegate = self;
        [self.productsRequest start];
    }
    return self;
}

- (void)unloadView {
    [self.view removeFromSuperview];
    [self.delegate iapViewManagerUnloaded:self];
}

- (void)loadViewInSuperview:(UIView *)superview {
    [superview addSubview:self.view];
    [superview addConstraints:[CPUtility constraintsWithView:self.view edgesAlignToView:superview]];
    
    CPMaskView *maskView = [[CPMaskView alloc] initWithTarget:self action:@selector(unloadView)];
    [self.view addSubview:maskView];
    [self.view addConstraints:[CPUtility constraintsWithView:maskView edgesAlignToView:self.view]];
    
    [self.view addSubview:self.tableView];
    [self.view addConstraints:[CPUtility constraintsWithView:self.tableView alignToView:self.view attributes:NSLayoutAttributeLeft, NSLayoutAttributeRight, NSLayoutAttributeBottom, NSLayoutAttributeNotAnAttribute]];
    [self.tableView addConstraint:[CPUtility constraintWithView:self.tableView height:self.tableView.rowHeight]];

    [self.tableView addSubview:self.refreshControl];
}

- (void)buyButtonTapped:(id)sender {
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = self.products[buyButton.tag];
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKPaymentTransactionObserver implement

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored:
                [CPSettings removeWatermark];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed: {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Erroe" message:transaction.error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                [alertView show];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - SKProductsRequestDelegate implement

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.products = response.products;
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Erroe" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
    [self.refreshControl endRefreshing];
}

#pragma mark - UITableViewDataSource implement

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CPIAPTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    SKProduct *product = (SKProduct *)self.products[indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = product.localizedDescription;

    if ([CPSettings isWatermarkRemoved]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.tag = indexPath.row;
        buyButton.layer.borderColor = buyButton.tintColor.CGColor;
        buyButton.layer.borderWidth = 1.0;
        buyButton.layer.cornerRadius = 2.0;

        NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
        priceFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        priceFormatter.locale = product.priceLocale;
        [buyButton setTitle:[priceFormatter stringFromNumber:product.price] forState:UIControlStateNormal];
        [buyButton sizeToFit];
        CGRect frame = buyButton.frame;
        frame.size.width += 16.0;
        buyButton.frame = frame;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    return cell;
}

#pragma mark - lazy init

- (UIView *)view {
    if (!_view) {
        _view = [[UIView alloc] init];
        _view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _view;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.rowHeight = 60.0;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tableView;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
    }
    return _refreshControl;
}

- (SKProductsRequest *)productsRequest {
    if (!_productsRequest) {
        NSSet *productIdentifiers = [[NSSet alloc] initWithObjects: @"codingpotato.SmileyCollage.RemoveWatermark", nil];
        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    }
    return _productsRequest;
}

@end
