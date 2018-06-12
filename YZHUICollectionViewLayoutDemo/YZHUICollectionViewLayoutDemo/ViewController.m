//
//  ViewController.m
//  YZHUICollectionViewLayoutDemo
//
//  Created by yuan on 2018/6/11.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "ViewController.h"
#import "YZHUICollectionViewLayout.h"
#import "CollectionViewCell.h"
#import "CollectionItem.h"

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource,YZHUICollectionViewLayoutDelegate>

/** 注释 */
@property (nonatomic, strong) YZHUICollectionViewLayout *layout;

/** 注释 */
@property (nonatomic, strong) UICollectionView *collectionView;

/** 注释 */
@property (nonatomic, strong) NSMutableArray<CollectionItem*> *items;

/** name */
@property (nonatomic, assign) CGSize contentSize;

/** name,0为主要的，1位normal，2位自定义 */
@property (nonatomic, assign) NSInteger type;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type > 0) {
        [self _loadData];
    }
    [self _setupChildView];
}

-(YZHUICollectionViewLayout*)layout
{
    if (_layout == nil) {
        _layout = [[YZHUICollectionViewLayout alloc] init];
        _layout.delegate = self;
    }
    return _layout;
}

-(NSMutableArray<CollectionItem*>*)items
{
    if (_items == nil) {
        _items = [NSMutableArray array];
    }
    return _items;
}

-(void)_loadData
{
    NSInteger column = 100 / 4;
    NSInteger rowIndex = 0;
    NSInteger columnIndex = 0;
    
    for (NSInteger i = 0; i < 100; ++i) {
        CollectionItem *item = [[CollectionItem alloc] init];
        if (self.type == 1) {
            item.text = NEW_STRING_WITH_FORMAT(@"%@",@(arc4random()));
            
            item.sizeBlock = ^CGSize(NSIndexPath *indexPath, id target) {
                CollectionItem *itemTmp = (CollectionItem*)target;
                CGSize size = [itemTmp.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, UI_HEIGHT(80)) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:FONT(20)} context:nil].size;
                CGSize newSize = CGSizeMake(size.width + 30, size.height);
                return newSize;
            };
            
            item.lineSpacingBlock = ^CGFloat(NSIndexPath *indexPath, id target) {
                return 15;
            };
            item.rowSpacingBlock = ^CGFloat(NSIndexPath *indexPath, id target) {
                return 25;
            };
        }
        else {
            item.text = NEW_STRING_WITH_FORMAT(@"%@",@(i+1));
            item.rowIndex = rowIndex+1;
            item.columnIndex = columnIndex+1;
            ++columnIndex;
            if (columnIndex >= column) {
                ++rowIndex;
                columnIndex = 0;
            }
            
            item.layoutAttributesBlock = ^UICollectionViewLayoutAttributes *(NSIndexPath *indexPath, id<YZHUICollectionCellItemLayoutProtocol> target) {
                CollectionItem *item = (CollectionItem*)target;
                UICollectionViewLayoutAttributes *layoutAttr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                
                
                CGFloat x = 0;
                CGFloat y = 0;
                CGFloat w = UI_WIDTH(225);
                CGFloat h = UI_HEIGHT(62);
                if (TYPE_AND(item.rowIndex, 1)) {
                    x = (item.rowIndex / 2) * UI_WIDTH(225*2+30+80) + UI_WIDTH(75);
                }
                else {
                    x = (item.rowIndex / 2 - 1) * UI_WIDTH(225*2+30+80) + UI_WIDTH(75+225+30);
                }
                
                y = UI_HEIGHT(75) + (item.columnIndex -1) * UI_HEIGHT(62 + 50);
                
                layoutAttr.frame = CGRectMake(x, y, w, h);
                
                return layoutAttr;
            };
        }
        [self.items addObject:item];
    }
    
    [self.items enumerateObjectsUsingBlock:^(CollectionItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        

    }];
    
    CGSize contentSize = [YZHUICollectionViewLayout collectionViewSingleSectionContentSizeForCellItems:self.items boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX) layoutOptions:@{NSCellAlignmentKey:@(NSCellAlignmentCenter)}];
    self.contentSize = contentSize;
}

-(UIButton*)_createButtonWithTitle:(NSString*)title frame:(CGRect)frame tag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    btn.frame = frame;
    btn.backgroundColor = RAND_COLOR;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(_btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

-(void)_btnAction:(UIButton*)sender
{
    if (sender.tag == 1) {
        ViewController *normalVC = [[ViewController alloc] init];
        normalVC.type = 1;
        [self presentViewController:normalVC animated:YES completion:nil];
    }
    else if (sender.tag == 2) {
        ViewController *customVC = [[ViewController alloc] init];
        customVC.type = 2;
        [self presentViewController:customVC animated:YES completion:nil];
    }
    else if (sender.tag == 3) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)_setupChildView
{
    if (self.type == 0) {
        
        CGFloat w = SCREEN_WIDTH * 0.8;
        CGFloat h = 40;
        
        CGFloat x = (SCREEN_WIDTH - w)/2;
        CGFloat y = SCREEN_HEIGHT/2 - 2 * h;
        
        UIButton *btn =  [self _createButtonWithTitle:@"normal" frame:CGRectMake(x, y, w, h) tag:1];
        
        y = CGRectGetMaxY(btn.frame) + h;
        btn = [self _createButtonWithTitle:@"custom" frame:CGRectMake(x, y, w, h) tag:2];
        return;
    }
    else {
    }
    self.collectionView = [[UICollectionView alloc] initWithFrame:SCREEN_BOUNDS collectionViewLayout:self.layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = WHITE_COLOR;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.contentSize  = self.contentSize;
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:NSSTRING_FROM_CLASS(CollectionViewCell)];
    [self.view addSubview:self.collectionView];
    
    UIButton *btn =  [self _createButtonWithTitle:@"关闭" frame:CGRectMake(0, 20, 80, 40) tag:3];
    
}


#pragma mark UICollectionViewDelegate, UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSSTRING_FROM_CLASS(CollectionViewCell) forIndexPath:indexPath];
    CollectionItem *item = self.items[indexPath.item];
    cell.item = item;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark YZHUICollectionViewLayoutDelegate
-(UICollectionViewLayoutAttributes*)YZHUICollectionViewLayout:(YZHUICollectionViewLayout *)layout layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionItem *item = self.items[indexPath.item];
    return item.layoutAttribute;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
