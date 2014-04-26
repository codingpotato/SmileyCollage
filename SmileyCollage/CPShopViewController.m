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

@interface CPShopViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *panelView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSArray *products;

@property (strong, nonatomic) SKProductsRequest *productsRequest;

@end

@implementation CPShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.layer.cornerRadius = 2.0;
    [self.activityIndicatorView startAnimating];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    self.productsRequest.delegate = self;
    [self.productsRequest start];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)buyButtonTapped:(id)sender {
    NSUInteger index = ((UIButton *)sender).tag;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.accessoryView = self.activityIndicatorView;
    [self.activityIndicatorView startAnimating];
    
    SKProduct *product = self.products[index];
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - SKPaymentTransactionObserver implement

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored: {
                [CPSettings removeWatermark];
                // TODO: need change row:0 in the future
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.accessoryView = nil;
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:transaction.error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
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
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    self.products = response.products;
    [self.tableView reloadData];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
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

- (SKProductsRequest *)productsRequest {
    if (!_productsRequest) {
        NSSet *productIdentifiers = [[NSSet alloc] initWithObjects: @"codingpotato.SmileyCollage.RemoveWatermark", nil];
        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    }
    return _productsRequest;
}

@end
