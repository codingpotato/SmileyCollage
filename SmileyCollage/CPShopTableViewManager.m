//
//  CPShopTableViewManager.m
//  SmileyCollage
//
//  Created by wangyw on 5/10/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPShopTableViewManager.h"

#import "CPSettings.h"

/*
 * only support one product "Remove Watermark" now
 */
@interface CPShopTableViewManager () <UIAlertViewDelegate, UITableViewDataSource, SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (weak, nonatomic) UITableView *tableView;

@property (strong, nonatomic) void (^dismissBlock)();

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) UIButton *currentBuyButton;

@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) SKProductsRequest *productsRequest;

@end

@implementation CPShopTableViewManager

- (id)initWithTableView:(UITableView *)tableView dismissBlock:(void (^)())dismissBlock {
    self = [super init];
    if (self) {
        self.tableView = tableView;
        self.dismissBlock = dismissBlock;
        
        self.tableView.dataSource = self;
        [self.tableView reloadData];

        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSAssert(cell, @"");
        [self showActivityIndicatorViewOnView:cell];

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[CPSettings productsIdentifiers]];
        self.productsRequest.delegate = self;
        [self.productsRequest start];
    }
    return self;
}

- (void)dealloc {
    if (self.productsRequest) {
        [self.productsRequest cancel];
        self.productsRequest.delegate = nil;
    }
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)restoreCompletedTransactions {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[CPSettings numberOfProducts] inSection:0]];
    NSAssert(cell, @"");
    [self showActivityIndicatorViewOnView:cell];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)buyButtonPressed:(id)sender {
    self.currentBuyButton = sender;
    NSUInteger index = self.currentBuyButton.tag;
    NSAssert(index < self.products.count, @"");
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSAssert(cell, @"");
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.accessoryView = activityIndicatorView;
    [activityIndicatorView startAnimating];
    
    [self setButtonsEnable:NO];

    SKProduct *product = self.products[index];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)showActivityIndicatorViewOnView:(UIView *)view {
    [self setButtonsEnable:NO];
    
    self.activityIndicatorView.center = view.center;
    [self.tableView addSubview:self.activityIndicatorView];
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
    NSAssert(cell, @"");
    if (cell) {
        UIView *view = cell.accessoryView;
        if ([view isMemberOfClass:[UIButton class]]) {
            ((UIButton *)view).enabled = enable;
        }
    }
}

- (UIButton *)restoreButton {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[CPSettings numberOfProducts] inSection:0]];
    NSAssert(cell, @"");
    NSAssert(cell.contentView.subviews > 0, @"");
    UIButton *restoreButton = [cell.contentView.subviews objectAtIndex:0];
    NSAssert(restoreButton, @"");
    return restoreButton;
}

#pragma mark - UIAlertViewDelegate implement

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.dismissBlock();
}

#pragma mark - UITableViewDataSource implement

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // add 1 for restore button
    return [CPSettings numberOfProducts] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row < [CPSettings numberOfProducts]) {
        static NSString *CellIdentifier = @"CPIAPItemCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        if (self.products.count > 0) {
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
        }
    } else if (indexPath.row == [CPSettings numberOfProducts]) {
        static NSString *CellIdentifier = @"CPRestoreButtonCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    NSAssert(cell, @"");
    return cell;
}

#pragma mark - SKPaymentTransactionObserver implement

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored: {
                if ([transaction.payment.productIdentifier isEqualToString:[CPSettings productNameRemoveWatermark]]) {
                    [CPSettings purchaseRemoveWatermark];

                    [self hideActivityIndicatorView];                    
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    NSAssert(cell, @"");
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.accessoryView = nil;
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                if ([transaction.payment.productIdentifier isEqualToString:[CPSettings productNameRemoveWatermark]]) {
                    [self hideActivityIndicatorView];
                    
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    NSAssert(cell, @"");
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    NSAssert(self.currentBuyButton, @"");
                    cell.accessoryView = self.currentBuyButton;
                    self.currentBuyButton = nil;
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Issue" message:transaction.error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    [alertView show];
                }
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
    self.productsRequest.delegate = nil;
    self.productsRequest = nil;

    [self hideActivityIndicatorView];
    [self.tableView reloadData];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self hideActivityIndicatorView];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Issue" message:error.localizedDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
}

#pragma mark - lazy init

- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityIndicatorView;
}

@end
