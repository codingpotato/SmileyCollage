//
//  CPCell.m
//  Smiley
//
//  Created by wangyw on 3/22/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCell.h"

#import "CPUtility.h"

@interface CPCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation CPCell

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    if (!self.imageView.superview) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addConstraints:[CPUtility constraintsWithView:self.imageView edgesAlignToView:self.contentView]];
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

@end
