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

+ (void)removeWatermark;

+ (BOOL)isWatermarkRemoved;

+ (void)acknowledgeSmileyTapHelp;

+ (BOOL)isSmileyTapAcknowledged;

+ (void)acknowledgeCollageTapHelp;

+ (BOOL)isCollageTapAcknowledged;

+ (void)acknowledgeCollageDragHelp;

+ (BOOL)isCollageDragAcknowledged;

+ (void)acknowledgeEditDragHelp;

+ (BOOL)isEditDragAcknowledged;

+ (void)acknowledgeEditZoomHelp;

+ (BOOL)isEditZoomHelpAcknowledged;

@end
