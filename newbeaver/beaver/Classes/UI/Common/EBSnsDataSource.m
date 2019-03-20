//
// Created by 何 义 on 14-3-18.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBSnsDataSource.h"

@implementation EBSnsDataSource
{
     NSMutableArray *_snsArray;
     CGSize _cellSize;
     UICollectionView *_collectionView;
}

#pragma mark collection view delegate

- (UICollectionView *)setupCollectionViewWithFrame:(CGRect)frame cellSize:(CGSize)cellSize direction:(UICollectionViewScrollDirection)direction
{
    _snsArray = [[NSMutableArray alloc] init];
    for (NSNumber *choice in self.choices)
    {
        NSString *key = [NSString stringWithFormat:@"sns_%ld", [choice integerValue]];
        [_snsArray addObject:@{@"image":[UIImage imageNamed:key], @"title": NSLocalizedString(key, nil)}];
    }

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:direction];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"snsCell"];
    _collectionView.backgroundColor = [UIColor clearColor];

//    collectionView.alwaysBounceVertical = YES;
    _collectionView.alwaysBounceHorizontal = YES;

    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"snsCell"];

    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;

    _cellSize = cellSize;

    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _snsArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"snsCell" forIndexPath:indexPath];
    if (cell == nil)
    {
        cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, _cellSize.width, _cellSize.height)];
    }

    NSUInteger itemIndex = [indexPath row];
    NSDictionary *itemConfig = [_snsArray objectAtIndex:itemIndex];

    [self updateCellView:cell withImage:[itemConfig objectForKey:@"image"] title:[itemConfig objectForKey:@"title"] tag:itemIndex];

    return cell;
}

#pragma mark - collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDictionary *itemConfig = [_snsArray objectAtIndex:[indexPath row]];
//    Class cls = [itemConfig objectForKey:@"viewController"];

//    UIViewController *controller = [[cls alloc] init];
//    controller.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:controller animated:YES];
}

//- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor blackColor];
//    return YES;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    cell.backgroundColor = [UIColor clearColor];
//}

#define SNS_CELL_LINE_WIDTH 1.f

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _cellSize;
}

#define SNS_CELL_IMAGE_Y_START 0.f
#define SNS_CELL_IMAGE_HEIGHT 60.f
#define SNS_CELL_TAG_IMAGE 99
#define SNS_CELL_TAG_LABEL 100
#define SNS_CELL_IMAGE_TITLE_GAP 5.f
#define SNS_CELL_LABEL_HEIGHT 20.f

- (void)updateCellView:(UICollectionViewCell *)cell withImage:(UIImage *)image title:(NSString *)title tag:(NSInteger)tag
{
    UIView *imageView = (UIView *)[cell.contentView viewWithTag:SNS_CELL_TAG_IMAGE];
    UILabel *titleView = (UILabel *)[cell.contentView viewWithTag:SNS_CELL_TAG_LABEL];
    if (imageView == nil)
    {
        imageView = [[UIView alloc] initWithFrame:CGRectMake(0.0, SNS_CELL_IMAGE_Y_START, _cellSize.width, SNS_CELL_IMAGE_HEIGHT)];
        UIButton *btn = [[UIButton alloc] initWithFrame:imageView.bounds];
        [imageView addSubview:btn];
        imageView.tag = SNS_CELL_TAG_IMAGE;
        [cell.contentView addSubview:imageView];

        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, SNS_CELL_IMAGE_Y_START + SNS_CELL_IMAGE_HEIGHT +
                SNS_CELL_IMAGE_TITLE_GAP, _cellSize.width, SNS_CELL_LABEL_HEIGHT)];
        titleView.font = [UIFont systemFontOfSize:14.0];
        titleView.textAlignment = NSTextAlignmentCenter;
        titleView.textColor = [UIColor colorWithRed:90/255.f green:90/255.f blue:90/255.f alpha:1.0];
        titleView.tag = SNS_CELL_TAG_LABEL;
        [cell.contentView addSubview:titleView];
    }

    UIButton *btn = imageView.subviews[0];
    btn.tag = tag + 1;
    [btn addTarget:self action:@selector(doShare:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:image forState:UIControlStateNormal];

    titleView.text = title;
}

- (void)doShare:(UIButton *)btn
{
//   [[EBController sharedInstance] shareItemWith:@"baidu.com" image:nil text:@"分享内容"];

//    if (btn.tag == 5)
//    {
//
//
//    }
//    else
//    {
//        [[EBController sharedInstance] shareItemWith:@"baidu.com" image:nil text:@"分享内容"];
//    }

    self.selectBlock(btn.tag - 1);
}

- (void)setChoices:(NSArray *)choices
{
    _choices = choices;
    [_snsArray removeAllObjects];
    for (NSNumber *choice in self.choices)
    {
        NSString *key = [NSString stringWithFormat:@"sns_%ld", [choice integerValue]];
        [_snsArray addObject:@{@"image":[UIImage imageNamed:key], @"title": NSLocalizedString(key, nil)}];
    }
    [_collectionView reloadData];
}

@end