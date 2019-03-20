//
//  SKGridCell.h
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SKAssetsViewController;
@interface SKGridCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *items;
@property (strong) NSMutableArray *viewArrays;
@property (weak) SKAssetsViewController *assetViewCtrl;

- (id)initWithViewCtrl:(SKAssetsViewController *)assetViewCtrl items:(NSMutableArray *)items identifier:(NSString *)identifier;

@end
