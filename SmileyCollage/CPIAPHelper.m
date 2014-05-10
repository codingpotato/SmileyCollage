//
//  CPIAPHelper.m
//  SmileyCollage
//
//  Created by wangyw on 5/10/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPIAPHelper.h"

#import "CPSettings.h"

@interface CPIAPHelper () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (weak, nonatomic) id<CPIAPHelperDelegate> delegate;

@property (strong, nonatomic) SKProductsRequest *productsRequest;

@end

@implementation CPIAPHelper

- (id)initWithDelegate:(id<CPIAPHelperDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
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

- (void)buyProductOfIndex:(NSUInteger)index {
    NSAssert(index < self.products.count, @"");
    
    SKProduct *product = self.products[index];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - SKPaymentTransactionObserver implement

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            case SKPaymentTransactionStateRestored: {
                if ([transaction.payment.productIdentifier isEqualToString:[CPSettings productNameRemoveWatermark]]) {
                    [CPSettings purchaseRemoveWatermark];
                    [self.delegate didPayProductOfIndex:0 fromIAPHelper:self];
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed: {
                if ([transaction.payment.productIdentifier isEqualToString:[CPSettings productNameRemoveWatermark]]) {
                    [self.delegate didFailPayProductOfIndex:0 withErrorMessage:transaction.error.localizedDescription fromIAPHelper:self];
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
    
    [self.delegate didReceiveProductsFromIAPHelper:self];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self.delegate didFailProductsRequestWithErrorMessage:error.localizedDescription fromIAPHelper:self];
}

@end
