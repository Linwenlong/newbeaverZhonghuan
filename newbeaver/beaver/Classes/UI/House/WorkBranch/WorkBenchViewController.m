 //
//  WorkBenchViewController.m
//  beaver
//  工作台
//  Created by zhaoyao on 15/12/7.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "WorkBenchViewController.h"
#import "workbenchBtn.h"
#import "ERPWebViewController.h"
#import "EBShowingView.h"
#import "EBNewsView.h"
#import "MJRefresh.h"
#import "EBWorkBenchMenuViewController.h"
#import "EBRefreshHeader.h"
#import "EBHttpClient.h"
#import "EBPreferences.h"
#import "SDCycleScrollView.h"
#import "EBController.h"
#import "EBUpdater.h"
#import "EBAlert.h"

//LWL
#import "NewsViewController.h"
#import "LWLShowView.h"
#import "LWLNewsView.h"
#import "NewTableViewCell.h"
#import "SDAutoLayout.h"
#import "ButtonViews.h"
#import "NewsModel.h"

#import "HouseViewController.h"
#import "ZHDCNewHouseViewController.h"
#import "VedioTeachViewController.h"
#import "NearByMapViewController.h"
#import "ContactsViewController.h"
#import "QRScannerViewController.h"
#import "PerformanceRankingViewController.h"
#import "PublicNoticeViewController.h"
#import "MyMemorandumViewController.h"

#import "StoreFinanceViewController.h"      //第三方收付
#import "CostCountViewController.h"         //费用统计
#import "FinancialViewController.h"         //财物收款
#import "ContractDealListViewController.h"  //买卖成交
#import "WorkSumListViewController.h"  //工作总结

#import "EBCache.h"
#import "ZHDCWebViewController.h"

#import "HouseCollectionViewController.h"

@interface WorkBenchViewController ()<SDCycleScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,ButtonViewsDelegate,LWLShowViewDelegate,LWLNewsViewDelegate>
{
     UIView *_containView;
     CGFloat _btnsWidth;
     CGFloat _btnsHeifht;
    
    BOOL isShowFee;//是否显示费用统计
    BOOL isShowCompanyMoney;//公司收入分账
    BOOL isShowStoneAccount;//门店佣金分账
    BOOL isShowReimbursement;//报销划账管理
    BOOL isMoneyReceive;//是否显示收单
    
    
    BOOL isMonthfinance;//月结统计
    BOOL isHalfmonthfinance;//半月结
    BOOL isDayfinance;//单日结
    BOOL isTenfinance;//十日结佣
}
@property (nonatomic, strong) SDCycleScrollView *showingView;//滚动图片
@property (nonatomic, weak) UIScrollView *baseScrollView;
@property (nonatomic, strong) EBNewsView *newsView;
@property (nonatomic, strong) LWLShowView *showView;//头视图
@property (nonatomic, strong) LWLNewsView *xiaoxiShouView;//消息列表

//视图
@property (nonatomic, strong)ButtonViews *buttonViews;
//页面控制
@property (nonatomic, strong)UIPageControl *pageControl;
@property (nonatomic, strong) NSArray *iconInfos;
@property (nonatomic, strong)NSMutableArray *tableViewArray;
@property (nonatomic, assign)BOOL finance;

//工资统计
@property (nonatomic, copy)NSString *financeDec;

//房源决策
@property (nonatomic, copy)NSString *inputDisks;
@property (nonatomic, strong)NSMutableArray *finProfile;

@property (nonatomic, strong)NSMutableArray  *arr;

@end

@implementation WorkBenchViewController

- (UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.numberOfPages = 2;
        _pageControl.currentPage = 0;
        [_pageControl setValue:[UIImage imageNamed:@"select"] forKeyPath:@"_currentPageImage"];
        [_pageControl setValue:[UIImage imageNamed:@"unselect"] forKeyPath:@"_pageImage"];
        [_pageControl addTarget:self action:@selector(changeBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pageControl;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"工作台";

    //lwl
    [self LWLbuildView];
//     [self buildView];
    _tableViewArray = [NSMutableArray array];
    _finProfile = [NSMutableArray array];
    _arr = [NSMutableArray arrayWithObjects:@"房贷计算",@"扫二维码", @"成交合同",@"工作总结", nil];

    [self.baseScrollView.mj_header performSelector:@selector(beginRefreshing) withObject:nil afterDelay:.5f];
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"juhePay"] target:self action:@selector(juhePay:)];
    
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"消息"] target:self action:@selector(enterNews:)];
//    [self.baseScrollView.mj_header beginRefreshing];
}


