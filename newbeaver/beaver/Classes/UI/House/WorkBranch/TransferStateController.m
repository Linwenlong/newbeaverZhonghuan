//
//  TransferStateController.m
//  chow
//
//  Created by 刘海伟 on 2017/11/3.
//  Copyright © 2017年 eallcn. All rights reserved.
//
//  交易详情2.0 - 过户状态界面

#import "TransferStateController.h"
#import "TransferHeaderView.h"
#import "ZHTransferStateCell.h"
#import "MBProgressHUD+CZ.h"


#define HeaderHeight 120

@interface TransferStateController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIView *topBgView;
@property (nonatomic, strong) UIView *midView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
/** API安全校验access_token */
@property (nonatomic, copy) NSString *access_token;
/** 过户状态的字典数组信息 */
@property (nonatomic, strong) NSMutableArray *transferArray;
/** 办理成功的字典数组信息 */
@property (nonatomic, strong) NSMutableArray *successArray;
/** 办理成功最后一个节点的索引 */
@property (nonatomic, assign) NSInteger index;
/** 过户状态的节点个数 */
@property (nonatomic, assign) NSInteger transCount;

@property (nonatomic, copy) NSString *taskIdOne;
/** 中间midView赋值的字典信息 */
@property (nonatomic, strong) NSMutableDictionary *midDict;
/** 过户节点的字典数组 */
@property (nonatomic, strong) NSMutableArray *NodeArray;

/** midView上面的twoView */
@property (nonatomic, strong) UIView *midTwoView;
/** midView上面的"任务办理结果"lbl */
@property (nonatomic, strong) UILabel *midHeaderLbl;
/** midView上面的bottomLineView */
@property (nonatomic, strong) UIView *midBottomLine;


@end

@implementation TransferStateController

#pragma mark -- 懒加载
- (NSMutableArray *)transferArray {
    if (_transferArray == nil) {
        _transferArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _transferArray;
}
- (NSMutableArray *)successArray {
    if (_successArray == nil) {
        _successArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _successArray;
}
- (NSMutableArray *)NodeArray {
    if (_NodeArray == nil) {
        _NodeArray = [NSMutableArray array];
    }
    return _NodeArray;
}
- (NSMutableDictionary *)midDict {
    if (_midDict == nil) {
        _midDict = [NSMutableDictionary dictionary];
    }
    return _midDict;
}
#pragma mark -- 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = LWL_LineColor;
    
    self.title = @"过户状态";
    self.contractNo = @"CTR173533971008";
    NSLog(@"传递至过户状态的合同号: %@",self.contractNo);
    
    //3.0 加载设置底部的tableView
    [self setUpBottomTableView];
    
    //4.0 关于网络请求的业务处理
    // 发起网络请求, 获取access token信息
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"Authorization"] = @"Basic YWNtZTo=";
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"http://192.168.2.107:4000/uaa/oauth/token?scope=openid&username=customer-app&password=123456&grant_type=password"] parameters:nil error:nil];
    
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setAllHTTPHeaderFields:params];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            //NSLog(@"请求成功, token:%@", responseObject);
            
            self.access_token = responseObject[@"access_token"];
            
            //4.1 发送网络请求, 获取过户状态的实时状态数据
            [self loadRecordDates];
            
        } else {
            NSLog(@"请求失败: %@",error);
            [MBProgressHUD showError:@"网络繁忙,请稍后再试"];
        }
        
    }] resume];
    
    
}

