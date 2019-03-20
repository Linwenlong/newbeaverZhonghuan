//
//  WorkSumListViewController.m
//  beaver
//
//  Created by mac on 18/1/17.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkSumListViewController.h"
#import "WorkChooseModelViewController.h"

#import "ZYSideSlipFilterController.h"
#import "ZYSideSlipFilterRegionModel.h"
#import "CommonItemModel.h"
#import "AddressModel.h"
#import "PriceRangeModel.h"
#import "SideSlipCommonTableViewCell.h"
#import "WorkSumListModel.h"
#import "WorkSumLIstTableViewCell.h"

#import "WorkBrokerModelViewController.h"
#import "WorkTradeStaffViewController.h"
#import "WorkTradeManageViewController.h"
#import "WorkTradeCenterViewController.h"
#import "WorkDeptManagerViewController.h"
#import "WorkDeptInspectorViewController.h"
#import "ZHAreaManagerController.h"
#import "ZHShopAssistController.h"
#import "ZHShopManagerController.h"

@interface WorkSumListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int page;
    BOOL loadingHeader;

    NSString *startDate;//开始日期
    NSString *endDate;//开始日期
    
    NSString *user_type;//用户类型
    NSString *user_id;//用户id
    NSString *department_id;//用户部门
    
    NSString *workType;//职务
    NSString *status;//状态
    NSString *workContentType;//总结类型
}



@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据

@property (nonatomic,strong) UIButton *selectBtn;//编辑
@property (nonatomic,strong) UIButton *addBtn;//新增

@property (nonatomic, strong)DefaultView *defaultView;

@property (nonatomic, strong)UIView *backgroundView;

@property (strong, nonatomic) ZYSideSlipFilterController *filterController;

@end

@implementation WorkSumListViewController

- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = self.mainTableView.center;
        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];
        _defaultView.placeText.text = @"暂未获取到任何工作总结";
    }
    return _defaultView;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _mainTableView;
}


//设置导航
- (void)setNav{
    self.title = @"工作总结";
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 40)];
    //    view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc]initWithCustomView:view];
    self.navigationItem.rightBarButtonItem = bar;
    
    //上面添加btn
    _selectBtn = [UIButton new];//编辑
    [_selectBtn setImage:[UIImage imageNamed:@"workSelected"] forState:UIControlStateNormal];
    [_selectBtn addTarget:self action:@selector(selected:) forControlEvents:UIControlEventTouchUpInside];
    
    _addBtn = [UIButton new];//新增
    [_addBtn setImage:[UIImage imageNamed:@"workAdd"] forState:UIControlStateNormal];
    [_addBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    
    [view sd_addSubviews:@[_selectBtn,_addBtn]];
    CGFloat w = 30;
    
    
    _addBtn.sd_layout
    .topSpaceToView(view,5)
    .rightSpaceToView(view,0)
    .widthIs(w)
    .heightIs(w);
    
    _selectBtn.sd_layout
    .topSpaceToView(view,5)
    .rightSpaceToView(_addBtn,5)
    .widthIs(w)
    .heightIs(w);
}

-(NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:timeString];
    NSTimeInterval interval = (long)[date timeIntervalSince1970];
    return interval;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNav];
    self.view.tag = 11111;
    
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"isSelectedStaff"];//能选员工
    user_type = @"上报人";
    startDate = @"";
    endDate = @"";
    user_id = @"";
    workType = @"";
    status = @"";
    workContentType = @"";
    
    [self refreshHeader];
    [self footerLoading];
    self.dataArray = [NSMutableArray array];
    
    [self.view addSubview:self.mainTableView];
    [self addTest];
    [self.mainTableView registerClass:[WorkSumLIstTableViewCell class] forCellReuseIdentifier:@"cell"];
    [self beaverStatistics:@"WorkSummary"];
}


