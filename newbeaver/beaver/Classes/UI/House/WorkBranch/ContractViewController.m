//
//  ContractViewController.m
//  beaver
//
//  Created by mac on 17/11/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ContractViewController.h"
#import "FinanceDetailTableViewCell.h"
#import "FinanceDetailModel.h"
#import "ContractTableViewCell.h"

@interface ContractViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *sectionTitles;
}
@property (nonatomic, strong)UITableView *mainTableView;

@property (nonatomic, strong)NSMutableArray *dataArray1;//基本信息
@property (nonatomic, strong)NSMutableArray *dataArray2;//分成信息


@property (nonatomic, copy)NSString *paid_money;//佣金实收总额
@property (nonatomic, copy)NSString *expect_money;//应收佣金总额
@property (nonatomic, copy)NSString *min_agencyfee;//最低收佣总额

@end

@implementation ContractViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64) style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.estimatedRowHeight = 80;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        [_mainTableView setSeparatorColor:[UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00]];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.showsHorizontalScrollIndicator = NO;
        _mainTableView.showsVerticalScrollIndicator = NO;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _mainTableView;
}

- (void)requestData{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Zhpay/houseDealDetail?token=%@&deal_id=%@",[EBPreferences sharedInstance].token,_ht_id]);
    
    NSString *urlStr = @"/Zhpay/houseDealDetail";//公司收入分账
    NSLog(@"token=%@",[EBPreferences sharedInstance].token);
    NSLog(@"deal_id=%@",_ht_id);
    if (_ht_id == nil) {
        [EBAlert alertError:@"合同id为空" length:2.0f];
        return;
    }
    
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"deal_id":_ht_id,
       }success:^(id responseObject) {
           [EBAlert hideLoading];
           
           _mainTableView.enablePlaceHolderView = YES;
           DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
           defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
           defaultView.placeText.text = @"暂无详情数据";
           
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSLog(@"currenttDic = %@",currentDic);
           [self analysisData:currentDic];
           [self.mainTableView reloadData];
           
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           if (_dataArray1.count == 0) {
               //是否启用占位图
               _mainTableView.enablePlaceHolderView = YES;
               DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
               defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
               defaultView.placeText.text = @"数据获取失败";
               [self.mainTableView reloadData];
           }
           [EBAlert alertError:@"请检查网络" length:2.0f];
       }];
}

- (void)analysisData:(NSDictionary *)dic{
    NSArray *tmpArray = dic[@"data"][@"data"];
    NSArray *tmp = nil;
    if (tmpArray.count > 0) {
        NSDictionary *tmpDic = tmpArray.firstObject;
        _paid_money = tmpDic[@"paid_money"];
        _expect_money = tmpDic[@"expect_money"];
        _min_agencyfee = tmpDic[@"min_agencyfee"];
        
    //数组1
        NSString *property_address = @"";//产证地址
        if ([tmpDic[@"property_address"] isEqualToString:@""]) {
                property_address = @"暂无";
        }else{
                property_address = tmpDic[@"property_address"];
        }
        tmp =@[@{@"name":@"合同编号",@"value":self.ht_code},
                   @{@"name":@"房源地址",@"value":tmpDic[@"house_address"]},
                   @{@"name":@"产证地址",@"value":property_address},
               @{@"name":@"成交时间",@"value":[self timeWithTimeIntervalString:tmpDic[@"complete_date"]]},
                   @{@"name":@"成交人",@"value": [NSString stringWithFormat:@"%@-%@",tmpDic[@"deal_department_name"],tmpDic[@"deal_username"]]},
                   ];
        for (NSDictionary *dic in tmp) {
            FinanceDetailModel *model = [[FinanceDetailModel alloc]initWithDict:dic];
            [_dataArray1 addObject:model];
        }
        //其他分成
        NSArray *tmpArray = tmpDic[@"commission"][@"data"];
        for (NSDictionary *dic in tmpArray) {
            [_dataArray2 addObject:dic];
        }
        //头
        sectionTitles = @[@"基本信息",@"分成信息"];
        [self.mainTableView reloadData];
    }
}

