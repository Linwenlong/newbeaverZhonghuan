//
//  WorkLoadChildViewController.m
//  beaver
//
//  Created by mac on 17/8/28.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "WorkLoadChildViewController.h"
#import "ExcelView.h"
#import "MJRefresh.h"
#import "HeaderViewForDailCheckView.h"
#import "WSDropMenuView.h"
#import "EBCache.h"
#import "HooDatePicker.h"

#define Left_Height 50

@interface WorkLoadChildViewController ()<ExcelViewDataSource,HeaderViewForDailCheckViewDelegate,HooDatePickerDelegate>
{
    int page;
    BOOL loadingHeader;
}

@property (nonatomic, strong)ValuePickerView *pickerView;

@property (nonatomic, strong) ExcelView *excel;
@property (nonatomic, strong) NSArray * topTitleArray;
@property (nonatomic, strong) NSMutableArray * leftTitleArray;
@property (nonatomic, strong) NSMutableArray  * dataArray;
@property (nonatomic, strong) HeaderViewForDailCheckView *headerLable;
@property (nonatomic, strong)NSMutableArray  *dept_Array;  //
@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器
@property (nonatomic, strong)NSString *currentDate;//当前的日
@property (nonatomic, strong)NSString *current_id;  //当前的id期
@property (nonatomic, strong)NSString *sub_type;  //选择的类型


@end

@implementation WorkLoadChildViewController

#pragma mark -- ExcelViewDataSource

// 返回  多少 列

- (NSInteger)numberOfColumnInExcelView:(ExcelView*)excelView{
    return self.topTitleArray.count;
}

// 每一个区返回多少行
- (NSInteger)contentTableView:(ContentTableView*)contentTableView numberOfRowsInSection:(NSInteger)section{
    return self.leftTitleArray.count;
}

// 返回 区 行 列 的数据
- (NSString*)contentTableView:(ContentTableView*)contentTableView cellForRowAtIndexPath:(NSIndexPath*)indexPath withColumn:(NSInteger)column{
    return self.dataArray[indexPath.row][column];
}

//@optional
//// 高度 区  行
- (CGFloat)heightOfContentTableView:(ContentTableView*)contentTableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    return Left_Height;
}
//// 每一列的宽度
- (CGFloat)widthOfContentTableView:(ContentTableView*)contentTableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    return 50;
}
//
// 每一列的标题  默认是 1 、2、3
- (NSString*)topCollectionView:(TopCollectionView*)topCollectionView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    return self.topTitleArray[indexPath.row];
}
// 左边序号 内容   默认是 1、2、3、、、、
- (NSString*)leftTableView:(LeftTableView*)leftTableView cellForRowAtIndexPath:(NSIndexPath*)indexPath{
    return self.leftTitleArray[indexPath.row];
}


- (void)CreateData{
    _sub_type = @"";
    self.pickerView = [[ValuePickerView alloc]init];
    _dataArray = [NSMutableArray array];
    _leftTitleArray = [NSMutableArray array];
    _dept_Array = [NSMutableArray arrayWithArray:[[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_DEPT_ALL]];
    NSLog(@"_dept_Array=%@",_dept_Array);
    //初始化数据
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    _currentDate = [dateFormatter stringFromDate:[NSDate date]];
}

- (void)setUI{
    _headerLable = [[HeaderViewForDailCheckView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 40) titleArr:@[@"模式",@"部门",@"月份",@"类型"] isShowBottomView:NO];
    _headerLable.headerViewDelegate = self;
    [self.view addSubview:_headerLable];
    
    self.excel = [[ExcelView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerLable.frame), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    self.excel.dataSource = self;
    self.excel.leftCount = self.leftTitleArray.count;
    [self.view addSubview:_excel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self CreateData];
    [self setUI];
    [self refreshHeader];
    [self refreshFooter];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}
-(void)refreshHeader{
    _excel.contentTbaleView.mj_header  = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        loadingHeader = YES;
        [self requestData:page];//加载数据
    }];
    [_excel.contentTbaleView.mj_header beginRefreshing];
}

- (void)refreshFooter{
    _excel.contentTbaleView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        page += 1;
        loadingHeader = NO;
        [self requestData:page];
    }];
}


-(void)end{
    [_excel.contentTbaleView.mj_header endRefreshing];
    [_excel.contentTbaleView.mj_footer endRefreshing];
}