#pragma mark -- 4.1 发送网络请求, 获取过户状态的实时状态数据
- (void)loadRecordDates {

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"Authorization"] = [NSString stringWithFormat:@"bearer %@",self.access_token];
    
    NSString *contractNo = self.contractNo;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.2.107:9001/trade-customer/api/v1/trade-process/%@/1",contractNo];
    NSLog(@"获取过户状态的url: %@",urlStr);
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:urlStr parameters:nil error:nil];
    
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setAllHTTPHeaderFields:params];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"请求成功, 过户状态信息:%@", responseObject);
            [self.transferArray removeAllObjects];
            [self.transferArray addObjectsFromArray:responseObject];
            self.transCount = self.transferArray.count;
            NSLog(@"过户状态数据条数: %ld",self.transCount);
            
            for (NSDictionary *dic in self.transferArray) { //s:成功 f:异常 u:没有办理
                if (![dic[@"status"] isEqualToString:@"u"]) {
                    [self.successArray addObject:dic];
                }
            }
            //NSLog(@"成功successArray: %@",self.successArray);
            
            self.taskIdOne = self.successArray.lastObject[@"taskId"];
            
            
            for (int i = 0; i <self.transferArray.count; i++) {
                if ([self.taskIdOne isEqualToString:[NSString stringWithFormat:@"%@",self.transferArray[i][@"taskId"]]]) {
                    self.index = i;
                }
            }
            NSLog(@"index: %ld",self.index);
            
            [self.midDict addEntriesFromDictionary:self.successArray.lastObject];
            //NSLog(@"self.midDict: %@",self.midDict);
            
            //1.0 加载设置顶部的过户节点ScrollView
            [self setUpTopScrollView];
            
            //2.0 加载设置中间的过户节点标题
            [self setUpMidTitleView];
            
            if (![self.taskIdOne isKindOfClass:[NSNull class]]) {
                //4.2 首次进来, 获取第一个节点任务办理信息
                [self loadFirstNodeDates];
            }

        } else {
            NSLog(@"请求失败: %@",error);
            [MBProgressHUD showError:@"网络繁忙,请稍后再试"];
        }
        
    }] resume];

}

#pragma mark -- 4.2 首次进来, 获取第一个节点任务办理信息
- (void)loadFirstNodeDates {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"Authorization"] = [NSString stringWithFormat:@"bearer %@",self.access_token];
    
    NSString *taskId = self.taskIdOne;
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.2.107:9001/trade-customer/api/v1/banli/%@",taskId];
    NSLog(@"获取过户节点信息的url: %@",urlStr);
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:urlStr parameters:nil error:nil];
    
    req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req setAllHTTPHeaderFields:params];
    
    [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (!error) {
            NSLog(@"请求成功, 过户节点信息:%@", responseObject);
            [self.NodeArray removeAllObjects];
            [self.NodeArray addObjectsFromArray:responseObject];
            NSLog(@"过户节点数据条数: %ld",(unsigned long)self.NodeArray.count);
            
            //3.0 加载设置底部的tableView
            //[self setUpBottomTableView];
            
            if (self.NodeArray.count == 0) {
                self.midTwoView.backgroundColor = [UIColor redColor];
                self.midHeaderLbl.hidden = YES;
                self.midBottomLine.hidden = YES;
                
            } else {
                self.midTwoView.backgroundColor = [UIColor whiteColor];
                self.midHeaderLbl.hidden = NO;
                self.midBottomLine.hidden = NO;
            }
            
            // 刷新tableView
            [self.tableView reloadData];
            
            
        } else {
            NSLog(@"请求失败: %@",error);
            [MBProgressHUD showError:@"网络繁忙,请稍后再试"];
        }
        
    }] resume];
    
}

#pragma mark -- 1.0 加载设置顶部的过户节点ScrollView
- (void)setUpTopScrollView {
    
//    //新增 加载顶部合同编号显示栏
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 8)];
    [self.view addSubview:bgView];
    bgView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
