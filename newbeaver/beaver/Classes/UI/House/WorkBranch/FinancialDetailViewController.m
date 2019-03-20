//
//  FinancialDetailViewController.m
//  beaver
//
//  Created by mac on 17/11/26.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinancialDetailViewController.h"
#import "CKSlideMenu.h"
#import "FinancialHeaderView.h"
#import "FinancialTableViewCell.h"
#import "FinancialDetailTableViewCell.h"
#import "HWPopTool.h"
#import "NSString+Zirkfied.h"
#import "ZHFundEditController.h"
#import "ZHCheckController.h"

@interface FinancialDetailViewController ()<FinancialHeaderViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    int page;
    BOOL loadingHeader;
    float price_num;
    NSInteger enit_count;
    NSInteger current_offx;

}
@property (nonatomic, strong)FinancialHeaderView *headerView;
@property (nonatomic, strong)UIScrollView *reafedScrollView;//下拉
@property (nonatomic, strong)UIScrollView *mainScrollView;//主滚动视图

@property (nonatomic, strong)DefaultView *defaultView1;//客户
@property (nonatomic, strong)DefaultView *defaultView2;//客户

@property (nonatomic, strong)UITableView *tableView1;//客户
@property (nonatomic, strong)UITableView *tableView2;//业主

@property (nonatomic, strong)NSMutableArray *dataArray1;//客户
@property (nonatomic, strong)NSMutableArray *dataArray2;//业主

@property (nonatomic, strong)NSMutableArray *selectArray1;//客户选择
@property (nonatomic, strong)NSMutableArray *selectArray2;//业主选择

@property (nonatomic,strong) UIView *popView;
@property (nonatomic,strong) UIImageView *qrImageView;

@property (nonatomic,strong) UIButton *edit;//编辑
@property (nonatomic,strong) UIButton *add;//新增

//底部
//非编辑状态的view
@property (nonatomic, strong)UIView *noEditbackView;
@property (nonatomic, strong)UILabel *type;//总实收
@property (nonatomic, strong)UILabel *price;//价格

//编辑状态的view
@property (nonatomic, strong)UIView *EditbackView;
@property (nonatomic, strong)UIButton *allBtn;//全选图

@property (nonatomic, strong)UILabel *selectedClient;//已选客户
@property (nonatomic, strong)UILabel *selectedProprietor;//已选业主

@property (nonatomic, strong)UIButton *bringAdd;//生成订单号

@end

@implementation FinancialDetailViewController


#pragma mark -- 懒加载

