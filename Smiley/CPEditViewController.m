//
//  CPEditViewController.m
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPEditViewController.h"

#import "CPFace.h"
#import "CPFaceEditInformation.h"
#import "CPFacesManager.h"
#import "CPPhoto.h"

@interface CPEditViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic) CGSize originalImageSize;

@property (weak, nonatomic) IBOutlet UIView *faceIndicator;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faceIndicatorLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faceIndicatorTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faceIndicatorWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *faceIndicatorHeightConstraint;

@property (nonatomic) CGRect imageFrame;
@property (nonatomic) CGFloat ratio;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture;
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture;

@end

@implementation CPEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.faceEditInformation, @"");
    
    CGImageRef fullScreenImage = self.faceEditInformation.asset.defaultRepresentation.fullScreenImage;
    self.originalImageSize = CGSizeMake(CGImageGetWidth(fullScreenImage), CGImageGetHeight(fullScreenImage));
    self.imageView.image = [UIImage imageWithCGImage:fullScreenImage];
    self.faceIndicator.layer.borderColor = [UIColor redColor].CGColor;
    self.faceIndicator.layer.borderWidth = 1.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [self setFaceIndicatorPosition];
    self.faceIndicator.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self setFaceIndicatorPosition];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged || panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [panGesture translationInView:self.faceIndicator];
        self.faceIndicatorLeadingConstraint.constant += translation.x;
        self.faceIndicatorTopConstraint.constant += translation.y;
        if (self.faceIndicatorLeadingConstraint.constant < self.imageFrame.origin.x) {
            self.faceIndicatorLeadingConstraint.constant = self.imageFrame.origin.x;
        }
        if (self.faceIndicatorTopConstraint.constant < self.imageFrame.origin.y) {
            self.faceIndicatorTopConstraint.constant = self.imageFrame.origin.y;
        }
        if (self.faceIndicatorLeadingConstraint.constant + self.faceIndicatorWidthConstraint.constant > self.imageFrame.origin.x + self.imageFrame.size.width) {
            self.faceIndicatorLeadingConstraint.constant = self.imageFrame.origin.x + self.imageFrame.size.width - self.faceIndicatorWidthConstraint.constant;
        }
        if (self.faceIndicatorTopConstraint.constant + self.faceIndicatorHeightConstraint.constant > self.imageFrame.origin.y + self.imageFrame.size.height) {
            self.faceIndicatorTopConstraint.constant = self.imageFrame.origin.y + self.imageFrame.size.height - self.faceIndicatorHeightConstraint.constant;
        }
        self.faceEditInformation.userBounds = [self userBoundsFromFaceIndicator];

        [panGesture setTranslation:CGPointZero inView:self.faceIndicator];
    }
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateChanged || pinchGesture.state == UIGestureRecognizerStateEnded) {
        self.faceIndicatorWidthConstraint.constant *= pinchGesture.scale;
        self.faceIndicatorHeightConstraint.constant *= pinchGesture.scale;
        if (self.faceIndicatorWidthConstraint.constant < 10.0 || self.faceIndicatorHeightConstraint.constant < 10.0 || self.faceIndicatorLeadingConstraint.constant + self.faceIndicatorWidthConstraint.constant > self.imageFrame.origin.x + self.imageFrame.size.width || self.faceIndicatorTopConstraint.constant + self.faceIndicatorHeightConstraint.constant > self.imageFrame.origin.y + self.imageFrame.size.height) {
            self.faceIndicatorWidthConstraint.constant /= pinchGesture.scale;
            self.faceIndicatorHeightConstraint.constant /= pinchGesture.scale;
        }
        self.faceEditInformation.userBounds = [self userBoundsFromFaceIndicator];
    }
    pinchGesture.scale = 1.0;
}

- (void)setFaceIndicatorPosition {
    CGSize imageViewSize = self.imageView.bounds.size;
    CGFloat ratioWidth = imageViewSize.width / self.originalImageSize.width;
    CGFloat ratioHeight = imageViewSize.height / self.originalImageSize.height;
    if (ratioWidth < ratioHeight) {
        self.ratio = ratioWidth;
        self.imageFrame = CGRectMake(0.0, (imageViewSize.height - self.originalImageSize.height * self.ratio) / 2, imageViewSize.width, self.originalImageSize.height * self.ratio);
    } else {
        self.ratio = ratioHeight;
        self.imageFrame = CGRectMake((imageViewSize.width - self.originalImageSize.width * self.ratio) / 2, 0.0, self.originalImageSize.width * self.ratio, imageViewSize.height);
    }
    
    CGRect bounds = self.faceEditInformation.userBounds;
    self.faceIndicatorLeadingConstraint.constant = self.imageFrame.origin.x + bounds.origin.x * self.ratio;
    self.faceIndicatorTopConstraint.constant = self.imageFrame.origin.y + bounds.origin.y * self.ratio;
    self.faceIndicatorWidthConstraint.constant = bounds.size.width * self.ratio;
    self.faceIndicatorHeightConstraint.constant = bounds.size.height * self.ratio;
}

- (CGRect)userBoundsFromFaceIndicator {
    return CGRectMake(
                      (self.faceIndicatorLeadingConstraint.constant - self.imageFrame.origin.x) / self.ratio,
                      (self.faceIndicatorTopConstraint.constant - self.imageFrame.origin.y) / self.ratio,
                      self.faceIndicatorWidthConstraint.constant / self.ratio,
                      self.faceIndicatorHeightConstraint.constant / self.ratio
                      );

}

@end
