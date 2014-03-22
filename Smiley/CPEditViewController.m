//
//  CPEditViewController.m
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPEditViewController.h"

#import "CPFace.h"
#import "CPFacesManager.h"
#import "CPPhoto.h"

@interface CPEditViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

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
    
    NSURL *url = [[NSURL alloc] initWithString:self.face.photo.url];
    [self.facesManager assertForURL:url resultBlock:^(ALAsset *result) {
        CGImageRef fullScreenImage = result.defaultRepresentation.fullScreenImage;
        self.imageView.image = [UIImage imageWithCGImage:fullScreenImage];
        self.faceIndicator.layer.borderColor = [UIColor redColor].CGColor;
        self.faceIndicator.layer.borderWidth = 1.0;
        
        CGSize imageViewSize = self.imageView.bounds.size;
        CGSize imageSize = CGSizeMake(CGImageGetWidth(fullScreenImage), CGImageGetHeight(fullScreenImage));
        CGFloat ratioWidth = imageViewSize.width / imageSize.width;
        CGFloat ratioHeight = imageViewSize.height / imageSize.height;
        if (ratioWidth < ratioHeight) {
            self.ratio = ratioWidth;
            self.imageFrame = CGRectMake(0.0, (imageViewSize.height - imageSize.height * self.ratio) / 2, imageViewSize.width, imageSize.height * self.ratio);
        } else {
            self.ratio = ratioHeight;
            self.imageFrame = CGRectMake((imageViewSize.width - imageSize.width * self.ratio) / 2, 0.0, imageSize.width * self.ratio, imageViewSize.height);
        }
        
        CGRect bounds = self.userBounds.CGRectValue;
        self.faceIndicatorLeadingConstraint.constant = self.imageFrame.origin.x + bounds.origin.x * self.ratio;
        self.faceIndicatorTopConstraint.constant = self.imageFrame.origin.y + bounds.origin.y * self.ratio;
        self.faceIndicatorWidthConstraint.constant = bounds.size.width * self.ratio;
        self.faceIndicatorHeightConstraint.constant = bounds.size.height * self.ratio;
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    CGRect bounds;
    bounds.origin.x = (self.faceIndicatorLeadingConstraint.constant - self.imageFrame.origin.x) / self.ratio;
    bounds.origin.y = (self.faceIndicatorTopConstraint.constant - self.imageFrame.origin.y) / self.ratio;
    bounds.size.width = self.faceIndicatorWidthConstraint.constant / self.ratio;
    bounds.size.height = self.faceIndicatorHeightConstraint.constant / self.ratio;
    self.userBounds = [NSValue valueWithCGRect:bounds];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    }
    pinchGesture.scale = 1.0;
}

@end
