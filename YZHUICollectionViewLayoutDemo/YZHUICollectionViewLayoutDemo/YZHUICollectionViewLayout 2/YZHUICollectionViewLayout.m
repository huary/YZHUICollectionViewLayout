//
//  YZHUICollectionViewLayout.m
//  易打分
//
//  Created by yuan on 2017/7/6.
//  Copyright © 2017年 yuan. All rights reserved.
//

#import "YZHUICollectionViewLayout.h"

NSString * const NSCellAlignmentKey = TYPE_STR(NSCellAlignmentKey);
NSString * const NSCollectionEdgeInsetsKey = TYPE_STR(NSCollectionEdgeInsetsKey);

@interface YZHUICollectionViewLayout ()

@property (nonatomic, assign) CGFloat lastAdjustLineSpacing;
@property (nonatomic, assign) CGRect lastItemFrame;

@property (nonatomic, assign) CGFloat totalItemHeight;
@property (nonatomic, strong) NSMutableArray *itemAttrs;

@end

@implementation YZHUICollectionViewLayout

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self _setUpDefaultValue];
    }
    return self;
}

-(void)_setUpDefaultValue
{
    _totalItemHeight = 0;
    _itemAttrs = [NSMutableArray array];
    _lastItemFrame = CGRectZero;
    _lastAdjustLineSpacing = 0;
}

-(void)prepareLayout
{
    [super prepareLayout];
    [self _setUpDefaultValue];
    

    CGFloat totalHeight = 0;
    NSInteger sectionCnt = [self.collectionView numberOfSections];
    sectionCnt = MAX(sectionCnt, 1);
    for (NSInteger section =0; section < sectionCnt; ++section) {
        NSInteger count = [self.collectionView numberOfItemsInSection:section];
        
        CGFloat sectionHeight = 0;

        for (NSInteger i = 0; i < count; ++i) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:section];
            
            UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [_itemAttrs addObject:layoutAttributes];
            
            sectionHeight = CGRectGetMaxY(layoutAttributes.frame);
        }
        
        UIEdgeInsets insets = [YZHUICollectionViewLayout _collectionViewLayout:self insetsAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:section] layoutOptions:nil];
        
        sectionHeight += insets.bottom;
        
        totalHeight += sectionHeight;
    }
    self.totalItemHeight = totalHeight;
}

-(CGSize)collectionViewContentSize
{
    CGSize size = CGSizeMake(self.collectionView.bounds.size.width, self.totalItemHeight);
    return size;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(YZHUICollectionViewLayout:layoutAttributesForItemAtIndexPath:)]) {
        return [self.delegate YZHUICollectionViewLayout:self layoutAttributesForItemAtIndexPath:indexPath];
    }
    
    UICollectionViewLayoutAttributes *layoutAttributes = [YZHUICollectionViewLayout _layoutAttributesForItem:self.delegate atIndexPath:indexPath cellItems:nil boundingRectWithSize:self.collectionView.bounds.size layoutOptions:nil layoutTarget:self];
    
    return layoutAttributes;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    return _itemAttrs;
}


