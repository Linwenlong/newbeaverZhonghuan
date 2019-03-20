//
//  CostCountDetailTwoViewController.m
//  beaver
//
//  Created by mac on 17/10/18.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "CostCountDetailTwoViewController.h"
#import "MJRefresh.h"
#import "CostCountDetailView.h"

@interface CostCountDetailTwoViewController ()

@property (nonatomic, strong)DefaultView *defaultView;

@end

@implementation CostCountDetailTwoViewController



- (void)setNav{
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    lable.textColor = [UIColor whiteColor];
    lable.text = self.config_type;
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:18.0f];
    self.navigationItem.titleView = lable;
    
    UIImage *navBg = [UIImage imageNamed:@"nav_bground"];
    //设置导航
    [self.navigationController.navigationBar setBackgroundImage:navBg forBarMetrics:UIBarMetricsDefault];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"_month = %@",_month);
    NSLog(@"_month_half = %@",_month_half);
    NSLog(@"_statistics = %@",_statistics);
    [self setNav];
    _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 300, 100)];
    _defaultView.center = self.view.center;
    _defaultView.centerY -= 60;
    _defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
    _defaultView.placeText.text = @"数据获取失败";
    _defaultView.hidden = YES;
    [self.view addSubview:_defaultView];
    self.view.backgroundColor = [UIColor whiteColor];
    //刷新头部
    [self requestData];
}



- (void)requestData{
    
    if (self.dic[@"department_id"] == nil) {
        [EBAlert alertError:@"数据加载错误,请重新加载" length:2.0f];
        return;
    }
    NSString *record_locked_detail_status = @"";
    if (self.dic[@"record_locked_detail_status"] != nil) {
        record_locked_detail_status = self.dic[@"record_locked_detail_status"];
    }
    NSDictionary *parm = nil;
    if (_month_half == nil || [_month_half isEqualToString:@""]) {
        parm = @{
               @"token":[EBPreferences sharedInstance].token,
               @"month":self.month,
               @"statistics":_statistics,
               @"department_id":self.dic[@"department_id"],
               @"type":self.type,
               @"config_type":self.config_type,
               @"record_locked_detail_status":record_locked_detail_status
               };
        
         NSLog(@"strList=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/finance/NewWageStatistics?token=%@&month=%@&department_id=%@&type=%@&config_type=%@&record_locked_detail_status=%@&statistics=%@",[EBPreferences sharedInstance].token,self.month,self.dic[@"department_id"],self.type,self.config_type,record_locked_detail_status,_statistics]);
    }else{
        parm = @{
                  @"token":[EBPreferences sharedInstance].token,
                  @"month":self.month,
                  @"month_half":_month_half,
                  @"statistics":_statistics,
                  @"department_id":self.dic[@"department_id"],
                  @"type":self.type,
                  @"config_type":self.config_type,
                  @"record_locked_detail_status":record_locked_detail_status
          };
        NSLog(@"strList=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/finance/NewWageStatistics?token=%@&month=%@&department_id=%@&type=%@&config_type=%@&record_locked_detail_status=%@&month_half=%@&statistics=%@",[EBPreferences sharedInstance].token,self.month,self.dic[@"department_id"],self.type,self.config_type,record_locked_detail_status,_month_half,_statistics]);
    }
    NSLog(@"parm = %@",parm);
//    NewWageStatisticsView
    
    [EBAlert showLoading:@"加载中..."allowUserInteraction:NO];
    [HttpTool post:@"finance/NewWageStatistics" parameters:parm success:^(id responseObject) {
            [EBAlert hideLoading];
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([currentDic[@"data"] isKindOfClass:[NSDictionary class]] && [currentDic[@"data"][@"data"]isKindOfClass:[NSArray class]]) {
                NSArray *tmpArr = [NSMutableArray arrayWithArray:currentDic[@"data"][@"data"]];
//                NSLog(@"tmpArr = %@",tmpArr);
                if (tmpArr.count == 0) {
                    _defaultView.hidden = NO;
                    _defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
                    _defaultView.placeText.text = @"暂无详情数据";
                    self.title = @"暂无详情数据";
                }else{
                    [self addCostCountDetailView:tmpArr];
                }
            }else{
                _defaultView.hidden = NO;
                _defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
                _defaultView.placeText.text = @"暂无详情数据";
                self.title = @"暂无详情数据";
            }
       } failure:^(NSError *error) {
            [EBAlert hideLoading];
           self.title = @"暂无详情数据";
           _defaultView.hidden = NO;
           _defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
           _defaultView.placeText.text = @"数据获取失败";
        [EBAlert alertError:@"请检查网络" length:2.0f];
       }];
}

- (void)addCostCountDetailView:(NSArray *)arr{
    CostCountDetailView *detailView = [[CostCountDetailView alloc]initWithFrame:self.view.bounds arr:arr];
    [self.view addSubview:detailView];
}

@end
