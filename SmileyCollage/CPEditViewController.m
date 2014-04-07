//
//  CPEditViewController.m
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPEditViewController.h"

#import "CPFaceEditInformation.h"
#import "CPUtility.h"

@interface CPEditViewController ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *faceIndicator;

@property (nonatomic) CGSize originalImageSize;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture;
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture;

@end

@implementation CPEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.faceEditInformation, @"");

    [self showImageView];
    [self showFaceIndicator];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutFaceIndicator];
    [self layoutImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self.view];
        self.imageView.frame = CGRectOffset(self.imageView.frame, translation.x, translation.y);
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        [self validateImageViewPosition];
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
    [self updateFaceFrame];
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (pinchGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat width = self.imageView.frame.size.width * pinchGesture.scale;
        CGFloat height = self.imageView.frame.size.height * pinchGesture.scale;
        CGFloat originalFaceWidth = self.faceIndicator.frame.size.width * self.originalImageSize.width / self.imageView.frame.size.width;
        CGFloat originalFaceHeight = self.faceIndicator.frame.size.height * self.originalImageSize.height / self.imageView.frame.size.height;
        static const CGFloat sizeLimitation = 10.0;
        if ((pinchGesture.scale < 1.0 && width > sizeLimitation && height > sizeLimitation) || (pinchGesture.scale > 1.0 && originalFaceWidth > sizeLimitation && originalFaceHeight > sizeLimitation)) {
            self.imageView.frame = CGRectMake(self.imageView.frame.origin.x - (width - self.imageView.frame.size.width) / 2, self.imageView.frame.origin.y - (height - self.imageView.frame.size.height) / 2, width, height);
        }
    } else if (pinchGesture.state == UIGestureRecognizerStateEnded || pinchGesture.state == UIGestureRecognizerStateCancelled || pinchGesture.state == UIGestureRecognizerStateFailed) {
        [self validateImageViewPosition];
    }
    pinchGesture.scale = 1.0;
    [self updateFaceFrame];
}

- (void)updateFaceFrame {
    CGFloat ratioX = self.originalImageSize.width / self.imageView.frame.size.width;
    CGFloat ratioY = self.originalImageSize.height / self.imageView.frame.size.height;
    self.faceEditInformation.frame = CGRectMake((self.faceIndicator.frame.origin.x - self.imageView.frame.origin.x) * ratioX, (self.faceIndicator.frame.origin.y - self.imageView.frame.origin.y) * ratioY, self.faceIndicator.frame.size.width * ratioX, self.faceIndicator.frame.size.height * ratioY);
}

- (void)showFaceIndicator {
    [self.view addSubview:self.faceIndicator];
}

- (void)layoutFaceIndicator {
    CGFloat size = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    self.faceIndicator.frame = CGRectMake((self.view.bounds.size.width - size) / 2, (self.view.bounds.size.height - size) / 2, size, size);
}

- (void)showImageView {
    CGImageRef fullScreenImage = self.faceEditInformation.asset.defaultRepresentation.fullScreenImage;
    self.originalImageSize = CGSizeMake(CGImageGetWidth(fullScreenImage), CGImageGetHeight(fullScreenImage));
    self.imageView.image = [UIImage imageWithCGImage:fullScreenImage];
    [self.view addSubview:self.imageView];
}

- (void)layoutImageView {
    CGFloat ratioWidth = self.faceIndicator.frame.size.width / self.faceEditInformation.frame.size.width;
    CGFloat ratioHeight = self.faceIndicator.frame.size.height / self.faceEditInformation.frame.size.height;
    self.imageView.frame = CGRectMake(self.faceIndicator.frame.origin.x - self.faceEditInformation.frame.origin.x * ratioWidth, self.faceIndicator.frame.origin.y - self.faceEditInformation.frame.origin.y * ratioHeight, self.originalImageSize.width * ratioWidth, self.originalImageSize.height * ratioHeight);
}

- (void)validateImageViewPosition {
    CGRect frame = self.imageView.frame;
    if (frame.size.width < self.faceIndicator.frame.size.width || frame.size.height < self.faceIndicator.frame.size.height) {
        if (frame.size.width < frame.size.height) {
            frame.size.height *= self.faceIndicator.frame.size.width / frame.size.width;
            frame.size.width = self.faceIndicator.frame.size.width;
        } else {
            frame.size.width *= self.faceIndicator.frame.size.height / frame.size.height;
            frame.size.height = self.faceIndicator.frame.size.height;
        }
    }
    if (frame.origin.x > self.faceIndicator.frame.origin.x) {
        frame = CGRectOffset(frame, self.faceIndicator.frame.origin.x - frame.origin.x, 0.0);
    }
    if (frame.origin.y > self.faceIndicator.frame.origin.y) {
        frame = CGRectOffset(frame, 0.0, self.faceIndicator.frame.origin.y - frame.origin.y);
    }
    if (frame.origin.x + frame.size.width < self.faceIndicator.frame.origin.x + self.faceIndicator.frame.size.width) {
        frame = CGRectOffset(frame, self.faceIndicator.frame.origin.x + self.faceIndicator.frame.size.width - frame.origin.x - frame.size.width, 0.0);
    }
    if (frame.origin.y + frame.size.height < self.faceIndicator.frame.origin.y + self.faceIndicator.frame.size.height) {
        frame = CGRectOffset(frame, 0.0, self.faceIndicator.frame.origin.y + self.faceIndicator.frame.size.height - frame.origin.y - frame.size.height);
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.imageView.frame = frame;
    }];
}

#pragma mark - lazy init

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (UIView *)faceIndicator {
    if (!_faceIndicator) {
        _faceIndicator = [[UIView alloc] init];
        _faceIndicator.layer.borderColor = [UIColor whiteColor].CGColor;
        _faceIndicator.layer.borderWidth = 1.0;
    }
    return _faceIndicator;
}

@end
