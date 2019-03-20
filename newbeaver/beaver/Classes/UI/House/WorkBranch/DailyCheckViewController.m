//
//  DailyCheckViewController.m
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "DailyCheckViewController.h"
#import "DailCheckTableViewCell.h"
#import "HeaderViewForDailCheckView.h"
#import "DailyCheckDetailViewController.h"
#import "HooDatePicker/HooDatePicker.h"
#import "MJRefresh.h"
#import "DailyCheckModel.h"
#import "EBCache.h"
#import "EBContact.h"
#import "YBPopupMenu.h"
#import "NameAndDepermentViewController.h"
#import "ContactsViewController.h"

#define TITLES @[@"按名字搜索",@"按门店搜索"]

@interface DailyCheckViewController ()<UITableViewDelegate,UITableViewDataSource,HeaderViewForDailCheckViewDelegate,HooDatePickerDelegate,UISearchBarDelegate,YBPopupMenuDelegate>{
    UISearchBar *_searchBar;
    int page;
    BOOL loadingHeader;
}
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)HeaderViewForDailCheckView * headerLable;
@property (nonatomic, strong)ValuePickerView *pickerView;
@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器
@property (nonatomic, strong)NSArray *positionArr;

@property (nonatomic, copy) NSString *user_id;        //使用者id
@property (nonatomic, copy) NSString *dept_id;          //部门id
@property (nonatomic, copy) NSString *user_duty;       //职务
@property (nonatomic, copy) NSString *status;               //状态
@property (nonatomic, copy) NSString *date;             //日期

@property (nonatomic, strong)YBPopupMenu *popupMenu;

@property (nonatomic, weak) UIButton *dateBtn;
@property (nonatomic, weak) UIButton *zhiwuBtn;

@end

@implementation DailyCheckViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _headerLable = [[HeaderViewForDailCheckView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 85) titleArr:@[@"职务",@"提交日期",@"日报状态"] isShowBottomView:YES];
        _headerLable.headerViewDelegate = self;
        _mainTableView.tableHeaderView = _headerLable;
    }
    return _mainTableView;
}


- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu{
    //点击了搜索
    if (index == 0) {
        ContactsViewController *cvc = [[ContactsViewController alloc]init];
        cvc.title = @"按名字搜索";
        cvc.is_Daily = YES;
        cvc.returnBlock = ^(NSString *name, NSString *userid){
            //请求数据
            _dept_id = @"";
            _user_duty = @"";//请求职务
            _user_id = [userid componentsSeparatedByString:@"_"].lastObject;
            [_headerLable.zhiwuBtn setTitle:name forState:UIControlStateNormal];
            [self refreshHeader];//刷新头部
        };
        cvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:cvc animated:YES];
    }else{
        NameAndDepermentViewController *nvc = [[NameAndDepermentViewController alloc]init];
        nvc.hidesBottomBarWhenPushed = YES;
        nvc.title = @"门店筛选";
        nvc.returnBlock = ^(NSString *dept_id,NSString *dept_name){
            //请求数据
            _user_id = @"";
            _user_duty = @"";
            [_headerLable.zhiwuBtn setTitle:dept_name forState:UIControlStateNormal];
            _dept_id = dept_id;
            [self refreshHeader];//刷新头部
        };
        [self.navigationController pushViewController:nvc animated:YES];
        
    }
   
}

//
- (void)clearData{
    _user_duty = @"";
    _date = @"";
    _status = @"";
    _user_id = [[EBPreferences sharedInstance].userId componentsSeparatedByString:@"_"].lastObject;
    _dept_id = [[EBPreferences sharedInstance].dept_id componentsSeparatedByString:@"_"].lastObject;
}

#pragma mark - action
- (void)searchContact:(id)btn{
    self.popupMenu = [YBPopupMenu showAtPoint:CGPointMake(kScreenW, 44) titles:TITLES icons:nil menuWidth:110 delegate:self];
    self.popupMenu.dismissOnSelected = YES;
    self.popupMenu.isShowShadow = YES;
    self.popupMenu.delegate = self;
    self.popupMenu.offset = 10;
    self.popupMenu.type = YBPopupMenuTypeDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self clearData];
    
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_search"] target:self action:@selector(searchContact:)];
    self.title = @"日报审核";
