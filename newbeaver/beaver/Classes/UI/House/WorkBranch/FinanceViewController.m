//
//  FinanceViewController.m
//  beaver
//
//  Created by mac on 17/11/13.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinanceViewController.h"
#import "HeaderViewForDailCheckView.h"
#import "HooDatePicker.h"
#import "FinanceTableViewCell1.h"
#import "FinanceDetailViewController.h"
#import "ContractViewController.h"
#import "MJRefresh.h"
#import "DefaultView.h"

@interface FinanceViewController ()<UISearchBarDelegate,HeaderViewForDailCheckViewDelegate,UITableViewDataSource,UITableViewDelegate,HooDatePickerDelegate>
{
    UISearchBar *_searchBar;
    BOOL isSearchBarActive;//是否响应
    NSArray *titleArr;//头视图文字
    
    NSString *startDate;//开始日期
    NSString *endDate;//开始日期
    NSString *contract_code;//合同编号
    NSString *status;//状态
    
    CGFloat price_count;//状态
    
    int page;
    BOOL loadingHeader;
}

@property (nonatomic, strong)DefaultView *defaultView;
@property (nonatomic, strong)UIView *backgroundView;

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据

@property (nonatomic, strong)HeaderViewForDailCheckView * headerLable;
@property (nonatomic, strong)ValuePickerView *pickerView;
@property (nonatomic, strong)HooDatePicker *datePicker1;  //开始日期
@property (nonatomic, strong)HooDatePicker *datePicker2;  //结束日期

@property (nonatomic, weak)UIButton *btn1;  //开始日期btn
@property (nonatomic, weak)UIButton *btn2;  //结束日期btn

@property (nonatomic, weak)UIButton *btn3;  //status btn


@property (nonatomic, copy) NSString *dept_id;          //部门id

@end

@implementation FinanceViewController

- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc]initWithFrame:_mainTableView.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.5;
    }
    return _backgroundView;
}

- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = self.mainTableView.center;
        _defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
        _defaultView.placeText.text = @"暂无详情数据";
    }
    return _defaultView;
}

- (HooDatePicker *)datePicker1{
    if (!_datePicker1) {
        _datePicker1 = [[HooDatePicker alloc] initWithSuperView:self.view withTitle:@"请选择开始日期"];
        _datePicker1.delegate = self;
        _datePicker1.datePickerMode = HooDatePickerModeDate;
    }
    return _datePicker1;
}

- (HooDatePicker *)datePicker2{
    if (!_datePicker2) {
        _datePicker2 = [[HooDatePicker alloc] initWithSuperView:self.view withTitle:@"请选择结束日期"];
        _datePicker2.delegate = self;
        _datePicker2.datePickerMode = HooDatePickerModeDate;
    }
    return _datePicker2;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64) style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _headerLable = [[HeaderViewForDailCheckView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 74) titleArr:titleArr BottonView:[UIView new]];
        _headerLable.headerViewDelegate = self;
        _mainTableView.tableHeaderView = _headerLable;
    }
    return _mainTableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化数据
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
    
//    startDate = @"";//开启日期
    startDate = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentDateStr]];//开启日
    endDate = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentDateStr]+(24*60*60-1)];//结束日期
    
    contract_code = @"";
    status = @"";
    price_count = 0.0f;
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenW-100, 30)];
    _searchBar.placeholder = @"请输入合同编号进行查找";
    _searchBar.delegate = self;
  
    _searchBar.tintColor = UIColorFromRGB(0xff3800);
    self.navigationItem.titleView = _searchBar;
    
    _dataArray = [NSMutableArray array];
    
    _dept_id = [[EBPreferences sharedInstance].dept_id componentsSeparatedByString:@"_"].lastObject;//部门id
    
    
    if (_finaceType == ZHFinanceTypeCompanyIncomeLedger) {//公司收入分账
        titleArr = @[currentDateStr,currentDateStr,@"确认情况"];
    }else if (_finaceType == ZHFinanceTypeStoreCommission){//门店佣金分账
        titleArr = @[currentDateStr,currentDateStr,@"确认情况"];
    }else if (_finaceType == ZHFinanceTypeReimbursementAccountManagement){//报销划账管理
        titleArr = @[currentDateStr,currentDateStr,@"确认情况"];
    }
    
    [self.view addSubview:self.mainTableView];
     self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
    
    [self refreshHeader];
    [self footerLoading];

    [self.mainTableView registerNib:[UINib nibWithNibName:@"FinanceTableViewCell1" bundle:nil] forCellReuseIdentifier:@"cell"];
}


