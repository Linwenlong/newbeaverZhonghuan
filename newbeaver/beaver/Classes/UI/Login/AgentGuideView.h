//
// Created by 何 义 on 14-5-24.
// Copyright (c) 2014 eall. All rights reserved.
//

#pragma mark -- 引导页面


#import <Foundation/Foundation.h>


@interface AgentGuideView : UIView

@property (nonatomic, copy) void(^finishGuide)();
@property (nonatomic) NSInteger page;

@end