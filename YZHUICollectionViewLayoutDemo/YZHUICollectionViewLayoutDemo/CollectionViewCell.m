//
//  CollectionViewCell.m
//  YZHUICollectionViewLayoutDemo
//
//  Created by yuan on 2018/6/11.
//  Copyright © 2018年 yuan. All rights reserved.
//

#import "CollectionViewCell.h"
@interface CollectionViewCell ()
//UI
/** <#注释#> */
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation CollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupChildView];
    }
    return self;
}

-(void)_setupChildView
{
    self.textLabel = [UILabel new];
    self.textLabel.frame = self.bounds;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.backgroundColor = RAND_COLOR;
    [self.contentView addSubview:self.textLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}

-(void)setItem:(CollectionItem *)item
{
    _item = item;
    self.textLabel.text = item.text;
    self.textLabel.font = FONT(20);
}

@end