- (void)requestData:(int)pageindex{
    if (_dept_id == nil) {
        [EBAlert alertError:@"部门的ID为空,请重新登录" length:2.0f];
        return;
    }
    NSLog(@"status=%@",status);
    
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    [parm setObject:_dept_id forKey:@"deptOrUser"];//发布的时候打开
//    [parm setObject:@186 forKey:@"deptOrUser"];//发布的时候关闭
    
    [parm setObject:[NSNumber numberWithInt:pageindex] forKey:@"page"];
    [parm setObject:[NSNumber numberWithInt:12] forKey:@"page_size"];
    
    if (![startDate isEqualToString:@""]) {//开始日期
        [parm setObject:startDate forKey:@"begin_date"];
    }
    
    if (![endDate isEqualToString:@""]) {//结束日期
        [parm setObject:endDate forKey:@"end_date"];
    }
    
    if (![contract_code isEqualToString:@""]) {//合同编号
        [parm setObject:contract_code forKey:@"contract_code"];
    }
    if (![status isEqualToString:@""]) {//状态
        [parm setObject:status forKey:@"check_status"];
    }
    NSLog(@"dic = %@",parm);
    
    NSString *urlStr = @"Zhpay/accAgencyList";//公司收入分账
    if (_finaceType == ZHFinanceTypeStoreCommission) {//门店佣金分账
        urlStr = @"Zhpay/accDivisionList";
    }else if (_finaceType == ZHFinanceTypeReimbursementAccountManagement){//报销划账管理
        urlStr = @"Zhpay/tranManagerList";
    }

    NSLog(@"urlStr = %@",urlStr);//http://218.65.86.83:
    
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:[parm mutableCopy] success:^(id responseObject) {
           [EBAlert hideLoading];
           //           [_dataArray removeAllObjects]; //移除所有
           //是否启用占位图
           if (loadingHeader ==  YES) {
               price_count = 0.0f;
               [self.dataArray removeAllObjects];
           }
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
            if ([currentDic[@"code"] integerValue] != 0) {
                [EBAlert alertError:currentDic[@"desc"] length:2.0f];
                [self.mainTableView.mj_footer endRefreshing];
                [self.mainTableView.mj_header endRefreshing];
                return ;
           }
            NSArray *tmpArray = currentDic[@"data"][@"list"][@"data"];
        for (NSDictionary *dic in tmpArray) {
            [_dataArray addObject:dic];//添加字典
            price_count += [dic[@"price"]floatValue];
        }
        //价格
        NSString *leftStr = [NSString stringWithFormat:@"总额 (元) : %0.2f",price_count];
        NSMutableAttributedString *attributeStr1 =[[NSMutableAttributedString alloc]initWithString:leftStr];
        [attributeStr1 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x404040)} range:NSMakeRange(0, 8)];
        [attributeStr1 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x808080)} range:NSMakeRange(8, leftStr.length-8)];
          _headerLable.leftLable.attributedText = attributeStr1;
        //数量
        NSString *rightStr = [NSString stringWithFormat:@"总量 (条) : %ld",_dataArray.count];

        NSMutableAttributedString *attributeStr2 =[[NSMutableAttributedString alloc]initWithString:rightStr];
        [attributeStr2 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x404040)} range:NSMakeRange(0, 8)];
        [attributeStr2 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x808080)} range:NSMakeRange(8, rightStr.length-8)];
        _headerLable.rightLable.attributedText = attributeStr2;
        
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
           [EBAlert hideLoading];
           [EBAlert alertError:@"请检查网络" length:2.0f];
           [self.mainTableView.mj_header endRefreshing];
           [self.mainTableView.mj_footer endRefreshing];
       }];
    
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


