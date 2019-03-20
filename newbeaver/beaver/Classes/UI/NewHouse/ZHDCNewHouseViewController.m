//
//  ZHDCNewHouseViewController.m
//  beaver
//
//  Created by mac on 17/4/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ZHDCNewHouseViewController.h"
#import "ZHDCHeaderView.h"
#import "NewHouseListTableViewCell.h"
#import "ZHDCNewHouseDetailViewController.h"
#import "SearchViewController.h"
#import "HttpTool.h"
#import "EBPreferences.h"
#import "MJRefresh.h"
#import "EBAlert.h"
#import "NewHouseListModel.h"
#import "MBProgressHUD+CZ.h"
#import "LEEBubble.h"
#import "CollectiveUpdateViewController.h"
#import "UITableView+PlaceHolderView.h"
#import "DefaultView.h"

@interface ZHDCNewHouseViewController ()<ZHDCHeaderViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
        int page;
        BOOL loadingHeader;
        NSInteger currentIndex;
        NSString *district;//行政区
        NSString *purpose;//用途
        NSString *area;//面积
        NSString *unit_pay;//均价
    
        NSArray *firstArr;
        NSArray *twoArr;
        NSArray *threeArr;
        NSArray *fourArr;
        NSMutableArray *strThreeArr;
        NSMutableArray *strFourArr;
}
@property (nonatomic, strong) UITableView *homeResoureTableView;
@property (nonatomic, strong)LEEBubble *bubble;
@property (nonatomic, strong)  NSMutableArray *dataArray;
@property (nonatomic, weak) ZHDCHeaderView *headerView;

@end

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@implementation ZHDCNewHouseViewController

#pragma mark -- lasy

- (UITableView *)homeResoureTableView{    
    if (!_homeResoureTableView) {
        _homeResoureTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, kScreenW, kScreenH-50-64)];
        _homeResoureTableView.delegate = self;
        _homeResoureTableView.dataSource = self;
        _homeResoureTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_homeResoureTableView setSeparatorInset:UIEdgeInsetsZero];
        [_homeResoureTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _homeResoureTableView;
}

- (void)addBuddle{
    _bubble = [[LEEBubble alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 58, CGRectGetHeight(self.view.frame) - 140, 48, 48)];
    
    _bubble.image = [UIImage imageNamed:@"image.jpg"];
    
    _bubble.edgeInsets = UIEdgeInsetsMake(64, 0 , 0 , 0);
    
    [self.view addSubview:_bubble];
    
    __weak typeof(self) weakSelf = self;
    
    _bubble.clickBubbleBlock = ^(){
        
        if (weakSelf){
            NSLog(@"集体报备");
            //点击事件
            CollectiveUpdateViewController *cuvc = [[CollectiveUpdateViewController alloc]init];
            [weakSelf.navigationController pushViewController:cuvc animated:YES];
        }
    };
}

- (void)requestData:(NSString *)typeString withPgae:(int)pageindex{
  NSLog(@"strList=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/NewHouse/getList?token=%@&page=%d&page_size=12&district=%@&purpose=%@&area=%@&unit_pay=%@",[EBPreferences sharedInstance].token,pageindex,district,purpose,area,unit_pay]);
    
    [HttpTool post:@"NewHouse/getList" parameters:@{
                                    @"token":[EBPreferences sharedInstance].token,
                                    @"page":[NSNumber numberWithInt:pageindex],
                                    @" page_size":[NSNumber numberWithInt:12],
                                    @"district":district,
                                    @"purpose":purpose,
                                    @"area":area,
                                    @"unit_pay":unit_pay
        } success:^(id responseObject) {
//        [MBProgressHUD hideHUD];
            //是否启用占位图
            _homeResoureTableView.enablePlaceHolderView = YES;
            DefaultView *defaultView = (DefaultView *)_homeResoureTableView.yh_PlaceHolderView;
            defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
            defaultView.placeText.text = @"暂无详情数据";
        //请求到数据移除数组
            if (  loadingHeader ==  YES) {
                [self.dataArray removeAllObjects];
            }
            NSDictionary *currentArray =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSArray *newHouses = currentArray[@"data"][@"data"];
            for (NSDictionary *dic in newHouses) {
                NewHouseListModel *model = [[NewHouseListModel alloc]initWithDict:dic];
                [_dataArray addObject:model];
            }
    
            if (_headerView == nil) {
                NSDictionary *filter = currentArray[@"data"][@"filter"];
                [self createData:filter];
            }
            [self.homeResoureTableView.mj_header endRefreshing];
            if (newHouses.count == 0) {
                [self.homeResoureTableView.mj_footer endRefreshingWithNoMoreData];
                 [self.homeResoureTableView reloadData];
                return ;
            }else{
                [self.homeResoureTableView.mj_footer endRefreshing];
            }
            [self.homeResoureTableView reloadData];
    } failure:^(NSError *error) {
        if (_dataArray.count == 0) {
            //是否启用占位图
            _homeResoureTableView.enablePlaceHolderView = YES;
            DefaultView *defaultView = (DefaultView *)_homeResoureTableView.yh_PlaceHolderView;
            defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
             defaultView.placeText.text = @"数据获取失败";
             [self.homeResoureTableView reloadData];
        }
            [EBAlert alertError:@"请检查网络" length:2.0f];
            [self.homeResoureTableView.mj_header endRefreshing];
            [self.homeResoureTableView.mj_footer endRefreshing];
    }];
}