+(CGSize)collectionViewSingleSectionContentSizeForCellItems:(NSArray<id<YZHUICollectionCellItemLayoutProtocol>>*)cellItems boundingRectWithSize:(CGSize)boundingRectSize layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions
{
    NSInteger i = 0;
    CGFloat totalWidth = 0;
    CGFloat totalHeight = 0;
    CGFloat maxW = 0;
    CGFloat maxH = 0;
    CGFloat minW = 0;
    CGFloat minH = 0;
    for (id<YZHUICollectionCellItemLayoutProtocol> cellItem in cellItems) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i++ inSection:0];
        UICollectionViewLayoutAttributes *layoutAttributes = nil;
        if ([cellItem respondsToSelector:@selector(layoutAttributesBlock)] && cellItem.layoutAttributesBlock) {
            layoutAttributes = cellItem.layoutAttributesBlock(nil,indexPath,cellItem);
        }
        else {
            layoutAttributes = [YZHUICollectionViewLayout _layoutAttributesForItem:cellItem atIndexPath:indexPath cellItems:cellItems boundingRectWithSize:boundingRectSize layoutOptions:layoutOptions layoutTarget:nil];
        }
        cellItem.layoutAttribute = layoutAttributes;
        totalWidth = MAX(CGRectGetMaxX(layoutAttributes.frame), totalWidth);
        totalHeight = MAX(CGRectGetMaxY(layoutAttributes.frame), totalHeight);
        maxW = MAX(maxW, CGRectGetWidth(layoutAttributes.frame));
        maxH = MAX(maxH, CGRectGetHeight(layoutAttributes.frame));
        
        minW = MIN(minW, CGRectGetWidth(layoutAttributes.frame));
        minH = MIN(minH, CGRectGetHeight(layoutAttributes.frame));
    }
    UIEdgeInsets insets = [YZHUICollectionViewLayout _collectionViewLayout:nil insetsAtIndexPath:nil layoutOptions:layoutOptions];
    totalHeight += insets.bottom + insets.top;
    totalWidth += insets.left + insets.right;
    if (boundingRectSize.width == MAXFLOAT && boundingRectSize.height == MAXFLOAT) {
        return CGSizeMake(totalWidth, totalHeight);
    }
    else if (boundingRectSize.width == MAXFLOAT) {
        return CGSizeMake(totalWidth, boundingRectSize.height);
    }
    else if (boundingRectSize.height == MAXFLOAT) {
        return CGSizeMake(boundingRectSize.width, totalHeight);
    }
    return CGSizeMake(totalWidth, totalHeight);
}


