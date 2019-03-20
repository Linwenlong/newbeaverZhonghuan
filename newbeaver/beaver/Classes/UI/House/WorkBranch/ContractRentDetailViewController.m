//
//  ContractRentDetailViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "ContractRentDetailViewController.h"
#import "CKSlideMenu.h"
#import "RentBaseInfomationViewController.h"
#import "RentChargeViewController.h"


@interface ContractRentDetailViewController ()<CKSlideMenuDelegate,UIScrollViewDelegate>

@property (nonatomic, strong)CKSlideMenu *slideMenu;

@end

@implementation ContractRentDetailViewController

- (void)changeTitle:(NSInteger)index{
    NSLog(@"index = %ld",index);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"合同详情";
    [self loadSlideMenu];
}

- (void)loadSlideMenu{
    NSArray *titleArr = @[@"基本信息",@"财务收付"];
    for (int i=0; i<titleArr.count; i++) {
        UIViewController *vc = nil;
        if (i==0) {
            vc = [[RentBaseInfomationViewController alloc]init];
            RentBaseInfomationViewController *rentVC = (RentBaseInfomationViewController *)vc;
            rentVC.deal_id = self.deal_id;
            rentVC.deal_code = self.deal_code;
        }else if( i == 1){
            vc = [[RentChargeViewController alloc]init];
            RentChargeViewController *rentVC = (RentChargeViewController *)vc;
            rentVC.deal_id = self.deal_id;
            rentVC.deal_code = self.deal_code;

        }
        vc.title = titleArr[i];
        [self addChildViewController:vc];
    }
    _slideMenu = [[CKSlideMenu alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46) titles:titleArr controllers:self.childViewControllers];
    _slideMenu.backgroundColor = [UIColor whiteColor];
    
    _slideMenu.bodyFrame = CGRectMake(0,  CGRectGetMaxY(_slideMenu.frame), self.view.frame.size.width, self.view.frame.size.height- CGRectGetMaxY(_slideMenu.frame));
    _slideMenu.ckslideMenuDelegate = self;
    _slideMenu.bodySuperView = self.view;
    _slideMenu.indicatorOffsety = 0;
    _slideMenu.indicatorWidth = 25;
    _slideMenu.indicatorHeight = 3.0f;
    _slideMenu.lazyLoad = YES;
    _slideMenu.font = [UIFont systemFontOfSize:18.0f];
    _slideMenu.indicatorStyle = SlideMenuIndicatorStyleFollowText;
    _slideMenu.titleStyle = SlideMenuTitleStyleNormal;
    _slideMenu.selectedColor = UIColorFromRGB(0xE60012);
    _slideMenu.unselectedColor = UIColorFromRGB(0x595959);
    _slideMenu.isFixed = YES;
    _slideMenu.showLine = NO;
    [self.view addSubview:_slideMenu];

}

@end
