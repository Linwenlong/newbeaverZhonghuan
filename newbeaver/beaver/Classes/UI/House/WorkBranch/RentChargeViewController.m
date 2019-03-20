//
//  RentChargeViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "RentChargeViewController.h"
#import "RentChargeUnpaidTableViewCell.h"
#import "RentChargePaidTableViewCell.h"
#import "ZHDCWebViewController.h"

@interface RentChargeViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int page;
    BOOL loadingHeader;
}


@property (nonatomic, strong)UITableView *mainTableView;

@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, strong)DefaultView *defaultView;

@end

@implementation RentChargeViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64 - 40)];
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _mainTableView;
}

- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = self.mainTableView.center;
        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];
        _defaultView.placeText.text = @"暂未获取到任何财务信息";
    }
    return _defaultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mainTableView];
    _dataArr = [NSMutableArray array];
    [self refreshHeader];
    [self.mainTableView registerClass:[RentChargeUnpaidTableViewCell class] forCellReuseIdentifier:@"unpaidCell"];
    [self.mainTableView registerClass:[RentChargePaidTableViewCell class] forCellReuseIdentifier:@"paidCell"];
}
- (void)requestData{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/dealReceivableFees?token=%@&deal_id=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_deal_id]);
    if (_deal_id == nil) {
        [EBAlert alertError:@"合同id为空" length:2.0f];
        return;
    }
    NSString *urlStr = @"zhpay/dealReceivableFees";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"deal_id":_deal_id
       } success:^(id responseObject) {
           [EBAlert hideLoading];
       
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSArray *tmpArray = currentDic[@"data"][@"data"];
           NSLog(@"currentDic = %@",currentDic);
           NSLog(@"tmpArray=%@",tmpArray);
           [_dataArr removeAllObjects];
           
           [_mainTableView.mj_header endRefreshing];
           
           if ([tmpArray isKindOfClass:[NSArray class]]) {//数组就解析数据
              [_dataArr addObjectsFromArray:tmpArray];
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
           
           if (_dataArr.count == 0) {//如果没有数据
               [self.mainTableView addSubview:self.defaultView];
           }else{
               if (self.defaultView) {
                   [self.defaultView  removeFromSuperview];
               }
           }
           
           [_mainTableView reloadData];
       } failure:^(NSError *error) {
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           [self.mainTableView.mj_header endRefreshing];
       }];
}

//刷新头部、、MJ
-(void)refreshHeader{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        loadingHeader = YES;
        [self requestData];
    }];
    [self.mainTableView.mj_header beginRefreshing];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dic = _dataArr[indexPath.section];
    
    if ([dic[@"order_no_status"] intValue] == 0) { //未支付
        RentChargeUnpaidTableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:@"unpaidCell" forIndexPath:indexPath];
        cell.dic = dic;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.tag = indexPath.section;
        cell.cost_btn.tag = indexPath.section;
       
        cell.btnClick = ^(NSInteger selectedIndex) {
            NSLog(@"selectedIndex = %ld",selectedIndex);
            //跳转到聚合支付
            //验证合同是否有效
            [self verifyContract:_dataArr[selectedIndex]];
        };
        return cell;
    }else{//已支付
        RentChargePaidTableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:@"paidCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.dic = dic;
        return cell;
    }
}


- (void)verifyContract:(NSDictionary *)dic{
    NSLog(@"dic=%@",dic);
    NSString *url = [NSString stringWithFormat:@"%@/Housedeal/verifyContract",NewHttpBaseUrl];
    NSDictionary *parm = @{
                           @"token" : [EBPreferences sharedInstance].token,
                           @"servercode" : [EBPreferences sharedInstance].companyCode,
                           @"contract_code" : _deal_code
                           };
    NSLog(@"parm=%@",parm);

    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:url parameters:parm success:^(id responseObject) {
        [EBAlert hideLoading];
        //                    NSLog(@"responseObject=%@",responseObject);
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"result=%@",result);
        if ([result[@"code"] integerValue] == 0){
            if ([result[@"data"] boolValue] == YES) {
                [self juhePay:_deal_code detail:dic];
            }else{
                [EBAlert alertError:@"无效合同" length:2.0f];
            }
        }else{
            [EBAlert alertError:@"数据加载失败" length:2.0f];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"数据加载失败" length:2.0f];
    }];
}

//聚合支付
- (void)juhePay:(NSString *)contact detail:(NSDictionary *)tmpDic{
    NSLog(@"tmpDic = %@",tmpDic);
    NSString *url = @"http://218.65.86.80:8112/pay/getCityQuery";
    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:url parameters:nil success:^(id responseObject) {
        [EBAlert hideLoading];
        
        NSDictionary *tmpdic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *tmpStr = tmpdic[@"data"];
        NSArray *tmpArr = [NSJSONSerialization JSONObjectWithData:[tmpStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if ([tmpdic[@"code"] integerValue] == 200) {
            for (NSDictionary * dic in tmpArr) {
                NSLog(@"city = %@", dic[@"cityName"]);
                
                if ([dic[@"cityName"] isEqualToString:[EBPreferences sharedInstance].city] || [[EBPreferences sharedInstance].city containsString:dic[@"cityName"]]) {
                    NSString *mercId = dic[@"mercId"];
                    ZHDCWebViewController *webVC = [[ZHDCWebViewController alloc] init];
                    webVC.hidesBottomBarWhenPushed = YES;
                    NSString *tittleString = @"中环地产聚合支付";
                  
                    if (contact.length > 0) {
                        webVC.homeUrl =[NSURL URLWithString:[NSString stringWithFormat:@"http://218.65.86.80:8114/index.html#/?mercId=%@&contract=%@&fee=%@",mercId,contact,tmpDic[@"price_num"]]];
                    }else{
                        webVC.homeUrl =[NSURL URLWithString:[NSString stringWithFormat:@"http://218.65.86.80:8114/index.html#/?mercId=%@",mercId]];
                    }
                    NSLog(@"homeUrl = %@",webVC.homeUrl);
                    webVC.title = tittleString;
                    NSLog(@"nav1 = %@",self.navigationController);
                    [self.navigationController pushViewController:webVC animated:YES];
                    return ;
                }
            }
            [EBAlert alertError:@"该城市暂未开通" length:2.0f];
        }else{
            [EBAlert alertError:@"数据加载失败" length:2.0f];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"数据加载失败" length:2.0f];
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = _dataArr[indexPath.section];

    if ([dic[@"order_no_status"] intValue] == 0) {
        return 194;
    }
    return 163;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 15)];
    view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    return view;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{

    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 97; //这里是我的headerView和footerView的高度
    if (_mainTableView.contentOffset.y<=sectionHeaderHeight && _mainTableView.contentOffset.y>=0) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-_mainTableView.contentOffset.y, 0, 0, 0);
    } else if (_mainTableView.contentOffset.y >= sectionHeaderHeight) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
