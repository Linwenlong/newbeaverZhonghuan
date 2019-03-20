//
//  PublishHouseItemView.h
//  beaver
//
//  Created by wangyuliang on 14-9-3.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , EPublishHouseItemType)
{
    EPublishHouseItemRecord = 1,
    EPublishHouseItemOrder = 2,
};

typedef void(^httpHandBlock)(BOOL success);

@protocol PublishHouseItemDelegate

@optional
- (void)refreshTouchTag:(NSInteger)row tag:(NSInteger)tag handlback:(httpHandBlock)handlback;

@end

@interface PublishHouseItemView : UIView

@property (nonatomic, readonly) UILabel *portView;
@property (nonatomic, readonly) UILabel *titleView;
@property (nonatomic, readonly) UILabel *contentView;
@property (nonatomic, readonly) UILabel *timeView;
@property (nonatomic, readonly) UIImageView *photoView;
@property (nonatomic, readonly) UIView *refreshView;
@property (nonatomic, readonly) UIView *tipView;
@property (nonatomic, readonly) UIActivityIndicatorView *activeView;
@property (nonatomic, readonly) UILabel *errorView;
@property (nonatomic, readonly) UIView *line;

@property (nonatomic, assign)   id <PublishHouseItemDelegate>   delegate;
@property (nonatomic, strong) NSDictionary *publishHouse;

@property (nonatomic, assign) EPublishHouseItemType showItemType;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger touchTag;//0 未点击初始状态  1显示刷新按钮  2显示tip 3显示菊花

@end