//聚合支付
- (void)juhePay:(UIBarButtonItem *)item{

//    HouseCollectionViewController *VC = [[HouseCollectionViewController alloc]init];
//    VC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:VC animated:YES];
//    return;
    //
    QRScannerViewController *qr = [[QRScannerViewController alloc]init];
    qr.title = @"扫二维码";
    qr.is_JuhePay = YES;
    qr.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:qr animated:YES];
    
}

#pragma mark -- 进入消息界面
- (void)enterNews:(UIBarButtonItem *)item{
    NewsViewController *nvc = [[NewsViewController alloc]init];
    nvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nvc animated:YES];
}

- (BOOL)fd_prefersNavigationBarHidden
{
    [self hiddenleftNVItem];
    return NO;
    
}
//隐藏左箭头 并添加logo跟titleLable
- (void)hiddenleftNVItem{
    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark -- LWLNewsViewDelegate

-(void)LWLNewsViewImageClick:(UIImageView *)imageView{

   //公告列表
    PublicNoticeViewController *pnc = [[PublicNoticeViewController alloc]init];
    pnc.hidesBottomBarWhenPushed = YES;
    pnc.title = @"公告列表";
    [self.navigationController pushViewController:pnc animated:YES];
}

#pragma mark -- LWLShowViewDelegate
- (void)LWLShowViewBtnClick:(UIButton *)btn{
    //业绩排行
    PerformanceRankingViewController *prvc = [[PerformanceRankingViewController alloc]init];
    prvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:prvc animated:YES];
}

#pragma mark -- ButtonViewsDelegate

- (void)btnClick:(UIButton *)btn{

    if ([btn.titleLabel.text isEqualToString:@"查看房源"]) {
        //房源
        HouseViewController * hvc = [[HouseViewController alloc]init];
        hvc.title = @"房源";
        hvc.hidesBottomBarWhenPushed = YES;
        hvc.inputDisks = _inputDisks;
        [self.navigationController pushViewController:hvc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"查看新房"]){
        //新房
        ZHDCNewHouseViewController *hvc = [[ZHDCNewHouseViewController alloc]init];
        hvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:hvc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"新房跟进"]){
        //新房跟进
        VedioTeachViewController *hvc = [[VedioTeachViewController alloc]init];
        hvc.count = 8;
        hvc.menuType = ZHMenuTypeNewList;
        hvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:hvc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"附近房源"]){
        //附近房源
        NearByMapViewController *hvc = [[NearByMapViewController alloc]init];
        hvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:hvc animated:YES];
    }else if([btn.titleLabel.text isEqualToString:@"通讯录"]){
        //通讯录
        ContactsViewController *cvc = [[ContactsViewController alloc]init];
        cvc.title = @"通讯录";
        cvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:cvc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"我的备忘"]){
        MyMemorandumViewController *mvc = [[MyMemorandumViewController alloc]init];
        mvc.hidesBottomBarWhenPushed = YES;
        mvc.title = @"我的备忘";
        [self.navigationController pushViewController:mvc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"房贷计算"]){
        //房贷计算
        NSString *str = @"120";
        CGFloat mortgage = [str floatValue] * 0.6;
        NSDictionary *info = @{@"amount":str, @"mortgage":@(mortgage)};
        [[EBController sharedInstance] showCalculator:info];
    }else if ([btn.titleLabel.text isEqualToString:@"扫二维码"]){
        //扫二维码
        QRScannerViewController *qr = [[QRScannerViewController alloc]init];
        qr.title = @"扫二维码";
        qr.hidesBottomBarWhenPushed = YES;
        NSLog(@"nav = %@",self.navigationController);
        [self.navigationController pushViewController:qr animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"门店财务"]){
        StoreFinanceViewController *sfvc = [[StoreFinanceViewController alloc]init];
        sfvc.hidesBottomBarWhenPushed = YES;
        sfvc.financeDec = _financeDec;
        sfvc.isShowFee = isShowFee;

        sfvc.isShowCompanyMoney = isShowCompanyMoney;
        sfvc.isShowStoneAccount = isShowStoneAccount;
        sfvc.isShowReimbursement = isShowReimbursement;
        sfvc.finProfile = _finProfile;
        
        sfvc.monthfinance = isMonthfinance;
        sfvc.halfmonthfinance = isHalfmonthfinance;
        sfvc.dayfinance = isDayfinance;
        sfvc.tenfinance = isTenfinance;
        
        [self.navigationController pushViewController:sfvc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"财务收付"]){
        FinancialViewController *fvc = [[FinancialViewController alloc]init];
        fvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:fvc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"成交合同"]){
        ContractDealListViewController *hvc = [[ContractDealListViewController alloc]init];
        hvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:hvc animated:YES];
        [EBTrack event:EVENT_CLICK_TRADE];
    }else if ([btn.titleLabel.text isEqualToString:@"工作总结"]){
        
        WorkSumListViewController *wvc = [[WorkSumListViewController alloc]init];
        wvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wvc animated:YES];
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger current = _buttonViews.contentOffset.x/kScreenW;
    _pageControl.currentPage = current;
}

