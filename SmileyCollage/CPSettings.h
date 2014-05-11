//
//  CPSettings.h
//  SmileyCollage
//
//  Created by wangyw on 4/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPSettings : NSObject

+ (void)registerDefaults;

+ (void)reset;

+ (NSUInteger)numberOfProducts;

+ (NSSet *)productsIdentifiers;

+ (NSString *)productNameRemoveWatermark;

+ (void)purchaseRemoveWatermark;

+ (BOOL)isWatermarkRemovePurchased;

+ (void)acknowledgeSmileyTapHelp;

+ (BOOL)isSmileyTapHelpAcknowledged;

+ (void)acknowledgeCollageTapHelp;

+ (BOOL)isCollageTapHelpAcknowledged;

+ (void)acknowledgeCollageDragHelp;

+ (BOOL)isCollageDragHelpAcknowledged;

+ (void)acknowledgeEditDragHelp;

+ (BOOL)isEditDragHelpAcknowledged;

+ (void)acknowledgeEditZoomHelp;

+ (BOOL)isEditZoomHelpAcknowledged;

@end
