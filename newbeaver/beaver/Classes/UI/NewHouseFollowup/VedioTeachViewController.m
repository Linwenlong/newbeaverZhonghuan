//
//  HomeViewController.m
//  FollowProject
//
//  Created by 刘海伟 on 16/9/18.
//  Copyright © 2016年 zhdc. All rights reserved.
//

#import "VedioTeachViewController.h"
#import "ZHDCNewHouseFollowupViewController.h"
#import "XMGHomeLabel.h"
#import "WorkLogViewController.h"

@interface VedioTeachViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *tittleScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;

//@property (strong, nonatomic) UIScrollView *tittleScrollView;
//@property (strong, nonatomic) UIScrollView *contentScrollView;

@property (nonatomic,strong) UIView *sliderView;
@property (nonatomic,weak) UILabel *nav_title;

@end

@implementation VedioTeachViewController

- (void)setUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    _nav_title = label;
    if (_menuType == ZHMenuTypeNewList) {
        label.text = @"新房客户跟进";
    }else{
        label.text = @"合同详情";
    }
    label.font = [UIFont systemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    
    self.contentScrollView.delegate = self;
    self.contentScrollView.pagingEnabled = YES;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 1, kScreenW, 1)];
    view.backgroundColor = [UIColor lightGrayColor];
    [_contentScrollView addSubview:view];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setUI];
    [self setupChildControllers];
    [self setupTittle];
    [self scrollViewDidEndScrollingAnimation:self.contentScrollView];
}




- (void)setupTittle
{
    
    //定义临时的变量
    CGFloat labelW =[UIScreen mainScreen].bounds.size.width/4;
    CGFloat labelY = 0;
    CGFloat labelH = self.tittleScrollView.frame.size.height;
   
    if (_menuType == ZHMenuTypeContractDetailList) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tittleScrollView.frame)-3, kScreenW, 3)];
        view.backgroundColor = [UIColor clearColor];
        _sliderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 75, 3)];
        //修改滑块
        _sliderView.backgroundColor =UIColorFromRGB(0xFFF100);
        [view addSubview:_sliderView];
        [self.view addSubview:view];
        self.tittleScrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bground"]];;
    }else{
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tittleScrollView.frame), kScreenW, 2)];
        view.backgroundColor = UIColorFromRGB(0xEAEAEC);
        _sliderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW/4, 2)];
        _sliderView.backgroundColor = [UIColor redColor];
        [view addSubview:_sliderView];
        [self.view addSubview:view];
    }
    
    for (NSInteger i = 0; i < self.count; i++) {
        UILabel *label = nil;
        if (_menuType == ZHMenuTypeNewList) {
            label = [[XMGHomeLabel alloc] init];
            XMGHomeLabel *homeLable = (XMGHomeLabel*)label;
            if (i == 0) {
                homeLable.scale = 1.0;
            }
        }else{
            label = [[UILabel alloc] init];
            label.font = [UIFont boldSystemFontOfSize:14.0f];
            label.textColor = [UIColor whiteColor];
            if (i>3) {
                label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bground"]];
            }
        }
        label.text = [self.childViewControllers[i] title];
        label.textAlignment = NSTextAlignmentCenter;
        CGFloat labelX = i *  labelW;
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelAction:)]];
        label.userInteractionEnabled = YES;
        label.tag = i ;
        [self.tittleScrollView addSubview:label];
        
    }
    self.tittleScrollView.contentSize = CGSizeMake(labelW*self.count, 0 );
    self.contentScrollView.contentSize = CGSizeMake(self.count * [UIScreen mainScreen].bounds.size.width, 0);
}

- (void)labelAction:(UITapGestureRecognizer *)tap
{
//    [self.tittleScrollView.subviews indexOfObject:tap.view];
    NSInteger index =  tap.view.tag;
    _nav_title.text = [self.childViewControllers[index] title];
    // 让底部的内容scrollView滚动到对应位置
    CGPoint offset = self.contentScrollView.contentOffset;
    offset.x = index * self.contentScrollView.frame.size.width;
    [self.contentScrollView setContentOffset:offset animated:YES];
}

