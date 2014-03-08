//
//  CPEditViewController.m
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPEditViewController.h"

#import "CPFace.h"

@interface CPEditViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIView *faceIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faceIndicatorLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faceIndicatorTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faceIndicatorWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faceIndicatorHeightConstraint;

@end

@implementation CPEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGImageRef fullScreenImage = self.face.asset.defaultRepresentation.fullScreenImage;
    self.imageView.image = [UIImage imageWithCGImage:fullScreenImage];
    self.faceIndicator.layer.borderColor = [UIColor redColor].CGColor;
    self.faceIndicator.layer.borderWidth = 1.0;
    
    CGSize imageViewSize = self.imageView.bounds.size;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(fullScreenImage), CGImageGetHeight(fullScreenImage));
    CGFloat ratioWidth = imageViewSize.width / imageSize.width;
    CGFloat ratioHeight = imageViewSize.height / imageSize.height;
    CGFloat ratio = ratioWidth < ratioHeight ? ratioWidth : ratioHeight;
    CGFloat leftGap = ratioWidth < ratioHeight ? 0.0 : (imageViewSize.width - imageSize.width * ratio) / 2;
    CGFloat topGap = ratioWidth < ratioHeight ? (imageViewSize.height - imageSize.height * ratio) / 2 : 0.0;

    self.faceIndicatorLeadingConstraint.constant = leftGap + self.face.bounds.origin.x * ratio;
    self.faceIndicatorTopConstraint.constant = topGap + self.face.bounds.origin.y * ratio;
    self.faceIndicatorWidthConstraint.constant = self.face.bounds.size.width * ratio;
    self.faceIndicatorHeightConstraint.constant = self.face.bounds.size.height * ratio;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