- (void)addTest{
    self.filterController = [[ZYSideSlipFilterController alloc] initWithSponsor:self
        resetBlock:^(NSArray *dataList) {
            [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"isSelectedStaff"];//能选员工
            for (ZYSideSlipFilterRegionModel *model in dataList) {
                //selectedStatus
                for (CommonItemModel *itemModel in model.itemList) {
                    [itemModel setSelected:NO];
                }
                        //selectedItem
                model.selectedItemList = nil;
            }
            //清楚数据
            user_type = @"上报人";
            startDate = @"";
            endDate = @"";
            user_id = @"";
            workType = @"";
            status = @"";
            workContentType = @"";
            [self refreshHeader];
            
        }commitBlock:^(NSArray *dataList) {
            NSLog(@"dataList = %@",dataList);
            //只看自己的工作总结
            ZYSideSlipFilterRegionModel *model0 = dataList[0];
            if (model0.selectedItemList.count > 0) {//只看自己的工作
                user_id = [[EBPreferences sharedInstance].userId componentsSeparatedByString:@"_"].lastObject;;
            }else{
                user_id = @"";
            }
            
            //提交人
            ZYSideSlipFilterRegionModel *model1 = dataList[1];
            if (model1.selectedItemList.count > 0) {
                CommonItemModel *commonmodel1 = model1.selectedItemList.firstObject;
                user_type = commonmodel1.itemName;
            }else{
                user_type = @"上报人";
            }
            //员工
            ZYSideSlipFilterRegionModel *model2 = dataList[2];
            if (model2.selectedItemList.count > 0) {
                NSString *tmp_user_id = model2.selectedItemList.firstObject;
                user_id = ![user_id isEqualToString:@""]?user_id :[ tmp_user_id componentsSeparatedByString:@"_"].lastObject;
//                user_id = [tmp_user_id componentsSeparatedByString:@"_"].lastObject;
            }else{
                user_id =[user_id isEqualToString:@""] ? @"" : user_id;
            }
            
            //职务
            ZYSideSlipFilterRegionModel *model3 = dataList[3];
            if (model3.selectedItemList.count > 0) {
                NSMutableArray *tmpArr = [NSMutableArray array];
                for (CommonItemModel *model in model3.selectedItemList) {
                    [tmpArr addObject:model.itemName];
                }
                workType = [tmpArr componentsJoinedByString:@";"];
            }else{
                workType = @"";
            }
           
            
            //状态
            //提交人
            ZYSideSlipFilterRegionModel *model4 = dataList[4];
            if (model4.selectedItemList.count > 0) {
                CommonItemModel *commonmodel1 = model4.selectedItemList.firstObject;
                status = commonmodel1.itemName;
            }else{
                status = @"";
            }
            
            //总结类型
            ZYSideSlipFilterRegionModel *model5 = dataList[5];
            if (model5.selectedItemList.count > 0) {
                CommonItemModel *commonmodel1 = model5.selectedItemList.firstObject;
                workContentType = commonmodel1.itemName;
            }else{
                workContentType = @"";
            }
            
            //提交时间
            ZYSideSlipFilterRegionModel *model6 = dataList[6];
            if (model6.selectedItemList.count > 0) {
                NSString *startStr = model6.selectedItemList.firstObject;
                startDate = [startStr isEqualToString:@" "] ?startStr : [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:startStr]];
        
                NSString *endStr = model6.selectedItemList.lastObject;
                endDate = [endStr isEqualToString:@" "] ? endStr :[NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:endStr]+24*60*60-1];
            }else{
                startDate = @"";
                endDate = @"";
            }
            NSLog(@"user_type=%@",user_type);
            NSLog(@"startDate=%@",startDate);
            NSLog(@"endDate=%@",endDate);
            NSLog(@"user_id=%@",user_id);
            NSLog(@"workType=%@",workType);
            NSLog(@"status=%@",status);
            NSLog(@"workContentType=%@",workContentType);
            [self refreshHeader];//刷新头部
    }];
    _filterController.animationDuration = .3f;
    _filterController.sideSlipLeading = 0.15*[UIScreen mainScreen].bounds.size.width;
    _filterController.dataList = [self packageDataList];
}



