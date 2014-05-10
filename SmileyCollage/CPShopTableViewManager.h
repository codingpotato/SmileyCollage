//
//  CPShopTableViewManager.h
//  SmileyCollage
//
//  Created by wangyw on 5/10/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPShopTableViewManager : NSObject

- (id)initWithTableView:(UITableView *)tableView dismissBlock:(void (^)())dismissBlock;

- (void)restoreCompletedTransactions;

@end