#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_dataArray.count == 0) {
        return 0;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = _dataArray[indexPath.section];
    FinanceTableViewCell1 *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if (_finaceType == ZHFinanceTypeReimbursementAccountManagement) {
        [cell setDic:dic isTranManager:YES];
    }else{
        [cell setDic:dic isTranManager:NO];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _dataArray[indexPath.section];
    FinanceDetailViewController *devc = [[FinanceDetailViewController alloc]init];
    devc.hidesBottomBarWhenPushed = YES;
    devc.document_id = dic[@"document_id"];
    devc.finaceType = _finaceType;
    devc.returnBlock = ^{
        [self refreshHeader];//刷新数据
    };
    [self.navigationController pushViewController:devc animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

//进入合同
- (void)loadContract:(UITapGestureRecognizer *)tap{
    NSDictionary *dic = _dataArray[tap.view.tag];
    ContractViewController * cvc=[[ContractViewController alloc]init];
    cvc.hidesBottomBarWhenPushed = YES;
    cvc.ht_id = dic[@"ht_id"];
    cvc.ht_code = dic[@"ht_code"];
    [self.navigationController pushViewController:cvc animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CGFloat x = 15;
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 40)];
    view.tag = section;
    view.backgroundColor = [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadContract:)];
    [view addGestureRecognizer:tap];
    
    CGFloat iconH = 11;
    CGFloat iconW = 7;
    UIImageView *icon = [UIImageView new];
    icon.image = [UIImage imageNamed:@"jiantou"];
    [view addSubview:icon];
    CGFloat lableH = 20;
    NSDictionary *dic = _dataArray[section];
   
    
    UILabel *rightLable = [UILabel new];
    rightLable.textAlignment = NSTextAlignmentRight;
    rightLable.text = @"";
    rightLable.font = [UIFont systemFontOfSize:13.0f];
    rightLable.textColor = UIColorFromRGB(0xff3800);
    [view addSubview:rightLable];
    
    if ([dic.allKeys containsObject:@"execute_status"]&&[dic.allKeys containsObject:@"return_status"]) {
        if ([dic[@"execute_status"] intValue] == 0) {
            rightLable.text = @"未执行";
        }else if([dic[@"execute_status"] intValue] == 1){
            if ([dic[@"return_status"] intValue] == 1) {
                rightLable.text = @"成功";
            }else if ([dic[@"return_status"] intValue] == 2){
                rightLable.text = @"失败";
            }else if ([dic[@"return_status"] intValue] == 3){
                rightLable.text = @"重复";
            }else if ([dic[@"return_status"] intValue] == 4){
                rightLable.text = @"重新生成";
            }
        }
    }
    
    UILabel *leftlable = [UILabel new];
    leftlable.textAlignment = NSTextAlignmentLeft;
    leftlable.font = [UIFont systemFontOfSize:13.0f];
//    leftlable.text = @"合同编号: NF1478554488545";
    NSString *str = [NSString stringWithFormat:@"合同编号: %@",dic[@"ht_code"]];

    NSMutableAttributedString *attributeStr =[[NSMutableAttributedString alloc]initWithString:str];
    [attributeStr addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x404040)} range:NSMakeRange(0, 5)];
    [attributeStr addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x808080)} range:NSMakeRange(5, str.length-5)];
    leftlable.attributedText = attributeStr;
    
    [view addSubview:leftlable];
   
    UIView *lineview = [[UIView alloc]init];
    lineview.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [view addSubview:lineview];
    
    icon.sd_layout
    .topSpaceToView(view,(view.height-iconH)/2.0f)
    .rightSpaceToView(view,x)
    .widthIs(iconW)
    .heightIs(iconH);
    
    rightLable.sd_layout
    .topSpaceToView(view,(view.height-lableH)/2.0f)
    .rightSpaceToView(icon,10)
    .widthIs(80)
    .heightIs(lableH);
    
    leftlable.sd_layout
    .topSpaceToView(view,(view.height-lableH)/2.0f)
    .leftSpaceToView(view,x)
    .rightSpaceToView(rightLable,10)
    .heightIs(lableH);

    lineview.sd_layout
    .leftSpaceToView(view,0)
    .rightSpaceToView(view,0)
    .bottomSpaceToView(view,0)
    .heightIs(1);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section != _dataArray.count-1) {
        return 5;
    }else{
        return 1;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (section != _dataArray.count-1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 5)];
        view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
        line1.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        [view addSubview:line1];
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 4, kScreenW, 1)];
        line2.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        [view addSubview:line2];
        return view;
    }else{
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
        line1.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        return line1;
    }
    
}


