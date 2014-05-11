//
//  CPUtility.m
//  Smiley
//
//  Created by wangyw on 3/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPUtility.h"

#import "Accelerate/Accelerate.h"

@implementation CPUtility

static NSString *g_applicationDocumentsPath = nil;
static NSString *g_thumbnailPath = nil;

+ (NSString *)applicationDocumentsPath {
    if (!g_applicationDocumentsPath) {
        g_applicationDocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    }
    return g_applicationDocumentsPath;
}

+ (NSString *)thumbnailPath {
    if (!g_thumbnailPath) {
        g_thumbnailPath = [[CPUtility applicationDocumentsPath] stringByAppendingPathComponent:@"thumbnail"];
    }
    return g_thumbnailPath;
}

+ (NSArray *)constraintsWithView:(id)view1 edgesAlignToView:(id)view2 {
    return [CPUtility constraintsWithView:view1 alignToView:view2 attributes:NSLayoutAttributeLeft, NSLayoutAttributeTop, NSLayoutAttributeRight, NSLayoutAttributeBottom, NSLayoutAttributeNotAnAttribute];
}

+ (NSArray *)constraintsWithView:(id)view1 centerAlignToView:(id)view2 {
    return [CPUtility constraintsWithView:view1 alignToView:view2 attributes:NSLayoutAttributeCenterX, NSLayoutAttributeCenterY, NSLayoutAttributeNotAnAttribute];
}

+ (NSArray *)constraintsWithView:(id)view1 alignToView:(id)view2 attributes:(NSLayoutAttribute)firstAttr, ... {
    NSMutableArray *result = [NSMutableArray array];
    
    NSLayoutAttribute eachAttr;
    va_list attrList;
    if (firstAttr != NSLayoutAttributeNotAnAttribute) {
        [result addObject:[CPUtility constraintWithView:view1 alignToView:view2 attribute:firstAttr]];
        va_start(attrList, firstAttr);
        while ((eachAttr = va_arg(attrList, NSLayoutAttribute)) != NSLayoutAttributeNotAnAttribute) {
            [result addObject:[CPUtility constraintWithView:view1 alignToView:view2 attribute:eachAttr]];
        }
        va_end(attrList);
    }
    
    return result;
}

+ (NSLayoutConstraint *)constraintWithView:(id)view1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr multiplier:1.0 constant:0.0];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr2 {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr2 multiplier:1.0 constant:0.0];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr constant:(CGFloat)c {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr multiplier:1.0 constant:c];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr2 constant:(CGFloat)c {
    return [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:NSLayoutRelationEqual toItem:view2 attribute:attr2 multiplier:1.0 constant:c];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view width:(CGFloat)width {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
}

+ (NSLayoutConstraint *)constraintWithView:(id)view height:(CGFloat)height {
    return [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:height];
}

+ (UIImage *)bluredSnapshotForView:(UIView *)view inRect:(CGRect)rect {
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:CGRectMake(-rect.origin.x, -rect.origin.y, view.bounds.size.width, view.bounds.size.height) afterScreenUpdates:NO];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self applyBlurWithRadius:25.0 tintColor:nil/*[UIColor colorWithWhite:1.0 alpha:0.1]*/ saturationDeltaFactor:1.0 toImage:snapshotImage];
}

+ (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor toImage:(UIImage *)image {
    NSAssert(image.CGImage && image.size.width > 0.0 && image.size.height > 0.0, @"");
    
    CGRect imageRect = {CGPointZero, image.size};
    UIImage *effectImage = nil;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.0) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -image.size.height);
        CGContextDrawImage(effectInContext, imageRect, image.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [UIScreen mainScreen].scale;
            unsigned int radius = floor(inputRadius * 3.0 * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix) / sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -image.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, image.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end
