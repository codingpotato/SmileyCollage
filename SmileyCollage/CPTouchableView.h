//
//  CPTouchableView.h
//  SmileyCollage
//
//  Created by wangyw on 4/29/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@class CPTouchableView;

@protocol CPTouchableViewDelegate <NSObject>

- (void)viewIsTouched:(CPTouchableView *)view;

@end

@interface CPTouchableView : UIView

@end