//    
//    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 44)];
//    [bgView addSubview:topView];
//    topView.backgroundColor = [UIColor whiteColor];
//    
//    UILabel *titleLbl = [[UILabel alloc] init];
//    [topView addSubview:titleLbl];
//    titleLbl.sd_layout
//    .leftSpaceToView(topView,10)
//    .centerYEqualToView(topView)
//    .widthIs(kScreenW-20)
//    .heightIs(20);
//   
//    titleLbl.text = [NSString stringWithFormat:@"合同编号: %@",self.contractNo];
//    titleLbl.font = [UIFont boldSystemFontOfSize:14];
//    titleLbl.textColor = LWL_DarkGrayrColor;
    
    //加载设置顶部的ScrollView
    UIView *topBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame), kScreenW, HeaderHeight)];
    [self.view addSubview:topBgView];
    self.topBgView = topBgView;
    topBgView.backgroundColor = [UIColor whiteColor];
    
    UIScrollView *ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame), kScreenW, HeaderHeight)];
    [self.view addSubview:ScrollView];
    self.scrollView = ScrollView;
    
    CGFloat scale = self.transCount *1.00 /4;
    //NSLog(@"scale: %.2f",scale);
    ScrollView.contentSize = CGSizeMake(kScreenW *scale, HeaderHeight);  // 设置内容大小
    ScrollView.pagingEnabled = YES;
    ScrollView.bounces = NO;
    ScrollView.showsHorizontalScrollIndicator = NO;//滚动的时候是否有水平的滚动条，默认是有的
    CGFloat offset = (self.index) /4;
    NSLog(@"index: %ld,offset: %.2f",self.index +1,offset);
    ScrollView.contentOffset = CGPointMake(kScreenW *offset, 0);
    
    //1.1 添加headerView
    CGFloat marginX = 0;
    CGFloat viewH = HeaderHeight;
    CGFloat viewW = (kScreenW - 3 * marginX) / 4;
    CGFloat viewY = 0;
    for (int i = 0; i < self.transferArray.count; i++) {
        TransferHeaderView *headerView = [TransferHeaderView headerView];
        [ScrollView addSubview:headerView];
        
        
        
        
        CGFloat viewX = marginX + i * (viewW + marginX);
        headerView.frame = CGRectMake(viewX, viewY, viewW, viewH);
        headerView.tag = i;
        
        UIButton *btn = [[UIButton alloc]initWithFrame:headerView.frame];
        
        [btn addTarget:self action:@selector(didClickNode:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:btn];
        [headerView bringSubviewToFront:btn];
//        headerView.contentLbl.userInteractionEnabled = YES;
//        headerView.userInteractionEnabled = YES;//与用户交互
        
        
        headerView.contentLbl.text = self.transferArray[i][@"processName"];
        
        NSDictionary *dict = self.transferArray[i];   //s:成功 f:异常 u:没有办理
        if ( [dict[@"addTime"] isEqual:[NSNull null]] || dict[@"addTime"] == nil || dict[@"addTime"] == NULL || dict[@"addTime"] == Nil) {
            headerView.timeLbl.text = @"";
            
        } else {
            NSString *time = [NSString stringWithFormat:@"%@",dict[@"addTime"]];
            headerView.timeLbl.text = [self NewtimeWithTimeIntervalString:time]; //@"2017-10-28";
        }
        
        if ([dict[@"status"] isEqualToString:@"s"]) { //s:成功 f:异常 u:没有办理
            headerView.smallIcon.image = [UIImage imageNamed:@"transfergreen"];
            headerView.contentLbl.textColor = LWL_BlueColor;
            headerView.midLineLeft.backgroundColor = LWL_BlueColor;
            headerView.midLineRight.backgroundColor = LWL_LightGrayColor;
            headerView.timeLbl.textColor = LWL_BlueColor;
            
        } else if ([dict[@"status"] isEqualToString:@"f"]) {
            headerView.smallIcon.image = [UIImage imageNamed:@"transfergray"];
            headerView.contentLbl.textColor = LWL_LightGrayColor;
            headerView.midLineLeft.backgroundColor = LWL_LightGrayColor;
            headerView.midLineRight.backgroundColor = LWL_LightGrayColor;
            headerView.timeLbl.textColor = LWL_LightGrayColor;
            
        } else if ([dict[@"status"] isEqualToString:@"u"]) {
            headerView.smallIcon.image = [UIImage imageNamed:@"transfergray"];
            headerView.contentLbl.textColor = LWL_LightGrayColor;
            headerView.midLineLeft.backgroundColor = LWL_LightGrayColor;
            headerView.midLineRight.backgroundColor = LWL_LightGrayColor;
            headerView.timeLbl.textColor = LWL_LightGrayColor;
        }
        
        if (i > 0 && i < self.transferArray.count -1) { //s:成功 f:异常 u:没有办理
            //NSDictionary *foreDict = self.transferArray[i-1]; //前一个字典
            NSDictionary *nextDict = self.transferArray[i+1]; //后一个字典
            
            if ([nextDict[@"status"] isEqualToString:@"s"]) {
                headerView.midLineRight.backgroundColor = LWL_BlueColor;
                
            } else if ([nextDict[@"status"] isEqualToString:@"f"]) {
                headerView.midLineRight.backgroundColor = LWL_LightGrayColor;
                
            } else if ([nextDict[@"status"] isEqualToString:@"u"]) {
                headerView.midLineRight.backgroundColor = LWL_LightGrayColor;
                
            }
            
        }
        //隐藏第一组左边线和最后一组右边线
        if (headerView.tag == 0) {
            headerView.midLineLeft.hidden = YES;
            
        } else if (headerView.tag == self.transCount -1) {
            headerView.midLineRight.hidden = YES;
        }
        
//        // 添加节点手势
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickNode:)];
//        [headerView addGestureRecognizer:tap];
    }
    

}