- (void)setupChildControllers
{
    if (_menuType == ZHMenuTypeNewList) {
        NSArray *arrtitle = @[@"界定中",@"待确认",@"已确认",@"已带看",@"已成交",@"已结佣",@"已驳回",@"已失效"];
        NSArray *urlString = @[@"界定中",@"待确认",@"已确认",@"已带看",@"已成交",@"已结佣",@"驳回",@"失效"];
        for (int i=0; i<arrtitle.count; i++) {
            ZHDCNewHouseFollowupViewController *social = [[ZHDCNewHouseFollowupViewController alloc] init];
            social.title = arrtitle[i];
            social.urlString = urlString[i];
            [self addChildViewController:social];
        }
    }else{
        NSArray *arrtitle = @[@"基本信息",@"财物收付",@"合同图片",@"满意调查",@"过户手续",@"日  志"];
        for (int i=0; i<arrtitle.count; i++) {
            WorkLogViewController *social = [[WorkLogViewController alloc] init];
            social.title = arrtitle[i];
//            social.urlString = @"界定中";
            [self addChildViewController:social];
        }
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - <UIScrollViewDelegate>
/**
 * scrollView结束了滚动动画以后就会调用这个方法（比如- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated;方法执行的动画完毕后）
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    // 一些临时变量
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    CGFloat offsetX = scrollView.contentOffset.x;

    // 当前位置需要显示的控制器的索引
    NSInteger index = offsetX / width;
    _nav_title.text = self.childViewControllers[index].title;
    // 让对应的顶部标题居中显示
    XMGHomeLabel  *label = self.tittleScrollView.subviews[index];
#pragma mark 对应的位置居中代码
    
    CGPoint titleOffset = self.tittleScrollView.contentOffset;
    titleOffset.x = label.center.x - width * 0.5;
    // 左边超出处理
    if (titleOffset.x < 0) titleOffset.x = 0;
    // 右边超出处理
    CGFloat maxTitleOffsetX = self.tittleScrollView.contentSize.width - width;
    if (titleOffset.x > maxTitleOffsetX) titleOffset.x = maxTitleOffsetX;

    CGFloat left = 0;
    
    NSLog(@"ofx = %f",offsetX);
    NSLog(@"index = %ld",index);
    
    if (offsetX < 2 * kScreenW) {   //小于两倍的宽度
        left = index * (kScreenW / 4)+(kScreenW / 4-_sliderView.width)/2.0f;
    }else if (offsetX >= (self.count-2)*kScreenW){//超出
        left = (index - (self.count-4)) * (kScreenW / 4)+(kScreenW / 4-_sliderView.width)/2.0f;
    }else{//中间
        left = self.view.centerX - (_sliderView.width / 2);
    }
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _sliderView.left = left;
    } completion:^(BOOL finished) {
            
    }];
   
        [self.tittleScrollView setContentOffset:titleOffset animated:YES];

    // 让其他label回到最初的状态
    if (_menuType == ZHMenuTypeNewList) {
        for (XMGHomeLabel *otherLabel in self.tittleScrollView.subviews) {
            if (otherLabel != label) otherLabel.scale = 0.0;
        }
    }
    
    // 取出需要显示的控制器
    UIViewController *willShowVc = self.childViewControllers[index];
    // 如果当前位置的位置已经显示过了，就直接返回
    NSLog(@"isViewLoaded=%d",[willShowVc isViewLoaded]);
    if ([willShowVc isViewLoaded]) return;
    
    // 添加控制器的view到contentScrollView中;
    willShowVc.view.frame = CGRectMake(offsetX, 0, width, height);
    [scrollView addSubview:willShowVc.view];
}


/**
 * 只要scrollView在滚动，就会调用
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_menuType == ZHMenuTypeContractDetailList) return;
    
    CGFloat scale = scrollView.contentOffset.x/scrollView.frame.size.width;
    
    //左边
    NSInteger  leftIndex = scale;
    XMGHomeLabel  *leftLabel = self.tittleScrollView.subviews[leftIndex];
    
    if (leftIndex == self.tittleScrollView.subviews.count - 1) return;
    //右边
    NSInteger rightIndex = leftIndex + 1;
    XMGHomeLabel *rightLabel = self.tittleScrollView.subviews[rightIndex];
    
    // 右边比例
    CGFloat rightScale = scale - leftIndex;
    // 左边比例
    CGFloat leftScale = 1 - rightScale;
    
    // 设置label的比例
    leftLabel.scale = leftScale;
    rightLabel.scale = rightScale;
}
/**
 * 手指松开scrollView后，scrollView停止减速完毕就会调用这个
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

@end
