//
//  CPSettings.m
//  SmileyCollage
//
//  Created by wangyw on 4/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSettings.h"

@implementation CPSettings

static NSString *g_isWatermarkRemoved = @"IsWatermarkRemoved";

static NSString *g_isSmileyTapAcknowledged = @"IsSmileyTapAcknowledged";

static NSString *g_isCollageTapAcknowledge = @"IsCollageTapAcknowledge";

static NSString *g_isCollageDragAcknowledged = @"IsCollageDragAcknowledged";

static NSString *g_isEditDragAcknowledged = @"IsEditDragAcknowledged";

static NSString *g_isEditZoomHelpAcknowledged = @"IsEditZoomHelpAcknowledged";

+ (void)registerDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{g_isWatermarkRemoved: @(NO), g_isSmileyTapAcknowledged: @(NO), g_isCollageTapAcknowledge: @(NO), g_isCollageDragAcknowledged: @(NO), g_isEditDragAcknowledged: @(NO), g_isEditZoomHelpAcknowledged: @(NO)}];
}

+ (void)reset {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isWatermarkRemoved];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isSmileyTapAcknowledged];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isCollageTapAcknowledge];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isCollageDragAcknowledged];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isEditDragAcknowledged];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isEditZoomHelpAcknowledged];
}

+ (void)removeWatermark {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isWatermarkRemoved];
}

+ (BOOL)isWatermarkRemoved {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isWatermarkRemoved];
}

+ (void)acknowledgeSmileyTapHelp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isSmileyTapAcknowledged];
}

+ (BOOL)isSmileyTapAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isSmileyTapAcknowledged];
}

+ (void)acknowledgeCollageTapHelp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isCollageTapAcknowledge];
}

+ (BOOL)isCollageTapAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isCollageTapAcknowledge];
}

+ (void)acknowledgeCollageDragHelp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isCollageDragAcknowledged];
}

+ (BOOL)isCollageDragAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isCollageDragAcknowledged];
}

+ (void)acknowledgeEditDragHelp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isEditDragAcknowledged];
}

+ (BOOL)isEditDragAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isEditDragAcknowledged];
}

+ (void)acknowledgeEditZoomHelp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isEditZoomHelpAcknowledged];
}

+ (BOOL)isEditZoomHelpAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isEditZoomHelpAcknowledged];
}

@end
