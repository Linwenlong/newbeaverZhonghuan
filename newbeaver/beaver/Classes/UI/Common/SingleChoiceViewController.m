//
//  SingleChoiceViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "SingleChoiceViewController.h"
#import "EBSingleChoiceView.h"

@interface SingleChoiceViewController ()
@end

@implementation SingleChoiceViewController

- (id)init
{
    if (self = [super init])
    {
        _singleChoiceView = [[EBSingleChoiceView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
        _singleChoiceView.touchBackDisabled = YES;
    }

    return self;
}

- (void)loadView
{
    [super loadView];
    [self.view addSubview:_singleChoiceView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
