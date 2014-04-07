//
//  CPPhotoCell.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPhotoCell.h"

@interface CPPhotoCell ()

@property (strong, nonatomic) UIView *selectedMask;

@end

@implementation CPPhotoCell

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        [self.contentView addSubview:self.selectedMask];
        [self pinFrameOfView:self.selectedMask];
    } else {
        [self.selectedMask removeFromSuperview];
    }
}

#pragma mark - lazy init

- (UIView *)selectedMask {
    if (!_selectedMask) {
        _selectedMask = [[UIView alloc] init];
        _selectedMask.backgroundColor = [UIColor whiteColor];
        _selectedMask.alpha = 0.5;
        _selectedMask.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _selectedMask;
}

@end