-(void)footerLoading{
    self.homeResoureTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        page += 1;
        loadingHeader = NO;
        [self requestData:[EBPreferences sharedInstance].token  withPgae:page];
    }];
}
//刷新头部、、MJ
-(void)refreshHeader{
    self.homeResoureTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        loadingHeader = YES;
        [self requestData:[EBPreferences sharedInstance].token withPgae:page];//加载数据
    }];
    [self.homeResoureTableView.mj_header beginRefreshing];
}

//增加上面的视图
- (void)addTitleView{
    //加入searchBar
    UIImageView *backView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenW-100, 30)];
    backView.image = [UIImage imageNamed:@"搜索框"];
    UIImageView *imageViewIcon = [[UIImageView alloc]initWithFrame:CGRectMake(20, 7, 16, 16)];
    imageViewIcon.image = [UIImage imageNamed:@"放大镜"];
    [backView addSubview:imageViewIcon];
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imageViewIcon.frame)+10, 5, backView.width-CGRectGetMaxX(imageViewIcon.frame), 20)];
    lable.textAlignment = NSTextAlignmentLeft;
    lable.text = @"请输入新房名称";
    lable.font = [UIFont systemFontOfSize:16.0f];
    lable.textColor = [UIColor whiteColor];
    [backView addSubview:lable];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterSearchVC:)];
    backView.userInteractionEnabled = YES;
    [backView addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterSearchVC:)];
    lable.userInteractionEnabled = YES;
    [lable addGestureRecognizer:tap2];
    self.navigationItem.titleView = backView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTitleView];
    [self addRightNavigationBtnWithTitle:@"" target:nil action:nil];
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [NSMutableArray array];
    [self.view addSubview:self.homeResoureTableView];
    [self addBuddle];
    //初始化四个属性
    district = @"不限";
    purpose = @"不限";
    area = @"不限";
    unit_pay = @"不限";
    //刷新头部
    [self refreshHeader];
    [self footerLoading];
    [_homeResoureTableView registerClass:[NewHouseListTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self beaverStatistics:@"CheckNewHouse"];
}

- (void)createData:(NSDictionary *)dic{
    //  创建标题菜单
    NSArray *fourMenuTitleArray =  @[@"区域",@"用途",@"面积",@"均价"];
    //区域的数组
    firstArr = dic[@"district"][@"val"];
    //用途的数组
    twoArr = dic[@"purpose"][@"val"];
    //面积的数组
    strThreeArr = [NSMutableArray array];
    
    NSArray *areaTmp = dic[@"area"][@"val"];
    NSMutableArray *areaTmpArray = [NSMutableArray array];
    for (NSDictionary *dic in areaTmp) {
        [areaTmpArray addObject:dic[@"title"]];
        [strThreeArr addObject:[NSString stringWithFormat:@"%@;%@",dic[@"down"],dic[@"up"]]];
    }
    threeArr = (NSArray *)areaTmpArray;
    //价格的数组
    strFourArr = [NSMutableArray array];
    NSArray *unitpayTmp = dic[@"unit_pay"][@"val"];
    NSMutableArray *unit_payTmpArray = [NSMutableArray array];
    for (NSDictionary *dic in unitpayTmp) {
        [unit_payTmpArray addObject:dic[@"title"]];
        [strFourArr addObject:[NSString stringWithFormat:@"%@;%@",dic[@"down"],dic[@"up"]]];
    }
    fourArr =(NSArray *)unit_payTmpArray ;
    ZHDCHeaderView *menu = [[ZHDCHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 200)];
    _headerView = menu;
    menu.delegate = self;
    [self.view addSubview:menu];
    
    //添加的时候做判断
    if (firstArr.count != 0 && twoArr.count != 0 && threeArr.count != 0 && fourArr.count != 0) {
          [menu createFourMenuTitleArray:fourMenuTitleArray FirstArr:firstArr SecondArr:twoArr threeArr:threeArr fourArr:fourArr];
        self.homeResoureTableView.top = CGRectGetMaxY(_headerView.frame)+11;
    }
    
  
    
}

#pragma mark -- 搜索控制器
- (void)enterSearchVC:(UIBarButtonItem *)bar{
    SearchViewController *svc = [[SearchViewController alloc]init];
    [self.navigationController pushViewController:svc animated:YES];
}

#pragma mark -- 筛选按钮
- (void)menuCellDidSelected:(NSInteger)MenuIndex andDetailIndex:(NSInteger)DetailIndex{
    
    NSLog(@"菜单数:%ld 子菜单数:%ld",MenuIndex,DetailIndex);
    switch (MenuIndex) {
        case 0:
            district = firstArr[DetailIndex];
       
            break;
        case 1:
            purpose = twoArr[DetailIndex];
          
            break;
        case 2:
            area = strThreeArr[DetailIndex];
       
            break;
        case 3:
        unit_pay = strFourArr[DetailIndex];
    
            break;
            
        default:
            break;
    }
    [self refreshHeader];
}

#pragma mark -- UITableDataSoure and UITableDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewHouseListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NewHouseListModel *model  = _dataArray[indexPath.row];
    [cell setModel:model];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NewHouseListModel *model = _dataArray[indexPath.row];

    //进入详情控制器
    ZHDCNewHouseDetailViewController *detailVC = [[ZHDCNewHouseDetailViewController alloc]init];
    detailVC.house_id =  model.house_id;
    detailVC.house_title = model.house_name;
    detailVC.sale_status = model.sale_status;
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
