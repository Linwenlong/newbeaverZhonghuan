//
//  FinancialDetainAndHandViewController.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinancialDetainAndHandViewController.h"
#import "FinancialHeaderView.h"
#import "ContractHeaderView.h"
#import "FinancialDetainAndHandTableViewCell.h"
#import "FinancialDetainModel.h"
#import "ChargeSellAndBuyTableViewCell.h"

@interface FinancialDetainAndHandViewController ()<ContractHeaderViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)ContractHeaderView *headerView;
@property (nonatomic, strong)UIScrollView *reafedScrollView;//下拉

//甲方
@property (nonatomic, strong)NSMutableArray *arrSell;
@property (nonatomic, assign)CGFloat sell_totel_fee;//总费用
@property (nonatomic, assign)CGFloat sell_totel_other;//欠费

//乙方
@property (nonatomic, strong)NSMutableArray *arrBuy;
@property (nonatomic, assign)CGFloat buy_totel_fee;//总费用
@property (nonatomic, assign)CGFloat buy_totel_other;//欠费

@property (nonatomic, strong)UIScrollView *mainScrollView;//主滚动视图
@property (nonatomic, strong)UITableView *tableView1;//应收
@property (nonatomic, strong)UITableView *tableView2;//实收

@property (nonatomic, strong)NSMutableArray *dataArray1;//应收
@property (nonatomic, strong)NSMutableArray *dataArray2;//实收

@property (nonatomic, strong)DefaultView *defaultView1;
@property (nonatomic, strong)DefaultView *defaultView2;

@property (nonatomic, assign)CGFloat price_totle;//总额

//tableView1
@property (nonatomic, weak)UILabel * leftLable;
@property (nonatomic, weak)UILabel * rightLable;

//tableView2
@property (nonatomic, weak)UILabel * leftLable1;
@property (nonatomic, weak)UILabel * rightLable1;


@property (nonatomic, weak)UILabel * customerleftLable;
@property (nonatomic, weak)UILabel * customerRightLableTop;
@property (nonatomic, weak)UILabel * customerRightLableBottom;
@property (nonatomic, weak)UILabel * sellleftLable;
@property (nonatomic, weak)UILabel * sellRightLableTop;
@property (nonatomic, weak)UILabel * sellRightLableBottom;

@property (nonatomic, weak)UILabel * yingli;
@property (nonatomic, weak)UILabel * shishou;
@property (nonatomic, weak)UILabel * shifu;
@property (nonatomic, weak)UILabel * yue;

@property (nonatomic, weak)UILabel * shangdai;
@property (nonatomic, weak)UILabel * pinggu;
@property (nonatomic, weak)UILabel * gongjijin;


@end

@implementation FinancialDetainAndHandViewController


- (UIView *)headerView1{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 45)];
    headerView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    UIView *line1 = [UIView new];
    
    line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    UILabel *leftLable = [UILabel new];
    leftLable.textAlignment = NSTextAlignmentLeft;
    leftLable.text = @"";
    _leftLable = leftLable;
    leftLable.textColor = UIColorFromRGB(0x404040);
    leftLable.font = [UIFont boldSystemFontOfSize:13.0f];
    
    UILabel *rightLable = [UILabel new];
    _rightLable = rightLable;
    rightLable.textAlignment = NSTextAlignmentRight;
    
    rightLable.textColor = UIColorFromRGB(0x404040);
    rightLable.font = [UIFont boldSystemFontOfSize:13.0f];
    
    [headerView sd_addSubviews:@[line1,leftLable,rightLable]];
    
    line1.sd_layout
    .topSpaceToView(headerView,0)
    .leftSpaceToView(headerView,0)
    .rightSpaceToView(headerView,0)
    .heightIs(1);
    
    leftLable.sd_layout
    .topSpaceToView(headerView,15)
    .leftSpaceToView(headerView,15)
    .widthIs(kScreenW/2.0f)
    .heightIs(15);
    
    rightLable.sd_layout
    .topSpaceToView(headerView,15)
    .rightSpaceToView(headerView,15)
    .widthIs(kScreenW/2.0f)
    .heightIs(15);
    
    return headerView;
}