- (void)requestData:(int)pageIndex{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/work/WorkData?token=%@&month=%@&type=%@&page=%d&page_size=20&sub_type=%@",[EBPreferences sharedInstance].token,@"2017-04",self.type,pageIndex,_sub_type]);
    NSString *urlStr = @"work/WorkData";
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"month":@"2017-04",
       @"type":self.type,
       @"sub_type":_sub_type,
       @"page":[NSNumber numberWithInt:pageIndex],
       @"page_size":[NSNumber numberWithInt:20]
       }success:^(id responseObject) {
           //是否启用占位图
           _excel.contentTbaleView.enablePlaceHolderView = YES;
           DefaultView *defaultView = (DefaultView *)_excel.contentTbaleView.yh_PlaceHolderView;
           defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
           defaultView.placeText.text = @"暂无详情数据";
           if (  loadingHeader ==  YES) {
               [self.dataArray removeAllObjects];
               [self.leftTitleArray removeAllObjects];
           }
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSDictionary *tmpDic = currentDic[@"data"];
           NSLog(@"currentDic=%@",currentDic);
           if ([currentDic[@"code"] integerValue] == 0) {
               
               NSArray *tmpArray = nil;
               if ([tmpDic[@"user"] isKindOfClass:[NSDictionary class]]) {
                  NSDictionary *userDic = tmpDic[@"user"];
                  tmpArray = userDic.allValues;
                [self.leftTitleArray addObjectsFromArray:userDic.allValues];
                NSDictionary *dataDic= tmpDic[@"data"];
                   for (id object in userDic.allKeys) {
                       NSDictionary *dic = dataDic[object];
                       [_dataArray addObject:dic.allValues];
                       if (self.topTitleArray==nil) {
                           self.topTitleArray = dic.allKeys;//获取头部
                       }
                   }
                   
               }else if ([tmpDic[@"user"] isKindOfClass:[NSArray class]]){
                   tmpArray = tmpDic[@"user"];
               }
               
               if (tmpArray.count == 0) {
                   [self.excel.contentTbaleView.mj_footer endRefreshingWithNoMoreData];
               }else{
                   [self.excel.contentTbaleView.mj_footer endRefreshing];
               }
               
               [self.excel.contentTbaleView.mj_header endRefreshing];
               [self.excel reloadData];
               
           }else{
               [EBAlert alertError:@"请求失败" length:2.0f];
           }
       } failure:^(NSError *error) {
           if (_dataArray.count == 0) {
               //是否启用占位图
               _excel.contentTbaleView.enablePlaceHolderView = YES;
               DefaultView *defaultView = (DefaultView *)_excel.contentTbaleView.yh_PlaceHolderView;
               defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
               defaultView.placeText.text = @"数据获取失败";
               [_excel reloadData];
           }
           [EBAlert hideLoading];
            [self.excel.contentTbaleView.mj_footer endRefreshing];
           [self.excel.contentTbaleView.mj_header endRefreshing];
           [EBAlert alertError:@"请检查网络" length:2.0f];
       }];
}

- (void)btnClick:(UIButton *)btn{
    NSLog(@"点击了btn － %ld",btn.tag);
    
    switch (btn.tag) {
        case 0:
            [EBAlert alertError:@"暂不支持模式筛选" length:2.0f];
            break;
        case 1:
            [EBAlert alertError:@"暂不支持部门筛选" length:2.0f];
//            [self showDeptView];
            break;
        case 2:
            [self showPickerView];
            break;
        case 3:
            [self showTypeView];
            break;
        default:
            break;
    }
}

- (void)showDeptView{
    NSLog(@"选择了部门");
  
}

- (HooDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view.superview.superview];
        _datePicker.delegate = self;
        _datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
    }
    return _datePicker;
}

- (void)showPickerView{
    [self.datePicker show];
}

- (void)showTypeView{
    
    if ([self.type isEqualToString:@"house"]) {
        self.pickerView.dataSource = @[@"不限",@"出租",@"出售"];
    }else if ([self.type isEqualToString:@"client"]){
        self.pickerView.dataSource = @[@"不限",@"求租",@"求购"];
    }else{
        self.pickerView.dataSource = @[@"不限",@"一手",@"二手",@"租赁"];
    }
    self.pickerView.pickerTitle = @"请选择类型";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        NSLog(@"value = %@",result);
        _sub_type = result;
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
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];
    NSLog(@"currentOlderOneDateStr=%@",currentOlderOneDateStr);
    
    if ([date compare:[NSDate date]] < 0) {
        _currentDate = currentOlderOneDateStr;
    }else{
        [EBAlert alertError:@"请选择小于本月的月份" length:2.0 ];
        return;
    }
    //获取当前的日期比较，如果是相当就本月
    NSDate *currentDate = [NSDate date];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    _currentDate = currentOlderOneDateStr;
    
    _datePicker.date = date;
}


@end