- (void)addEditSubviews{
    _allBtn = [UIButton new];
    [_allBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_allBtn setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
    [_allBtn addTarget:self action:@selector(selectedAll:) forControlEvents:UIControlEventTouchUpInside];
    _allBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_allBtn setImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    _allBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _allBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    _allBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    NSString *clientStr = @"已选客户: 0";
    
    _selectedClient = [UILabel new];
    _selectedClient.text = clientStr;

    _selectedClient.textAlignment = NSTextAlignmentLeft;
    _selectedClient.font = [UIFont systemFontOfSize:13.0f];
    _selectedClient.textColor = UIColorFromRGB(0x808080);
    
    NSString *proprietorStr = @"已选业主: 0";
    _selectedProprietor = [UILabel new];
    _selectedProprietor.text = proprietorStr;
    
    _selectedProprietor.textAlignment = NSTextAlignmentLeft;
    _selectedProprietor.font = [UIFont systemFontOfSize:13.0f];
    _selectedProprietor.textColor = UIColorFromRGB(0x808080);
    
    _bringAdd = [UIButton new];
    [_bringAdd setTitle:@"生成订单号" forState:UIControlStateNormal];
    _bringAdd.backgroundColor = UIColorFromRGB(0xff3800);
    [_bringAdd addTarget: self action:@selector(bringOrder:) forControlEvents:UIControlEventTouchUpInside];
    [_bringAdd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _bringAdd.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    
    [_EditbackView sd_addSubviews:@[_allBtn,_selectedClient,_selectedProprietor,_bringAdd]];
    CGFloat x = 15;
    CGFloat h = 20;
    _allBtn.sd_layout
    .leftSpaceToView(_EditbackView,x)
    .topSpaceToView(_EditbackView,(_EditbackView.height-h)/2.0f)
    .widthIs(60)
    .heightIs(h);
    CGFloat spaing = 0;
    CGFloat btn_w = 0;
    if (kScreenW > 320) {
        spaing = 18;
        btn_w = 100;
    }else{
        spaing = 10;
        btn_w = 80;
    }
    _selectedClient.sd_layout
    .leftSpaceToView(_allBtn,spaing)
    .topEqualToView(_allBtn)
    .widthIs([clientStr stringWidthRectWithSize:CGSizeMake(100, h) font:[UIFont systemFontOfSize:13.0f]].size.width)
    .heightIs(h);
    
    _selectedProprietor.sd_layout
    .leftSpaceToView(_selectedClient,spaing)
    .topEqualToView(_allBtn)
    .widthIs([proprietorStr stringWidthRectWithSize:CGSizeMake(100, h) font:[UIFont systemFontOfSize:13.0f]].size.width)
    .heightIs(h);
    
    _bringAdd.sd_layout
    .topSpaceToView(_EditbackView,0)
    .rightSpaceToView(_EditbackView,0)
    .heightIs(_EditbackView.height)
    .widthIs(btn_w);
}

- (void)addNoEditSubviews{
    
    _type = [UILabel new];
    _type.text = @"总实收";
    _type.textColor = [UIColor whiteColor];
    _type.textAlignment = NSTextAlignmentLeft;
    
    _price = [UILabel new];
    _price.text = @"";
    _price.textColor = [UIColor whiteColor];
    _price.textAlignment = NSTextAlignmentRight;
    [_noEditbackView sd_addSubviews:@[_type,_price]];
    
    CGFloat x = 15;
    CGFloat h = 20;
    _type.sd_layout
    .leftSpaceToView(_noEditbackView,x)
    .topSpaceToView(_noEditbackView,(_noEditbackView.height-h)/2.0f)
    .widthIs(100)
    .heightIs(h);
    
    _price.sd_layout
    .rightSpaceToView(_noEditbackView,x)
    .topSpaceToView(_noEditbackView,(_noEditbackView.height-h)/2.0f)
    .leftSpaceToView(_type,20)
    .heightIs(h);
}

- (DefaultView *)defaultView1{
    if (!_defaultView1) {
        _defaultView1 = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView1.center = self.tableView1.center;
        _defaultView1.centerY = _defaultView1.centerY-120;
        _defaultView1.placeView.image = [UIImage imageNamed:@"Receivables"];
        _defaultView1.placeText.text = @"暂未获取到任何收款信息哦";
    }
    return _defaultView1;
}

- (DefaultView *)defaultView2{
    if (!_defaultView2) {
        _defaultView2 = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView2.center = self.tableView2.center;
        _defaultView2.centerY = _defaultView2.centerY-120;
        _defaultView2.centerX = _defaultView2.centerX-kScreenW;
        _defaultView2.placeView.image = [UIImage imageNamed:@"Receivables"];
        _defaultView2.placeText.text = @"暂未获取到任何收款信息哦";
    }
    return _defaultView2;
}

- (UIView *)EditbackView{
    if (!_EditbackView) {
        _EditbackView = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64, [UIScreen mainScreen].bounds.size.width, 50)];
        _EditbackView.backgroundColor = [UIColor whiteColor];
        
    }
    return _EditbackView;
}

- (UIView *)noEditbackView{
    if (!_noEditbackView) {
        _noEditbackView = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 114, [UIScreen mainScreen].bounds.size.width, 50)];
        
        _noEditbackView.backgroundColor = AppMainColor(1);
        
    }
    return _noEditbackView;
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
        _mainScrollView.delegate = self;
        _mainScrollView.pagingEnabled = YES;
//        _mainScrollView.contentSize = CGSizeMake(kScreenW*2, 0);
    }
    return _mainScrollView;
}