- (UIView *)headerView2{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 45)];
    headerView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    UIView *line1 = [UIView new];
    
    line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    UILabel *leftLable = [UILabel new];
    leftLable.textAlignment = NSTextAlignmentLeft;
    leftLable.text = @"";
    _leftLable1 = leftLable;
    leftLable.textColor = UIColorFromRGB(0x404040);
    leftLable.font = [UIFont boldSystemFontOfSize:13.0f];
    
    UILabel *rightLable = [UILabel new];
    _rightLable1 = rightLable;
    rightLable.textAlignment = NSTextAlignmentRight;
    rightLable.textColor = UIColorFromRGB(0x404040);
    rightLable.font = [UIFont boldSystemFontOfSize:13.0f];
    
    [headerView sd_addSubviews:@[line1,leftLable,rightLable]];
    
    line1.sd_layout
    .topSpaceToView(headerView,0)
    .leftSpaceToView(headerView,0)
    .rightSpaceToView(headerView,0)
    .heightIs(1);
    
    leftLable.sd_layout
    .topSpaceToView(headerView,15)
    .leftSpaceToView(headerView,15)
    .widthIs(kScreenW/2.0f)
    .heightIs(15);
    
    rightLable.sd_layout
    .topSpaceToView(headerView,15)
    .rightSpaceToView(headerView,15)
    .widthIs(kScreenW/2.0f)
    .heightIs(15);
    
    return headerView;
}
- (DefaultView *)defaultView1{
    if (!_defaultView1) {
        _defaultView1 = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView1.center = self.tableView1.center;
        _defaultView1.top -= 40;
        _defaultView1.placeView.image = [UIImage imageNamed:@"contract"];//需要更换
        _defaultView1.placeText.text = @"暂无应收信息...";
    }
    return _defaultView1;
}
- (DefaultView *)defaultView2{
    if (!_defaultView2) {
        _defaultView2 = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView2.center = self.tableView2.center;
        _defaultView2.top -= 40;
        _defaultView2.placeView.image = [UIImage imageNamed:@"contract"];//需要更换
        _defaultView2.placeText.text = @"暂无实收、实付信息...";
    }
    return _defaultView2;
}

- (UIScrollView *)reafedScrollView{
    if (!_reafedScrollView) {
        _reafedScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        //        _reafedScrollView.delegate = self;
    }
    return _reafedScrollView;
}

- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        _mainScrollView.backgroundColor = [UIColor grayColor];
//        _mainScrollView.delegate = self;
        _mainScrollView.pagingEnabled = YES;
//        _mainScrollView.contentSize = CGSizeMake(kScreenW*2, 0);
    }
    return _mainScrollView;
}


- (UITableView *)tableView1{
    if (!_tableView1) {
        _tableView1 = [[UITableView alloc]initWithFrame:CGRectMake(0, _headerView.height, kScreenW, kScreenH-155)];
//        _tableView1.bounces = YES;
        _tableView1.tableHeaderView = [self headerView1];
        _tableView1.delegate = self;
        _tableView1.dataSource = self;
        _tableView1.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView1.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _tableView1.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView1;
}


- (UITableView *)tableView2{
    if (!_tableView2) {
        _tableView2 = [[UITableView alloc]initWithFrame:CGRectMake(kScreenW,_headerView.height, kScreenW, kScreenH-155)];
        _tableView2.delegate = self;
         _tableView2.dataSource = self;
        _tableView2.bounces = YES;
        _tableView2.tableHeaderView = [self headerView2];
        _tableView2.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _tableView2.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView2;
}

//设置UI
- (void)setUI{
    //添加数据源
    _arrSell = [NSMutableArray array];
    _arrBuy = [NSMutableArray array];
    //1.添加下拉视图
    [self.view addSubview:self.reafedScrollView];
    NSLog(@"reafedScrollView=%@",self.reafedScrollView);
    //1.添加主滚动视图
    [self.reafedScrollView addSubview:self.mainScrollView];
    //2.添加头部视图
    _headerView = [[ContractHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 52) leftTitle:@"甲方（卖家）" rightTitle:@"已方（买家）"];
    _headerView.backgroundColor = [UIColor whiteColor];
    _headerView.contractDelegate = self;
    [self.reafedScrollView addSubview:_headerView];
    [self.reafedScrollView bringSubviewToFront:_headerView];
    //3.添加tableview
    [_mainScrollView addSubview:self.tableView1];
    [_mainScrollView addSubview:self.tableView2];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    
    [self refreshHeader];
    [_tableView1 registerClass:[ChargeSellAndBuyTableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView2 registerClass:[ChargeSellAndBuyTableViewCell class] forCellReuseIdentifier:@"cell"];
}
- (void)requestData{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/NewDealFeesDetail?token=%@&deal_code=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_deal_code]);
    if (_deal_code == nil) {
        [EBAlert alertError:@"合同编号为空" length:2.0f];
        return;
    }
    NSString *urlStr = @"zhpay/NewDealFeesDetail";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"deal_code":_deal_code
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           [_dataArray1 removeAllObjects];
           [_dataArray2 removeAllObjects];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSArray *tmpArray = currentDic[@"data"][@"data"];
           NSLog(@"tmpArray=%@",tmpArray);
            [self.reafedScrollView.mj_header endRefreshing];
           if ([tmpArray isKindOfClass:[NSArray class]]) {//数组就解析数据
                [self analysisData:tmpArray];
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
       } failure:^(NSError *error) {
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           [self.reafedScrollView.mj_header endRefreshing];
       }];
}