#pragma mark - ------------------------------
- (NSArray *)packageDataList {
    NSMutableArray *dataArray = [NSMutableArray array];
    [dataArray addObject:[self commonFilterRegionModelWithKeyword:@"本人" selectionType:BrandTableViewCellSelectionTypeSingle andList:@[@"只看我的总结"]]];
    [dataArray addObject:[self commonFilterRegionModelWithKeyword:@"提交人" selectionType:BrandTableViewCellSelectionTypeSingle andList:@[@"上报人",@"批注人",@"点评人"]]];
//    [dataArray addObject:[self allCategoryFilterRegionModel:@"部门"]];
    [dataArray addObject:[self allCategoryFilterRegionModel:@"员工"]];
    [dataArray addObject:[self commonFilterRegionModelWithKeyword:@"职务" selectionType:BrandTableViewCellSelectionTypeMultiple andList:@[@"经纪人",@"店助",@"店长",@"区域经理",@"区域总监"]]];
    [dataArray addObject:[self commonFilterRegionModelWithKeyword:@"状态" selectionType:BrandTableViewCellSelectionTypeSingle andList:@[@"已提交",@"已批注",@"已点评"]]];
    [dataArray addObject:[self commonFilterRegionModelWithKeyword:@"总结类型" selectionType:BrandTableViewCellSelectionTypeSingle andList:@[@"日常总结",@"一周总结",@"一月总结",@"半年总结",@"一年总结"]]]
    ;
    [dataArray addObject:[self priceFilterRegionModel]];
    
    return [dataArray mutableCopy];
}

- (ZYSideSlipFilterRegionModel *)commonFilterRegionModelWithKeyword:(NSString *)keyword selectionType:(CommonTableViewCellSelectionType)selectionType
    andList:(NSArray *)list{
    ZYSideSlipFilterRegionModel *model = [[ZYSideSlipFilterRegionModel alloc] init];
    model.containerCellClass = @"SideSlipCommonTableViewCell";
    model.isShowAll = YES;
    model.regionTitle = keyword;
    model.customDict = @{REGION_SELECTION_TYPE:@(selectionType)};
    NSMutableArray *tmp = [NSMutableArray array];
    for (int i = 0; i < list.count; i++ ) {
        NSString *str = list[i];
        [tmp addObject:[self createItemModelWithTitle:str itemId:[NSString stringWithFormat:@"%d",i+1] selected:NO]];
    }
    model.itemList = tmp;
    return model;
}

- (CommonItemModel *)createItemModelWithTitle:(NSString *)itemTitle
                                       itemId:(NSString *)itemId
                                     selected:(BOOL)selected {
    CommonItemModel *model = [[CommonItemModel alloc] init];
    model.itemId = itemId;
    model.itemName = itemTitle;
    model.selected = selected;
    return model;
}

- (ZYSideSlipFilterRegionModel *)serviceFilterRegionModel {
    ZYSideSlipFilterRegionModel *model = [[ZYSideSlipFilterRegionModel alloc] init];
    model.containerCellClass = @"SideSlipServiceTableViewCell";
    model.regionTitle = @"本人";
    model.itemList = @[[self createItemModelWithTitle:@"只看我的总结" itemId:@"0000" selected:NO]];
    return model;
}

- (ZYSideSlipFilterRegionModel *)priceFilterRegionModel {
    ZYSideSlipFilterRegionModel *model = [[ZYSideSlipFilterRegionModel alloc] init];
    model.containerCellClass = @"SideSlipPriceTableViewCell";
    model.regionTitle = @"提交时间";
    return model;
}

- (ZYSideSlipFilterRegionModel *)allCategoryFilterRegionModel:(NSString *)title{
    ZYSideSlipFilterRegionModel *model = [[ZYSideSlipFilterRegionModel alloc] init];
    model.containerCellClass = @"SideSlipAllCategoryTableViewCell";
    model.regionTitle = title;
    model.customDict = @{ADDRESS_LIST:[self generateAddressDataList]};
    return model;
}

- (ZYSideSlipFilterRegionModel *)spaceFilterRegionModel {
    ZYSideSlipFilterRegionModel *model = [[ZYSideSlipFilterRegionModel alloc] init];
    model.containerCellClass = @"SideSlipSpaceTableViewCell";
    return model;
}

- (NSArray *)generateAddressDataList {
    return @[[self createAddressModelWithAddress:@"广州市天河区猎德地铁站" addressId:@"0000"],
             [self createAddressModelWithAddress:@"广州市天河区珠江新城地铁站" addressId:@"0001"],
             [self createAddressModelWithAddress:@"广州市天河区潭村地铁站" addressId:@"0002"],
             [self createAddressModelWithAddress:@"广州市天河区黄埔大道西地铁站" addressId:@"0003"],
             [self createAddressModelWithAddress:@"广州市天河区员村街道员村地铁站临江大道员村二横路自编25号" addressId:@"0004"],
             [self createAddressModelWithAddress:@"广州市天河区昌岗地铁站" addressId:@"0005"]];
}

