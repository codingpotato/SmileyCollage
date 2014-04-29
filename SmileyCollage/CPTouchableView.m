//
//  CPTouchableView.m
//  SmileyCollage
//
//  Created by wangyw on 4/29/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPTouchableView.h"

@interface CPTouchableView ()

@property (weak, nonatomic) IBOutlet id<CPTouchableViewDelegate> delegate;

@end

@implementation CPTouchableView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.delegate viewIsTouched:self];
}

@end
