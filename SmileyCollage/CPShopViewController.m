//
//  CPIAPViewController.m
//  SmileyCollage
//
//  Created by wangyw on 4/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPShopViewController.h"

#import <StoreKit/StoreKit.h>

#import "CPSettings.h"
#import "CPUtility.h"

@class CPMaskView;

@protocol CPMaskViewDelegate <NSObject>

- (void)maskViewTouched:(CPMaskView *)maskView;

@end

@interface CPMaskView : UIView

@property (weak, nonatomic) IBOutlet id<CPMaskViewDelegate> delegate;

@end

@implementation CPMaskView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate maskViewTouched:self];
}

@end

/*
 * only support one product "Remove Watermark" now
 */
@interface CPShopViewController () <CPMaskViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate, UIAlertViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *restoreButton;

@property (weak, nonatomic) IBOutlet UIView *maskOfTableView;

@property (weak, nonatomic) IBOutlet UIView *maskOfRestoreButton;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) SKProductsRequest *productsRequest;

@property (strong, nonatomic) UIButton *currentBuyButton;

- (IBAction)doneBarButtonPressed:(id)sender;

- (IBAction)restoreButtonPressed:(id)sender;

@end

@implementation CPShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    static const CGFloat cornerRadius = 3.0;
    //self.tableView.layer.cornerRadius = cornerRadius;
    // self.restoreButton.layer.cornerRadius = cornerRadius;
    self.maskOfTableView.layer.cornerRadius = cornerRadius;
    self.maskOfRestoreButton.layer.cornerRadius = cornerRadius;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [CPSettings purchaseRemoveWatermark];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[CPSettings productsIdentifiers]];
    self.productsRequest.delegate = self;
    [self.productsRequest start];

    [self showActivityIndicatorViewOnView:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.productsRequest) {
        [self.productsRequest cancel];
        self.productsRequest.delegate = nil;
        self.productsRequest = nil;
    }
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
    [self hideActivityIndicatorView];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)doneBarButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)restoreButtonPressed:(id)sender {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    [self showActivityIndicatorViewOnView:self.restoreButton];
}

- (void)buyButtonPressed:(id)sender {
    self.currentBuyButton = sender;
    NSUInteger index = self.currentBuyButton.tag;
    NSAssert(index < self.products.count, @"");
    
    SKProduct *product = self.products[index];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSAssert(cell, @"");
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.accessoryView = activityIndicatorView;
    [activityIndicatorView startAnimating];
    
    [self setButtonsEnable:NO];
}

- (void)showActivityIndicatorViewOnView:(UIView *)view {
    [self setButtonsEnable:NO];
    
    self.activityIndicatorView.center = view.center;
    [self.panelView addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}

- (void)hideActivityIndicatorView {
    [self setButtonsEnable:YES];
    
    if (self.activityIndicatorView.isAnimating) {
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
    }
}

- (void)setButtonsEnable:(BOOL)enable {
    self.restoreButton.enabled = enable;

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell) {
        UIView *view = cell.accessoryView;
        if ([view isMemberOfClass:[UIButton class]]) {
            ((UIButton *)view).enabled = enable;
        }
    }
}

#pragma mark - CPMaskViewDelegate implement

- (void)maskViewTouched:(CPMaskView *)maskView {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SKPaymentTransactionObserver implement

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored: {
                if ([transaction.payment.productIdentifier isEqualToString:[CPSettings productNameRemoveWatermark]]) {
                    [CPSettings purchaseRemoveWatermark];
                    
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.accessoryView = nil;
                    
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    
                    [self hideActivityIndicatorView];
                }
                break;
            }
            case SKPaymentTransactionStateFailed: {
                if ([transaction.payment.productIdentifier isEqualToString:[CPSettings productNameRemoveWatermark]]) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Issue" message:transaction.error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    [alertView show];
                    
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    NSAssert(self.currentBuyButton, @"");
                    cell.accessoryView = self.currentBuyButton;
                    self.currentBuyButton = nil;
                    
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                    
                    [self hideActivityIndicatorView];
                }
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
    [self.tableView reloadData];
    
    self.productsRequest.delegate = nil;
    self.productsRequest = nil;
    
    [self hideActivityIndicatorView];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Issue" message:error.localizedDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
    
    [self hideActivityIndicatorView];
}

#pragma mark - UIAlertViewDelegate implement

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self.navigationController popViewControllerAnimated:YES];
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
    
    NSAssert(self.products, @"");
    NSAssert(indexPath.row >= 0 && indexPath.row < self.products.count, @"");
    
    SKProduct *product = (SKProduct *)self.products[indexPath.row];
    cell.textLabel.text = product.localizedTitle;
    cell.detailTextLabel.text = product.localizedDescription;
    
    if ([CPSettings isWatermarkRemovePurchased]) {
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
        [buyButton addTarget:self action:@selector(buyButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    return cell;
}

#pragma mark - lazy init

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicatorView;
}

@end