- (void)analysisData:(NSArray *)tmpArray{
    
    for (NSDictionary *dic in tmpArray) {
        if ([dic.allKeys containsObject:@"holder"] && [dic[@"holder"] isEqualToString:@"1"]) {
            [_arrSell addObject:dic];
            //欠费
            NSLog(@"received = %d",[NSString StringIsNullOrEmpty:dic[@"received"]]);
            NSLog(@"receivable = %d",[NSString StringIsNullOrEmpty:dic[@"receivable"]]);
            
            if (![NSString StringIsNullOrEmpty:dic[@"receivable"]]) {
                _sell_totel_fee += [dic[@"receivable"] floatValue];
                //欠费
                NSLog(@"null = %d",[NSString StringIsNullOrEmpty:dic[@"received"]]);
                if (![NSString StringIsNullOrEmpty:dic[@"received"]]) {
                    _sell_totel_other += [dic[@"receivable"] floatValue] - [dic[@"received"] floatValue];
                }else{
                    _sell_totel_other += [dic[@"receivable"] floatValue] - 0;
                }
            }
        }else{
            [_arrBuy addObject:dic];
            if (dic[@"receivable"] != nil) {
                _buy_totel_fee += [dic[@"receivable"] floatValue];
                //欠费
                if (dic[@"received"] != nil) {
                    _buy_totel_other += [dic[@"receivable"] floatValue] - [dic[@"received"] floatValue];
                }else{
                    _buy_totel_other += [dic[@"receivable"] floatValue] - 0;
                }
            }
        }
    }
    
    [self setTest];
}

- (void)setTest{
    
    _leftLable.attributedText = [NSString changeString:[NSString stringWithFormat:@"应收合计: %0.02f",_sell_totel_fee] frontLength:6 frontColor:LWL_LightGrayColor otherColor:LWL_RedColor ];
    if (_sell_totel_other > 0) {
        _rightLable.text = [NSString stringWithFormat:@"欠费: %0.2f",fabs(_sell_totel_other)];
        _rightLable.textColor = LWL_PurpleColor;
    }else if (_sell_totel_other < 0){
        _rightLable.text = [NSString stringWithFormat:@"应退: %0.2f",fabs(_sell_totel_other)];
        _rightLable.textColor = LWL_YellowColor;
    }else{
        _rightLable.text = @"已补齐";
        _rightLable.textColor = LWL_GreenColor;
    }
    
    _leftLable1.attributedText = [NSString changeString:[NSString stringWithFormat:@"应收合计: %0.02f",_buy_totel_fee] frontLength:6 frontColor:LWL_LightGrayColor otherColor:LWL_RedColor ];
    if (_buy_totel_other > 0) {
        _rightLable1.text = [NSString stringWithFormat:@"欠费: %0.2f",fabs(_buy_totel_other)];
        _rightLable1.textColor = LWL_PurpleColor;
    }else if (_buy_totel_other < 0){
        _rightLable1.text = [NSString stringWithFormat:@"应退: %0.2f",fabs(_buy_totel_other)];
        _rightLable1.textColor = LWL_YellowColor;
    }else{
        _rightLable1.text = @"已补齐";
        _rightLable1.textColor = LWL_GreenColor;
    }
    
    [self.tableView1 reloadData];
    [self.tableView2 reloadData];
}


//刷新头部、、MJ
-(void)refreshHeader{
    //刷新头部视图
    self.reafedScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];//加载数据
    }];
    [self.reafedScrollView.mj_header beginRefreshing];
}

- (void)test{
    [self.reafedScrollView.mj_header endRefreshing];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

#pragma mark -- ContractHeaderViewDelegate

-(void)currentBtn:(UIButton *)btn otherBtn:(UIButton *)otherBtn{
    
    CGPoint offset = self.mainScrollView.contentOffset;
    offset.x = self.mainScrollView.width * btn.tag;
    [self.mainScrollView setContentOffset:offset animated:YES];
    
    [UIView animateWithDuration:0.5 animations:^{
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    }];
    
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == _tableView1) {
        return _arrSell.count;
    }else{
        return _arrBuy.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChargeSellAndBuyTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dic = nil;
    if (tableView == _tableView1) {
        dic = _arrSell[indexPath.section];
    }else{
        dic = _arrBuy[indexPath.section];
    }
    [cell setDic:dic];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 ) {
        return 0;
    }
    return 8;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0 ) {
        return nil;
    }
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
    if (_tableView1.contentOffset.y<=sectionHeaderHeight&&_tableView1.contentOffset.y>=0) {
        _tableView1.contentInset = UIEdgeInsetsMake(-_tableView1.contentOffset.y, 0, 0, 0);
    } else if (_tableView1.contentOffset.y>=sectionHeaderHeight) {
        _tableView1.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
