//
//  CPShopViewController.h
//  SmileyCollage
//
//  Created by wangyw on 4/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPShopViewController : UIViewController

@property (strong, nonatomic) void (^dismissBlock)();

- (NSArray *)glassViews;

@end