- (NSString *)timeWithTimeIntervalString:(NSString *)timeString{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    //1483849740
    return dateString;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"合同详情";
     _dataArray1 = [NSMutableArray array];//分成信息
     _dataArray2 = [NSMutableArray array];//分成信息
    [self.view addSubview:self.mainTableView];
     [self requestData];
    [_mainTableView registerClass:[FinanceDetailTableViewCell class] forCellReuseIdentifier:@"cell1"];
    [_mainTableView registerClass:[ContractTableViewCell class] forCellReuseIdentifier:@"cell2"];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 48)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, kScreenW/2, 21)];
        lable.text = sectionTitles[section];
        lable.textAlignment = NSTextAlignmentLeft;
        lable.textColor = UIColorFromRGB(0x404040);
        lable.font = [UIFont boldSystemFontOfSize:13.0f];
        [view addSubview:lable];
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
        line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
        [view addSubview:line1];
        
//        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 47, kScreenW, 1)];
//        line2.backgroundColor = UIColorFromRGB(0xe8e8e8);
//        [view addSubview:line2];
        return view;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 96)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, kScreenW/2, 21)];
        lable.text = sectionTitles[section];
        lable.textAlignment = NSTextAlignmentLeft;
        lable.textColor = UIColorFromRGB(0x404040);
        lable.font = [UIFont boldSystemFontOfSize:13.0f];
        [view addSubview:lable];
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
        line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
        [view addSubview:line1];
        
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 47, kScreenW, 1)];
        line2.backgroundColor = UIColorFromRGB(0xe8e8e8);
        [view addSubview:line2];
        
        
        //最低收佣
        
        
        UILabel *leftlable = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(line2.frame)+13, (kScreenW-15*2)/2.0f, 21)];
//        NSString *str1 = [NSString stringWithFormat:@"最低收佣金额(元):%@",_min_agencyfee];
        if ([_min_agencyfee isEqualToString:@"<null>"]||[_min_agencyfee isEqual:[NSNull class]]||
            [_min_agencyfee isEqual:[NSNull null]]
            ||_min_agencyfee == nil) {
            _min_agencyfee = @"暂无";
        }
        NSString *leftStr = [NSString stringWithFormat:@"最低收佣金额(元) : %@",_min_agencyfee];
        NSLog(@"leftStr = %ld",leftStr.length);
        NSMutableAttributedString *attributeStr1 =[[NSMutableAttributedString alloc]initWithString:leftStr];
        [attributeStr1 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x404040)} range:NSMakeRange(0, 11)];
        [attributeStr1 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x808080)} range:NSMakeRange(11, leftStr.length-11)];
        leftlable.attributedText = attributeStr1;
        leftlable.textAlignment = NSTextAlignmentLeft;
        leftlable.font = [UIFont systemFontOfSize:13.0f];
        [view addSubview:leftlable];
        
        //实收业绩
        UILabel *rightlable = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW/2.0f, CGRectGetMaxY(line2.frame)+13, (kScreenW-15*2)/2.0f, 21)];
        NSString *rightStr = [NSString stringWithFormat:@"实收业绩(元) : %@",_paid_money];
        NSMutableAttributedString *attributeStr2 =[[NSMutableAttributedString alloc]initWithString:rightStr];
        [attributeStr2 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x404040)} range:NSMakeRange(0, 9)];
        [attributeStr2 addAttributes:@{ NSForegroundColorAttributeName:UIColorFromRGB(0x808080)} range:NSMakeRange(9, rightStr.length-9)];
        rightlable.attributedText = attributeStr2;
        rightlable.textAlignment = NSTextAlignmentRight;
        rightlable.font = [UIFont systemFontOfSize:13.0f];
        [view addSubview:rightlable];
        
//        UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, 95, kScreenW, 1)];
//        line3.backgroundColor = UIColorFromRGB(0xe8e8e8);
//        [view addSubview:line3];
        return view;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 48;
    }else{
        return 48*2;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section != sectionTitles.count-1) {
        return 5;
    }else{
        return 1;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section != sectionTitles.count-1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 5)];
        view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        return view;
    }else{
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
        line1.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        return line1;
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sectionTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _dataArray1.count;
    }else{
        return _dataArray2.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        FinanceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        FinanceDetailModel *model = _dataArray1[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setModel:model isContactDetail:YES];
        return cell;
    }else{
        ContractTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setDic:_dataArray2[indexPath.row]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        FinanceDetailModel *model = _dataArray1[indexPath.row];
        return [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[FinanceDetailTableViewCell class] contentViewWidth:kScreenW];
    }else{
        return 103;
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

@end
