//
//  YZHUICollectionViewLayout.h
//  易打分
//
//  Created by yuan on 2017/7/6.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NSCellAlignment)
{
    NSCellAlignmentLeft     = 0,
    NSCellAlignmentCenter   = 1,
    NSCellAlignmentRight    = 2,
};

UIKIT_EXTERN NSString * const NSCellAlignmentKey;
UIKIT_EXTERN NSString * const NSCollectionEdgeInsetsKey;


@class YZHUICollectionViewLayout;

typedef CGSize(^YZHUICollectionCellItemSizeBlock)(YZHUICollectionViewLayout *layout, NSIndexPath *indexPath,id target);
typedef CGFloat(^YZHUICollectionCellItemMinRowSpacingBlock)(YZHUICollectionViewLayout *layout, NSIndexPath *indexPath,id target);
typedef CGFloat(^YZHUICollectionCellItemMinLineSpacingBlock)(YZHUICollectionViewLayout *layout, NSIndexPath *indexPath,id target);
typedef UICollectionViewLayoutAttributes*(^YZHUICollectionCellItemLayoutAttributesBlock)(YZHUICollectionViewLayout *layout, NSIndexPath *indexPath,id target);


@protocol YZHUICollectionCellItemLayoutProtocol <NSObject>

@property (nonatomic, assign) CGFloat layoutAdjustLineSpacing;
@property (nonatomic, strong) UICollectionViewLayoutAttributes *layoutAttribute;
@property (nonatomic, copy) YZHUICollectionCellItemSizeBlock sizeBlock;
@property (nonatomic, copy) YZHUICollectionCellItemMinRowSpacingBlock rowSpacingBlock;
@property (nonatomic, copy) YZHUICollectionCellItemMinLineSpacingBlock lineSpacingBlock;
//也可以只要只要这一个
@property (nonatomic, copy) YZHUICollectionCellItemLayoutAttributesBlock layoutAttributesBlock;
@end



@protocol YZHUICollectionViewLayoutDelegate <UICollectionViewDelegateFlowLayout>
@optional
-(CGSize)YZHUICollectionViewLayout:(YZHUICollectionViewLayout*)layout sizeForItemAtIndexPath:(NSIndexPath*)indexPath;
-(CGFloat)YZHUICollectionViewLayout:(YZHUICollectionViewLayout *)layout minLineSpacingForItemAtIndexPath:(NSIndexPath*)indexPath;
-(CGFloat)YZHUICollectionViewLayout:(YZHUICollectionViewLayout *)layout minRowSpacingForItemAtIndexPath:(NSIndexPath*)indexPath;
//也可以只要如下一个接口
-(UICollectionViewLayoutAttributes*)YZHUICollectionViewLayout:(YZHUICollectionViewLayout *)layout layoutAttributesForItemAtIndexPath:(NSIndexPath*)indexPath;
@end



@interface YZHUICollectionViewLayout : UICollectionViewLayout

@property (nonatomic, assign) NSCellAlignment cellAlignment;

@property (nonatomic, weak) id <YZHUICollectionViewLayoutDelegate>delegate;

/*
 *这个boudingRectSize希望获得width或者heigh值的话，就需要传MAX_FLOAT的参数，可以两个都是MAX_FLOAT
 */
+(CGSize)collectionViewSingleSectionContentSizeForCellItems:(NSArray<id<YZHUICollectionCellItemLayoutProtocol>>*)cellItems boundingRectWithSize:(CGSize)boundingRectSize layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions;
@end
