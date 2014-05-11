//
//  CPSettings.m
//  SmileyCollage
//
//  Created by wangyw on 4/7/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPSettings.h"

@implementation CPSettings

static NSString *g_isSmileyTapHelpAcknowledged = @"SmileyTapHelpAcknowledged";

static NSString *g_isCollageTapHelpAcknowledge = @"CollageTapHelpAcknowledge";

static NSString *g_isCollageDragHelpAcknowledged = @"CollageDragHelpAcknowledged";

static NSString *g_isEditDragHelpAcknowledged = @"EditDragHelpAcknowledged";

static NSString *g_isEditZoomHelpAcknowledged = @"EditZoomHelpAcknowledged";

static NSSet *g_productsIdentifiers = nil;

+ (void)registerDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              [self productNameRemoveWatermark]: @(NO),
                                                              g_isSmileyTapHelpAcknowledged: @(NO),
                                                              g_isCollageTapHelpAcknowledge: @(NO),
                                                              g_isCollageDragHelpAcknowledged: @(NO),
                                                              g_isEditDragHelpAcknowledged: @(NO),
                                                              g_isEditZoomHelpAcknowledged: @(NO)
                                                              }];
}

+ (void)reset {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self productNameRemoveWatermark]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isSmileyTapHelpAcknowledged];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isCollageTapHelpAcknowledge];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isCollageDragHelpAcknowledged];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:g_isEditDragHelpAcknowledged];
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
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isSmileyTapHelpAcknowledged];
}

+ (BOOL)isSmileyTapHelpAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isSmileyTapHelpAcknowledged];
}

+ (void)acknowledgeCollageTapHelp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isCollageTapHelpAcknowledge];
}

+ (BOOL)isCollageTapHelpAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isCollageTapHelpAcknowledge];
}

+ (void)acknowledgeCollageDragHelp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isCollageDragHelpAcknowledged];
}

+ (BOOL)isCollageDragHelpAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isCollageDragHelpAcknowledged];
}

+ (void)acknowledgeEditDragHelp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isEditDragHelpAcknowledged];
}

+ (BOOL)isEditDragHelpAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isEditDragHelpAcknowledged];
}

+ (void)acknowledgeEditZoomHelp {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:g_isEditZoomHelpAcknowledged];
}

+ (BOOL)isEditZoomHelpAcknowledged {
    return [[NSUserDefaults standardUserDefaults] boolForKey:g_isEditZoomHelpAcknowledged];
}

@end
