//
//  ECTaxFeeSelectViewController.h
//  chow
//
//  Created by kevin on 15/4/15.
//  Copyright (c) 2015年 eallcn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class ECSingleSelectViewController;

@protocol ECSingleSelectViewControllerDelegate <NSObject>

@optional
- (void)singleSelectViewController:(ECSingleSelectViewController *)singleSelectViewController didSelectValue:(NSInteger)value forIndexPath:(NSIndexPath *)indexPath;

@end

@interface ECSingleSelectViewController : BaseViewController
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, assign) NSInteger currentValue;
@property (nonatomic, weak) id<ECSingleSelectViewControllerDelegate> delegate;
@end
