//
//  CPIAPHelper.h
//  SmileyCollage
//
//  Created by wangyw on 5/10/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPIAPHelper;

@protocol CPIAPHelperDelegate <NSObject>

- (void)didReceiveProductsFromIAPHelper:(CPIAPHelper *)iapHelper;

- (void)didFailProductsRequestWithErrorMessage:(NSString *)errorMessage fromIAPHelper:(CPIAPHelper *)iapHelper;

- (void)didPayProductOfIndex:(NSUInteger)index fromIAPHelper:(CPIAPHelper *)iapHelper;

- (void)didFailPayProductOfIndex:(NSUInteger)index withErrorMessage:(NSString *)errorMessage fromIAPHelper:(CPIAPHelper *)iapHelper;

@end

@interface CPIAPHelper : NSObject

@property (strong, nonatomic) NSArray *products;

- (id)initWithDelegate:(id<CPIAPHelperDelegate>)delegate;

- (void)buyProductOfIndex:(NSUInteger)index;

- (void)restoreCompletedTransactions;

@end
