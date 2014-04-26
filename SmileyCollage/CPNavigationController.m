//
//  CPNavigationController.m
//  SmileyCollage
//
//  Created by wangyw on 4/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPNavigationController.h"

@implementation CPNavigationController

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

@end
