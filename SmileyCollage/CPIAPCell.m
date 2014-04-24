//
//  CPIAPCell.m
//  SmileyCollage
//
//  Created by wangyw on 4/24/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPIAPCell.h"

#import "CPUtility.h"

@interface CPIAPCell ()

@property (strong, nonatomic) UILabel *label;

@end

@implementation CPIAPCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.label];
        [self.contentView addConstraints:[CPUtility constraintsWithView:self.label centerAlignToView:self.contentView]];
    }
    return self;
}

- (void)setText:(NSString *)text {
    self.label.text = text;
    [self.label sizeToFit];
}

#pragma mark - lazy init

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _label;
}

@end