#pragma mark -- UIPageControl
- (void)changeBtn:(UIPageControl *)control{
    
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_tableViewArray.count < 3) {
        return _tableViewArray.count;
    }else{
        return 3;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        [cell setIConImage:[UIImage imageNamed:@"yellow"]];
    }else if (indexPath.row == 1){
        [cell setIConImage:[UIImage imageNamed:@"green"]];
    }else{
         [cell setIConImage:[UIImage imageNamed:@"blue"]];
    }
    NewsModel *nm = _tableViewArray[indexPath.row];
    [cell setModel:nm];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

//点击效果
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewsModel *nm = _tableViewArray[indexPath.row];
    
    if (nm.detail && nm.detail.length>0) {
          [self openWebPage:nm.detail title:nm.title];
    }
}

#pragma mark -- private

- (void)LWLbuildView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[EBStyle fullScrTableFrame:YES]];
    
    scrollView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    
    scrollView.height += 14;
    [scrollView setContentSize:CGSizeMake(scrollView.width, scrollView.height + 0.5)];
    self.baseScrollView = scrollView;
    self.baseScrollView.showsHorizontalScrollIndicator = NO;
    self.baseScrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:scrollView];
    
    EBRefreshHeader *refreshHeader = [EBRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshAction)];
    scrollView.mj_header = refreshHeader;
    
    //添加头部
    self.showView = [[LWLShowView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 170)];
    self.showView.lwlShowViewDelegate = self;
    [self.baseScrollView addSubview:_showView];
    
    //这个中间是10px
    
    // 中间公告栏
    _xiaoxiShouView = [[LWLNewsView alloc]initWithFrame:CGRectMake(0, self.showView.bottom+10, kScreenW, 290) ];
    _xiaoxiShouView.mainTableView.delegate= self;
    _xiaoxiShouView.mainTableView.dataSource = self;
    _xiaoxiShouView.lwlShowViewDelegate = self;
    [scrollView addSubview:_xiaoxiShouView];
    
    [_xiaoxiShouView.mainTableView registerNib:[UINib nibWithNibName:@"NewTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self addButtonViews];
    
}

- (void)addButtonViews{

    NSLog(@"arr = %@",self.arr);
//    for (NSString *str in self.arr) {
//        NSLog(@"^^^^^^^^^^^");
//        NSLog(@"str = %@",str);
//        NSLog(@"^^^^^^^^^^^");
//    }
    _buttonViews = [[ButtonViews alloc]initWithFrame:CGRectMake(0, _xiaoxiShouView.bottom+10, kScreenW, 300) containView1:@[@"查看房源",@"查看新房",@"新房跟进",@"附近房源",@"通讯录",@"我的备忘"] contaionView2:self.arr];//测试

    _buttonViews.delegate = self;
    _buttonViews.btnDelegate = self;
    _buttonViews.showsVerticalScrollIndicator = NO;
    _buttonViews.showsHorizontalScrollIndicator = NO;
 
    [self.baseScrollView addSubview:_buttonViews];
    
    self.baseScrollView.contentSize = CGSizeMake(self.baseScrollView.width, _buttonViews.bottom+20);
    //添加页面指示器
    [self.baseScrollView addSubview:self.pageControl];
    //设置frame
    
    _pageControl.frame = CGRectMake(0, 0, 100, 37);
    _pageControl.centerX = self.baseScrollView.centerX;
    _pageControl.bottom = _buttonViews.bottom - 10;
}


#pragma mark - private
- (void)buildView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[EBStyle fullScrTableFrame:YES]];
    scrollView.height += 14;
    [scrollView setContentSize:CGSizeMake(scrollView.width, scrollView.height + 0.5)];
    //    scrollView.backgroundColor = [UIColor redColor];
    self.baseScrollView = scrollView;
    [self.view addSubview:scrollView];
    EBRefreshHeader *refreshHeader = [EBRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshAction)];
    scrollView.mj_header = refreshHeader;
    
    //添加图片消息的代码
    
    self.showingView = [[SDCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollView.width, [EBStyle screenWidth] * 4.0 / 9.0)];
    
