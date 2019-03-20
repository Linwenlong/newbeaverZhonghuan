//
//  ContractDealDetailViewController.m
//  beaver
//
//  Created by mac on 17/12/18.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ContractDealDetailViewController.h"
#import "CKSlideMenu.h"
#import "WorkLogViewController.h"
#import "BasisInformationViewController.h"
#import "FinancialDetainAndHandViewController.h"
#import "ContractImageViewController.h"
#import "SatisfiedInvestigateViewController.h"
#import "TransferProcedureViewController.h"
#import "ZHDCNewHouseFollowupViewController.h"
#import "ChargeDetailViewController.h"

@interface ContractDealDetailViewController ()<CKSlideMenuDelegate,UIScrollViewDelegate>

@property (nonatomic, strong)NSMutableArray *arr;
@property (nonatomic, strong)CKSlideMenu *slideMenu;

@property (strong, nonatomic) UIScrollView *tittleScrollView;
@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (nonatomic,strong) UIView *sliderView;
@property (nonatomic,weak) UILabel *nav_title;

@property (nonatomic, weak)BasisInformationViewController *basisVc;

@end

@implementation ContractDealDetailViewController


- (void)changeTitle:(NSInteger)index{
    NSLog(@"index = %ld",index);
    //加载第一个控制器

}



#pragma mark -- 文字点击方法
- (void)labelAction:(UITapGestureRecognizer *)tap{
    //    [self.tittleScrollView.subviews indexOfObject:tap.view];
    NSInteger index =  tap.view.tag;
    _nav_title.text = [self.childViewControllers[index] title];
    // 让底部的内容scrollView滚动到对应位置
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = index * self.contentScrollView.frame.size.width;
    [self.contentScrollView setContentOffset:offset animated:YES];
}

- (void)setTest{
//        NSArray *titleArr = @[@"基本信息",@"财务收付",@"合同图片",@"满意调查",@"过户手续",@"日  志"];
//        NSArray *titleArr = @[@"基本信息",@"财务收付",@"合同图片",@"过户手续"];
        NSArray *titleArr = @[@"基本信息",@"财务收付",@"合同图片",@"过户手续"];
    
        _arr = [NSMutableArray array];
    
    for (int i=0; i<titleArr.count; i++) {
        UIViewController *vc = nil;
        if (i==0) {
            vc = [[BasisInformationViewController alloc]init];
            _basisVc = (BasisInformationViewController *)vc;
            _basisVc.deal_id = self.deal_id;
            _basisVc.deal_code = self.deal_code;
            
        }else if( i == 1){
            vc = [[FinancialDetainAndHandViewController alloc]init];
            FinancialDetainAndHandViewController *uc = (FinancialDetainAndHandViewController *)vc;
            uc.deal_id = self.deal_id;
            uc.deal_code = self.deal_code;
//            vc = [[ChargeDetailViewController alloc]init];
//            ChargeDetailViewController *uc = (ChargeDetailViewController *)vc;
//            uc.deal_code = self.deal_code;
        }else if( i == 2){
            vc = [[ContractImageViewController alloc]init];
            ContractImageViewController *uc = (ContractImageViewController *)vc;
            uc.deal_code = self.deal_code;
            
        }else if( i == 3){
            vc = [[TransferProcedureViewController alloc]init];
            TransferProcedureViewController *uc = (TransferProcedureViewController *)vc;
            uc.deal_code = self.deal_code;
        }
        vc.title = titleArr[i];
        [self addChildViewController:vc];
    }
        _slideMenu = [[CKSlideMenu alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 46) titles:titleArr controllers:self.childViewControllers];
        _slideMenu.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bground"]];
    
        _slideMenu.bodyFrame = CGRectMake(0,  CGRectGetMaxY(_slideMenu.frame), self.view.frame.size.width, self.view.frame.size.height- CGRectGetMaxY(_slideMenu.frame));
        _slideMenu.ckslideMenuDelegate = self;
        _slideMenu.bodySuperView = self.view;
        _slideMenu.indicatorOffsety = 0;
        _slideMenu.indicatorWidth = 25;
        _slideMenu.indicatorHeight = 3.0f;
        _slideMenu.lazyLoad = YES;
        _slideMenu.font = [UIFont systemFontOfSize:16.0f];
        _slideMenu.indicatorStyle = SlideMenuIndicatorStyleStretch;
        _slideMenu.titleStyle = SlideMenuTitleStyleGradient;
        _slideMenu.selectedColor = [UIColor whiteColor];
        _slideMenu.unselectedColor = [UIColor whiteColor];
        _slideMenu.indicatorColor = UIColorFromRGB(0xFFF100);
        [self.view addSubview:_slideMenu];
    
        _basisVc.slideMenu = _slideMenu;
}

- (void)setNav{
    self.title = @"合同详情";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    [self setTest];
}


@end