- (UITableView *)tableView1{
    if (!_tableView1) {
        _tableView1 = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, kScreenW, kScreenH-165)];
        _tableView1.bounces = YES;
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
        _tableView2 = [[UITableView alloc]initWithFrame:CGRectMake(kScreenW,50, kScreenW, kScreenH-165)];
        _tableView2.delegate = self;
        _tableView2.bounces = YES;
        _tableView2.dataSource = self;
        _tableView2.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _tableView2.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView2.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView2;
}


#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;{
    NSInteger currentPage = scrollView.contentOffset.x/kScreenW;
    [UIView animateWithDuration:0.1 animations:^{
        _headerView.sliderview.left = currentPage*(kScreenW/2.0f)+ (kScreenW/2.0f-50)/2.0f;
    }];
    
}

#pragma mark -- FinancialHeaderViewDelegate

- (void)currentPage:(NSInteger)current{
  
    current_offx = current;
    CGPoint offset = self.mainScrollView.contentOffset;
    offset.x = self.mainScrollView.width * current;
    [self.mainScrollView setContentOffset:offset animated:YES];
    
    [UIView animateWithDuration:0.1 animations:^{
        _headerView.sliderview.left = current*(kScreenW/2.0f)+ (kScreenW/2.0f-50)/2.0f;
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    CGPoint offset = self.mainScrollView.contentOffset;
   
    if (_mainScrollView) {
        CGPoint offset = self.mainScrollView.contentOffset;
        offset.x = self.mainScrollView.width * current_offx;
        [_mainScrollView setContentOffset:offset animated:YES];
    }
    
}

//设置导航
- (void)setNav{
//    [self addRightNavigationBtnWithTitle:@"编辑" target:self action:@selector(editing:)];
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 120, 40)];
//    view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *bar = [[UIBarButtonItem alloc]initWithCustomView:view];
    self.navigationItem.rightBarButtonItem = bar;
    
    //上面添加btn
     _edit = [UIButton new];//编辑
    [_edit setImage:[UIImage imageNamed:@"generate"] forState:UIControlStateNormal];
    [_edit addTarget:self action:@selector(editing:) forControlEvents:UIControlEventTouchUpInside];
    
     _add = [UIButton new];//新增
    [_add setImage:[UIImage imageNamed:@"increase"] forState:UIControlStateNormal];
    [_add addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    
    [view sd_addSubviews:@[_edit,_add]];
    CGFloat w = 30;
    
    _edit.sd_layout
    .topSpaceToView(view,5)
    .rightSpaceToView(view,5)
    .widthIs(w)
    .heightIs(w);
    
    _add.sd_layout
    .topSpaceToView(view,5)
    .rightSpaceToView(_edit,15)
    .widthIs(w)
    .heightIs(w);
    
}

//设置UI
- (void)setUI{
    //添加数据源
    _dataArray1 = [NSMutableArray array];
    _dataArray2 = [NSMutableArray array];
    
    _selectArray1 = [NSMutableArray array];
    _selectArray2 = [NSMutableArray array];
    //1.添加下拉视图
    [self.view addSubview:self.reafedScrollView];
    
    NSLog(@"reafedScrollView=%@",self.reafedScrollView);
    
    //1.添加主滚动视图
    [self.reafedScrollView addSubview:self.mainScrollView];
    //2.添加头部视图
    _headerView = [[FinancialHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 50)];
    _headerView.financiaDelegate = self;
    [self.reafedScrollView addSubview:_headerView];
    [self.reafedScrollView bringSubviewToFront:_headerView];
    //3.添加tableview
    [_mainScrollView addSubview:self.tableView1];
    [_mainScrollView addSubview:self.tableView2];
    
    //4.无编辑底部的视图
    [self.view addSubview:self.noEditbackView];
    [self addNoEditSubviews];
    
    //5.编辑底部的视图
    [self.view addSubview:self.EditbackView];
    [self addEditSubviews];
}

//-(void)footerLoading{
//    self.reafedScrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        page += 1;
//        loadingHeader = NO;
//        [self requestData:page];
//    }];
//}

//刷新头部、、MJ
-(void)refreshHeader{
    //刷新头部视图
    self.reafedScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        loadingHeader = YES;
        [self requestData:page];//加载数据
    }];
    [self.reafedScrollView.mj_header beginRefreshing];
}

