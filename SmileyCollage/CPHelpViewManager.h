//
//  CPHelpViewManager.h
//  SmileyCollage
//
//  Created by wangyw on 4/18/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPHelpViewManager : NSObject

- (void)showSmileyHelpInSuperview:(UIView *)superview;

- (void)showCollageHelpInSuperview:(UIView *)superview;

- (void)showEditHelpInSuperview:(UIView *)superview;

- (void)removeHelpView;

@end
