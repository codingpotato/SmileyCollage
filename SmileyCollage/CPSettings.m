//
//  CPSettings.m
//  SmileyCollage
//
//  Created by wangyw on 4/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSettings.h"

@implementation CPSettings

static NSString *g_isSmileyTapAcknowledged = @"IsSmileyTapAcknowledged";

static NSString *g_isCollageTapAcknowledge = @"IsCollageTapAcknowledge";

static NSString *g_isCollageDragAcknowledged = @"IsCollageDragAcknowledged";

static NSString *g_isEditDragAcknowledged = @"IsEditDragAcknowledged";

static NSString *g_isEditZoomHelpAcknowledged = @"IsEditZoomHelpAcknowledged";

static NSSet *g_productsIdentifiers = nil;

+ (void)registerDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{[self productNameRemoveWatermark]: @(NO), g_isSmileyTapAcknowledged: @(NO), g_isCollageTapAcknowledge: @(NO), g_isCollageDragAcknowledged: @(NO), g_isEditDragAcknowledged: @(NO), g_isEditZoomHelpAcknowledged: @(NO)}];
}

+ (void)reset {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self productNameRemoveWatermark]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isSmileyTapAcknowledged];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isCollageTapAcknowledge];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isCollageDragAcknowledged];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isEditDragAcknowledged];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isEditZoomHelpAcknowledged];
}

+ (NSUInteger)numberOfProducts {
    return [self productsIdentifiers].count;
}

+ (NSSet *)productsIdentifiers {
    if (!g_productsIdentifiers) {
        g_productsIdentifiers = [[NSSet alloc] initWithObjects:[self productNameRemoveWatermark], nil];
    }
    return g_productsIdentifiers;
}

+ (NSString *)productNameRemoveWatermark {
    return @"codingpotato.SmileyCollage.RemoveWatermark";
}

+ (void)purchaseRemoveWatermark {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[self productNameRemoveWatermark]];
}

+ (BOOL)isWatermarkRemovePurchased {
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self productNameRemoveWatermark]];
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
