//
//  CPHelpViewManager.h
//  SmileyCollage
//
//  Created by wangyw on 4/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPHelpViewManager : NSObject

- (void)showSmileyHelpInView:(UIView *)view rect:(CGRect)rect;

- (void)showCollageHelpInView:(UIView *)view rect:(CGRect)rect;

- (void)showEditHelpInView:(UIView *)view rect:(CGRect)rect;

- (void)removeHelpView;

@end
