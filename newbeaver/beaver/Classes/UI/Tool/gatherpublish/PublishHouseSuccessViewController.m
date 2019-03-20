//
//  PublishHouseSuccessViewController.m
//  beaver
//
//  Created by LiuLian on 9/3/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "PublishHouseSuccessViewController.h"

@interface PublishHouseSuccessViewController ()

@end

@implementation PublishHouseSuccessViewController

- (void)loadView
{
    [super loadView];
    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"title_complete", nil) target:self action:@selector(complete)];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:scrollView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_addhouse_sucess"]];
    imageView.frame = CGRectOffset(imageView.frame, 160 - imageView.frame.size.width / 2, 80);
    [scrollView addSubview:imageView];
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *labelOne = [[UILabel alloc] initWithFrame:CGRectMake(0, 164, [EBStyle screenWidth], 35)];
    labelOne.textAlignment = NSTextAlignmentCenter;
    labelOne.textColor = [EBStyle blackTextColor];
    labelOne.font = [UIFont systemFontOfSize:14.0];
    labelOne.backgroundColor = [UIColor clearColor];
    labelOne.text = NSLocalizedString(@"publish_to_port_success1", nil);
  
    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 194 , [EBStyle screenWidth], 35)];
    labelTwo.text = NSLocalizedString(@"publish_to_port_success2", nil);
    labelTwo.font = [UIFont systemFontOfSize:14.0];
    labelTwo.textAlignment = NSTextAlignmentCenter;
    labelTwo.textColor = [EBStyle blackTextColor];
    labelTwo.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:labelOne];
    [scrollView addSubview:labelTwo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)complete
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