- (AddressModel *)createAddressModelWithAddress:(NSString *)address addressId:(NSString *)addressId {
    AddressModel *model = [[AddressModel alloc] init];
    model.addressString = address;
    model.addressId = addressId;
    return model;
}

#pragma mark -- ------------------------------

-(void)footerLoading{
    
    self.mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        page += 1;
        loadingHeader = NO;
        [self requestData:page];
    }];
}

//刷新头部、、MJ
-(void)refreshHeader{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        loadingHeader = YES;
        [self requestData:page];//加载数据
    }];
    [self.mainTableView.mj_header beginRefreshing];
}

- (void)requestData:(int)pageindex{
   
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    [parm setObject:user_type forKey:@"user_type"];
    //查询某个人的
    if ([user_type isEqualToString:@"上报人"]) {
         [parm setObject:user_id forKey:@"user_id"];//上报人
    }else if ([user_type isEqualToString:@"批注人"]){
        [parm setObject:user_id forKey:@"opinion_user_id"];//批注人
    }else if ([user_type isEqualToString:@"点评人"]){
        [parm setObject:user_id forKey:@"comment_user_id"];//点评人
    }
    [parm setObject:workType forKey:@"tmp_type"];
    [parm setObject:status forKey:@"status"];
    [parm setObject:workContentType forKey:@"type"];
    
    //时间
    [parm setObject:startDate forKey:@"begin_time"];
    [parm setObject:endDate forKey:@"end_time"];
    
    [parm setObject:[NSNumber numberWithInt:pageindex] forKey:@"page"];
    [parm setObject:[NSNumber numberWithInt:20] forKey:@"page_size"];
    
    NSLog(@"dic = %@",parm);
    
    NSString *urlStr = @"jobsummary/jobSummaryList";//工作总结列表
    
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:[parm mutableCopy] success:^(id responseObject) {
        [EBAlert hideLoading];
        
        //是否启用占位图
        if (loadingHeader ==  YES) {
            [self.dataArray removeAllObjects];
        }
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([currentDic[@"code"] integerValue] != 0) {
            [EBAlert alertError:currentDic[@"desc"] length:2.0f];
            [self.mainTableView.mj_footer endRefreshing];
            [self.mainTableView.mj_header endRefreshing];
            return ;
        }
        NSArray *tmpArray = currentDic[@"data"][@"data"];
        for (NSDictionary *dic in tmpArray) {
            WorkSumListModel *model = [[WorkSumListModel alloc]initWithDict:dic];
            
            [self.dataArray addObject:model];
        }
        if (self.dataArray.count == 0) {//如果没有数据
            [self.mainTableView addSubview:self.defaultView];
        }else{
            if (self.defaultView) {
                [self.defaultView  removeFromSuperview];
            }
        }
        if (tmpArray.count == 0) {
            [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
            [self.mainTableView.mj_header endRefreshing];
            [self.mainTableView reloadData];
            return ;
        }else{
            [self.mainTableView.mj_footer endRefreshing];
        }
        [self.mainTableView reloadData];
        [self.mainTableView.mj_header endRefreshing];
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"请检查网络" length:2.0f];
        [self.mainTableView.mj_header endRefreshing];
        [self.mainTableView.mj_footer endRefreshing];
    }];
    
}

#pragma mark -- Method
- (void)selected:(UIButton*)btn{
    NSLog(@"筛选");
    [_filterController show];
}

