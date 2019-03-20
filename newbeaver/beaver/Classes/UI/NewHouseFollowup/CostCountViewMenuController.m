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
#import "HeaderViewForDailCheckView.h"
#import "HooDatePicker.h"
#import "CostCountDetailViewController.h"

@interface VedioTeachViewController ()<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *tittleScrollView;
@property (strong, nonatomic) IBOutlet UIScrollView *contentScrollView;

//@property (strong, nonatomic) UIScrollView *tittleScrollView;
//@property (strong, nonatomic) UIScrollView *contentScrollView;

@property (nonatomic, strong)HeaderViewForDailCheckView * headerLable;
@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器
@property (nonatomic, strong)ValuePickerView *pickerView;

@property (nonatomic,strong) UIView *sliderView;
@property (nonatomic,weak) UILabel *nav_title;

@property (nonatomic, strong)NSString *currentDate;
@property (nonatomic, copy)NSString *type;


@property (nonatomic, strong)NSDictionary *dic;

@end

@implementation VedioTeachViewController

- (void)setUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
    
//    _tittleScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 45)];
//    _contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 53, kScreenW, kScreenH-53)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    _nav_title = label;
    label.text = @"新房客户跟进";
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
    if (self.menuType == EMenuTypeNewHouse) {
        [self setupChildControllers];
        [self setupTittle];
#pragma mark   默认显示第0个子控制器
        [self scrollViewDidEndScrollingAnimation:self.contentScrollView];
    }else if (self.menuType == EMenuTypeCostCount){
        _tittleScrollView.top = 104;
        _contentScrollView.top = CGRectGetMaxY(_tittleScrollView.frame) + 40;
        _headerLable = [[HeaderViewForDailCheckView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 40) titleArr:@[@"本月",@"二手房业绩"] isShowBottomView:NO];
        _headerLable.headerViewDelegate = self;
        [self.view addSubview:_headerLable];
        self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
        
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM"];
        NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:currentDate];
        _currentDate = currentOlderOneDateStr;
        _type = @"二手房业绩";
        //请求数据
         [self requestData];
    }
    
}



#pragma mark -- RequestData

- (void)requestData{
    NSLog(@"month = %@",_currentDate);
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/finance/financeData?token=%@&month=%@&type=%@",[EBPreferences sharedInstance].token,_currentDate, _type]);
    //    [EBPreferences sharedInstance].dept_id
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:@"http://218.65.86.83:8010/finance/financeData" parameters:
     @{@"token" : [EBPreferences sharedInstance].token,
       @"department_id":@118,
       @"month" : @"2014-01",
       @"type" :  _type}
           success:^(id responseObject) {
               //添加费用统计
               [EBAlert hideLoading];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               self.dic = currentDic[@"data"];
               self.count = 1;
               //添加view
               [self setupChildControllers];
               [self setupTittle];
#pragma mark   默认显示第0个子控制器
               [self scrollViewDidEndScrollingAnimation:self.contentScrollView];
             
           } failure:^(NSError *error) {
               [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
           }];
}


- (void)setupTittle
{
    //定义临时的变量
    CGFloat labelW =[UIScreen mainScreen].bounds.size.width/4;
    CGFloat labelY = 0;
    CGFloat labelH = self.tittleScrollView.frame.size.height;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_tittleScrollView.frame), kScreenW, 2)];
    view.backgroundColor = UIColorFromRGB(0xEAEAEC);
    _sliderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW/4, 2)];
    _sliderView.backgroundColor = [UIColor redColor];
    [view addSubview:_sliderView];
    [self.view addSubview:view];

    for (NSInteger i = 0; i < self.count; i++) {
        XMGHomeLabel *label = [[XMGHomeLabel alloc] init];
        label.text = [self.childViewControllers[i] title];
        label.textAlignment = NSTextAlignmentCenter;
        CGFloat labelX = i *  labelW;
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelAction:)]];
        label.userInteractionEnabled = YES;
        label.tag = i ;
        [self.tittleScrollView addSubview:label];
        if (i == 0) {
            label.scale = 1.0;
        }
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
    
    if (self.menuType == EMenuTypeNewHouse) {
        ZHDCNewHouseFollowupViewController *social0 = [[ZHDCNewHouseFollowupViewController alloc] init];
        social0.title = @"界定中";
        social0.urlString = @"界定中";
        [self addChildViewController:social0];
        
        ZHDCNewHouseFollowupViewController *social1 = [[ZHDCNewHouseFollowupViewController alloc] init];
        social1.title = @"待确认";
        social1.urlString = @"待确认";
        [self addChildViewController:social1];
        
        ZHDCNewHouseFollowupViewController *social2 = [[ZHDCNewHouseFollowupViewController alloc] init];
        social2.title = @"已确认";
        social2.urlString = @"已确认";
        [self addChildViewController:social2];
        
        ZHDCNewHouseFollowupViewController *social3 = [[ZHDCNewHouseFollowupViewController alloc] init];
        social3.title = @"已带看";
        social3.urlString = @"已带看";
        [self addChildViewController:social3];
        
        ZHDCNewHouseFollowupViewController *social4 = [[ZHDCNewHouseFollowupViewController alloc] init];
        social4.title = @"已成交";
        social4.urlString = @"已成交";
        [self addChildViewController:social4];
        
        ZHDCNewHouseFollowupViewController *social5 = [[ZHDCNewHouseFollowupViewController alloc] init];
        social5.title = @"已结佣";
        social5.urlString = @"已结佣";
        [self addChildViewController:social5];
        
        ZHDCNewHouseFollowupViewController *social6 = [[ZHDCNewHouseFollowupViewController alloc] init];
        social6.title = @"已驳回";
        social6.urlString = @"驳回";
        [self addChildViewController:social6];
        
        ZHDCNewHouseFollowupViewController *social7 = [[ZHDCNewHouseFollowupViewController alloc] init];
        social7.title = @"已失效";
        social7.urlString = @"失效";
        [self addChildViewController:social7];

    }else{
        CostCountDetailViewController *cost = [[CostCountDetailViewController alloc] init];
        cost.title = @"新城吴越一组";
        cost.dic = self.dic;
        [self addChildViewController:cost];
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
    
    if (offsetX < 2 * kScreenW) {   //小于两倍的宽度
        left = index * (kScreenW / 4);
    }else if (offsetX >= 6*kScreenW){//超出
         left = (index - 4) * (kScreenW / 4);
    }else{//中间
        left = self.view.centerX - (_sliderView.width / 2);
    }
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _sliderView.left = left;
        } completion:^(BOOL finished) {
            
        }];
   
        [self.tittleScrollView setContentOffset:titleOffset animated:YES];

    // 让其他label回到最初的状态
    for (XMGHomeLabel *otherLabel in self.tittleScrollView.subviews) {
        if (otherLabel != label) otherLabel.scale = 0.0;
    }
    
    // 取出需要显示的控制器
    UIViewController *willShowVc = self.childViewControllers[index];
    // 如果当前位置的位置已经显示过了，就直接返回
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