#pragma mark -- 节点手势的监听
- (void)didClickNode:(UIButton *)btn {
    NSLog(@"点击的tag: %ld",btn.tag);
    
    // 关于中间部分midView的赋值
    [self.midDict removeAllObjects];
    [self.midDict addEntriesFromDictionary: self.transferArray[btn.tag]];
    [self setUpMidTitleView];
    
    // 关于下面tableView办理结果数据的刷新
    NSString *taskId = self.transferArray[btn.tag][@"taskId"];
    NSLog(@"taskId: %@",taskId);
    
    if ([taskId isKindOfClass:[NSNull class]]) {
        [self.NodeArray removeAllObjects];
        // 刷新tableView
        [self.tableView reloadData];
        
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"Authorization"] = [NSString stringWithFormat:@"bearer %@",self.access_token];
        
        taskId = self.transferArray[btn.tag][@"taskId"];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSString *urlStr = [NSString stringWithFormat:@"http://192.168.2.107:9001/trade-customer/api/v1/banli/%@",taskId];
        NSLog(@"切换过户节点信息的url: %@",urlStr);
        NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:urlStr parameters:nil error:nil];
        
        req.timeoutInterval= [[[NSUserDefaults standardUserDefaults] valueForKey:@"timeoutInterval"] longValue];
        [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [req setAllHTTPHeaderFields:params];
        
        [[manager dataTaskWithRequest:req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            
            if (!error) {
                NSLog(@"切换成功, 过户节点信息:%@", responseObject);
                [self.NodeArray removeAllObjects];
                [self.NodeArray addObjectsFromArray:responseObject];
                NSLog(@"切换过户节点条数: %ld",(unsigned long)self.NodeArray.count);
                
                if (self.NodeArray.count == 0) {
                    self.midTwoView.backgroundColor = LWL_RedColor;
                    self.midHeaderLbl.hidden = YES;
                    self.midBottomLine.hidden = YES;
                    
                } else {
                    self.midTwoView.backgroundColor = [UIColor whiteColor];
                    self.midHeaderLbl.hidden = NO;
                    self.midBottomLine.hidden = NO;
                }
                
                // 刷新tableView
                [self.tableView reloadData];
                
            } else {
                NSLog(@"请求失败: %@",error);
                [MBProgressHUD showError:@"网络繁忙,请稍后再试"];
            }
            
        }] resume];

    }
    
}

