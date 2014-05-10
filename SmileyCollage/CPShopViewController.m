//
//  CPShopViewController.m
//  SmileyCollage
//
//  Created by wangyw on 4/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPShopViewController.h"

#import "CPIAPHelper.h"
#import "CPSettings.h"
#import "CPTouchableView.h"
#import "CPUtility.h"

/*
 * only support one product "Remove Watermark" now
 */
@interface CPShopViewController () <CPIAPHelperDelegate, CPTouchableViewDelegate, UIAlertViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) CPIAPHelper *iapHelper;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) UIButton *currentBuyButton;

@property (weak, nonatomic) IBOutlet UIView *maskOfTableView;

@property (weak, nonatomic) IBOutlet UIView *maskOfCancelButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)restoreButtonPressed:(id)sender;

@end

@implementation CPShopViewController

static NSString * g_shopViewControllerUnwindSegueName = @"CPShopViewControllerUnwindSegue";

static const NSUInteger g_numberOfIAPItems = 1;

- (NSArray *)glassViews {
    return @[self.maskOfTableView, self.maskOfCancelButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    static const CGFloat alpha = 0.7;
    self.maskOfTableView.alpha = alpha;
    self.maskOfCancelButton.alpha = alpha;
    
    static const CGFloat cornerRadius = 3.0;
    self.maskOfTableView.layer.cornerRadius = cornerRadius;
    self.maskOfCancelButton.layer.cornerRadius = cornerRadius;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSAssert(cell, @"");
    [self showActivityIndicatorViewOnView:cell];
    
    NSAssert(!self.iapHelper, @"");
    self.iapHelper = [[CPIAPHelper alloc] initWithDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideActivityIndicatorView];
    
    NSAssert(self.iapHelper, @"");
    self.iapHelper = nil;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)restoreButtonPressed:(id)sender {
    [self showActivityIndicatorViewOnView:self.restoreButton];
}

- (void)buyButtonPressed:(id)sender {
    self.currentBuyButton = sender;
    NSUInteger index = self.currentBuyButton.tag;
    NSAssert(index < self.iapHelper.products.count, @"");
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    NSAssert(cell, @"");
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.accessoryView = activityIndicatorView;
    [activityIndicatorView startAnimating];
    
    [self setButtonsEnable:NO];
}

- (void)showActivityIndicatorViewOnView:(UIView *)view {
    [self setButtonsEnable:NO];
    
    self.activityIndicatorView.center = [self.view convertPoint:view.center fromView:view.superview];
    [self.view addSubview:self.activityIndicatorView];
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
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:g_numberOfIAPItems inSection:0]];
    NSAssert(cell, @"");
    NSAssert(cell.contentView.subviews > 0, @"");
    UIButton *restoreButton = [cell.contentView.subviews objectAtIndex:0];
    NSAssert(restoreButton, @"");
    return restoreButton;
}

#pragma mark - CPIAPHelperDelegate implement

- (void)didReceiveProductsFromIAPHelper:(CPIAPHelper *)iapHelper {
    [self hideActivityIndicatorView];
    [self.tableView reloadData];
}

- (void)didFailProductsRequestWithErrorMessage:(NSString *)errorMessage fromIAPHelper:(CPIAPHelper *)iapHelper {
    [self hideActivityIndicatorView];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Issue" message:errorMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
}

- (void)didPayProductOfIndex:(NSUInteger)index fromIAPHelper:(CPIAPHelper *)iapHelper {
    NSAssert(index == 0, @"");
    [self hideActivityIndicatorView];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSAssert(cell, @"");
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.accessoryView = nil;
}

- (void)didFailPayProductOfIndex:(NSUInteger)index withErrorMessage:(NSString *)errorMessage fromIAPHelper:(CPIAPHelper *)iapHelper {
    NSAssert(index == 0, @"");
    [self hideActivityIndicatorView];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSAssert(cell, @"");
    cell.accessoryType = UITableViewCellAccessoryNone;
    NSAssert(self.currentBuyButton, @"");
    cell.accessoryView = self.currentBuyButton;
    self.currentBuyButton = nil;

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Issue" message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    [alertView show];
}

#pragma mark - CPTouchableViewDelegate implement

- (void)viewIsTouched:(CPTouchableView *)view {
    [self performSegueWithIdentifier:g_shopViewControllerUnwindSegueName sender:nil];
}

#pragma mark - UIAlertViewDelegate implement

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [self performSegueWithIdentifier:g_shopViewControllerUnwindSegueName sender:nil];
}

#pragma mark - UITableViewDataSource implement

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // add 1 for restore button
    return g_numberOfIAPItems + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row < g_numberOfIAPItems) {
        static NSString *CellIdentifier = @"CPIAPItemCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        if (self.iapHelper.products.count > 0) {
            NSAssert(indexPath.row >= 0 && indexPath.row < self.iapHelper.products.count, @"");
            
            SKProduct *product = (SKProduct *)self.iapHelper.products[indexPath.row];
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
    } else if (indexPath.row == g_numberOfIAPItems) {
        static NSString *CellIdentifier = @"CPRestoreButtonCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    NSAssert(cell, @"");
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
