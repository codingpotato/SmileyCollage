//
//  CPPhotoCell.h
//  Smiley
//
//  Created by wangyw on 3/2/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

@interface CPPhotoCell : UICollectionViewCell

@property (nonatomic) BOOL isSelected;

- (void)initCell;

- (void)showImage:(UIImage *)image;

@end
