//
//  CPUtility.h
//  Smiley
//
//  Created by wangyw on 3/26/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPUtility : NSObject

+ (NSString *)applicationDocumentsPath;

+ (NSString *)thumbnailPath;

+ (NSArray *)constraintsWithView:(id)view1 edgesAlignToView:(id)view2;
+ (NSArray *)constraintsWithView:(id)view1 centerAlignToView:(id)view2;
+ (NSArray *)constraintsWithView:(id)view1 alignToView:(id)view2 attributes:(NSLayoutAttribute)attr, ...;

+ (NSLayoutConstraint *)constraintWithView:(id)view1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr;
+ (NSLayoutConstraint *)constraintWithView:(id)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr2;

+ (NSLayoutConstraint *)constraintWithView:(id)view1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr constant:(CGFloat)c;
+ (NSLayoutConstraint *)constraintWithView:(id)view1 attribute:(NSLayoutAttribute)attr1 alignToView:(id)view2 attribute:(NSLayoutAttribute)attr2 constant:(CGFloat)c;

+ (NSLayoutConstraint *)constraintWithView:(id)view width:(CGFloat)width;
+ (NSLayoutConstraint *)constraintWithView:(id)view height:(CGFloat)height;

@end
