//
//  CPUtility.m
//  Smiley
//
//  Created by wangyw on 3/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPUtility.h"

@implementation CPUtility

+ (NSString *)applicationDocumentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString *)thumbnailPath {
    return [[CPUtility applicationDocumentsPath] stringByAppendingPathComponent:@"thumbnail"];
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

@end