+(UICollectionViewLayoutAttributes *)_layoutAttributesForItem:(id)target atIndexPath:(NSIndexPath*)indexPath cellItems:(NSArray<id<YZHUICollectionCellItemLayoutProtocol>>*)cellItems boundingRectWithSize:(CGSize)boundingRectSize layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions layoutTarget:(YZHUICollectionViewLayout*)layoutTarget
{
    UICollectionViewLayoutAttributes *layoutAttr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGRect frame = CGRectZero;
    //获取item的size
    CGSize itemSize = [YZHUICollectionViewLayout _collectionCellItemSizeForItem:target layoutTarget:layoutTarget atIndexPath:indexPath];
    frame.size = itemSize;
    
    //获取inset
    UIEdgeInsets insets = [YZHUICollectionViewLayout _collectionViewLayout:layoutTarget insetsAtIndexPath:indexPath layoutOptions:layoutOptions];
    
    //获取minRowSpacing，minLineSpacing
    CGFloat minLineSpacing = [YZHUICollectionViewLayout _collectionCellItemLineSpacingForItem:target layoutTarget:layoutTarget atIndexPath:indexPath];
    CGFloat minRowSpacing = [YZHUICollectionViewLayout _collectionCellItemRowSpacingForItem:target layoutTarget:layoutTarget atIndexPath:indexPath];
    
    CGSize collectionViewSize = boundingRectSize;
    if (layoutTarget) {
        collectionViewSize = layoutTarget.collectionView.bounds.size;
    }
    
    CGRect lastItemFrame = [YZHUICollectionViewLayout _collectionLastItemFrameForLayoutTarget:layoutTarget cellItems:cellItems atIndexPath:indexPath];
//    if (indexPath.item == 0) {
//        lastItemFrame = CGRectMake(insets.left, insets.top, 0, 0);
//    }
//    else
//    {
//        lastItemFrame = [YZHUICollectionViewLayout _collectionLastItemFrameForLayoutTarget:layoutTarget cellItems:cellItems atIndexPath:indexPath];
//    }
    
    //定位x,y
    CGFloat originX = 0;
    CGFloat originY = 0;
    CGFloat remWidth = collectionViewSize.width - insets.left - insets.right;
    if (indexPath.item > 0) {
        remWidth = collectionViewSize.width - CGRectGetMaxX(lastItemFrame) - insets.right;
    }
    
    CGFloat adjustLineSpacing = [YZHUICollectionViewLayout _collectionLayoutAdjustLineSpacingForTarget:target layoutTarget:layoutTarget];
    
    CGFloat itemLineSpacing = minLineSpacing;
    if (adjustLineSpacing > 0) {
        itemLineSpacing = adjustLineSpacing;
    }
    
//    NSLog(@"index=%ld,remWidth=%f,itemSize.width=%f",indexPath.item,remWidth,itemSize.width);
    if (indexPath.item > 0 && remWidth >= itemSize.width + itemLineSpacing) {
        originX = CGRectGetMaxX(lastItemFrame) + itemLineSpacing;
        originY = lastItemFrame.origin.y;
    }
    else
    {
        originX = insets.left;
        originY = insets.top;//CGRectGetMaxY(lastItemFrame);
        if (indexPath.item > 0) {
            originY = CGRectGetMaxY(lastItemFrame) + minRowSpacing;
        }
        
        NSCellAlignment alignment = [YZHUICollectionViewLayout _collectionCellAlignmentForLayoutTarget:layoutTarget layoutOptions:layoutOptions];
        
        if (alignment == NSCellAlignmentCenter || alignment == NSCellAlignmentRight) {
            layoutAttr.frame = CGRectMake(originX, originY, itemSize.width, itemSize.height);
            [YZHUICollectionViewLayout _resetCollectionCellItemLayoutAttribute:layoutAttr forTarget:target layoutTarget:layoutTarget];
            
            CGPoint adjustPoint = [YZHUICollectionViewLayout _adjustRowFirstItemOrignPointForItem:target atIndexPath:indexPath cellItems:cellItems boundingRectWithSize:boundingRectSize layoutOptions:layoutOptions layoutTarget:layoutTarget];
            
            originX = adjustPoint.x;
            originY = adjustPoint.y;
        }
    }
    layoutAttr.frame = CGRectMake(originX, originY, itemSize.width, itemSize.height);
    [YZHUICollectionViewLayout _resetCollectionCellItemLayoutAttribute:layoutAttr forTarget:target layoutTarget:layoutTarget];
    return layoutAttr;
}

+(CGSize)_collectionCellItemSizeForItem:(id)target layoutTarget:(YZHUICollectionViewLayout*)layoutTarget atIndexPath:(NSIndexPath*)indexPath
{
    if ([target conformsToProtocol:@protocol(YZHUICollectionCellItemLayoutProtocol)]) {
        id<YZHUICollectionCellItemLayoutProtocol> newTarget = target;
        if (newTarget && newTarget.sizeBlock) {
            return newTarget.sizeBlock(layoutTarget, indexPath, target);
        }
    }
    else if ([layoutTarget.delegate respondsToSelector:@selector(YZHUICollectionViewLayout:sizeForItemAtIndexPath:)])
    {
        return [layoutTarget.delegate YZHUICollectionViewLayout:layoutTarget sizeForItemAtIndexPath:indexPath];
    }
    return CGSizeZero;
}

+(UIEdgeInsets)_collectionViewLayout:(YZHUICollectionViewLayout*)layoutTarget insetsAtIndexPath:(NSIndexPath*)indexPath layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([layoutTarget.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        insets = (UIEdgeInsets)[layoutTarget.delegate collectionView:layoutTarget.collectionView layout:layoutTarget insetForSectionAtIndex:indexPath.section];
    }
    else if (IS_AVAILABLE_NSSET_OBJ(layoutOptions))
    {
        insets = [[layoutOptions objectForKey:NSCollectionEdgeInsetsKey] UIEdgeInsetsValue];
    }
    return insets;
}