//    self.showingView = showingView;
    NSArray *news = [EBPreferences sharedInstance].workBenchDatas[@"news"];
    NSMutableArray *temp = [@[] mutableCopy];
    for (NSDictionary *dict in news) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        [temp addObject:dict[@"url"]];
    }

    self.showingView.imageURLStringsGroup = [temp copy];
    
    self.showingView.delegate = self;
    self.showingView.autoScrollTimeInterval = 4;
    
    __weak __typeof(self) weakSelf = self;

    [scrollView addSubview:self.showingView];
    
    // 中间公告栏
    NSArray *notices = [EBPreferences sharedInstance].workBenchDatas[@"notice"];
    [temp removeAllObjects];
    if (notices) {
        for (NSDictionary *dict in notices) {
            EBNews *news = [EBNews newsWithId:dict[@"document_id"] title:dict[@"title"] info:dict[@"title"] url:[NSString stringWithFormat:@"%@",dict[@"detail"]]];
            [temp addObject:news];
        }
    } else {
        EBNews *news = [EBNews newsWithId:nil title:@"加载中" info:@"加载中" url:nil];
        [temp addObject:news];
    }
    EBNewsView *newsView = [EBNewsView newsViewWithNews:[temp copy] clickAction:^(EBNews *news) {
        __strong __typeof(self) safeSelf = weakSelf;
        if (news.urlStr &&news.urlStr.length>0) {
            [safeSelf openWebPage:news.urlStr title:news.info];
        }
        
    }];
    self.newsView = newsView;
    newsView.backgroundColor = [EBStyle grayUnClickLineColor];
    newsView.frame = CGRectMake(0, self.showingView.bottom, self.view.width, newsView.height + 10);
    [scrollView addSubview:newsView];
    _containView = [[UIView alloc] initWithFrame:scrollView.bounds];
    _containView.top = newsView.bottom;
    _containView.height -= _containView.top;
    if ([EBStyle screenHeight]<=480) {
        _containView.height = 568 - _containView.top;
    }
    [scrollView addSubview:_containView];
    self.baseScrollView.contentSize = CGSizeMake(self.baseScrollView.width, _containView.bottom);

    CGFloat itemWidth = self.view.width * 0.5f;
    CGFloat itemHeight = _containView.height / (self.iconInfos.count / 2 + self.iconInfos.count % 2);

    _btnsWidth = itemWidth;
    _btnsHeifht = itemHeight - 4;
}
#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSArray *news = [EBPreferences sharedInstance].workBenchDatas[@"news"];
    if (!news) return;
    NSDictionary *dict = news[index];
    if (dict[@"detail"]&&[dict[@"detail"] length]>0) {
        [self openWebPage:dict[@"detail"] title:@""];
    }
}

#define KEY_UPDATE_FORCE @"EB_FORCED_UPDATE"
#define KEY_NEW_VERSION @"EB_ONLINE_VERSION"
#define KEY_NEW_VERSION_URL @"EB_ONLINE_VERSION_URL"

