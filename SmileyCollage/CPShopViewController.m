//
//  CPShopViewController.m
//  SmileyCollage
//
//  Created by wangyw on 4/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPShopViewController.h"

#import "CPShopTableViewManager.h"
#import "CPTouchableView.h"

@interface CPShopViewController () <CPTouchableViewDelegate>

@property (strong, nonatomic) CPShopTableViewManager *shopTableViewManager;

@property (weak, nonatomic) IBOutlet UIView *maskOfTableView;

@property (weak, nonatomic) IBOutlet UIView *maskOfCancelButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)restoreButtonPressed:(id)sender;

- (IBAction)cancelButtonPressed:(id)sender;

@end

@implementation CPShopViewController

- (NSArray *)glassViews {
    return @[self.maskOfTableView, self.maskOfCancelButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    static const CGFloat alpha = 0.7;
    self.maskOfTableView.alpha = alpha;
    self.maskOfCancelButton.alpha = alpha;
    
    static const CGFloat cornerRadius = 5.0;
    self.maskOfTableView.layer.cornerRadius = cornerRadius;
    self.maskOfCancelButton.layer.cornerRadius = cornerRadius;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.shopTableViewManager = [[CPShopTableViewManager alloc] initWithTableView:self.tableView dismissBlock:self.dismissBlock];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.shopTableViewManager = nil;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)restoreButtonPressed:(id)sender {
    [self.shopTableViewManager restoreCompletedTransactions];
}

- (IBAction)cancelButtonPressed:(id)sender {
    self.dismissBlock();
}

#pragma mark - CPTouchableViewDelegate implement

- (void)viewIsTouched:(CPTouchableView *)view {
    self.dismissBlock();
}

@end
