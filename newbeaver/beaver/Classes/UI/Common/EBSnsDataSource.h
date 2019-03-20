//
// Created by 何 义 on 14-3-18.
// Copyright (c) 2014 eall. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface EBSnsDataSource : NSObject<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) void(^selectBlock)(NSInteger selected);
@property (nonatomic, strong) NSArray *choices;

- (UICollectionView *)setupCollectionViewWithFrame:(CGRect)frame cellSize:(CGSize)cellSize direction:(UICollectionViewScrollDirection)direction;

@end