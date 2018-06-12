//
//  CollectionItem.h
//  YZHUICollectionViewLayoutDemo
//
//  Created by yuan on 2018/6/11.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHUICollectionViewLayout.h"

@interface CollectionItem : NSObject <YZHUICollectionCellItemLayoutProtocol>

/** <#注释#> */
@property (nonatomic, strong) NSString *text;

/** <#name#> */
@property (nonatomic, assign) NSInteger rowIndex;

/** name */
@property (nonatomic, assign) NSInteger columnIndex;

#pragma mark YZHUICollectionCellItemLayoutProtocol
@property (nonatomic, assign) CGFloat layoutAdjustLineSpacing;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *layoutAttribute;
//1
@property (nonatomic, copy) YZHUICollectionCellItemSizeBlock sizeBlock;
@property (nonatomic, copy) YZHUICollectionCellItemMinRowSpacingBlock rowSpacingBlock;
@property (nonatomic, copy) YZHUICollectionCellItemMinLineSpacingBlock lineSpacingBlock;
//2
@property (nonatomic, copy) YZHUICollectionCellItemLayoutAttributesBlock layoutAttributesBlock;

@end
