//
//  RentBaseInfomationViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/11/8.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "RentBaseInfomationViewController.h"
#import "RentBaseInformationTableViewCell.h"
#import "RentBasePerformanceTableViewCell.h"

@interface RentBaseInfomationViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *mainTableView;

@property (nonatomic, strong) UILabel * receivable_content;             //应收业绩合计
@property (nonatomic, strong) UILabel * official_content;               //实收业绩合计
@property (nonatomic, strong) UILabel * divide_scale_content;           //分成比例合计

@property (nonatomic, strong) NSDictionary * baseDetail;                //合同的基本信息
@property (nonatomic, strong) NSMutableArray * commission;              //业绩分成

@property (nonatomic, strong) NSString * paid_money;                    //实收总额
@property (nonatomic, strong) NSString * expect_money;                  //应收总额

@end

@implementation RentBaseInfomationViewController


- (UITableView *)mainTableView{
    if (!_mainTableView) {
        CGFloat offex = 64;
        if (@available(iOS 11.0, *)) {
            offex = 74;
        }
        
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- offex - 40)];
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
        [_mainTableView setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.mainTableView];
    _commission = [NSMutableArray array];
    
    [self refreshHeader];
    [self.mainTableView registerClass:[RentBaseInformationTableViewCell class] forCellReuseIdentifier:@"baseCell"];
    [self.mainTableView registerClass:[RentBasePerformanceTableViewCell class] forCellReuseIdentifier:@"performanceCell"];
}

//刷新头部、、MJ
-(void)refreshHeader{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];//加载数据
    }];
    [self.mainTableView.mj_header beginRefreshing];
}

