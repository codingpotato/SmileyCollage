//
//  CPPopoverShopViewController.m
//  SmileyCollage
//
//  Created by wangyw on 5/10/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPopoverShopViewController.h"

#import "CPShopTableViewManager.h"

@interface CPPopoverShopViewController ()

@property (strong, nonatomic) CPShopTableViewManager *shopTableViewManager;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CPPopoverShopViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.preferredContentSize = CGSizeMake(320.0, 88.0);
    self.shopTableViewManager = [[CPShopTableViewManager alloc] initWithTableView:self.tableView dismissBlock:self.dismissBlock];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    self.shopTableViewManager = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)restoreButtonPressed:(id)sender {
    NSAssert(self.shopTableViewManager, @"");
    
    [self.shopTableViewManager restoreCompletedTransactions];
}

@end