#pragma mark -- 2.0 加载设置中间的过户节点标题
- (void)setUpMidTitleView {

    UIView *midView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topBgView.frame), kScreenW, 65 +10 +44)];
    [self.view addSubview:midView];
    self.midView = midView;
    midView.backgroundColor = [UIColor whiteColor];
    
    //2.1 上面的oneView
    UIView *oneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 65)];
    [midView addSubview:oneView];
    oneView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    [oneView addSubview:titleLbl];
    titleLbl.sd_layout
    .topSpaceToView(oneView,5)
    .centerXEqualToView(oneView)
    .widthIs(kScreenW)
    .heightIs(15);
    
    //s: 执行，u:未执行 f；异常
    if ([self.midDict[@"status"] isEqualToString:@"s"]) {
        titleLbl.text = [NSString stringWithFormat:@"%@已完成",self.midDict[@"processName"]];
        titleLbl.textColor = LWL_BlueColor;
        
    } else if ([self.midDict[@"status"] isEqualToString:@"f"]) {
        titleLbl.text = [NSString stringWithFormat:@"%@办理异常",self.midDict[@"processName"]];
        titleLbl.textColor = LWL_DarkGrayrColor;
        
    } else {
        titleLbl.text = [NSString stringWithFormat:@"待办理%@",self.midDict[@"processName"]];
        titleLbl.textColor = LWL_DarkGrayrColor;
    }
    //titleLbl.text = @"看档已完成";
    titleLbl.font = [UIFont boldSystemFontOfSize:16];
    
    UILabel *contentLbl = [[UILabel alloc] init];
    contentLbl.textAlignment = NSTextAlignmentCenter;
    [oneView addSubview:contentLbl];
    
    contentLbl.sd_layout
    .topSpaceToView(titleLbl,8)
    .centerXEqualToView(oneView)
    .widthIs(kScreenW)
    .heightIs(15);
    

    //s: 执行，u:未执行 f；异常
    if ([self.midDict[@"status"] isEqualToString:@"s"]) {
        NSString *time = self.midDict[@"addTime"];
        time = [self timeWithTimeIntervalString:time];
        contentLbl.text = [NSString stringWithFormat:@"%@已完成%@",time,self.midDict[@"processName"]];
        
    } else if ([self.midDict[@"status"] isEqualToString:@"f"]) {
        contentLbl.text = @"交易异常";
        
    } else {
        contentLbl.text = @"请等候办理";
    }
    //contentLbl.text = @"2017年9月10日已完成看档";
    contentLbl.textColor = LWL_DarkGrayrColor;
    contentLbl.font = [UIFont systemFontOfSize:13];
    
    // bottomLineView
    UIView *bottomLineView= [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(oneView.frame), kScreenW, 10)];
    [midView addSubview:bottomLineView];
    bottomLineView.backgroundColor = LWL_LineColor;
    
    //2.2 下面的twoView
    UIView *twoView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bottomLineView.frame), kScreenW, 44)];
    [midView addSubview:twoView];
    self.midTwoView = twoView;
    twoView.backgroundColor = LWL_LightGrayColor; //[UIColor whiteColor];
    
    UILabel *headerLbl = [[UILabel alloc] init];
    [twoView addSubview:headerLbl];
    self.midHeaderLbl = headerLbl;
    self.midHeaderLbl.hidden = YES;
    headerLbl.sd_layout
    .leftSpaceToView(twoView,15)
    .centerYEqualToView(twoView)
    .widthIs(kScreenW-30)
    .heightIs(15);
   
    headerLbl.text = @"任务办理结果";
    headerLbl.textColor = LWL_DarkGrayrColor;
    headerLbl.font = [UIFont boldSystemFontOfSize:13];
    
    // 底部的lineView
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(twoView.frame) -0.6, kScreenW, 0.6)];
    [midView addSubview:lineView];
    self.midBottomLine = lineView;
    self.midBottomLine.hidden = YES;
    lineView.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark -- 3.0 加载设置底部的tableView
- (void)setUpBottomTableView {
    
    CGFloat tableY = 60 +54 +HeaderHeight +65 +10 +44 -5;
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableY, kScreenW, kScreenW -tableY-50) style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    
    self.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    
    self.tableView.rowHeight = 44;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = LWL_LineColor;
    
}

#pragma mark -- tableView的数据源和代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.NodeArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZHTransferStateCell *cell = [ZHTransferStateCell cellWithTableView:tableView];
    
    NSDictionary *dic = self.NodeArray[indexPath.row];
    
    if ([dic[@"name"] isKindOfClass:[NSNull class]] || [dic[@"name"] isEqual:[NSNull null]] || dic[@"name"] == nil || dic[@"name"] == NULL || dic[@"name"] == Nil) {
        cell.titleOneLbl.text = @"";
        
    } else {
        cell.titleOneLbl.text = [NSString stringWithFormat:@"%@",dic[@"name"]];
    }
    
    if ([dic[@"value"] isKindOfClass:[NSNull class]] || [dic[@"value"] isEqual:[NSNull null]] || dic[@"value"] == nil || dic[@"value"] == NULL || dic[@"value"] == Nil) {
        cell.contentOneLbl.text = @"";
        
    } else {
        cell.contentOneLbl.text = [NSString stringWithFormat:@"%@",dic[@"value"]];
    }
    
    //把单元格点击时状态 改为None
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //设置标题的文字颜色
    cell.titleOneLbl.textColor = LWL_DarkGrayrColor;
    
    //设置内容的文字颜色
    cell.contentOneLbl.textColor = LWL_LightGrayColor;
    
    
    return cell;
}

- (NSString *)NewtimeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

@end