+(CGFloat)_collectionCellItemLineSpacingForItem:(id)target layoutTarget:(YZHUICollectionViewLayout*)layoutTarget atIndexPath:(NSIndexPath*)indexPath
{
    if ([target conformsToProtocol:@protocol(YZHUICollectionCellItemLayoutProtocol)]) {
        id<YZHUICollectionCellItemLayoutProtocol> newTarget = target;
        if (newTarget && newTarget.lineSpacingBlock) {
            return newTarget.lineSpacingBlock(layoutTarget, indexPath, target);
        }
    }
    else if (([layoutTarget.delegate respondsToSelector:@selector(YZHUICollectionViewLayout:minLineSpacingForItemAtIndexPath:)]))
    {
        return [layoutTarget.delegate YZHUICollectionViewLayout:layoutTarget minLineSpacingForItemAtIndexPath:indexPath];
    }
    return 0;
}

+(CGFloat)_collectionCellItemRowSpacingForItem:(id)target layoutTarget:(YZHUICollectionViewLayout*)layoutTarget atIndexPath:(NSIndexPath*)indexPath
{
    if ([target conformsToProtocol:@protocol(YZHUICollectionCellItemLayoutProtocol)]) {
        id<YZHUICollectionCellItemLayoutProtocol> newTarget = target;
        if (newTarget && newTarget.rowSpacingBlock) {
            return newTarget.rowSpacingBlock(layoutTarget, indexPath, target);
        }
    }
    else if (([layoutTarget.delegate respondsToSelector:@selector(YZHUICollectionViewLayout:minRowSpacingForItemAtIndexPath:)]))
    {
        return [layoutTarget.delegate YZHUICollectionViewLayout:layoutTarget minRowSpacingForItemAtIndexPath:indexPath];
    }
    return 0;
}

+(CGRect)_collectionLastItemFrameForLayoutTarget:(YZHUICollectionViewLayout*)layoutTarget cellItems:(NSArray<id<YZHUICollectionCellItemLayoutProtocol>>*)cellItems atIndexPath:(NSIndexPath*)indexPath
{
    if (layoutTarget) {
        return layoutTarget.lastItemFrame;
    }
    else
    {
        if (indexPath.item > 0) {
            NSInteger lastIndex = indexPath.item - 1;
            return [cellItems objectAtIndex:lastIndex].layoutAttribute.frame;
        }
    }
    return CGRectZero;
}

+(CGRect)_collectionItemFrameForTarget:(id)target layoutTarget:(YZHUICollectionViewLayout*)layoutTarget
{
    if ([target conformsToProtocol:@protocol(YZHUICollectionCellItemLayoutProtocol)]) {
        id<YZHUICollectionCellItemLayoutProtocol> newTarget = target;
        return newTarget.layoutAttribute.frame;
    }
    else if ([layoutTarget isKindOfClass:[YZHUICollectionViewLayout class]])
    {
        return layoutTarget.lastItemFrame;
    }
    return CGRectZero;
}

+(CGFloat)_collectionLayoutAdjustLineSpacingForTarget:(id)target layoutTarget:(YZHUICollectionViewLayout*)layoutTarget
{
    if ([target conformsToProtocol:@protocol(YZHUICollectionCellItemLayoutProtocol)]) {
        id<YZHUICollectionCellItemLayoutProtocol> newTarget = target;
        return newTarget.layoutAdjustLineSpacing;
    }
    else if ([layoutTarget isKindOfClass:[YZHUICollectionViewLayout class]])
    {
        return layoutTarget.lastAdjustLineSpacing;
    }
    return -1;
}

+(NSCellAlignment)_collectionCellAlignmentForLayoutTarget:(YZHUICollectionViewLayout*)layoutTarget layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions
{
    if (layoutTarget) {
        return layoutTarget.cellAlignment;
    }
    else if (IS_AVAILABLE_NSSET_OBJ(layoutOptions))
    {
        return [[layoutOptions objectForKey:NSCellAlignmentKey] integerValue];
    }
    return NSCellAlignmentLeft;
}

