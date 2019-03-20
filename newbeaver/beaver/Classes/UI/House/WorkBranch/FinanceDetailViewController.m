//
//  FinanceDetailViewController.m
//  beaver
//
//  Created by mac on 17/11/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "FinanceDetailViewController.h"
#import "FinanceDetailTableViewCell.h"
#import "FinanceDetailModel.h"
#import "Httptool.h"
#import "ContractViewController.h"

@interface FinanceDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, assign)CGFloat btnHeight;

//按钮
@property (nonatomic, strong)UIButton *add_button;//确定
@property (nonatomic, strong)UIActionSheet *sheet;

@property (nonatomic, copy)NSString *check_status;

@property (nonatomic, strong)NSDictionary *dic;

@end

@implementation FinanceDetailViewController

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        _mainTableView.delegate = self;
        _mainTableView.estimatedRowHeight = 80;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.showsHorizontalScrollIndicator = NO;
        _mainTableView.showsVerticalScrollIndicator = NO;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _mainTableView;
}

- (UIButton *)add_button{
    if (!_add_button) {
        _add_button = [[UIButton alloc]initWithFrame:CGRectMake(10,_btnHeight/3.0f+70,[UIScreen mainScreen].bounds.size.width-20, 40)];
        _add_button.backgroundColor = AppMainColor(1);
        [_add_button setTitle:@"确认" forState:UIControlStateNormal];
        [_add_button setTitleColor:UIColorFromRGB(0xfefeff)  forState:UIControlStateNormal];
        _add_button.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _add_button.clipsToBounds = YES;
        _add_button.layer.cornerRadius = 5.0f;
        //只有在待确认的时候才显示按钮，其他的时候隐藏 得判断下
        if ([_check_status isEqualToString:@"已确认"]) {
            _add_button.hidden = YES;
        }else{
            _add_button.hidden = NO;//待确认yes
        }
        [_add_button addTarget:self action:@selector(addTargetForButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _add_button;
}

- (void)updateData{

    //更新数据
    //关注小区
   NSString *user_id = [[EBPreferences sharedInstance].userId componentsSeparatedByString:@"_"].lastObject;
    NSLog(@"house_id=%@",self.document_id);
    NSString *urlStr = @"Zhpay/accAgencyCheck";//公司收入分账
    
    if (_finaceType == ZHFinanceTypeStoreCommission) {//门店佣金分账
        urlStr = @"Zhpay/accDivisionCheck";
    }else if (_finaceType == ZHFinanceTypeReimbursementAccountManagement){//报销划账管理
        urlStr = @"Zhpay/tranManagerCheck";
    }
    
    NSDictionary *parm = @{
                           @"document_id":self.document_id,
                           @"check_user":user_id,
                           @"token":[EBPreferences sharedInstance].token
                           };
    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:urlStr parameters:parm
           success:^(id responseObject) {
               [EBAlert hideLoading];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               if ([currentDic[@"code"] integerValue] == 0) {
                   //成功后隐藏 确认按钮
                   self.returnBlock();
                   [self.navigationController popViewControllerAnimated:YES];
               }else{
                   [EBAlert alertError:currentDic[@"desc"] length:2.0f];
               }
               
           } failure:^(NSError *error) {
               [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
           }];
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"butonindex = %ld",buttonIndex);
    if (buttonIndex == 0) {
        [self updateData];//提交确认
    }
}

//实现按钮修改颜色
- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    NSLog(@"actionSheet=%@",actionSheet);
    for (UIView *subViwe in actionSheet.subviews) {
        if ([subViwe isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subViwe;
            [button setTitleColor:UIColorFromRGB(0x404040) forState:UIControlStateNormal];
        }
    }
}

- (void)addTargetForButton:(UIButton *)btn{
    _sheet = [[UIActionSheet alloc]initWithTitle:@"您确定要同意该笔金额的分配么?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles: nil];
    
    [_sheet showInView:_mainTableView];
}

- (void)requestData{
   
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Zhpay/accAgencyInfo?token=%@&document_id=%@",[EBPreferences sharedInstance].token,_document_id]);
    
    NSString *urlStr = @"Zhpay/accAgencyInfo";//公司收入分账
    
    if (_finaceType == ZHFinanceTypeStoreCommission) {//门店佣金分账
        urlStr = @"Zhpay/accDivisionInfo";
    }else if (_finaceType == ZHFinanceTypeReimbursementAccountManagement){//报销划账管理
        urlStr = @"Zhpay/tranManagerInfo";
    }
    
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"document_id":_document_id,
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
           if (_dataArray.count == 0) {
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

- (void)analysisData:(NSDictionary *)dic{
    NSArray *tmpArray = dic[@"data"][@"list"][@"data"];
    NSArray *tmp = nil;
    if (tmpArray.count > 0) {
         NSDictionary *tmpDic = tmpArray.firstObject;
        _dic = tmpDic;
        _check_status = tmpDic[@"check_status"];
        
        
        if (_finaceType == ZHFinanceTypeCompanyIncomeLedger||_finaceType == ZHFinanceTypeStoreCommission) {
            NSString *check_str = @"";
            if ([tmpDic[@"check_dept"] isEqualToString:@""]) {
                check_str = @"暂无";
            }else{
                check_str = [NSString stringWithFormat:@"%@-%@",tmpDic[@"check_dept"],tmpDic[@"check_username"]];
            }
            tmp =@[@{@"name":@"合同编号",@"value":tmpDic[@"ht_code"]},
                        @{@"name":@"申请日期",@"value":[self timeWithTimeIntervalString:tmpDic[@"commission_date"]]},
                        @{@"name":@"转账说明",@"value":tmpDic[@"remark"]},
                        @{@"name":@"金额(元)",@"value":[NSString stringWithFormat:@"¥%@",tmpDic[@"price"]]},
                        @{@"name":@"收款部门",@"value":tmpDic[@"store_name"]},
                        @{@"name":@"审核人",@"value":[NSString stringWithFormat:@"%@-%@",tmpDic[@"verify_dept"],tmpDic[@"verify_username"]]},
                        @{@"name":@"确认人",@"value":check_str}
                    ];

        }else if (_finaceType == ZHFinanceTypeReimbursementAccountManagement){//报销划账详情
            NSString *check_str = @"";
            if ([tmpDic[@"check_dept_name"] isEqualToString:@""]) {
                check_str = @"暂无";
            }else{
                check_str = [NSString stringWithFormat:@"%@-%@",tmpDic[@"check_dept_name"],tmpDic[@"check_username"]];
            }
            tmp =@[@{@"name":@"合同编号",@"value":tmpDic[@"ht_code"]},
                   @{@"name":@"申请日期",@"value":[self timeWithTimeIntervalString:tmpDic[@"create_time"]]},
                   @{@"name":@"金额(元)",@"value":[NSString stringWithFormat:@"¥%@",tmpDic[@"price"]]},
                   @{@"name":@"转账说明",@"value":tmpDic[@"remark"]},
                   @{@"name":@"支付部门",@"value":tmpDic[@"dept_name"]},
                   @{@"name":@"收款卡号",@"value":tmpDic[@"card_number"]},
                   @{@"name":@"收款人",@"value":tmpDic[@"card_name"]},
                   @{@"name":@"审核人",@"value":[NSString stringWithFormat:@"%@-%@",tmpDic[@"verify_dept_name"],tmpDic[@"verify_username"]]},
                   @{@"name":@"确认人",@"value":check_str}
                   ];
            
        }
        for (NSDictionary *dic in tmp) {
            FinanceDetailModel *model = [[FinanceDetailModel alloc]initWithDict:dic];
            [_dataArray addObject:model];
        }
        [self.mainTableView reloadData];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [EBPreferences sharedInstance].dept_name;
    _dataArray = [NSMutableArray array];
    [self requestData];

    [self.view addSubview:self.mainTableView];
//    [_mainTableView addSubview:self.add_button];
    [_mainTableView registerClass:[FinanceDetailTableViewCell class] forCellReuseIdentifier:@"cell"];
    
}




#pragma mark -- DataSource



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    FinanceDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    FinanceDetailModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FinanceDetailModel *model = _dataArray[indexPath.row];
  
    _btnHeight += [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[FinanceDetailTableViewCell class] contentViewWidth:kScreenW];
    if (indexPath.row == _dataArray.count-1) {
        [_mainTableView addSubview:self.add_button];
    }
    return [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[FinanceDetailTableViewCell class] contentViewWidth:kScreenW];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ContractViewController * cvc=[[ContractViewController alloc]init];
        cvc.hidesBottomBarWhenPushed = YES;
        cvc.ht_id = _dic[@"ht_id"];
        cvc.ht_code = _dic[@"ht_code"];
        [self.navigationController pushViewController:cvc animated:YES];
    }
}

@end
