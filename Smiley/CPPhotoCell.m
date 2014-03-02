//
//  CPPhotoCell.m
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPPhotoCell.h"

@interface CPPhotoCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CPPhotoCell

- (void)setAssert:(ALAsset *)assert {
    _assert = assert;
    self.imageView.image = [UIImage imageWithCGImage:assert.thumbnail];
}

@end
