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

    self.imageView.image = [UIImage imageWithCGImage:self.face.asset.defaultRepresentation.fullScreenImage];
    self.faceIndicator.layer.borderColor = [UIColor redColor].CGColor;
    self.faceIndicator.layer.borderWidth = 1.0;
    self.faceIndicatorLeadingConstraint.constant = self.face.bounds.origin.x;
    self.faceIndicatorTopConstraint.constant = self.face.bounds.origin.y;
    self.faceIndicatorWidthConstraint.constant = self.face.bounds.size.width;
    self.faceIndicatorHeightConstraint.constant = self.face.bounds.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
