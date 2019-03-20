//
//  SKGridItem.h
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKAsset.h"

@class SKGridItem;
@class SKAssetsViewController;

@protocol SKGridItemDelegate <NSObject>

@optional
- (void)skGridItem:(SKGridItem *)gridItem didChangeSelectionState:(NSNumber *)selected;
- (BOOL)skGridItemCanSelect:(SKGridItem *)gridItem;

@end

@interface SKGridItem : UIView

@property (nonatomic, strong) SKAsset *skAsset;

@property (nonatomic, weak) id<SKGridItemDelegate> delegate;

//@property (nonatomic, weak) SKAssetsViewController *assetViewCtrl;

- (id)initWithSkAsset:(SKAsset *)skAsset frame:(CGRect)frame;

- (void)loadImageFromAsset;

- (void)tap;

@end