#pragma mark -- UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    //开始编辑
    [_mainTableView addSubview:self.backgroundView];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    //结束编辑
    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"搜索");
    if (self.backgroundView) {
        [self.backgroundView removeFromSuperview];
    }
    [_searchBar resignFirstResponder];
    contract_code = searchBar.text;
    [self refreshHeader];//刷新头部
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    contract_code = searchBar.text;//将数据负责
}


#pragma mark -- HeaderViewForDailCheckViewDelegate

- (void)btnClick:(UIButton *)btn{
    switch (btn.tag) {
        case 0: case 1:
            [self addDatePickerView:btn];
            break;
        case 2:
            [self addPickerViewForState:btn];
            break;
        default:
            break;
    }
}
//日期选择控制器
- (void)addDatePickerView:(UIButton *)btn{
    if (btn.tag == 0) {
        [self.datePicker1 show];
        _btn1 = btn;
    }else{
        [self.datePicker2 show];
        _btn2 = btn;
    }
}

#pragma mark -- HooDatePickerDelegate
- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date{
    
}

- (void)datePicker:(HooDatePicker *)datePicker didCancel:(UIButton *)sender{
    NSLog(@"取消");
    
}

- (void)datePicker:(HooDatePicker *)dataPicker didSelectedDate:(NSDate *)date{
    NSLog(@"选择了日期");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    NSLog(@"currentOlderOneDateStr=%@",currentOlderOneDateStr);
    
    if ([date compare:[NSDate date]] > 0) {

        [EBAlert alertError:@"请选择小于本月的月份" length:2.0 ];
        return;
    }
    
    if (dataPicker == _datePicker1) {
        [_btn1 setTitle:currentOlderOneDateStr forState:UIControlStateNormal];
//        startDate = currentOlderOneDateStr;
        startDate = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentOlderOneDateStr]];
        _datePicker1.date = date;
    }else{
        [_btn2 setTitle:currentOlderOneDateStr forState:UIControlStateNormal];
//        endDate = currentOlderOneDateStr;
        endDate = [NSString stringWithFormat:@"%0.0f",[self timeIntervalWithTimeString:currentOlderOneDateStr]+(24*60*60-1)];
        _datePicker2.date = date;
    }
    NSLog(@"startDate=%@",startDate);
    NSLog(@"endDate=%@",endDate);
    //两个都有
    if (![endDate isEqualToString:@""] && ![startDate isEqualToString:@""]) {
         [self refreshHeader];
    }
}

- (NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:timeString];
    NSTimeInterval interval = (long)[date timeIntervalSince1970];
    return interval;
}


//确认情况
- (void)addPickerViewForState:(UIButton *)btn{
    self.pickerView.dataSource = @[@"待确认",@"已确认"];
    self.pickerView.pickerTitle = @"请选择状态";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [btn setTitle:result forState:UIControlStateNormal];
        if ([result isEqualToString:@"待确认"]) {
            status = @"已审核";
        }else{
            status = result;
        }
        NSLog(@"result=%@",result);
        [weakSelf refreshHeader];
    };
    [self.pickerView show];
}

@end