- (void)requestData:(int)pageindex{
    if (_deal_id == nil) {
        [EBAlert alertError:@"合同id为空,请重新请求数据" length:2.0f];
        return;
    }

    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://192.168.2.140:8010/zhpay/collectPayList?token=%@&deal_id=%@",[EBPreferences sharedInstance].token,_deal_id]);
    NSString *urlStr = @"zhpay/collectPayList";
    
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"deal_id":_deal_id
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           
           if (loadingHeader ==  YES) {//清空数据
               [self.dataArray1 removeAllObjects];
               [self.dataArray2 removeAllObjects];
                price_num = 0;
               enit_count = 0;//可以编辑的个数
           }
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSDictionary *data = currentDic[@"data"];
           NSArray *client_data = data[@"client_data"][@"data"];
           NSArray *owner_data = data[@"owner_data"][@"data"];
           if ([currentDic[@"code"] integerValue] == 0) {
               //处理数据客户
               for (NSDictionary *dic in client_data) {
                   [_dataArray1 addObject:dic];
                   //实收增加
                   if ([dic[@"price_charge"] isEqualToString:@"实收"]) {
                       price_num += [dic[@"price_num"] floatValue];
                   }
                   if ([dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"]) {
                       enit_count++;//加1
                   }
               }
               //处理数据业主
               for (NSDictionary *dic in owner_data) {
                   [_dataArray2 addObject:dic];
                   //实收增加
                   if ([dic[@"price_charge"] isEqualToString:@"实收"]) {
                       price_num += [dic[@"price_num"] floatValue];
                   }
                   if ([dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"]) {
                       enit_count++;//加1
                   }
               }
               _price.text = [NSString stringWithFormat:@"¥%0.2f",price_num];
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
           
           if (_dataArray1.count == 0) {//业主没有数据
               [self.tableView1 addSubview:self.defaultView1];
           }else{
               if (self.defaultView1) {
                   [self.defaultView1  removeFromSuperview];
               }
           }
           
           if (_dataArray2.count == 0) {//业主没有数据
               [self.tableView2 addSubview:self.defaultView2];
           }else{
               if (self.defaultView2) {
                   [self.defaultView2  removeFromSuperview];
               }
           }
           
           [self.reafedScrollView.mj_header endRefreshing];
           
           if (client_data.count == 0 && owner_data.count == 0) {
               [self.reafedScrollView.mj_footer endRefreshingWithNoMoreData];
               [self.tableView1 reloadData];
               [self.tableView2 reloadData];
               return ;
           }else{
               [self.reafedScrollView.mj_footer endRefreshing];
           }
           [self.tableView1 reloadData];
           [self.tableView2 reloadData];
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"加载数据失败,请重新再试" length:2.0f];
           [self.reafedScrollView.mj_header endRefreshing];
       }];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _contract_code;
    
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    
    [self setNav];
    [self setUI];//FinanceDetailTableViewCell
    [self refreshHeader];
//    [self footerLoading];
    
    [_tableView1 registerClass:[FinancialDetailTableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView2 registerClass:[FinancialDetailTableViewCell class] forCellReuseIdentifier:@"cell"];
   
}

#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (tableView == _tableView1) {
        return _dataArray1.count;
    }else{
        return _dataArray2.count;
    }
}


//-(BOOL)gestureRecognizer:(UIGestureRecognizer*) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer
//{
//    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
//        return NO;
//    }else {
//        return YES;
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
     FinancialDetailTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
