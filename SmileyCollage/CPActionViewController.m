//
//  CPActionViewController.m
//  SmileyCollage
//
//  Created by wangyw on 4/29/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPActionViewController.h"

#import "CPActionSheetViewController.h"
#import "CPTouchableView.h"

@interface CPActionViewController () <CPActionSheetViewController, CPTouchableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *maskOfSaveButton;

@property (weak, nonatomic) IBOutlet UIView *maskOfShareButton;

@property (weak, nonatomic) IBOutlet UIView *maskOfCancelButton;

@end

@implementation CPActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    static const CGFloat alpha = 0.6;
    self.maskOfSaveButton.alpha = alpha;
    self.maskOfShareButton.alpha = alpha;
    self.maskOfCancelButton.alpha = alpha;
    
    static const CGFloat cornerRadius = 3.0;
    self.maskOfSaveButton.layer.cornerRadius = cornerRadius;
    self.maskOfShareButton.layer.cornerRadius = cornerRadius;
    self.maskOfCancelButton.layer.cornerRadius = cornerRadius;
}

#pragma mark - CPActionSheetViewController implement

- (NSArray *)glassViews {
    return @[self.maskOfSaveButton, self.maskOfShareButton, self.maskOfCancelButton];
}

#pragma mark - CPTouchableViewDelegate implement

- (void)viewIsTouched:(CPTouchableView *)view {
    [self performSegueWithIdentifier:@"CPActionViewControlerUnwindSegue" sender:nil];
}

@end
