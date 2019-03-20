//
//  SatisfiedInvestigateViewController.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "SatisfiedInvestigateViewController.h"
#import "SatisfiedInvestModel.h"
#import "SatisfiedInvestTableViewCell.h"

@interface SatisfiedInvestigateViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int page;
    BOOL loadingHeader;
}

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据
@property (nonatomic, strong)DefaultView *defaultView;

@property (nonatomic, strong)UILabel *dealWithName;//流程经办人
@property (nonatomic, strong)UILabel *dealWithPhone;//流程经办人电话

@property (nonatomic, strong)UILabel *sellName;//业主
@property (nonatomic, strong)UILabel *sellPhone;//业主电话
@property (nonatomic, strong)UILabel *buyName;//客户
@property (nonatomic, strong)UILabel *buyPhone;//客户电话
@property (nonatomic, strong)UIButton *btn;//新增回访

@end


@implementation SatisfiedInvestigateViewController

- (UIView *)headerView{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 196)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIView *view1 = [UIView new];
//    dealwithName
    view1.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    
    UIView *testLine1 = [UIView new];
    testLine1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    _dealWithName = [UILabel new];
    _dealWithName.textAlignment = NSTextAlignmentLeft;
    _dealWithName.text = @"流程经办人: 林文龙";
    _dealWithName.textColor = UIColorFromRGB(0x404040);
    _dealWithName.font = [UIFont systemFontOfSize:13.0f];
    
    _dealWithPhone = [UILabel new];
    _dealWithPhone.textAlignment = NSTextAlignmentRight;
    _dealWithPhone.text = @"联系方式: 13528840773";
    _dealWithPhone.textColor = UIColorFromRGB(0x404040);
    _dealWithPhone.font = [UIFont systemFontOfSize:13.0f];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    _sellName = [UILabel new];
    _sellName.textAlignment = NSTextAlignmentLeft;
    _sellName.text = @"甲方（业主）: 林文龙";
    _sellName.textColor = UIColorFromRGB(0x404040);
    _sellName.font = [UIFont systemFontOfSize:13.0f];
    
    _sellPhone = [UILabel new];
    _sellPhone.textAlignment = NSTextAlignmentRight;
    _sellPhone.text = @"联系方式: 13528840773";
    _sellPhone.textColor = UIColorFromRGB(0x404040);
    _sellPhone.font = [UIFont systemFontOfSize:13.0f];
    
    UIView *line2 = [UIView new];
    line2.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    _buyName = [UILabel new];
    _buyName.textAlignment = NSTextAlignmentLeft;
    _buyName.text = @"乙方（客户）: 林文龙";
    _buyName.textColor = UIColorFromRGB(0x404040);
    _buyName.font = [UIFont systemFontOfSize:13.0f];
    
    _buyPhone = [UILabel new];
    _buyPhone.textAlignment = NSTextAlignmentRight;
    _buyPhone.text = @"联系方式: 13528840773";
    _buyPhone.textColor = UIColorFromRGB(0x404040);
    _buyPhone.font = [UIFont systemFontOfSize:13.0f];
    
    UIView *view2 = [UIView new];
    view2.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    
    UIView *testLine2 = [UIView new];
    testLine2.backgroundColor = UIColorFromRGB(0xe8e8e8);
    UIView *testLine3 = [UIView new];
    testLine3.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    UILabel *testLable = [UILabel new];
    testLable.textAlignment = NSTextAlignmentLeft;
    testLable.text = @"满意度调查";
    testLable.textColor = UIColorFromRGB(0x404040);
    testLable.font = [UIFont boldSystemFontOfSize:13.0f];
    
    _btn = [UIButton new];
//    [_btn setTitle:@"+增加回访" forState:UIControlStateNormal];
    [_btn setTitleColor:UIColorFromRGB(0x2EB2EF) forState:UIControlStateNormal];
    _btn.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [_btn addTarget:self action:@selector(addClick:) forControlEvents:UIControlEventTouchUpInside];
    _btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [headerView sd_addSubviews:@[view1,testLine1,_dealWithName,_dealWithPhone,line1,_sellName,_sellPhone,line2,_buyName,_buyPhone,view2,testLable,_btn]];
    CGFloat top = 15;
    CGFloat left = 15;
    CGFloat right = left;
    CGFloat h = 15;
    CGFloat w = kScreenW/2.0f;
    view1.sd_layout
    .topSpaceToView(headerView,0)
    .leftSpaceToView(headerView,0)
    .rightSpaceToView(headerView,0)
    .heightIs(8);
    
    testLine1.sd_layout
    .topSpaceToView(headerView,7)
    .leftSpaceToView(headerView,0)
    .rightSpaceToView(headerView,0)
    .heightIs(1);
    
    _dealWithName.sd_layout
    .topSpaceToView(view1,top)
    .leftSpaceToView(headerView,left)
    .widthIs(w)
    .heightIs(h);
    _dealWithPhone.sd_layout
    .topSpaceToView(view1,top)
    .rightSpaceToView(headerView,right)
    .widthIs(w)
    .heightIs(h);
    line1.sd_layout
    .topSpaceToView(_dealWithName,top)
    .leftSpaceToView(headerView,left)
    .rightSpaceToView(headerView,right)
    .heightIs(1);
    
    _sellName.sd_layout
    .topSpaceToView(line1,top)
    .leftSpaceToView(headerView,left)
    .widthIs(w)
    .heightIs(h);
    _sellPhone.sd_layout
    .topSpaceToView(line1,top)
    .rightSpaceToView(headerView,right)
    .widthIs(w)
    .heightIs(h);
    line2.sd_layout
    .topSpaceToView(_sellName,top)
    .leftSpaceToView(headerView,left)
    .rightSpaceToView(headerView,right)
    .heightIs(1);
    
    _buyName.sd_layout
    .topSpaceToView(line2,top)
    .leftSpaceToView(headerView,left)
    .widthIs(w)
    .heightIs(h);
    _buyPhone.sd_layout
    .topSpaceToView(line2,top)
    .rightSpaceToView(headerView,right)
    .widthIs(w)
    .heightIs(h);
    
    view2.sd_layout
    .topSpaceToView(_buyName,top)
    .leftSpaceToView(headerView,0)
    .rightSpaceToView(headerView,0)
    .heightIs(8);
    
    testLine2.sd_layout
    .topSpaceToView(_buyName,top)
    .leftSpaceToView(headerView,0)
    .rightSpaceToView(headerView,0)
    .heightIs(1);
    
    testLine3.sd_layout
    .topSpaceToView(view2,7)
    .leftSpaceToView(headerView,0)
    .rightSpaceToView(headerView,0)
    .heightIs(1);
    
    testLable.sd_layout
    .topSpaceToView(view2,top)
    .leftSpaceToView(headerView,left)
    .widthIs(w)
    .heightIs(h);
    
    _btn.sd_layout
    .topSpaceToView(view2,top)
    .rightSpaceToView(headerView,right)
    .widthIs(w)
    .heightIs(h);
    
    return headerView;
}


- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = self.mainTableView.center;
//        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];//需要更换
        _defaultView.placeText.text = @"暂无满意度调查...";
    }
    return _defaultView;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64-40)];
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableHeaderView = [self headerView];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}





- (void)viewDidLoad {
    [super viewDidLoad];

    _dataArray = [NSMutableArray array];
    [self.view addSubview:self.mainTableView];
    
    [self refreshHeader];
    [self footerLoading];
    
    [self.mainTableView registerClass:[SatisfiedInvestTableViewCell class] forCellReuseIdentifier:@"cell"];
}

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
    
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/NewDealVisit?token=%@&deal_id=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_deal_id]);
    if (_deal_id == nil) {
        [EBAlert alertError:@"合同id为空" length:2.0f];
        return;
    }
    
    NSString *urlStr = @"zhpay/NewDealVisit";//需要替换下
    
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //    _dept_id
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"page":[NSNumber numberWithInt:pageindex],
       @"page_size":[NSNumber numberWithInt:12],
       @"deal_id":_deal_id
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           if (  loadingHeader ==  YES) {
               [self.dataArray removeAllObjects];
           }
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSDictionary *dataDic = currentDic[@"data"];
           _dealWithName.attributedText = [NSString changeString:[NSString stringWithFormat:@"流程经办人: %@",dataDic[@"transfer_user_name"]] frontLength:7 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
           _dealWithPhone.attributedText = [NSString changeString:[NSString stringWithFormat:@"联系方式: %@",dataDic[@"transfer_user_tel"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
           _sellName.attributedText = [NSString changeString:[NSString stringWithFormat:@"甲方（业主）: %@",dataDic[@"owner_name"]] frontLength:7 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
           _sellPhone.attributedText = [NSString changeString:[NSString stringWithFormat:@"联系方式: %@",dataDic[@"owner_tel"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
           _buyName.attributedText = [NSString changeString:[NSString stringWithFormat:@"乙方（客户）: %@",dataDic[@"client_name"]] frontLength:7 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
           _buyPhone.attributedText = [NSString changeString:[NSString stringWithFormat:@"联系方式: %@",dataDic[@"client_tel"]] frontLength:6 frontColor:LWL_DarkGrayrColor otherColor:LWL_LightGrayColor];
           NSArray *tmpArray = dataDic[@"visit"][@"data"];//公告列表
           
           NSLog(@"tmpArray=%@",tmpArray);
           
           if ([currentDic[@"code"] integerValue] == 0) {
               for (NSDictionary *dic in tmpArray) {
                   SatisfiedInvestModel *model = [[SatisfiedInvestModel alloc]initWithDict:dic];
                   [_dataArray addObject:model];
               }
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
           
           if (_dataArray.count == 0) {//如果没有数据
               [self.mainTableView addSubview:self.defaultView];
           }else{
               if (self.defaultView) {
                   [self.defaultView  removeFromSuperview];
               }
           }
           [self.mainTableView.mj_header endRefreshing];
           
           if (tmpArray.count == 0) {
               [self.mainTableView.mj_footer endRefreshingWithNoMoreData];
               [self.mainTableView reloadData];
               return ;
           }else{
               [self.mainTableView.mj_footer endRefreshing];
           }
           [self.mainTableView reloadData];
           
       } failure:^(NSError *error) {
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           [self.mainTableView.mj_footer endRefreshing];
           [self.mainTableView.mj_header endRefreshing];
       }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SatisfiedInvestModel *model = _dataArray[indexPath.section];
    SatisfiedInvestTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setModel:model];//有数据来的时候打开
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    SatisfiedInvestModel *model = _dataArray[indexPath.section];
    NSLog(@"model=%@",model);
    return [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[SatisfiedInvestTableViewCell class] contentViewWidth:kScreenW-30];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
    
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 8)];
    view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 7, kScreenW, 1)];
    line2.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [view addSubview:line2];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 8; //这里是我的headerView和footerView的高度
    if (_mainTableView.contentOffset.y<=sectionHeaderHeight&&_mainTableView.contentOffset.y>=0) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-_mainTableView.contentOffset.y, 0, 0, 0);
    } else if (_mainTableView.contentOffset.y>=sectionHeaderHeight) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

#pragma mark -- 新增满意度调查
- (void)addClick:(UIButton *)btn{
    NSLog(@"满意度调查");
}

@end