- (void)requestData{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/NewDealInfo?token=%@&deal_id=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_deal_id]);
    NSString *urlStr = @"zhpay/NewDealInfo";
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //_dept_id
    NSLog(@"_deal_id=%@",_deal_id);
    
    NSDictionary *parm = @{
                           @"token":[EBPreferences sharedInstance].token,
                           @"deal_id":_deal_id
                           };
    
    [HttpTool post:urlStr parameters:
     parm success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSLog(@"currentDic=%@",currentDic);
           NSDictionary *tmpDic = currentDic[@"data"];
           NSLog(@"tmpArray=%@",tmpDic);
         [_commission removeAllObjects];
           if ([currentDic[@"code"] integerValue] == 0) {
               [_commission addObjectsFromArray:tmpDic[@"commission"]];
               _baseDetail = tmpDic[@"detail"];
               _paid_money = _baseDetail[@"paid_money"];
               _expect_money = _baseDetail[@"expect_money"];
           }else{
               [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           }
           [self.mainTableView.mj_header endRefreshing];
           
           [self.mainTableView reloadData];
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
       }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  section == 0 ? 1 : _commission.count;//2后面需要改
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        RentBaseInformationTableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:@"baseCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (_baseDetail != nil) {
            cell.dic = _baseDetail;
        }
        return cell;
    }else{
        NSDictionary *dic =  _commission[indexPath.row];
        RentBasePerformanceTableViewCell *cell  =[tableView dequeueReusableCellWithIdentifier:@"performanceCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDic:dic pay_money:_paid_money expect_money:_expect_money];
        return cell;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        return 515;
    }
    return 180;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        return 15;
    }
    
    return 175;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 15)];
        view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        return view;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 155)];
        view.backgroundColor = [UIColor whiteColor];
        
        
        UIView *line = [UILabel new];
        line.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        
        
        UIFont *bigFont = [UIFont boldSystemFontOfSize:17.0f];
        UIFont *smallFont = [UIFont systemFontOfSize:15.0f];
        UIColor *deepColor = UIColorFromRGB(0x000000);
        UIColor *lightColor = UIColorFromRGB(0x474747);

        UILabel* baseInfo = [UILabel new];
        baseInfo.textAlignment = NSTextAlignmentLeft;
        baseInfo.textColor = deepColor;
        baseInfo.font = bigFont;
        baseInfo.text = @"业绩分成信息";
        
        UIView *line1 = [UILabel new];
        line1.backgroundColor = UIColorFromRGB(0xF6F6F6);
        
        UILabel *receivable = [UILabel new];
        receivable.textAlignment = NSTextAlignmentLeft;
        receivable.textColor = deepColor;
        receivable.font = smallFont;
        receivable.text = @"应收业绩合计(元):";
        
        _receivable_content = [UILabel new];
        _receivable_content.textAlignment = NSTextAlignmentRight;
        _receivable_content.textColor = UIColorFromRGB(0xE60012);
        _receivable_content.font = smallFont;
        _receivable_content.text =[NSString stringWithFormat:@"%0.2f",[_expect_money floatValue]] ;
        
        UILabel *official = [UILabel new];
        official.textAlignment = NSTextAlignmentLeft;
        official.textColor = deepColor;
        official.font = smallFont;
        official.text = @"实收业绩合计(元):";
        
        _official_content = [UILabel new];
        _official_content.textAlignment = NSTextAlignmentRight;
        _official_content.textColor = UIColorFromRGB(0xE60012);
        _official_content.font = smallFont;
        _official_content.text = [NSString stringWithFormat:@"%0.2f",[_paid_money floatValue]] ;
        
        UILabel *divide_scale = [UILabel new];
        divide_scale.textAlignment = NSTextAlignmentLeft;
        divide_scale.textColor = deepColor;
        divide_scale.font = smallFont;
        divide_scale.text = @"分成比例合计:";
        
        _divide_scale_content = [UILabel new];
        _divide_scale_content.textAlignment = NSTextAlignmentRight;
        _divide_scale_content.textColor = lightColor;
        _divide_scale_content.font = smallFont;
        
        if (_commission.count == 0) {
            _divide_scale_content.text = @"0%";
        }else{
            _divide_scale_content.text = @"100%";
        }
        
        
        
        
        UIView *line2 = [UILabel new];
        line2.backgroundColor = UIColorFromRGB(0xF6F6F6);
        
        [view sd_addSubviews:@[line,baseInfo,line1,receivable,_receivable_content,official,_official_content,divide_scale,_divide_scale_content,line2]];
        
        CGFloat x = 20;
        CGFloat y = 15;
        CGFloat spcing = 19;
        
        CGFloat title_w = 130;
        CGFloat content_w = (kScreenW - 2 * x - title_w);
        CGFloat h  = 15;
        
        line.sd_layout
        .topSpaceToView(view, 0)
        .leftSpaceToView(view, 0)
        .rightSpaceToView(view, 0)
        .heightIs(h);
        
        baseInfo.sd_layout
        .topSpaceToView(line, y)
        .leftSpaceToView(view, x)
        .widthIs(title_w)
        .heightIs(17);
        
        line1.sd_layout
        .topSpaceToView(baseInfo, y)
        .leftSpaceToView(view, y)
        .rightSpaceToView(view, y)
        .heightIs(1);
        
        receivable.sd_layout
        .topSpaceToView(line1, y)
        .leftSpaceToView(view, x)
        .widthIs(title_w)
        .heightIs(h);
        
        _receivable_content.sd_layout
        .topEqualToView(receivable)
        .rightSpaceToView(view, x)
        .widthIs(content_w)
        .heightIs(h);
        
        official.sd_layout
        .topSpaceToView(receivable, spcing)
        .leftSpaceToView(view, x)
        .widthIs(title_w)
        .heightIs(h);
        
        _official_content.sd_layout
        .topEqualToView(official)
        .rightSpaceToView(view, x)
        .widthIs(content_w)
        .heightIs(h);
        
        divide_scale.sd_layout
        .topSpaceToView(official, spcing)
        .leftSpaceToView(view, x)
        .widthIs(title_w)
        .heightIs(h);
        
        _divide_scale_content.sd_layout
        .topEqualToView(divide_scale)
        .rightSpaceToView(view, x)
        .widthIs(content_w)
        .heightIs(h);

        line2.sd_layout
        .topSpaceToView(divide_scale, y)
        .leftSpaceToView(view, y)
        .rightSpaceToView(view, y)
        .heightIs(1);
        
        return view;
    
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat top, left, bottom, right;
    if (indexPath.section == 0) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }else{
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 97; //这里是我的headerView和footerView的高度
    if (_mainTableView.contentOffset.y<=sectionHeaderHeight&&_mainTableView.contentOffset.y>=0) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-_mainTableView.contentOffset.y, 0, 0, 0);
    } else if (_mainTableView.contentOffset.y>=sectionHeaderHeight) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
