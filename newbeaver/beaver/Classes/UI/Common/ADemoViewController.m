//
// Created by 何 义 on 14-5-25.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "ADemoViewController.h"
#import "AgentGuideView.h"


@implementation ADemoViewController

- (void)loadView
{
    [super loadView];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.wantsFullScreenLayout = YES;
    [self.navigationController setNavigationBarHidden:YES];
    AgentGuideView *guideView = [[AgentGuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];

    [self.view addSubview:guideView];
}

@end