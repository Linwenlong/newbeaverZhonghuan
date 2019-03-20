//
//  RecommendViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

typedef NS_ENUM(NSInteger , EBShareType)
{
    EBShareTypeHouse = 0,
    EBShareTypeClient = 1,
    EBShareTypeNewHouse = 2,
};

@interface SnsViewController : UIViewController

@property (nonatomic, assign) BOOL isShowList;//是否是列表分享

@property (nonatomic, strong) NSArray *shareItems;//分享的房源
@property (nonatomic, strong) id extraInfo; //额外的info
@property (nonatomic) EBShareType shareType;
@property (nonatomic, copy) void(^shareHandler)(BOOL success, NSDictionary *info);

@end
