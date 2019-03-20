//
//  MyAchievementViewController.m
//  beaver
//
//  Created by mac on 17/8/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyAchievementViewController.h"
#import "ZHDCHouseDetailTitleView.h"
#import "MyAchievementChildViewController.h"

@interface MyAchievementViewController ()<UIScrollViewDelegate,ZHDCHouseDetailTitleViewDelegate>

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) ZHDCHouseDetailTitleView *houseDetailTitleView;

@end

@implementation MyAchievementViewController

- (void)setNav{
    
    CGFloat view_W = 140;
    ZHDCHouseDetailTitleView *view = [[ZHDCHouseDetailTitleView alloc]init];
    view.titleViewDelegate = self;
    view.frame = CGRectMake(0, 0, view_W, 40);
    view.backgroundColor = [UIColor clearColor];
    self.houseDetailTitleView = view;
    self.navigationItem.titleView = self.houseDetailTitleView;
}

/**
 添加scrollView
 */
-(void)setUpScrollView
{
    //不允许自动调整scrollView的内边距
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor whiteColor];
    self.mainScrollView = scrollView;
    scrollView.delegate = self;
    scrollView.frame = self.view.bounds;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(self.view.width * self.childViewControllers.count, 0);
}

-(void)setUpChildViewControllers
{
    //小区
    MyAchievementChildViewController *childvc1 = [[MyAchievementChildViewController alloc] init];
    childvc1.type = @"user";
    [self addChildViewController:childvc1];
    
    MyAchievementChildViewController *childvc2 = [[MyAchievementChildViewController alloc] init];
       childvc2.type = @"dep";
      [self addChildViewController:childvc2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的业绩";
    [self setNav];
    [self setUpChildViewControllers];
    [self setUpScrollView];
    [self addChildViewControllerView];
}

-(void)addChildViewControllerView
{
    NSInteger index = self.mainScrollView.contentOffset.x / self.mainScrollView.width;
    UIViewController *childVc = self.childViewControllers[index];
    if (childVc.view.superview) return; //判断添加就不用再添加了
    childVc.view.frame = CGRectMake(index * self.mainScrollView.width, 0, self.mainScrollView.width, self.mainScrollView.height);
    [self.mainScrollView addSubview:childVc.view];
    
}

#pragma mark -- ZHDCHouseDetailTitleViewDelegate
- (void)zhdcHouseDetailTitleViewClick:(UIButton*)button andAnthorButtons:(NSArray<UIButton *> *)buttonArray andSilderView:(UIView *)view{
    //让UIScrollView 滚动
    CGPoint offset = self.mainScrollView.contentOffset;
    offset.x = self.mainScrollView.width * button.tag;
    [self.mainScrollView setContentOffset:offset animated:YES];
    [self titelClick:button andAnthorButtons:buttonArray andSilderView:view];
}


- (void)titelClick:(UIButton *)button andAnthorButtons:(NSArray <UIButton*>*)buttonArray andSilderView:(UIView *)view{
//    //文字变色
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    for (UIButton *button in buttonArray) {
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    }
    //滑块
    [UIView animateWithDuration:0.1 animations:^{
        view.centerX = button.centerX;
    }];
    
}

#pragma mark -- UIScrollViewDelegate

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self addChildViewControllerView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //点击对应的按钮
    NSInteger index = scrollView.contentOffset.x / scrollView.width;
    UIButton *titleButton = self.houseDetailTitleView.buttonArray[index];
    //标题
    NSMutableArray *tmp = [NSMutableArray array];
    for (int i = 0; i < self.houseDetailTitleView.buttonArray.count; i++) {
        if (i != index) {
            [tmp addObject:self.houseDetailTitleView.buttonArray[i]];
        }
    }
    [self titelClick:titleButton andAnthorButtons:tmp andSilderView:self.houseDetailTitleView.sliderView];
    [self addChildViewControllerView];
}

@end