+(void)_resetCollectionCellItemLayoutAttribute:(UICollectionViewLayoutAttributes*)layoutAttribute forTarget:(id)target layoutTarget:(YZHUICollectionViewLayout*)layoutTarget
{
    if ([target conformsToProtocol:@protocol(YZHUICollectionCellItemLayoutProtocol)]) {
        id<YZHUICollectionCellItemLayoutProtocol> newTarget = target;
        newTarget.layoutAttribute = layoutAttribute;
    }
    else if ([layoutTarget isKindOfClass:[YZHUICollectionViewLayout class]])
    {
        layoutTarget.lastItemFrame = layoutAttribute.frame;
    }
}

+(CGPoint)_adjustRowFirstItemOrignPointForItem:(id)target atIndexPath:(NSIndexPath*)indexPath cellItems:(NSArray<id<YZHUICollectionCellItemLayoutProtocol>>*)cellItems boundingRectWithSize:(CGSize)boundingRectSize layoutOptions:(NSDictionary<NSString*, id>*)layoutOptions layoutTarget:(YZHUICollectionViewLayout*)layoutTarget
{
    NSInteger index = indexPath.item;
    NSInteger itemCount = 1;
    CGRect lastFrame = [YZHUICollectionViewLayout _collectionItemFrameForTarget:target layoutTarget:layoutTarget];
    CGFloat totalContentWidth = lastFrame.size.width;
    CGFloat totalLineSpacing = 0;
    
    UIEdgeInsets insets = [YZHUICollectionViewLayout _collectionViewLayout:layoutTarget insetsAtIndexPath:indexPath layoutOptions:layoutOptions];
    
    CGSize collectionViewSize = boundingRectSize;
    NSInteger itemCnt = cellItems.count;
    if (layoutTarget) {
        collectionViewSize = layoutTarget.collectionView.bounds.size;
        itemCnt = [layoutTarget.collectionView numberOfItemsInSection:indexPath.section];
    }
    
    while (YES) {
        ++index;
        if (index >= itemCnt) {
            break;
        }
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForItem:index inSection:indexPath.section];
        
        CGRect frame = CGRectZero;
        CGSize itemSize = [YZHUICollectionViewLayout _collectionCellItemSizeForItem:target layoutTarget:layoutTarget atIndexPath:indexPath];
        frame.size = itemSize;
        
        
        CGFloat minLineSpacing = [YZHUICollectionViewLayout _collectionCellItemLineSpacingForItem:target layoutTarget:layoutTarget atIndexPath:nextIndexPath];
        
        CGFloat remWidth = collectionViewSize.width - CGRectGetMaxX(lastFrame) - minLineSpacing - insets.right;
        
        if (remWidth < itemSize.width) {
            break;
        }
        lastFrame = CGRectMake(CGRectGetMaxX(lastFrame) + minLineSpacing, lastFrame.origin.y, itemSize.width, itemSize.height);
        
        totalContentWidth += itemSize.width;
        ++itemCount;
        totalLineSpacing += minLineSpacing;
    }
    
    NSCellAlignment alignment = [YZHUICollectionViewLayout _collectionCellAlignmentForLayoutTarget:layoutTarget layoutOptions:layoutOptions];

    CGFloat x = lastFrame.origin.x;
    if (alignment == NSCellAlignmentCenter) {
        x = (collectionViewSize.width - totalContentWidth)/(itemCount+1);
        if ([target conformsToProtocol:@protocol(YZHUICollectionCellItemLayoutProtocol)]) {
            id<YZHUICollectionCellItemLayoutProtocol> newTarget = target;
            newTarget.layoutAdjustLineSpacing = x;
        }
        else if (layoutTarget)
        {
            layoutTarget.lastAdjustLineSpacing = x;
        }
    }
    else if (alignment == NSCellAlignmentRight)
    {
        x = collectionViewSize.width - insets.right - totalContentWidth - totalLineSpacing;
    }
    return CGPointMake(x, lastFrame.origin.y);
}
@end
