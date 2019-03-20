//
//  ExcelView.m
//  Excel
//
//  Created by iosdev on 16/3/29.
//  Copyright © 2016年 Doer. All rights reserved.
//

#import "ExcelView.h"
#import "Excel.h"
#import "UIView+additional.h"

@interface ExcelView () {
    //    LeftTableView* leftTableView;
    //    _topCollectionView* _topCollectionView;
    //    ContentTableView *contentTbaleView;
    UIView* vertexView;
}
@end

@implementation ExcelView

@synthesize leftWidth, topHeight, contentWidth, contentHeight;

- (void)dealloc
{
    [_leftTableView removeObserver:self forKeyPath:Excel_leftTableViewContentOffset];
    [self.contentTbaleView removeObserver:self forKeyPath:Excel_contentTableViewContentOffset];
    [_topCollectionView removeObserver:self forKeyPath:Excel_topCollectionViewContentOffset];
    [self.contentTbaleView removeObserver:self forKeyPath:Excel_collectionViewContentOffset];
    
    [_leftTableView removeObserver:self forKeyPath:Excel_seletedPath];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [[UIColor colorWithRed:0xe5 / 255.0 green:0xe5 / 255.0 blue:0xe5 / 255.0 alpha:1.0] CGColor];
        self.layer.cornerRadius = 1.0f;
        self.layer.borderWidth = 1.0f;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00];
        leftWidth = LeftWidth;
        topHeight = TopHeight;
        contentWidth = ContentWidth;
        contentHeight = ContentHeight;
        
        self.contentTbaleView = [[ContentTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        
        self.contentTbaleView.backgroundColor = [UIColor clearColor];
        
        self.contentTbaleView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentTbaleView.excelView = self;
        [self addSubview:self.contentTbaleView]; //UIViewAutoresizingFlexibleLeftMargin |
        [self.contentTbaleView addObserver:self forKeyPath:Excel_contentTableViewContentOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self.contentTbaleView addObserver:self forKeyPath:Excel_collectionViewContentOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
        _leftTableView = [[LeftTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _leftTableView.showsVerticalScrollIndicator = NO;
        _leftTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _leftTableView.excelView = self;
        //leftTableViewCell 的背景颜色就是 分割线的颜色
        _leftTableView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:(0x90 / 255.0)green:(0x90 / 255.0)blue:(0x90 / 255.0)alpha:1];
        _leftTableView.layer.borderWidth = 1.0f;
        
        _leftTableView.layer.borderColor = [UIColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.00].CGColor;
        //        self.layer.borderWidth = 1.0f;
        //        [self borderForColor:[UIColor redColor] borderWidth:1.0f borderType:UIBorderSideTypeRight];
        _leftTableView.clipsToBounds = YES;
        [self addSubview:_leftTableView];
        
        
        vertexView = [[UIView alloc] initWithFrame:CGRectZero];
        vertexView.backgroundColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.80 alpha:1.00];
        vertexView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:vertexView];
        
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 1.0f;
        layout.minimumInteritemSpacing = 0.5f;
        layout.itemSize = CGSizeMake(contentWidth, topHeight);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _topCollectionView = [[TopCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _topCollectionView.showsHorizontalScrollIndicator = NO;
        _topCollectionView.showsVerticalScrollIndicator = NO;
        _topCollectionView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _topCollectionView.excelView = self;
        _topCollectionView.backgroundColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.80 alpha:1.00];
        _topCollectionView.layer.borderColor = [UIColor colorWithRed:0.99 green:0.79 blue:0.80 alpha:1.00].CGColor;
        //        self.layer.cornerRadius = 1.0f;
        _topCollectionView.layer.borderWidth = 1.0f;
        _topCollectionView.clipsToBounds = YES;
        [self addSubview:_topCollectionView];
        [_topCollectionView addObserver:self forKeyPath:Excel_topCollectionViewContentOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        
      
//        [self borderForColor:[UIColor redColor] borderWidth:1.0f borderType:UIBorderSideTypeRight];
//        [self borderForView:leftTableView color:[UIColor redColor] borderWidth:1.0f borderType:UIBorderSideTypeRight | UIBorderSideTypeBottom];
        [_leftTableView addObserver:self forKeyPath:Excel_leftTableViewContentOffset options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_leftTableView addObserver:self forKeyPath:Excel_seletedPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}



- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context{
    
    if ([keyPath isEqualToString:Excel_leftTableViewContentOffset]) {
        self.contentTbaleView.contentOffset = _leftTableView.contentOffset;
        NSLog(@"self.contentTbaleView.contentOffset=%f",self.contentTbaleView.contentOffset.x);
    }
    else if ([keyPath isEqualToString:Excel_contentTableViewContentOffset]) {
        _leftTableView.contentOffset = self.contentTbaleView.contentOffset;
    }
    else if ([keyPath isEqualToString:Excel_topCollectionViewContentOffset]) {
        self.contentTbaleView.topOffset = _topCollectionView.contentOffset;
    }
    else if ([keyPath isEqualToString:Excel_collectionViewContentOffset]) {
        _topCollectionView.contentOffset = [self.contentTbaleView.collectionViewContentOffset CGPointValue];
    }
    else if ([keyPath isEqualToString:Excel_seletedPath]) {
        self.contentTbaleView.seletedPath = _leftTableView.seletedPath;
    }
}

- (void)layoutSubviews
{
    
    [super layoutSubviews];
    CGFloat superWidth = self.bounds.size.width;
    CGFloat superHeight = self.bounds.size.height;
    vertexView.frame = CGRectMake(0, 0, leftWidth, topHeight+2);
    _leftTableView.frame = CGRectMake(0, topHeight, leftWidth, superHeight - topHeight + 1);
//    _leftTableView.frame = CGRectMake(0, topHeight, leftWidth, self.leftCount * 50);
    _topCollectionView.frame = CGRectMake(leftWidth , 0, superWidth - leftWidth + 1, topHeight+2);
    self.contentTbaleView.frame = CGRectMake(leftWidth, topHeight+1, superWidth - leftWidth + 1, superHeight - topHeight);

}

- (void)reloadData
{
    [_topCollectionView reloadData];
    [_leftTableView reloadData];
    [self.contentTbaleView reloadData];
}
- (void)reload_topCollectionViewData
{
    [_topCollectionView reloadData];
}
- (void)reloadLeftTableViewData
{
    [_leftTableView reloadData];
}
- (void)reloadContentTbaleViewData
{
    [self.contentTbaleView reloadData];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