- (void)refreshAction
{
    //检查版本更新
    [[EBHttpClient wapInstance] wapRequest:nil checkUpdate:^(BOOL success, id result) {
        if (success) {

            NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSString *newVersion = result[@"version"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:result[@"version"] forKey:KEY_NEW_VERSION];
            [defaults setObject:result[@"url"] forKey:KEY_NEW_VERSION_URL];
            [defaults setBool:[result[@"force"] boolValue] forKey:KEY_UPDATE_FORCE];
            [defaults synchronize];
            
            if (![currentVersion isEqualToString:newVersion]) {
                if (![result[@"force"] boolValue]) {
                    [EBAlert alertWithTitle:nil message:NSLocalizedString(@"force_update_or", nil) yes:NSLocalizedString(@"force_update_confirm",nil) no:@"取消" confirm:^{
                        [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:[EBUpdater newVersionUrl]]];
                    }];
                }
                else{
                    [EBUpdater newVersionAvailable:result[@"version"] url:result[@"url"] force:[result[@"force"] boolValue]];
                    [EBAlert alertWithTitle:nil message:NSLocalizedString(@"force_update", nil) yes:NSLocalizedString(@"force_update_confirm",nil) confirm:^{
                        [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:[EBUpdater newVersionUrl]]];
                    }];
                }
            }
        }
    }];

    __weak __typeof(self) weakSelf = self;
    
    [[EBHttpClient wapInstance] wapRequest:nil desktop:^(BOOL success, id result) {
        __strong __typeof(self) safeSelf = weakSelf;
        if (success) {
            _arr = [NSMutableArray arrayWithObjects:@"房贷计算",@"扫二维码", @"成交合同",@"工作总结", nil];
      
            // 缓存数据
            [EBPreferences sharedInstance].workBenchDatas = result;
            [[EBPreferences sharedInstance] writePreferences];
            // 获取上部
            NSArray *news = result[@"news"];
            NSMutableArray *temp = [@[] mutableCopy];
            for (NSDictionary *dict in news) {
                if (![dict isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                [temp addObject:dict[@"url"]];
            }
            
            safeSelf.showingView.imageURLStringsGroup = [temp copy];
            [_showView.lable1 countFrom:0 to:[result[@"sevenAddDeal"] floatValue] withDuration:.5f];
            [_showView.lable2 countFrom:0 to:[result[@"sevenAddHouse"] floatValue] withDuration:.5f];
            [_showView.lable3 countFrom:0 to:[result[@"sevenAddClient"] floatValue] withDuration:.5f];
            
            // 获取中部
            NSArray *notices = result[@"notice"];
            
            for (NSDictionary *dic in notices) {
                NewsModel *nm = [[NewsModel alloc]initWithDict:dic];
                [_tableViewArray addObject:nm];
            }
            [_xiaoxiShouView.mainTableView reloadData];
            
            [temp removeAllObjects];
            
            for (NSDictionary *dict in notices) {
                EBNews *news = [EBNews newsWithId:dict[@"document_id"] title:dict[@"type"] info:dict[@"title"] url:[NSString stringWithFormat:@"%@",dict[@"detail"]]];
                [temp addObject:news];
            }
            safeSelf.newsView.news = [temp copy];
            
            // 获取底部
            for (NSInteger i = 0; i<self.iconInfos.count; i++) {
                if ([[_containView viewWithTag:10 + i] isKindOfClass:[workbenchBtn class]]) {
                    workbenchBtn *btn =(workbenchBtn *)[_containView viewWithTag:10 + i];
                    [btn removeFromSuperview];
                     btn = nil;
                }
            }
            
            //费用统计的按钮显示与隐藏
            NSNumber *monthfinance = result[@"monthfinance"];
            NSNumber *halfmonthfinance = result[@"halfmonthfinance"];
            NSNumber *dayfinance = result[@"dayfinance"];
            NSNumber *tenfinance = result[@"tenfinance"];
            
            isMonthfinance = [monthfinance intValue];
            isHalfmonthfinance = [halfmonthfinance intValue];
            isDayfinance = [dayfinance intValue];
            isTenfinance = [tenfinance intValue];
 
            
            //公司收入分账
            NSDictionary *threeFince = result[@"threeFince"];
            isShowCompanyMoney = [threeFince[@"companyMoney"] intValue];
            isShowStoneAccount = [threeFince[@"StoneAccount"] intValue];
            isShowReimbursement = [threeFince[@"Reimbursement"] intValue];
            
            if ([monthfinance intValue] == 1 ||
                [halfmonthfinance intValue] == 1 ||
                [dayfinance intValue] == 1 ||
                [tenfinance intValue] == 1) {
                isShowFee = YES;//显示
            }else{
                isShowFee = NO;

            }
            //判断是否隐藏按钮只要有一个为yes就显示
            if (isShowFee == YES ||
                isShowCompanyMoney ==YES ||isShowStoneAccount == YES || isShowReimbursement == YES) {
                [self.arr insertObject:@"门店财务" atIndex:self.arr.count-2];
            }
    
            isMoneyReceive = [threeFince[@"MoneyReceive"] intValue];
            if (isMoneyReceive == 1 && [[EBPreferences sharedInstance].companyCode isEqualToString:@"25758352"]) {
                //不隐藏
                [self.arr insertObject:@"财务收付" atIndex:self.arr.count-2];
            }else{
                if (isMoneyReceive == 1) {
                    [self.arr insertObject:@"财务收付" atIndex:self.arr.count-2];
                }
            }
            
            //工资
            _financeDec = result[@"financeDec"];
            //房源决策
            _inputDisks = result[@"inputDisks"];
            
            NSArray *finProfile = result[@"finProfile"];
            
            for (NSDictionary *dic in finProfile) {
                if ([dic.allKeys containsObject:@"name"]) {
                    [_finProfile addObject:dic[@"name"]];
                }
            }
//            for (NSString *str in self.arr) {
//                NSLog(@" ------------- ");
//                NSLog(@"str = %@",str);
//                NSLog(@" ------------- ");
//            }
            
            [_buttonViews setUI:@[@"查看房源",@"查看新房",@"新房跟进",@"附近房源",@"通讯录",@"我的备忘"] andView2:self.arr];
            
            //控制台按钮
            NSDictionary *menu = result[@"menu"];
            NSInteger numOfBtn = 0;
            for (NSInteger i = 0; i < self.iconInfos.count; i++) {
                if (([menu[self.iconInfos[i][@"name"]] count]<1)) {
                    continue;
                }
                CGFloat xOffset = (numOfBtn % 2) * _btnsWidth;
                CGFloat yOffset = (numOfBtn / 2) * _btnsHeifht;
                numOfBtn ++;
                NSDictionary *item = self.iconInfos[i];
                NSString *title = item[@"title"];
                UIImage *imgN = [UIImage imageNamed:[NSString stringWithFormat:@"wbc_%@_n", item[@"name"]]];
                workbenchBtn *btn = [[workbenchBtn alloc] initWithTitle:title imageN:imgN imageH:nil frame:CGRectMake(xOffset, yOffset, _btnsWidth, _btnsHeifht)];
                btn.tag = 10 + i;
                [btn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];

                [btn addBorderWithType:workbenchBtnBorderBottom];
                [btn addBorderWithType:workbenchBtnBorderRight];
                [_containView addSubview:btn];
            }
            
            BOOL hasMenu = [result[@"message_tips"] boolValue];
            if(hasMenu){
                [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_GATHER_FIND object:@{@"show":@"1"}]];
            }
        }
    }];
    [self.baseScrollView.mj_header endRefreshing];
}