- (void)add:(UIButton*)btn{
    NSLog(@"新增");
    //调用接口选择模版
    //    //初始化数据
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
    
   NSString * start = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentDateStr]];//开启日
   NSString * end = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentDateStr]+(24*60*60-1)];//结束日期
    NSLog(@"start = %@",start);
    NSLog(@"end = %@",end);
    
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    [parm setObject:start forKey:@"begin_time"];
    [parm setObject:end forKey:@"end_time"];
    [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    NSLog(@"parm = %@",parm);
    NSString *urlStr = @"jobsummary/generateNewSummary";//工作总结模版
    [EBAlert showLoading:@"加载模版中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:parm success:^(id responseObject) {
        [EBAlert hideLoading];
        
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"currentDic=%@",currentDic);
        if ([currentDic[@"code"] integerValue] != 0) {
            [EBAlert alertError:currentDic[@"desc"] length:2.0f];
            return ;
        }else{
            if (!([currentDic[@"data"][@"tmp_type"] isEqualToString:@"agent"]||[currentDic[@"data"][@"tmp_type"] isEqualToString:@"assistant"]||[currentDic[@"data"][@"tmp_type"] isEqualToString:@"manager"] ||
                [currentDic[@"data"][@"tmp_type"] isEqualToString:@"regional-manager"]||
                  [currentDic[@"data"][@"tmp_type"] isEqualToString:@"director"])) {
                [EBAlert alertError:@"暂无无法加载该工作总结模版" length:2.0f];
                return;
            }
            //进入模版
            if ([currentDic[@"data"][@"tmp_type"] isEqualToString:@"agent"]) {//经纪人
                WorkBrokerModelViewController *wbvc = [[WorkBrokerModelViewController alloc]init];
                wbvc.dayData = currentDic[@"data"][@"dayData"];
                wbvc.monthData = currentDic[@"data"][@"monthData"];
                wbvc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wbvc animated:YES];
            }else if ([currentDic[@"data"][@"tmp_type"] isEqualToString:@"regional-manager"]){//区域经理
                ZHAreaManagerController *amvc = [[ZHAreaManagerController alloc]initWithNibName:@"ZHAreaManagerController" bundle:nil];
                amvc.dayData = currentDic[@"data"][@"dayData"];
                amvc.monthData = currentDic[@"data"][@"monthData"];
                amvc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:amvc animated:YES];
            }else if ([currentDic[@"data"][@"tmp_type"] isEqualToString:@"assistant"]){//店助
                ZHShopAssistController *wsac = [[ZHShopAssistController alloc]initWithNibName:@"ZHShopAssistController" bundle:nil];
                wsac.dayData = currentDic[@"data"][@"dayData"];
                wsac.monthData = currentDic[@"data"][@"monthData"];
                wsac.hidesBottomBarWhenPushed = YES;
                wsac.VcTag = 0;
                [self.navigationController pushViewController:wsac animated:YES];
            }else if ([currentDic[@"data"][@"tmp_type"] isEqualToString:@"manager"]){//店长
                ZHShopManagerController *wsmc = [[ZHShopManagerController alloc]initWithNibName:@"ZHShopManagerController" bundle:nil];
                wsmc.dayData = currentDic[@"data"][@"dayData"];
                wsmc.monthData = currentDic[@"data"][@"monthData"];
                wsmc.hidesBottomBarWhenPushed = YES;
                wsmc.VcTag = 0;
                wsmc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wsmc animated:YES];
            }else if ([currentDic[@"data"][@"tmp_type"] isEqualToString:@"trading-sign"]){//签约岗
                WorkTradeCenterViewController *wtcvc = [[WorkTradeCenterViewController alloc]init];
                wtcvc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wtcvc animated:YES];
            }else if ([currentDic[@"data"][@"tmp_type"] isEqualToString:@"trading-staff"]){//交易专员
                WorkTradeStaffViewController *wtsvc = [[WorkTradeStaffViewController alloc]init];
                wtsvc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wtsvc animated:YES];
            }else if ([currentDic[@"data"][@"tmp_type"] isEqualToString:@"trading-director"]){//部门经理
                WorkTradeManageViewController *wtmvc = [[WorkTradeManageViewController alloc]init];
                wtmvc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wtmvc animated:YES];
            }else if ([currentDic[@"data"][@"tmp_type"] isEqualToString:@"department-manager"]){//部门经理
                WorkDeptManagerViewController *wtmvc = [[WorkDeptManagerViewController alloc]init];
                wtmvc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wtmvc animated:YES];
            }else if ([currentDic[@"data"][@"tmp_type"] isEqualToString:@"director"]){//大区总监
                WorkDeptInspectorViewController *wtmvc = [[WorkDeptInspectorViewController alloc]init];
                wtmvc.dayData = currentDic[@"data"][@"dayData"];
                wtmvc.monthData = currentDic[@"data"][@"monthData"];
                wtmvc.regionList = currentDic[@"data"][@"regionList"];
                wtmvc.modelType = LWLWorkInsperctorTypeAdd;
                wtmvc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:wtmvc animated:YES];
            }else{
                [EBAlert alertError:@"抱歉,不支持的模版类型" length:2.0f];
            }
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"请检查网络" length:2.0f];
        
    }];

    
}

