//
//  CPPhotoCell.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPhotoCell.h"

@interface CPPhotoCell ()

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIView *faceIndicator;
@property (strong, nonatomic) NSLayoutConstraint *leftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) NSLayoutConstraint *widthConstraint;
@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;

@end

@implementation CPPhotoCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeTopLeft;
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.imageView];
        NSArray *constraints = @[[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0], [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0], [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0], [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
        [self addConstraints:constraints];
        
        self.faceIndicator = [[UIView alloc] init];
        self.faceIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        self.faceIndicator.backgroundColor = [UIColor clearColor];
        self.faceIndicator.layer.borderColor = [UIColor redColor].CGColor;
        self.faceIndicator.layer.borderWidth = 1.0;
        [self addSubview:self.faceIndicator];
        self.leftConstraint = [NSLayoutConstraint constraintWithItem:self.faceIndicator attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0];
        self.topConstraint = [NSLayoutConstraint constraintWithItem:self.faceIndicator attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
        self.widthConstraint = [NSLayoutConstraint constraintWithItem:self.faceIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0];
        self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.faceIndicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0.0];
        [self addConstraint:self.leftConstraint];
        [self addConstraint:self.topConstraint];
        [self addConstraint:self.widthConstraint];
        [self addConstraint:self.heightConstraint];
    }
    return self;
}

- (void)setAssert:(ALAsset *)assert {
    _assert = assert;
    self.imageView.image = [UIImage imageWithCGImage:assert.thumbnail];
}

-(void)setFace:(CGRect)face {
    _face = face;
    self.leftConstraint.constant = face.origin.x;
    self.topConstraint.constant = face.origin.y;
    self.widthConstraint.constant = face.size.width;
    self.heightConstraint.constant = face.size.height;
}

@end