//    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenW-100, 30)];
//    _searchBar.delegate = self;
//    _searchBar.placeholder = @"搜索部门或提交人姓名";
//    self.navigationItem.titleView = _searchBar;
    _dataArray = [NSMutableArray array];
    _positionArr = [[EBCache sharedInstance]objectForKey:EB_CACHE_KEY_POSITION_ALL];
    
    [self.view addSubview:self.mainTableView];
    self.pickerView = [[ValuePickerView alloc]initShowClear:YES];
    [self refreshHeader];
    [self footerLoading];
    [self.mainTableView registerNib:[UINib nibWithNibName:@"DailCheckTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
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
    if (_dept_id == nil) {
        [EBAlert alertError:@"部门的ID为空,请重新登录" length:2.0f];
        return;
    }
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@" http://218.65.86.83:8010/Daily/dailyList?token=%@&user_id=%@&department_id=%@&user_duty=%@&day=%@&status=%@&page=%d&page_size=12",[EBPreferences sharedInstance].token,_user_id,_dept_id,_user_duty,_date,_status,pageindex]);
    NSString *urlStr = @"Daily/dailyList/getAllRank";
    
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
           @"user_id":_user_id,
           @" department_id":_dept_id,
            @"user_duty":_user_duty,
            @"day":_date,
            @"status":_status,
            @"page":[NSNumber numberWithInt:pageindex],
            @"page_size":[NSNumber numberWithInt:12]
       }success:^(id responseObject) {
           [EBAlert hideLoading];
//           [_dataArray removeAllObjects]; //移除所有
           //是否启用占位图
           _mainTableView.enablePlaceHolderView = YES;
           DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
           defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
           defaultView.placeText.text = @"暂无详情数据";
           if (  loadingHeader ==  YES) {
               [self.dataArray removeAllObjects];
           }
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSDictionary *dic = currentDic[@"data"];
           NSDictionary *tmpDic= dic[@"statistic"];
           if ([currentDic[@"code"] integerValue] != 0) {
               [EBAlert alertError:currentDic[@"desc"] length:2.0f];
               [self clearData];
               [self.mainTableView.mj_footer endRefreshing];
               [self.mainTableView.mj_header endRefreshing];
               return ;
           }
           //分页的时候得多次相加count
           _headerLable.headerLable.text = [NSString stringWithFormat:@"共%@条数据",tmpDic[@"count"]];
            NSArray *tmpArray = dic[@"data"];
            for (NSDictionary *dic in tmpArray) {
                DailyCheckModel *model = [[DailyCheckModel alloc]initWithDict:dic];
                [_dataArray addObject:model];
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
               if (_dataArray.count == 0) {
                   //是否启用占位图
                   _mainTableView.enablePlaceHolderView = YES;
                   DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
                   defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
                   defaultView.placeText.text = @"数据获取失败";
                   [self.mainTableView reloadData];
               }
               [EBAlert alertError:@"请检查网络" length:2.0f];
               [self.mainTableView.mj_header endRefreshing];
               [self.mainTableView.mj_footer endRefreshing];
           }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DailCheckTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    DailyCheckModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kScreenW*222/683+30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DailyCheckDetailViewController *dc = [[DailyCheckDetailViewController alloc]init];
    DailyCheckModel *model = _dataArray[indexPath.row];
    dc.document_id = model.document_id;
    dc.user_id = model.user_id;
    dc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:dc animated:YES];
}

#pragma mark -- HeaderViewForDailCheckViewDelegate
- (void)btnClick:(UIButton *)btn{
    switch (btn.tag) {
        case 0:
            [self addPickerViewForWork:btn];
            break;
        case 1:
            [self addDatePickerView:btn];
            break;
        case 2:
            [self addPickerViewForState:btn];
            break;
        default:
            break;
    }
}

//职务
- (void)addPickerViewForWork:(UIButton *)btn{
    self.pickerView.dataSource = _positionArr;
    self.pickerView.pickerTitle = @"请选择职务";
     __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
     
        //选择职务搜索的时候，把user_id 跟 department_id 清空 date 清空 status 清空
        _user_id = @"";
        _dept_id = @"";
        _user_duty = result;
        [btn setTitle:result forState:UIControlStateNormal];
        [weakSelf refreshHeader];
    };
    self.pickerView.clearSelect = ^(){
        //清空职务筛选的时候，就加载自己的职务
        _user_duty = @"";
        _user_id = [[EBPreferences sharedInstance].userId componentsSeparatedByString:@"_"].lastObject;
        _dept_id = [[EBPreferences sharedInstance].dept_id componentsSeparatedByString:@"_"].lastObject;
        [btn setTitle:@"职务" forState:UIControlStateNormal];
        [weakSelf refreshHeader];
    };
    [self.pickerView show];
}

- (HooDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view withIsShowClearBtn:YES];
        _datePicker.delegate = self;
        _datePicker.datePickerMode = HooDatePickerModeDate;
    }
    return _datePicker;
}

//日期选择控制器
- (void)addDatePickerView:(UIButton *)btn{
    
    _dateBtn = btn;
    [self.datePicker show];
}

//职务
- (void)addPickerViewForState:(UIButton *)btn{
    self.pickerView.dataSource = @[@"未上报",@"已上报",@"已批示",@"已点评"];
    self.pickerView.pickerTitle = @"请选择状态";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
      
        _status = result;
        [btn setTitle:result forState:UIControlStateNormal];
        [weakSelf refreshHeader];
    };
    self.pickerView.clearSelect =^(){
        
         _status = @"";
        [btn setTitle:@"日报状态" forState:UIControlStateNormal];
        [weakSelf refreshHeader];
    };
    [self.pickerView show];
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

    if ([date compare:[NSDate date]] < 0) {
        _date = currentOlderOneDateStr;
    }else{
        [EBAlert alertError:@"请选择小于当前日期的天数" length:2.0 ];
        return;
    }
    
    [_dateBtn setTitle:_date forState:UIControlStateNormal];
    
    _date = [currentOlderOneDateStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    _datePicker.date = date;
    
    [self refreshHeader];
}

- (void)datePicker:(HooDatePicker *)datePicker didClear:(UIButton *)sender{
    _date = @"";
    [_dateBtn setTitle:@"日期" forState:UIControlStateNormal];
    [self refreshHeader];//刷新头部
}

#pragma mark -- UISearchBar


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
    NSLog(@"跳转");
}



@end
