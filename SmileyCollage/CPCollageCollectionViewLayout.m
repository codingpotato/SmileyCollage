//
//  CPCollageCollectionViewLayout.m
//  SmileyCollage
//
//  Created by wangyw on 5/17/14.
//  Copyright (c) 2014 codingpotato. All rights reserved.
//

#import "CPCollageCollectionViewLayout.h"

@interface CPCollageCollectionViewLayout ()

@property (weak, nonatomic) IBOutlet id<CPCollageCollectionViewLayoutDataSource> dataSource;

@property (nonatomic) CGSize contentSize;

@property (strong, nonatomic) NSArray *itemAttributes;

@end

@implementation CPCollageCollectionViewLayout

- (void)prepareLayout {
    [self calculateContentSize];
    
    NSMutableArray *itemAttributes = [[NSMutableArray alloc] initWithCapacity:[self.collectionView numberOfItemsInSection:0]];
    NSUInteger leftSpace = roundf((self.contentSize.width - [self totalImageWidth]) / 2);
    NSUInteger topSpace = roundf((self.contentSize.height - [self totalImageHeight]) / 2);
    CGFloat x = leftSpace;
    CGFloat y = topSpace;
    NSUInteger index = 0;
    NSUInteger height = [self totalImageHeight];
    NSUInteger row = 0;
    NSArray *numberOfColumnsInRows = [self.dataSource numberOfColumnsInRowsForCollectionView:self.collectionView];
    for (NSNumber *number in numberOfColumnsInRows) {
        NSUInteger rowHeight = 0;
        if (row < numberOfColumnsInRows.count - 1) {
            rowHeight = roundf([self totalImageWidth] / number.floatValue);
            height -= rowHeight;
        } else {
            // use remain height, not calculated height
            rowHeight = height;
        }
        NSUInteger width = [self totalImageWidth];
        for (NSUInteger column = 0; column < number.integerValue; ++column) {
            NSUInteger faceWidth = 0;
            if (column < number.integerValue - 1) {
                faceWidth = roundf(width / (number.floatValue - column));
                width -= faceWidth;
            } else {
                // use remain width, not calculated width
                faceWidth = width;
            }
            UICollectionViewLayoutAttributes *layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            layoutAttributes.frame = CGRectMake(x, y, faceWidth, rowHeight);
            [itemAttributes addObject:layoutAttributes];
            
            x += faceWidth;
            index++;
        }
        
        x = leftSpace;
        y += rowHeight;
        row++;
    }

    self.itemAttributes = [itemAttributes copy];
}

- (CGSize)collectionViewContentSize {
    return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.itemAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    return NO;
}

- (CGRect)imageFrame {
    NSUInteger leftSpace = roundf((self.contentSize.width - [self totalImageWidth]) / 2);
    NSUInteger topSpace = roundf((self.contentSize.height - [self totalImageHeight]) / 2);
    return CGRectMake(leftSpace, topSpace, [self totalImageWidth], [self totalImageHeight]);
}

- (void)calculateContentSize {
    CGSize contentSize = self.collectionView.bounds.size;
    contentSize.height -= [self.dataSource topInsetForCollectionView:self.collectionView];
    self.contentSize = contentSize;
}

- (CGFloat)contentWidthHeightRatio {
    return self.contentSize.width / self.contentSize.height;
}

- (NSUInteger)totalImageWidth {
    CGFloat imageWidthHeightRatio = [self.dataSource imageWidthHeightRatioForCollectionView:self.collectionView];
    if ([self contentWidthHeightRatio] < imageWidthHeightRatio) {
        return roundf(self.contentSize.width);
    } else {
        return roundf(self.contentSize.height * imageWidthHeightRatio);
    }
}

- (NSUInteger)totalImageHeight {
    CGFloat imageWidthHeightRatio = [self.dataSource imageWidthHeightRatioForCollectionView:self.collectionView];
    if ([self contentWidthHeightRatio] < imageWidthHeightRatio) {
        return roundf(self.contentSize.width / imageWidthHeightRatio);
    } else {
        return roundf(self.contentSize.height);
    }
}

@end
