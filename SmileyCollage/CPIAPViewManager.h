//
//  CPIAPViewManager.h
//  SmileyCollage
//
//  Created by wangyw on 4/24/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPIAPViewManager;

@protocol CPIAPViewManagerDelegate <NSObject>

- (void)iapViewManagerUnloaded:(CPIAPViewManager *)iapViewManager;

@end

@interface CPIAPViewManager : NSObject

- (id)initWithSuperview:(UIView *)superview delegate:(id<CPIAPViewManagerDelegate>)delegate;

- (void)unloadView;

@end
