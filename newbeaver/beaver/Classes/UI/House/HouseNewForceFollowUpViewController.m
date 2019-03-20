//
//  HouseNewForceFollowUpViewController.m
//  beaver
//
//  Created by mac on 17/11/17.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "HouseNewForceFollowUpViewController.h"
#import "HouseNewForceFollowupTableViewCell.h"

#import "HouseNewForceFollowupFooterView.h"
#import "HouseNewForceFollowupHeaderView.h"

#import "FinanceDetailModel.h"
#import "EBHouse.h"
#import "EBController.h"

@interface HouseNewForceFollowUpViewController ()<UITableViewDataSource,UITableViewDelegate,HeaderViewDelegate>

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;

@property (nonatomic, strong)HouseNewForceFollowupFooterView *footView;

@end

@implementation HouseNewForceFollowUpViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _mainTableView.delegate = self;
        _mainTableView.estimatedRowHeight = 80;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.showsHorizontalScrollIndicator = NO;
        _mainTableView.showsVerticalScrollIndicator = NO;
        if (_followUptype == ZHForceFollowUpTypeNO) {//不需要强制写跟进
            HouseNewForceFollowupHeaderView *headerView = [[HouseNewForceFollowupHeaderView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 51+_phoneNum.count*39) name:_name phones:_phoneNum];
            headerView.headerViewDelegate = self;
            _mainTableView.tableHeaderView = headerView;
        }
    
        _footView = [[HouseNewForceFollowupFooterView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 337)];
        [_footView.confirmBtn addTarget:self action:@selector(updateData:) forControlEvents:UIControlEventTouchUpInside];

        _mainTableView.tableFooterView = _footView;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _mainTableView;
}

- (void)hiddenFollow{
    
    if (_footView.followUpContent.text.length < 5) {
        [EBAlert alertError:@"跟进字数必须大于5个" length:2.0f];
        return;
    }
    
    if (self.house_id == nil) {
        [EBAlert alertError:@"数据加载错误,请重新加载" length:2.0f];
        return;
    }
    //关注小区
    NSLog(@"house_id=%@",self.house_id);
    NSString *urlStr = @"follow/addFollow";
    NSDictionary *parm = @{
                              @"house_id":self.house_id,
                              @"follow_way":@"房源跟进",
                              @"content":_footView.followUpContent.text,
                              @"token":[EBPreferences sharedInstance].token,
                              @"call_flags":_call_flags
                              };

    NSLog(@"parm = %@",parm);
    NSLog(@"url = %@",[NSString stringWithFormat:@"%@/follow/addFollow?token=%@&house_id=%@&follow_way=房源跟进&content=%@&call_flags=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,self.house_id,_footView.followUpContent.text,_call_flags]);
    
    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:urlStr parameters:parm
           success:^(id responseObject) {
               [EBAlert hideLoading];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"currentDic = %@",currentDic);
               if ([currentDic[@"code"] integerValue] == 0) {
                   BOOL succeed = YES;
                   self.returnBlock(succeed);
               }else{
                   [EBAlert alertError:currentDic[@"desc"] length:2.0f];
                   //                self.textBlock();//调用block
               }
               [self.navigationController popViewControllerAnimated:YES];
           } failure:^(NSError *error) {
               [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
    }];

}

- (void)follow{
    
    if (_footView.followUpContent.text.length < 5) {
        [EBAlert alertError:@"跟进字数必须大于5个" length:2.0f];
        return;
    }
    
    if (self.house_id == nil) {
        [EBAlert alertError:@"数据加载错误,请重新加载" length:2.0f];
        return;
    }
    
    
    
    //关注小区
    NSLog(@"house_id=%@",self.house_id);
    NSString *urlStr = @"follow/addFollow";
    NSDictionary *tmpParm = @{
                              @"house_id":self.house_id,
                              @"follow_way":@"电话跟进",
                              @"content":_footView.followUpContent.text,
                              @"token":[EBPreferences sharedInstance].token
                              };
    NSMutableDictionary *parm =[NSMutableDictionary dictionaryWithDictionary:tmpParm];
    
    [parm setObject:@"yes" forKey:@"view_phone"];
    
    NSLog(@"parm = %@",parm);
    NSLog(@"url = %@",[NSString stringWithFormat:@"%@/follow/addFollow?token=%@&house_id=%@&follow_way=查看电话&content=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,self.house_id,_footView.followUpContent.text]);
    
    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:urlStr parameters:parm
           success:^(id responseObject) {
               [EBAlert hideLoading];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               if ([currentDic[@"code"] integerValue] == 0) {
                   BOOL succeed = YES;
                   self.returnBlock(succeed);
               }else{
                   [EBAlert alertError:currentDic[@"desc"] length:2.0f];
                   //                self.textBlock();//调用block
               }
               [self.navigationController popViewControllerAnimated:YES];
           } failure:^(NSError *error) {
               [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
    }];

}

- (void)updateData:(id)sender{
    
    if (self.call_flags != nil) {
        [self hiddenFollow];
    }else{
        [self follow];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    NSArray *tmp = @[@{@"name":@"房源编号",@"value":_house_code},
                    @{@"name":@"跟进方式",@"value":@"电话跟进"}];
    if (self.call_flags != nil) {
        self.title = @"隐号通话跟进";
        tmp = @[@{@"name":@"房源编号",@"value":_house_code},
                @{@"name":@"跟进方式",@"value":@"房源跟进"}];
    }else{
        self.title = @"强制跟进";
    }
    for (NSDictionary *dic in tmp) {
        FinanceDetailModel *model = [[FinanceDetailModel alloc]initWithDict:dic];
        [_dataArray addObject:model];
    }
    [self.view addSubview:self.mainTableView];
    //    [_mainTableView addSubview:self.add_button];
    [_mainTableView registerClass:[HouseNewForceFollowupTableViewCell class] forCellReuseIdentifier:@"cell"];

}

-(void)phoneNumberClick:(NSString *)str{
    NSLog(@"str = %@",str);
    NSArray *array = [str componentsSeparatedByString:@" "]; //从字符A中分隔成2个元素的数组
    NSLog(@"array:%@",array); //结果是adfsfsfs和dfsdf
    if (array.count > 0) {
        NSMutableString * phone=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",array.firstObject];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HouseNewForceFollowupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    FinanceDetailModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        //跳转到房源
        NSLog(@"跳转");
        EBHouse *house = [[EBHouse alloc] init];
        house.id = _house_id;
        house.contractCode = _house_code;
        [[EBController sharedInstance] showHouseDetail:house];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FinanceDetailModel *model = _dataArray[indexPath.row];
    return [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[HouseNewForceFollowupTableViewCell class] contentViewWidth:kScreenW];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_followUptype == ZHForceFollowUpTypeYES) {
        return 0;
    }else{
        return 10;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (_followUptype == ZHForceFollowUpTypeYES) {
        return nil;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 10)];
        view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
        line1.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        [view addSubview:line1];
        UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 9, kScreenW, 1)];
        line2.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        [view addSubview:line2];
        return view;
    }
   

}



@end
