//
//  MyAchievementChildViewController.m
//  beaver
//
//  Created by mac on 17/8/22.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyAchievementChildViewController.h"
#import "ZFChart.h"
#import "MyAchievementView.h"
#import "MyAchievementTableViewCell.h"
#import "MJRefresh.h"

@interface MyAchievementChildViewController()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)MyAchievementView *seeView;

@property (nonatomic, strong)NSMutableArray   *sevenDate;
@property (nonatomic, strong)NSMutableArray   *fifteenDate;
@property (nonatomic, strong)NSMutableArray   *thirtyDate;

@property (nonatomic, strong)NSMutableArray   *sevenNum;
@property (nonatomic, strong)NSMutableArray   *fifteenNum;
@property (nonatomic, strong)NSMutableArray   *thirtyNum;


@property (nonatomic, strong)NSString   *curdealnum;//今日成交
@property (nonatomic, strong)NSString   *sevendealnum;
@property (nonatomic, strong)NSString   *fifteendealnum;
@property (nonatomic, strong)NSString   *thirtydealnum;
@property (nonatomic, strong)NSString   *allDealnum;

@end

@implementation MyAchievementChildViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-70)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _seeView =[[MyAchievementView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 430) sevenDate:_sevenDate fifteenDate:_fifteenDate thirtyDate:_thirtyDate sevenNum:_sevenNum fifteenNum:_fifteenNum thirtyNum:_thirtyNum sevendealnum:_sevendealnum fifteendealnum:_fifteendealnum thirtydealnum:_thirtydealnum];

        _mainTableView.tableHeaderView = _seeView;
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestData];
}


- (void)requestData{
    
    _sevenDate = [NSMutableArray array];
    _fifteenDate = [NSMutableArray array];
    _thirtyDate = [NSMutableArray array];
    _sevenNum = [NSMutableArray array];
    _fifteenNum = [NSMutableArray array];
    _thirtyNum = [NSMutableArray array];
    
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/achievement/achievement?token=%@&type=%@",[EBPreferences sharedInstance].token,self.type]);
    NSString *urlStr = @"achievement/achievement";
    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"type":self.type
       }success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSLog(@"currentDic=%@",currentDic);
           if ([currentDic[@"code"] integerValue] == 0) {
               NSDictionary *dic = currentDic[@"data"];
               //初始化数据
               NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
               [dateFormatter setDateFormat:@"MM-dd"];
               NSString *curDate = [dateFormatter stringFromDate:[NSDate date]];
               NSLog(@"curDate = %@",curDate);
               _allDealnum = [NSString stringWithFormat:@"%@",dic[@"allDeal"]];
               //7天
               _sevendealnum = [NSString stringWithFormat:@"%@",dic[@"sevenDealsum"]];
               NSArray *sevenQuotation = dic[@"sevenQuotation"];
               for (NSDictionary *dic in sevenQuotation) {
                   if ([dic[@"comdate"] isEqualToString:curDate]) {
                       NSLog(@"获取到了今日成交");
                       _curdealnum = dic[@"dealnum"];
                   }
                   [_sevenDate addObject:dic[@"comdate"]];
                   [_sevenNum addObject:[NSString stringWithFormat:@"%@",dic[@"dealnum"]]];
               }
               
               //15天
               _fifteendealnum = [NSString stringWithFormat:@"%@",dic[@"fifteenDealsum"]];
               NSArray *fifteenQuotation = dic[@"fifteenQuotation"];
               for (NSDictionary *dic in fifteenQuotation) {
                   [_fifteenDate addObject:dic[@"comdate"]];
                   [_fifteenNum addObject:[NSString stringWithFormat:@"%@",dic[@"dealnum"]]];
               }
               
               //30天
               _thirtydealnum = [NSString stringWithFormat:@"%@",dic[@"thirtyDealsum"]];
               NSArray *thirtyQuotation = dic[@"thirtyQuotation"];
               for (NSDictionary *dic in thirtyQuotation) {
                   [_thirtyDate addObject:dic[@"comdate"]];
                   [_thirtyNum addObject:[NSString stringWithFormat:@"%@",dic[@"dealnum"]]];
               }
               
           }else{
               [EBAlert alertError:@"请求失败" length:2.0f];
           }
           [self.view addSubview:self.mainTableView];
           [self.mainTableView registerNib:[UINib nibWithNibName:@"MyAchievementTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
           [self.mainTableView reloadData];
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请检查网络" length:2.0f];
       }];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyAchievementTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
       [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == 0) {
        [cell setLeftTitle:@"今日成交" leftConnent:_curdealnum rightType:@"近7日成交" rightConnent:_sevendealnum];
    }else if (indexPath.row == 1){
      [cell setLeftTitle:@"近15日成交" leftConnent:_fifteendealnum rightType:@"近30日成交" rightConnent:_thirtydealnum];
    }else{
      [cell setLeftTitle:@"总成交" leftConnent:_allDealnum rightType:@"" rightConnent:@""];
    }
 
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}



@end
