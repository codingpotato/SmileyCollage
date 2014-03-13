//
//  CPFacesController.h
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPFacesController : NSObject

@property (strong, nonatomic) NSMutableArray *faces;

@property (strong, nonatomic) NSMutableArray *selectedFaces;

+ (CPFacesController *)defaultController;

- (void)detectFacesWithRefreshBlock:(void (^)(void))refreshBlock;

- (void)selectFaceByIndex:(NSUInteger)index;

- (void)exchangeSelectedFacesByIndex1:(NSUInteger)index1 withIndex2:(NSUInteger)index2;

- (void)saveStitchedImage;

@end
