//
//  CPPhotoCell.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPhotoCell.h"

#import "CPUtility.h"

@interface CPPhotoCell ()

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIView *mask;

@property (strong, nonatomic) UIImageView *tickView;

@end

@implementation CPPhotoCell

- (void)initCell {
    [self.contentView addSubview:self.imageView];
    [self.contentView addConstraints:[CPUtility constraintsWithView:self.imageView edgesAlignToView:self.contentView]];
}

- (void)showImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    if (isSelected) {
        [self.contentView addSubview:self.mask];
        [self.contentView addConstraints:[CPUtility constraintsWithView:self.mask edgesAlignToView:self.contentView]];
        
        [self.contentView addSubview:self.tickView];
        [self.contentView addConstraints:[CPUtility constraintsWithView:self.tickView alignToView:self.contentView attributes:NSLayoutAttributeRight, NSLayoutAttributeBottom, NSLayoutAttributeNotAnAttribute]];
    } else {
        [self.mask removeFromSuperview];
        [self.tickView removeFromSuperview];
    }
}

#pragma mark - lazy init

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _imageView;
}

- (UIView *)mask {
    if (!_mask) {
        _mask = [[UIView alloc] init];
        _mask.backgroundColor = [UIColor whiteColor];
        _mask.alpha = 0.5;
        _mask.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return _mask;
}

- (UIImageView *)tickView {
    if (!_tickView) {
        _tickView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick.png"]];
        _tickView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _tickView;
}

@end