# pragma mark - actions

- (void)openWebPage:(NSString *)url title:(NSString *)title
{
    ERPWebViewController *erpVc = [ERPWebViewController sharedInstance];
    erpVc.isHiddenRightBarItem = YES;
    
    [erpVc openWebPage:@{@"title":title,@"url":url,@"type":@"公告详情"}];
    
    erpVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:erpVc animated:YES];
}

#pragma mark -- 工作台按钮点击方法
- (void)itemClick:(UIButton *)sender
{
    NSInteger index = sender.tag - 10;
    NSString *title = self.iconInfos[index][@"title"];
    NSString *key = self.iconInfos[index][@"name"];
    NSDictionary *menu = [EBPreferences sharedInstance].workBenchDatas[@"menu"];
    NSArray *items = menu[key];
 
    EBWorkBenchMenuViewController *menuVc = [[EBWorkBenchMenuViewController alloc] init];
    menuVc.title = title;
    menuVc.items = [EBWorkBenchItem itemsWithDicts:items];
    menuVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:menuVc animated:YES];
}

- (NSArray *)iconInfos{
    if (!_iconInfos) {
        _iconInfos = @[
                       @{@"name":@"message",@"title":@"消息"},
                       @{@"name":@"store",@"title":@"店铺"},
                       @{@"name":@"resource",@"title":@"资源"},
                       @{@"name":@"action",@"title":@"行程"},
                       @{@"name":@"achievement",@"title":@"业绩"},
                       @{@"name":@"office",@"title":@"办公"},
                       ];
    }
    return _iconInfos;
}

@end