#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WorkSumListModel *model = self.dataArray[indexPath.row];
    WorkSumLIstTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    WorkSumListModel *model = self.dataArray[indexPath.row];
    return [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[WorkSumLIstTableViewCell class] contentViewWidth:kScreenW];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入详情
    NSLog(@"工作详情");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WorkSumListModel *model = self.dataArray[indexPath.row];
    NSLog(@"%@",model.tmp_type);
    if (!([model.tmp_type isEqualToString:@"agent"]||[model.tmp_type isEqualToString:@"assistant"]||[model.tmp_type isEqualToString:@"manager"]||[model.tmp_type isEqualToString:@"regional-manager"]||
          [model.tmp_type isEqualToString:@"director"])) {
        [EBAlert alertError:@"暂无无法加载该工作总结详情" length:2.0f];
        return;
    }
    //进入模版
    if ([model.tmp_type isEqualToString:@"agent"]) {//经纪人
        WorkBrokerModelViewController *wbvc = [[WorkBrokerModelViewController alloc]init];
        wbvc.document_id = model.document_id;
        wbvc.modelType = LWLWorkTypeEdit;
        wbvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wbvc animated:YES];
    }else if ([model.tmp_type isEqualToString:@"regional-manager"]){//区域经理
        ZHAreaManagerController *amvc = [[ZHAreaManagerController alloc]initWithNibName:@"ZHAreaManagerController" bundle:nil];
        amvc.hidesBottomBarWhenPushed = YES;
        amvc.document_id = model.document_id;
        amvc.VcTag = 1;
        [self.navigationController pushViewController:amvc animated:YES];
    }else if ([model.tmp_type isEqualToString:@"assistant"]){//店助
        ZHShopAssistController *wbvc = [[ZHShopAssistController alloc]initWithNibName:@"ZHShopAssistController" bundle:nil];
        wbvc.document_id = model.document_id;
        wbvc.VcTag = 1;
        wbvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wbvc animated:YES];
    }else if ([model.tmp_type isEqualToString:@"manager"]){//店长
        ZHShopManagerController *wbvc = [[ZHShopManagerController alloc]initWithNibName:@"ZHShopManagerController" bundle:nil];
        wbvc.document_id = model.document_id;
        wbvc.VcTag = 1;
        wbvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wbvc animated:YES];
        
    }else if ([model.tmp_type isEqualToString:@"trading-sign"]){//签约岗
        WorkTradeCenterViewController *wtcvc = [[WorkTradeCenterViewController alloc]init];
        wtcvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wtcvc animated:YES];
    }else if ([model.tmp_type isEqualToString:@"trading-staff"]){//交易专员
        WorkTradeStaffViewController *wtsvc = [[WorkTradeStaffViewController alloc]init];
        wtsvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wtsvc animated:YES];
    }else if ([model.tmp_type isEqualToString:@"trading-director"]){//部门经理
        WorkTradeManageViewController *wtmvc = [[WorkTradeManageViewController alloc]init];
        wtmvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wtmvc animated:YES];
    }else if ([model.tmp_type isEqualToString:@"department-manager"]){//部门经理
        WorkDeptManagerViewController *wtmvc = [[WorkDeptManagerViewController alloc]init];
        wtmvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wtmvc animated:YES];
    }else if ([model.tmp_type isEqualToString:@"director"]){//大区总监
        WorkDeptInspectorViewController *wtmvc = [[WorkDeptInspectorViewController alloc]init];
        wtmvc.document_id = model.document_id;
        wtmvc.modelType = LWLWorkInsperctorTypeEdit;
        wtmvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:wtmvc animated:YES];
    }
}

- (void)dealloc{
    [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"isSelectedStaff"];//能选员工
}

@end
