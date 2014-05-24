//
//  CPEditViewController.m
//  Smiley
//
//  Created by wangyw on 3/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPEditViewController.h"

#import "CPFaceEditInformation.h"
#import "CPHelpViewManager.h"
#import "CPSettings.h"
#import "CPUtility.h"

@interface CPEditViewController ()

@property (strong, nonatomic) CPHelpViewManager *helpViewManager;

@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) UIView *faceIndicator;
@property (strong, nonatomic) UIView *maskView1;
@property (strong, nonatomic) UIView *maskView2;

@property (nonatomic) CGSize originalImageSize;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture;

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture;

@end

@implementation CPEditViewController

static const CGFloat g_maskViewAlpha = 0.5;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSAssert(self.faceEditInformation, @"");

    [self showImageView];
    [self showFaceIndicator];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showHelpView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideHelpView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self hideHelpView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // face insicator should be layout first
    [self layoutFaceIndicator];
    [self layoutImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [self hideHelpView];
}

- (CGRect)faceIndicatorFrame {
    CGFloat size = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
    return CGRectMake((self.view.bounds.size.width - size) / 2, (self.view.bounds.size.height - size) / 2, size, size);
}

- (UIView *)faceSnapshot {
    CGRect frame = [self.imageView convertRect:self.faceIndicator.frame fromView:self.view];
    return [self.imageView resizableSnapshotViewFromRect:frame afterScreenUpdates:NO withCapInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    [CPSettings acknowledgeEditDragHelp];
    
    if (panGesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [panGesture translationInView:self.view];
        self.imageView.frame = CGRectOffset(self.imageView.frame, translation.x, translation.y);
    } else if (panGesture.state == UIGestureRecognizerStateEnded || panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateFailed) {
        [self validateImageViewPosition];
    }
    [panGesture setTranslation:CGPointZero inView:self.view];
    [self updateFaceEditInformation];
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    [CPSettings acknowledgeEditZoomHelp];
    
    if (pinchGesture.state == UIGestureRecognizerStateChanged) {
        CGFloat width = self.imageView.frame.size.width * pinchGesture.scale;
        CGFloat height = self.imageView.frame.size.height * pinchGesture.scale;
        static const CGFloat minSize = 20.0;
        if ((pinchGesture.scale < 1.0 && width > minSize && height > minSize) || (pinchGesture.scale > 1.0 && self.faceEditInformation.frame.size.width > minSize && self.faceEditInformation.frame.size.height > minSize)) {
            CGFloat centerX = self.faceIndicator.frame.origin.x + self.faceIndicator.frame.size.width / 2;
            CGFloat centerY = self.faceIndicator.frame.origin.y + self.faceIndicator.frame.size.height / 2;
            CGFloat dx = (self.imageView.frame.size.width - width) * (centerX - self.imageView.frame.origin.x) / self.imageView.frame.size.width;
            CGFloat dy = (self.imageView.frame.size.height - height) * (centerY - self.imageView.frame.origin.y) / self.imageView.frame.size.height;
            self.imageView.frame = CGRectMake(self.imageView.frame.origin.x + dx, self.imageView.frame.origin.y + dy, width, height);
        }
    } else if (pinchGesture.state == UIGestureRecognizerStateEnded || pinchGesture.state == UIGestureRecognizerStateCancelled || pinchGesture.state == UIGestureRecognizerStateFailed) {
        [self validateImageViewPosition];
    }
    pinchGesture.scale = 1.0;
    [self updateFaceEditInformation];
}

- (void)updateFaceEditInformation {
    CGFloat ratioX = self.originalImageSize.width / self.imageView.frame.size.width;
    CGFloat ratioY = self.originalImageSize.height / self.imageView.frame.size.height;
    self.faceEditInformation.frame = CGRectMake((self.faceIndicator.frame.origin.x - self.imageView.frame.origin.x) * ratioX,
                                                (self.faceIndicator.frame.origin.y - self.imageView.frame.origin.y) * ratioY,
                                                self.faceIndicator.frame.size.width * ratioX,
                                                self.faceIndicator.frame.size.height * ratioY);
}

#pragma mark - handle face indicator

- (void)showFaceIndicator {
    NSAssert(!self.faceIndicator.superview, @"");
    NSAssert(!self.maskView1.superview, @"");
    NSAssert(!self.maskView2.superview, @"");
    
    [self.view addSubview:self.faceIndicator];
    [self.view addSubview:self.maskView1];
    [self.view addSubview:self.maskView2];
}

- (void)layoutFaceIndicator {
    CGRect faceIndicatorFrame = self.faceIndicatorFrame;
    self.faceIndicator.frame = faceIndicatorFrame;

    [UIView performWithoutAnimation:^{
        if (faceIndicatorFrame.size.width == self.view.bounds.size.width) {
            self.maskView1.frame = CGRectMake(0.0, 0.0, faceIndicatorFrame.size.width, faceIndicatorFrame.origin.y);
            self.maskView2.frame = CGRectMake(0.0, faceIndicatorFrame.origin.y + faceIndicatorFrame.size.height, faceIndicatorFrame.size.width, self.view.bounds.size.height - faceIndicatorFrame.origin.y - faceIndicatorFrame.size.height);
        } else if (faceIndicatorFrame.size.height == self.view.bounds.size.height) {
            self.maskView1.frame = CGRectMake(0.0, 0.0, faceIndicatorFrame.origin.x, faceIndicatorFrame.size.height);
            self.maskView2.frame = CGRectMake(faceIndicatorFrame.origin.x + faceIndicatorFrame.size.width, 0.0, self.view.bounds.size.width - faceIndicatorFrame.origin.x - faceIndicatorFrame.size.width, faceIndicatorFrame.size.height);
        } else {
            NSAssert(NO, @"");
        }
    }];
}

#pragma mark - handle image view

- (void)showImageView {
    NSAssert(!self.imageView.superview, @"");
    
    CGImageRef fullScreenImage = self.faceEditInformation.asset.defaultRepresentation.fullScreenImage;
    self.originalImageSize = CGSizeMake(CGImageGetWidth(fullScreenImage), CGImageGetHeight(fullScreenImage));
    self.imageView.image = [UIImage imageWithCGImage:fullScreenImage];
    [self.view addSubview:self.imageView];
}

- (void)layoutImageView {
    NSAssert(self.faceIndicator.frame.size.width > 0 && self.faceIndicator.frame.size.height > 0, @"face indicator should be layout first");
    
    CGFloat ratioWidth = self.faceIndicator.frame.size.width / self.faceEditInformation.frame.size.width;
    CGFloat ratioHeight = self.faceIndicator.frame.size.height / self.faceEditInformation.frame.size.height;
    self.imageView.frame = CGRectMake(self.faceIndicator.frame.origin.x - self.faceEditInformation.frame.origin.x * ratioWidth,
                                      self.faceIndicator.frame.origin.y - self.faceEditInformation.frame.origin.y * ratioHeight,
                                      self.originalImageSize.width * ratioWidth,
                                      self.originalImageSize.height * ratioHeight);
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

#pragma mark - handle help view

- (void)showHelpView {
    self.helpViewManager = [[CPHelpViewManager alloc] init];
    [self.helpViewManager showEditHelpInView:self.view rect:self.faceIndicator.frame];
}

- (void)hideHelpView {
    if (self.helpViewManager) {
        [self.helpViewManager removeHelpView];
        self.helpViewManager = nil;
    }
}

#pragma mark - lazy init

- (CPHelpViewManager *)helpViewManager {
    if (!_helpViewManager) {
        _helpViewManager = [[CPHelpViewManager alloc] init];
    }
    return _helpViewManager;
}

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
        _faceIndicator.layer.borderWidth = [UIScreen mainScreen].scale;
    }
    return _faceIndicator;
}

- (UIView *)maskView1 {
    if (!_maskView1) {
        _maskView1 = [[UIView alloc] init];
        _maskView1.backgroundColor = [UIColor blackColor];
        _maskView1.alpha = g_maskViewAlpha;
    }
    return _maskView1;
}

- (UIView *)maskView2 {
    if (!_maskView2) {
        _maskView2 = [[UIView alloc] init];
        _maskView2.backgroundColor = [UIColor blackColor];
        _maskView2.alpha = g_maskViewAlpha;
    }
    return _maskView2;
}

@end