//    cell.swipeGesture.delegate = self;
    
    //1.btn点击事件
    [cell.btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(qrcode:)];
   
    [cell.qrcode addGestureRecognizer:tap];
    if (_tableView1.editing == YES && _tableView2.editing == YES){
        [cell.btn setUserInteractionEnabled:NO];
        [cell.qrcode setUserInteractionEnabled:NO];
        cell.swipeGesture.enabled = NO;
    }else{
        [cell.btn setUserInteractionEnabled:YES];
        [cell.qrcode setUserInteractionEnabled:YES];
        cell.swipeGesture.enabled = YES;
    }
    //多选时的颜色
    cell.multipleSelectionBackgroundView = [UIView new];
    cell.tintColor = [UIColor redColor];
    NSDictionary *dic = nil;
    if (tableView == _tableView1) {
        dic = _dataArray1[indexPath.section];
        [cell setDic:dic isEdit:_tableView1.editing];//有数据来的时候打开
        cell.btn.tag = indexPath.section;
        cell.qrcode.tag = indexPath.section;
    }else{
        dic = _dataArray2[indexPath.section];
        [cell setDic:dic isEdit:_tableView2.editing];//有数据来的时候打开
        cell.btn.tag = indexPath.section + 1000000;
        cell.qrcode.tag = indexPath.section + 1000000;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入详情
    if (tableView.editing == YES) {
        NSDictionary *dic = nil;
        if (tableView == _tableView1) {//添加tableview1的数组
            dic = _dataArray1[indexPath.section];
            BOOL is_edit = [dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"];
            if (is_edit) {
                [_selectArray1 addObject:[self.dataArray1 objectAtIndex:indexPath.section]];
            }else{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            
        }else{//添加tableview2的数组
            dic = _dataArray2[indexPath.section];
            BOOL is_edit = [dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"];
            if (is_edit) {
                [_selectArray2 addObject:[self.dataArray2 objectAtIndex:indexPath.section]];
            }else{
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        //处理选择了多少
        _selectedClient.text = [NSString stringWithFormat:@"已选客户 :%ld",_selectArray1.count];
        _selectedProprietor.text = [NSString stringWithFormat:@"已选业主 :%ld",_selectArray2.count];
        if (_selectArray1.count+_selectArray2.count == enit_count) {
            _allBtn.selected = YES;
            [_allBtn setImage:[UIImage imageNamed:@"Hook"] forState:UIControlStateNormal];
        }
        
    }else{
        //进入详情数据
        
        NSDictionary *dic = nil;
        if (tableView == _tableView1) {//添加tableview1的数组
            dic = _dataArray1[indexPath.section];
        }else{
            dic = _dataArray2[indexPath.section];
        }
        
         [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ZHCheckController *checkVc = [[ZHCheckController alloc]init];
        checkVc.checkDic = dic;
        checkVc.deal_id = [NSString stringWithFormat:@"%@",self.deal_id];
        checkVc.returnBlock=^{
            [self refreshHeader];
        };
        checkVc.deal_type = self.deal_type;
        checkVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:checkVc animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    //点击了取消按钮全选
    _allBtn.selected = NO;
   [_allBtn setImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    
    if (tableView == _tableView1) {//移除tableview1的数组
         [_selectArray1 removeObject:[self.dataArray1 objectAtIndex:indexPath.section]];
    }else{//移除tableview2的数组
         [_selectArray2 removeObject:[self.dataArray2 objectAtIndex:indexPath.section]];
    }
    //处理选择了多少
    _selectedClient.text = [NSString stringWithFormat:@"已选客户 :%ld",_selectArray1.count];
    _selectedProprietor.text = [NSString stringWithFormat:@"已选业主 :%ld",_selectArray2.count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 8;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 8)];
    view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
    line1.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        [view addSubview:line1];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 7, kScreenW, 1)];
    line2.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [view addSubview:line2];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (tableView == _tableView1) {
        if (section == _dataArray1.count-1) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
            view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
            return view;
        }else{
            return nil;
        }
    }else{
        if (section == _dataArray2.count-1) {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
            view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
            return view;
        }else{
            return nil;
        }
    }
}

#pragma mark -- editing

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == _tableView1) {
        NSDictionary *dic = _dataArray1[indexPath.section];
        if ([dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"]) {
            return YES;//这种可以编辑
        }else{
            return NO;
        }
    }else {
        NSDictionary *dic = _dataArray2[indexPath.section];
        if ([dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"]) {
            return YES;//这种可以编辑
        }else{
            return NO;
        }
    }
    
}

CGAffineTransform  GetCGAffineTransformRotateAroundPoint(float centerX, float centerY ,float x ,float y ,float angle)
{
    x = x - centerX;
    y = y - centerY;
    
    CGAffineTransform  trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans,angle);
    trans = CGAffineTransformTranslate(trans,-x, -y);
    return trans;
}

//编辑
- (void)editing:(id)sender{
    
    //处理选择了多少
    _selectedClient.text = [NSString stringWithFormat:@"已选客户 :%ld",_selectArray1.count];
    _selectedProprietor.text = [NSString stringWithFormat:@"已选业主 :%ld",_selectArray2.count];
    
    //tableView进入编辑状态
    //支持同时选中多行
    _tableView1.allowsMultipleSelectionDuringEditing = YES;
    _tableView2.allowsMultipleSelectionDuringEditing = YES;
    //    [self.mainTableView setEditing:!self.mainTableView.editing animated:YES];
    _tableView1.editing = !_tableView1.editing;
    _tableView2.editing = !_tableView2.editing;
    
    [_tableView1 reloadData];//重新刷新数据
    [_tableView2 reloadData];//重新刷新数据
    
    if (_tableView1.editing && _tableView2.editing) {
        //显示
        [self.edit setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        self.add.hidden = YES;
        //动画处理下面view
        [UIView animateWithDuration:0.3 animations:^{
            _noEditbackView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                _noEditbackView.hidden = YES;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.4 animations:^{
                    _EditbackView.top -= 50;
                }];
            }];
        }];
    }else{
        _allBtn.selected = NO;
        [_allBtn setImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
        
        [self.edit setImage:[UIImage imageNamed:@"generate"] forState:UIControlStateNormal];
        self.add.hidden = NO;
        //动画处理下面view
        [UIView animateWithDuration:0.4 animations:^{
            _EditbackView.top += 50;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                _noEditbackView.hidden = NO;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.4 animations:^{
                    _noEditbackView.alpha = 1.0;
                }];
            }];
        }];
        //移除筛选的数据
        [self.selectArray1 removeAllObjects];
        [self.selectArray2 removeAllObjects];
    }
}


