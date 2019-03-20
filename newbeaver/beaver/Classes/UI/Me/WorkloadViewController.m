//
//  WorkloadViewController.m
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "WorkloadViewController.h"
#import "WorkLoadView.h"
#import "HeaderViewForDailCheckView.h"
#import "WorkLoadTableViewCell1.h"
#import "WorkLoadChildViewController.h"

@interface WorkloadViewController ()<WorkLoadViewDelegate,UIScrollViewDelegate,HeaderViewForDailCheckViewDelegate>

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) WorkLoadView *workLoadView;
@property (nonatomic, strong) HeaderViewForDailCheckView *headerLable;

@end

@implementation WorkloadViewController

- (void)setNav{
    
    CGFloat view_W = 55*3;
    WorkLoadView *view = [[WorkLoadView alloc]init];
    view.titleViewDelegate = self;
    view.frame = CGRectMake(0, 0, view_W, 40);
    view.backgroundColor = [UIColor clearColor];
    self.workLoadView = view;
    self.navigationItem.titleView = self.workLoadView;
    
//    _headerLable = [[HeaderViewForDailCheckView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 40) titleArr:@[@"模式",@"部门",@"月份",@"类型"] isShowBottomView:NO];
//    _headerLable.headerViewDelegate = self;
//    [self.view addSubview:_headerLable];
    
}

-(void)setUpChildViewControllers
{
    //小区
    WorkLoadChildViewController *childvc1 = [[WorkLoadChildViewController alloc] init];
    childvc1.view.frame = CGRectMake(0, 0, kScreenW, kScreenH-64);
     childvc1.type = @"house";
    [self addChildViewController:childvc1];
    
    WorkLoadChildViewController *childvc2 = [[WorkLoadChildViewController alloc] init];
    childvc2.type = @"client";
    [self addChildViewController:childvc2];
    
    WorkLoadChildViewController *childvc3 = [[WorkLoadChildViewController alloc] init];
    childvc3.type = @"deal";
    [self addChildViewController:childvc3];
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

-(void)addChildViewControllerView
{
    NSInteger index = self.mainScrollView.contentOffset.x / self.mainScrollView.width;
    UIViewController *childVc = self.childViewControllers[index];
    if (childVc.view.superview) return; //判断添加就不用再添加了
    childVc.view.frame = CGRectMake(index * self.mainScrollView.width, 0, self.mainScrollView.width, self.mainScrollView.height);
    [self.mainScrollView addSubview:childVc.view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    [self setUpChildViewControllers];
    [self setUpScrollView];
    [self addChildViewControllerView];
}


- (void)WorkLoadViewClick:(UIButton*)button andAnthorButtons:(NSArray<UIButton *>*)buttonArray andSilderView:(UIView *)view{
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
    UIButton *titleButton = self.workLoadView.buttonArray[index];
    //标题
    NSMutableArray *tmp = [NSMutableArray array];
    for (int i = 0; i < self.workLoadView.buttonArray.count; i++) {
        if (i != index) {
            [tmp addObject:self.workLoadView.buttonArray[i]];
        }
    }
    [self titelClick:titleButton andAnthorButtons:tmp andSilderView:self.workLoadView.sliderView];
    [self addChildViewControllerView];
}

- (void)btnClick:(UIButton *)btn{
    NSLog(@"点击了btn");
  
}

@end