//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return @"删除";
//}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    if (editingStyle == UITableViewCellEditingStyleDelete) {//删除
        
    }
}

#pragma mark -- 逻辑处理

//全选
- (void)selectedAll:(UIButton *)btn{
    
    if (btn.selected == NO) {//btn旋转
        [btn setImage:[UIImage imageNamed:@"Hook"] forState:UIControlStateNormal];
        [self.selectArray1 removeAllObjects];
        [self.selectArray2 removeAllObjects];
        //客户
        for (int i = 0; i < self.dataArray1.count; i ++) {
             NSDictionary *dic = _dataArray1[i];
            if ([dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
                [self.tableView1 selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                [self.selectArray1 addObject:dic];
            }
        }
        //业主
        for (int i = 0; i < self.dataArray2.count; i ++) {
            NSDictionary *dic = _dataArray2[i];
            if ([dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
                [self.tableView2 selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                [self.selectArray2 addObject:dic];
            }
        }
    }else{
        [btn setImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
        //客户
        for (int i = 0; i < self.dataArray1.count; i ++) {
            NSDictionary *dic = _dataArray1[i];
            if ([dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
                [self.tableView1 deselectRowAtIndexPath:indexPath animated:YES];
                
                [self.selectArray1 removeObject:dic];
            }
        }
        //业主
        for (int i = 0; i < self.dataArray2.count; i ++) {
            NSDictionary *dic = _dataArray2[i];
            if ([dic[@"order_no_status"] isEqualToString:@"未支付"]&&[dic[@"price_charge"] isEqualToString:@"实收"]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
                [self.tableView2 deselectRowAtIndexPath:indexPath animated:YES];
                [self.selectArray2 removeObject:dic];
            }
        }
        
    }
    btn.selected = !btn.selected;
    
    //处理选择了多少
    _selectedClient.text = [NSString stringWithFormat:@"已选客户 :%ld",_selectArray1.count];
    _selectedProprietor.text = [NSString stringWithFormat:@"已选业主 :%ld",_selectArray2.count];
    
}

//生成订单号
- (void)bringOrder:(UIButton *)btn{
    //请求接口返回订单号
//    http://192.168.2.140:8010/zhpay/orderNoAdd
    NSMutableArray *document_id_data = [NSMutableArray array];
    
    //客户
    for (NSDictionary *dic in _selectArray1) {//document_id
        [document_id_data addObject:dic[@"document_id"]];
    }
    //业主
    for (NSDictionary *dic in _selectArray2) {//document_id
         [document_id_data addObject:dic[@"document_id"]];
    }
    NSString *jsonStr = [document_id_data componentsJoinedByString:@","];
    

    
//    return;
    
    if (document_id_data.count > 0) {
        [EBAlert showLoading:@"订单号生成中..." allowUserInteraction:NO];
        [HttpTool post:@"zhpay/orderNoAdd" parameters:@{
            @"token":[EBPreferences sharedInstance].token,
            @"deal_department_id":_dept_id,
            @"deal_id":_deal_id,
            @"contract_code":_contract_code,
            @"user_id":[[EBPreferences sharedInstance].userId componentsSeparatedByString:@"_"].lastObject,
            @"document_id_data":jsonStr
        } success:^(id responseObject) {
            [EBAlert hideLoading];
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"currentDic=%@",currentDic);
            if ([currentDic[@"code"]integerValue] == 0) {
                NSDictionary *data = currentDic[@"data"];
                NSNumber *orderNumber = data[@"data"];//订单号生成成功
                [self editing:_edit];
                 //弹窗页面
                [self QRCode:[NSString stringWithFormat:@"%@",orderNumber]];
//                [self refreshHeader];//刷新数据
                
            }else{
                [EBAlert alertError:@"生成订单号失败,请重试" length:2.0f];
            }
            
         } failure:^(NSError *error) {
            [EBAlert hideLoading];
            [EBAlert alertError:@"生成订单号失败,请重试" length:2.0f];
        }];
    }else{
        [EBAlert alertError:@"请先选择订单" length:2.0f];
    }
}


//跳转到新增界面
- (void)add:(UIButton *)btn{
    ZHFundEditController *func = [[ZHFundEditController alloc]init];
    func.vcTag = 0;
    func.deal_id = [NSString stringWithFormat:@"%@",self.deal_id];
    func.deal_type = self.deal_type;
    func.returnBlock = ^{
        [self refreshHeader];
    };
    func.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:func animated:YES];
}

//删除
- (void)btnClick:(UIButton *)btn{
    
    NSLog(@"btn=%ld",btn.tag); //如果已经支付的就不能删除
    NSDictionary *dic = nil;
    
    if (btn.tag < 1000000) {
        dic = _dataArray1[btn.tag];
    }else{
        dic = _dataArray2[btn.tag-1000000];
    }
    BOOL is_del = ([dic[@"price_charge"]isEqualToString:@"实收"]&&[dic[@"order_no_status"]isEqualToString:@"已支付"]);
    if (is_del) {
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"该笔费用不允许删除" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认删除这条实收信息" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //NSLog(@"点击了确定");
        //点击删除确认, 发起删除实收请求
        [HttpTool post:@"zhpay/collectPayDel" parameters:@{
                @"token":[EBPreferences sharedInstance].token,
                @"document_id":dic[@"document_id"],
                @"user_id":[[EBPreferences sharedInstance].userId componentsSeparatedByString:@"_"].lastObject
            } success:^(id responseObject) {
                NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"currentDic=%@",currentDic);
                if ([currentDic[@"code"] integerValue] == 0) {
                    [EBAlert alertSuccess:@"删除成功" length:2.0f];
                    [self refreshHeader];
                }else{
                    if ([currentDic.allKeys containsObject:@"desc"]) {
                        [EBAlert alertError:currentDic[@"desc"] length:2.0f];
                    }else{
                        [EBAlert alertError:@"删除失败" length:2.0f];
                    }
                }
           } failure:^(NSError *error) {
                [EBAlert alertError:@"删除失败" length:2.0f];
                NSLog(@"error=%@",error);
        }];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}

//点击二维码
- (void)qrcode:(UITapGestureRecognizer *)tap{
    NSLog(@"tap=%ld",tap.view.tag);
    NSDictionary *dic = nil;
    if (tap.view.tag < 1000000) {
        dic = _dataArray1[tap.view.tag];
    }else{
        dic = _dataArray2[tap.view.tag - 1000000];
    }
    if ([dic[@"order_no"] isEqualToString:@""]) {
        
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"请先进行生成订单号操作" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }else{
        if ([dic[@"order_no_status"] isEqualToString:@"已支付"]) {
            [[[UIAlertView alloc]initWithTitle:@"提示" message:@"该笔费用已支付" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            return;
        }else{
            NSString *order_no = dic[@"order_no"];
            [self QRCode:order_no];
        }
    }
}

- (void)closePop:(UITapGestureRecognizer *)tap{
    [[HWPopTool sharedInstance]closeWithBlcok:^{
        NSLog(@"已经关闭");
        [self refreshHeader];//刷新数据
    }];
}


- (void)QRCode:(NSString *)order_no{
    //先生成视图
    _popView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW-60, 180)];;
    _popView.backgroundColor = [UIColor whiteColor];
    _popView.layer.cornerRadius = 7.0f;
    _qrImageView = [UIImageView new];
    [_popView addSubview:_qrImageView];
    UILabel *lable = [UILabel new];
    lable.text = order_no;
    lable.font = [UIFont systemFontOfSize:18.0f];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = UIColorFromRGB(0x404040);
    [_popView addSubview:lable];
    
    _qrImageView.sd_layout
    .topSpaceToView(_popView,20)
    .leftSpaceToView(_popView,20)
    .rightSpaceToView(_popView,20)
    .heightIs(100);
    
    lable.sd_layout
    .topSpaceToView(_qrImageView,10)
    .leftSpaceToView(_popView,0)
    .rightSpaceToView(_popView,0)
    .heightIs(40);
    
    //动画弹窗
    MyViewController *vc = [[HWPopTool sharedInstance] showWithPresentView:_popView animated:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop:)];
    vc.styleView.userInteractionEnabled = YES;
    [vc.styleView addGestureRecognizer:tap];
    
    CIImage *ciImage = [self generateBarCodeImage:order_no];
     UIImage *image = [self resizeCodeImage:ciImage withSize:CGSizeMake((self.view.frame.size.width - 100), 80)];
  
    if (image) {
        _qrImageView.image = image;
    }

}

- (CIImage *) generateBarCodeImage:(NSString *)source
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        NSData *data = [source dataUsingEncoding: NSASCIIStringEncoding];
        CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
        [filter setValue:data forKey:@"inputMessage"];
   
        [filter setValue:[NSNumber numberWithInteger:0] forKey:@"inputQuietSpace"];
        return filter.outputImage;
    }else{
        return nil;
    }
}

- (UIImage *) resizeCodeImage:(CIImage *)image withSize:(CGSize)size
{
    if (image) {
        CGRect extent = CGRectIntegral(image.extent);
        CGFloat scaleWidth = size.width/CGRectGetWidth(extent);
        CGFloat scaleHeight = size.height/CGRectGetHeight(extent);
        size_t width = CGRectGetWidth(extent) * scaleWidth;
        size_t height = CGRectGetHeight(extent) * scaleHeight;
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceGray();
        CGContextRef contentRef = CGBitmapContextCreate(nil, width, height, 8, 0, colorSpaceRef, (CGBitmapInfo)kCGImageAlphaNone);
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef imageRef = [context createCGImage:image fromRect:extent];
        CGContextSetInterpolationQuality(contentRef, kCGInterpolationNone);
        CGContextScaleCTM(contentRef, scaleWidth, scaleHeight);
        CGContextDrawImage(contentRef, extent, imageRef);
        CGImageRef imageRefResized = CGBitmapContextCreateImage(contentRef);
        CGContextRelease(contentRef);
        CGImageRelease(imageRef);
        return [UIImage imageWithCGImage:imageRefResized];
    }else{
        return nil;
    }
}

@end
