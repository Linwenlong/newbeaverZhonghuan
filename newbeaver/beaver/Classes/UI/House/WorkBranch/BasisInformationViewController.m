//
//  BasisInformationViewController.m
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BasisInformationViewController.h"
#import "ChargeTableViewCell.h"
#import "TransferAndLoanTableViewCell.h"
#import "BasisInformationTableViewCell.h"
#import "CustomerTableViewCell.h"
#import "AchievementTableViewCell.h"
#import "MortgageTableViewCell.h"
#import "MortgageWeiJieZhangTableViewCell.h"
#import "MortgageYiJieZhangTableViewCell.h"

#import "ContractStatusTableViewCell.h"
#import "ChargeDetailViewController.h"
#import "MortgageConfrimTopView.h"
#import "MortgageAmendTopView.h"
#import "HWPopTool.h"
#import "MBProgressHUD.h"

@interface BasisInformationViewController ()<UITableViewDataSource,UITableViewDelegate,ContractStatusTableViewDelegate,BasisInformationDelegate>

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *sectionTitle; //可能没有贷款
@property (nonatomic, strong)NSMutableArray *charge; //财务收付
@property (nonatomic, strong)NSMutableArray *transfer; //过户状态
@property (nonatomic, strong)NSMutableArray *loan; //贷款状态
@property (nonatomic, strong)NSMutableArray *basisInformation; //基本信息
@property (nonatomic, strong)NSMutableArray *customer; //客户分成
@property (nonatomic, strong)NSMutableArray *status; //状态
@property (nonatomic, strong)NSMutableArray *commission; //业绩分成
@property (nonatomic, strong)NSMutableArray *mortgage; //按揭代办费

@property (nonatomic, strong)NSMutableArray *tmpMortgage; //按揭代办费

@property (nonatomic, strong)NSMutableDictionary *detail; //详情
@property (nonatomic, strong)NSMutableDictionary *dealStatus; //交易过户

@property (nonatomic, weak)UILabel * left;
@property (nonatomic, weak)UILabel * right;

@property (nonatomic, strong)ValuePickerView *pickerView;

@end

@implementation BasisInformationViewController


- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64 - 40)];
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
//        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}

- (void)initwithData{
//    _sectionTitle = [NSMutableArray arrayWithObjects:@"收费状态",@"过户状态",@"贷款状态",@"基础信息",@"客户信息",@"业绩分成信息",@"按揭代办费信息",@"状态信息", nil];
//    _sectionTitle = [NSMutableArray arrayWithObjects:@"收费状态",@"过户状态",@"贷款状态",@"基础信息",@"业绩分成信息",@"按揭代办费信息",@"状态信息", nil];
    
//    _sectionTitle = [NSMutableArray array];
    _charge = [NSMutableArray array];
    _transfer = [NSMutableArray array];
    _loan = [NSMutableArray array];
    _basisInformation = [NSMutableArray array];
    _customer = [NSMutableArray array];

    _commission = [NSMutableArray array];
    _mortgage = [NSMutableArray array];
    _tmpMortgage = [NSMutableArray array];
    
    _status = [NSMutableArray array];
    
    _detail = [NSMutableDictionary dictionary];
    _dealStatus = [NSMutableDictionary dictionary];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

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
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"deal_id":_deal_id
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSLog(@"currentDic=%@",currentDic);
           NSDictionary *tmpDic = currentDic[@"data"];
           NSLog(@"tmpArray=%@",tmpDic);
           
           
           
           
           if ([currentDic[@"code"] integerValue] == 0) {
               
               //清空数组
               [_mortgage removeAllObjects];
               
               _detail = tmpDic[@"detail"];
               _commission = tmpDic[@"commission"];
               _tmpMortgage = tmpDic[@"mortgage"];
               _dealStatus = tmpDic[@"dealStatus"];
               
               _sectionTitle = [NSMutableArray arrayWithObjects:@"基础信息",@"状态信息",@"业绩分成信息",@"按揭代办费信息",@"财务收付",@"过户状态",@"贷款状态", nil];
               
               if (!([_dealStatus.allKeys containsObject:@"jfFinanceSummary"]&&[_dealStatus.allKeys containsObject:@"yfFinanceSummary"])) {
                   [_sectionTitle removeObject:@"财务收付"];
               }
               if ([_dealStatus.allKeys containsObject:@"ghTradeProcess"]&&[_dealStatus[@"ghTradeProcess"] isKindOfClass:[NSDictionary class]]){
                   NSLog(@"");
               }else{
                   [_sectionTitle removeObject:@"过户状态"];
               }
               
               if ([_dealStatus.allKeys containsObject:@"dkTradeProcess"]&&[_dealStatus[@"dkTradeProcess"] isKindOfClass:[NSDictionary class]]){
                   NSLog(@"");
               }else{
                   [_sectionTitle removeObject:@"贷款状态"];
               }
               
               if (_commission.count == 0) {
                   [_sectionTitle removeObject:@"业绩分成信息"];
               }
               
               if (_tmpMortgage.count == 0) {
                    [_sectionTitle removeObject:@"按揭代办费信息"];
               }else{
                   [_mortgage addObject:_tmpMortgage.firstObject];//添加第一个
               }
               
               //数据
               _left.attributedText = [NSString changeString:[NSString stringWithFormat:@"最低收佣金额(元): %@",_detail[@"min_agencyFee"]] frontLength:11 frontColor:LWL_DarkGrayrColor otherColor:LWL_RedColor];
               _right.attributedText = [NSString changeString:[NSString stringWithFormat:@"实收业绩(元): %@",_detail[@"paid_money"]] frontLength:9 frontColor:LWL_DarkGrayrColor otherColor:LWL_RedColor];
               
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

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initwithData];
    
    self.pickerView = [[ValuePickerView alloc]initShowClear:NO];    //显示行数
    
    [self.view addSubview:self.mainTableView];
    
    
    
    [self refreshHeader];
    
    [self.mainTableView registerClass:[ChargeTableViewCell class] forCellReuseIdentifier:@"chargeCell"];
    [self.mainTableView registerClass:[TransferAndLoanTableViewCell class] forCellReuseIdentifier:@"tranAndLoanCell"];
    [self.mainTableView registerClass:[BasisInformationTableViewCell class] forCellReuseIdentifier:@"basisInformationCell"];
    [self.mainTableView registerClass:[CustomerTableViewCell class] forCellReuseIdentifier:@"customerCell"];
    [self.mainTableView registerClass:[AchievementTableViewCell class] forCellReuseIdentifier:@"achievementCell"];
    [self.mainTableView registerClass:[MortgageTableViewCell class] forCellReuseIdentifier:@"mortgageCell"];
    
    [self.mainTableView registerClass:[MortgageWeiJieZhangTableViewCell class] forCellReuseIdentifier:@"mortgageWeiCell"];
    
    [self.mainTableView registerClass:[MortgageYiJieZhangTableViewCell class] forCellReuseIdentifier:@"mortgageYiCell"];
    
    [self.mainTableView registerClass:[ContractStatusTableViewCell class] forCellReuseIdentifier:@"statusCell"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _sectionTitle.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionUrl = _sectionTitle[section];
    if ([sectionUrl isEqualToString:@"业绩分成信息"]) {
        return _commission.count;
    }else if([sectionUrl isEqualToString:@"按揭代办费信息"]){
        return _mortgage.count;
    }else{
        return 1;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

//代办费取消
- (void)cancleDaiBanFei:(NSDictionary *)dic{
    MortgageConfrimTopView *createView = [[MortgageConfrimTopView alloc]initWithFrame:CGRectMake(0, 0, 270, 140) title:@"你确认要取消该笔按揭代办费吗?"];
    createView.btnClick = ^(UIButton *btn ) {
        
        if (btn.tag == 1) {
            [self closePop];
            return ;
        }
        
        //新增分组
        NSString *url = @"/zhpay/cancelMortgage";
        if (_deal_id == nil || dic[@"document_id"] == nil) {
            [EBAlert alertError:@"合同id为空"];
            return;
        }
        NSDictionary *parm = @{
                               @"token" : [EBPreferences sharedInstance].token,
                               @"deal_id" : _deal_id,
                               @"document_id" : dic[@"document_id"]
                               };
        NSLog(@"parm = %@",parm);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        __weak typeof(self) wealSelf = self;
        [HttpTool post:url parameters:parm success:^(id responseObject) {
            NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"dict = %@",dict);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self closePop];
            if ([dict[@"error_code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"确认成功"];
                [wealSelf refreshHeader];
            }else{
                [EBAlert alertError:@"确认失败"];
            }
            
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [EBAlert alertSuccess:@"请求失败"];
            [self closePop];
        }];
    };
    MyViewController *vc = [[HWPopTool sharedInstance]showWithPresentView:createView animated:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop)];
    vc.styleView.userInteractionEnabled = YES;
    [vc.styleView addGestureRecognizer:tap];
}

//代办费确定
- (void)confrimDaiBanFei:(NSDictionary *)dic{
    MortgageConfrimTopView *createView = [[MortgageConfrimTopView alloc]initWithFrame:CGRectMake(0, 0, 270, 140) title:@"你确认要确定该笔按揭代办费吗?"];
  
     createView.btnClick = ^(UIButton *btn ) {
     
        if (btn.tag == 1) {
             [self closePop];
             return ;
        }
     
     //新增分组
         NSString *url = @"/zhpay/confirmMortgage";
         if (_deal_id == nil || dic[@"document_id"] == nil) {
             [EBAlert alertError:@"合同id为空"];
             return;
         }
         NSDictionary *parm = @{
                            @"token" : [EBPreferences sharedInstance].token,
                            @"deal_id" : _deal_id,
                            @"document_id" : dic[@"document_id"]
                            };
         NSLog(@"parm = %@",parm);
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         __weak typeof(self) wealSelf = self;
         [HttpTool post:url parameters:parm success:^(id responseObject) {
             NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
             NSLog(@"dict = %@",dict);
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [self closePop];
             if ([dict[@"error_code"] integerValue] == 0) {
                 [EBAlert alertSuccess:@"确认成功"];
                 [wealSelf refreshHeader];
             }else{
                 [EBAlert alertError:@"确认失败"];
             }
     
         } failure:^(NSError *error) {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             [EBAlert alertSuccess:@"请求失败"];
             [self closePop];
         }];
     };
     
    MyViewController *vc = [[HWPopTool sharedInstance]showWithPresentView:createView animated:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop)];
    vc.styleView.userInteractionEnabled = YES;
    [vc.styleView addGestureRecognizer:tap];
}

//修改按揭代办费
- (void)amendDic:(NSDictionary *)dic{
    NSArray *mort = dic[@"mort"];
    if ([mort isKindOfClass:[NSArray class]]) {
        NSDictionary *first = mort.firstObject;
        NSDictionary *second = mort.lastObject;
        MortgageAmendTopView *createView = [[MortgageAmendTopView alloc]initWithFrame:CGRectMake(0, 0, 270, 249) title:@"修改按揭代办费" totle:dic[@"the_sum_agency"] first:first[@"price_num"] second:second[@"price_num"]];
        
        createView.btnClick = ^(UITextField *textFiled1, UITextField *textFiled2, UIButton *btn) {
            if (textFiled1.text.length == 0 || textFiled2.text.length == 0) {
                [EBAlert alertError:@"请输入费用"];
                return ;
            }
            
            if (btn.tag == 1) {
                [self closePop];
                return ;
            }
            
            //修改费用
            NSString *url = @"/zhpay/modifyMortgage";
            if (_deal_id == nil || dic[@"document_id"] == nil) {
                [EBAlert alertError:@"合同id为空"];
                return;
            }
            NSDictionary *parm = @{
                                   @"token" : [EBPreferences sharedInstance].token,
                                   @"deal_id" : _deal_id,
                                   @"document_id" : dic[@"document_id"],
                                   @"dept_agency" : textFiled1.text,
                                   @"headquarters_agency" : textFiled2.text,
                                   @"the_sum_agency" : dic[@"the_sum_agency"]
                                   };
            NSLog(@"parm = %@",parm);
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            __weak typeof(self) wealSelf = self;
            [HttpTool post:url parameters:parm success:^(id responseObject) {
                NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"dict = %@",dict);
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self closePop];
                if ([dict[@"error_code"] integerValue] == 0) {
                    [EBAlert alertSuccess:@"确认成功"];
                    [wealSelf refreshHeader];
                }else{
                    [EBAlert alertError:@"确认失败"];
                }
                
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [EBAlert alertSuccess:@"请求失败"];
                [self closePop];
            }];
            
        };
        
    
        
        MyViewController *vc = [[HWPopTool sharedInstance]showWithPresentView:createView animated:YES];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop)];
        vc.styleView.userInteractionEnabled = YES;
        [vc.styleView addGestureRecognizer:tap];
    }else{
        [EBAlert alertError:@"修改失败"];
    }
    
   
}

- (void)closePop{
    [[HWPopTool sharedInstance]closeWithBlcok:^{
        
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *sectionUrl = _sectionTitle[indexPath.section];
    UITableViewCell *cell = nil;
    if ([sectionUrl isEqualToString:@"财务收付"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"chargeCell" forIndexPath:indexPath];
        ChargeTableViewCell *tmpcell = (ChargeTableViewCell *)cell;
        [tmpcell setDic:_dealStatus];
    }else if ([sectionUrl isEqualToString:@"过户状态"]||        [sectionUrl isEqualToString:@"贷款状态"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"tranAndLoanCell" forIndexPath:indexPath];
        TransferAndLoanTableViewCell *tmpcell = (TransferAndLoanTableViewCell *)cell;
        if ([sectionUrl isEqualToString:@"过户状态"]) {
            [tmpcell setStatusTransfer:_dealStatus isLoan:NO];
        }else{
            [tmpcell setStatusTransfer:_dealStatus isLoan:YES];
        }
    }else if([sectionUrl isEqualToString:@"基础信息"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"basisInformationCell" forIndexPath:indexPath];
        BasisInformationTableViewCell *tmpcell = (BasisInformationTableViewCell *)cell;
        tmpcell.basisDelegate = self;
        [tmpcell setDic:_detail];
    }else if ([sectionUrl isEqualToString:@"客户信息"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"customerCell" forIndexPath:indexPath];
        CustomerTableViewCell *tmpcell = (CustomerTableViewCell *)cell;
        [tmpcell setDic:_detail];
    }else if([sectionUrl isEqualToString:@"业绩分成信息"]){
        cell = [tableView dequeueReusableCellWithIdentifier:@"achievementCell" forIndexPath:indexPath];
        AchievementTableViewCell *tmpcell = (AchievementTableViewCell *)cell;
        tmpcell.paid_money = [_detail[@"paid_money"] floatValue];
        NSDictionary *dic = _commission[indexPath.row];
        [tmpcell setDic:dic];
    }else if([sectionUrl isEqualToString:@"按揭代办费信息"]){
        NSDictionary *dic = _mortgage[indexPath.row];
        if ([dic[@"confirm_date"] intValue] > 0) {   //时间戳大于0 已结账和未结账
             if ([dic[@"settle_status"] intValue] == 2){//已结账
                cell = [tableView dequeueReusableCellWithIdentifier:@"mortgageYiCell" forIndexPath:indexPath];
                MortgageYiJieZhangTableViewCell *tmpcell = (MortgageYiJieZhangTableViewCell *)cell;
                 
                 [tmpcell setDic:dic];
                 
             }else{//未结账
                 cell = [tableView dequeueReusableCellWithIdentifier:@"mortgageWeiCell" forIndexPath:indexPath];
                 MortgageWeiJieZhangTableViewCell *tmpcell = (MortgageWeiJieZhangTableViewCell *)cell;
                 tmpcell.confirm = ^(UIButton *btn) {
                     NSLog(@"待办办费取消");
                     [self cancleDaiBanFei:dic];
                    
                 };
                 [tmpcell setDic:dic];
             }
        }else{//未确认
            cell = [tableView dequeueReusableCellWithIdentifier:@"mortgageCell" forIndexPath:indexPath];
            MortgageTableViewCell *tmpcell = (MortgageTableViewCell *)cell;
            tmpcell.confrim = ^(NSInteger tag) {
                if (tag == 1) {//修改
                    [self amendDic:dic];
                }else if (tag == 2){//代办费确认
                     [self confrimDaiBanFei:dic];
                }
            };
            [tmpcell setDic:dic];
        }
       
    }else if ([sectionUrl isEqualToString:@"状态信息"]){
         cell = [tableView dequeueReusableCellWithIdentifier:@"statusCell" forIndexPath:indexPath];
         ContractStatusTableViewCell*tmpcell = (ContractStatusTableViewCell *)cell;
        tmpcell.ContractDelegate = self;
        [tmpcell setDic:_detail];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *sectionUrl = _sectionTitle[indexPath.section];
    if ([sectionUrl isEqualToString:@"财务收付"]) {
        return 90;
    }else if ([sectionUrl isEqualToString:@"过户状态"]||[sectionUrl isEqualToString:@"贷款状态"]){
        return 70;
    }else if([sectionUrl isEqualToString:@"基础信息"]){
        return 300;
    }else if ([sectionUrl isEqualToString:@"客户信息"]){
        return 200;
    }else if([sectionUrl isEqualToString:@"业绩分成信息"]){
        return 65;
    }else if ([sectionUrl isEqualToString:@"按揭代办费信息"]){
        NSDictionary *dic = _mortgage[indexPath.row];
        if ([dic[@"confirm_date"] intValue] > 0) {   //时间戳大于0 已结账和未结账
            if ([dic[@"settle_status"] intValue] == 2){//已结账
                return 235;
            }else{//未结账
               return 250;
            }
        }else{//未确认
            return 175;
        }
        
        return 235; //未确定 175。其他 未结账250 已结账235
    }else if ([sectionUrl isEqualToString:@"状态信息"]){
        return 155;
    }else{
        return 0;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ([_sectionTitle[section] isEqualToString:@"状态信息"]) {
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
        line.backgroundColor = [UIColor whiteColor];
        return line;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 52)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 8)];
    header.backgroundColor=[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
     [view addSubview:header];
    //加线
    UIView *headerLine1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
    headerLine1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [header addSubview:headerLine1];
    UIView *headerLine2 = [[UIView alloc]initWithFrame:CGRectMake(0, 7, kScreenW, 1)];
    headerLine2.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [header addSubview:headerLine2];
   
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 20, kScreenW/2, 20)];
    lable.text = _sectionTitle[section];
    lable.textAlignment = NSTextAlignmentLeft;
    lable.textColor = UIColorFromRGB(0x404040);
    lable.font = [UIFont boldSystemFontOfSize:14.0f];
    [view addSubview:lable];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 51, kScreenW, 1)];
    line.backgroundColor = UIColorFromRGB(0xe8e8e8);
    [view addSubview:line];
    if ([_sectionTitle[section] isEqualToString:@"业绩分成信息"]) {
        view.height = 97;
        UILabel *left = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(line.frame)+15, (kScreenW-30)/2.0f, 15)];
        _left = left;
        left.font = [UIFont systemFontOfSize:13.0f];
        left.textAlignment = NSTextAlignmentLeft;
        [view addSubview:left];
        
        UILabel *right = [[UILabel alloc]initWithFrame:CGRectMake(kScreenW/2.0f, CGRectGetMaxY(line.frame)+15, (kScreenW-30)/2.0f, 15)];
        _right = right;
        right.font = [UIFont systemFontOfSize:13.0f];
        right.textAlignment = NSTextAlignmentRight;
        [view addSubview:right];
        if ([_detail.allKeys containsObject:@"min_agencyFee"]&&[_detail.allKeys containsObject:@"paid_money"]) {
            _left.attributedText = [NSString changeString:[NSString stringWithFormat:@"最低收佣金额(元): %@",_detail[@"min_agencyFee"]] frontLength:11 frontColor:LWL_DarkGrayrColor otherColor:LWL_RedColor];
            _right.attributedText = [NSString changeString:[NSString stringWithFormat:@"实收业绩(元): %@",_detail[@"paid_money"]] frontLength:9 frontColor:LWL_DarkGrayrColor otherColor:LWL_RedColor];
        }else{
            _left.text = @"最低收佣金额(元): ";
            _right.text = @"实收业绩(元): ";
        }
        //数据
        UIView *lin2 = [[UIView alloc]initWithFrame:CGRectMake(0, 96, kScreenW, 1)];
        lin2.backgroundColor = UIColorFromRGB(0xe8e8e8);
        [view addSubview:lin2];
    }else if([_sectionTitle[section] isEqualToString:@"按揭代办费信息"]){
        
        
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenW-15-7.5, 26, 14, 7.5)];
        UIImage *image = [[UIImage imageNamed:@"icon_arrow_down"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        icon.image = image;
        icon.tintColor = RGBA(254,58,3,1);
        [view addSubview:icon];
        
        UIButton *confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(kScreenW/2, 20, kScreenW/2- 30 - 7.5, 20)];
        NSDictionary *dic = _mortgage.firstObject;
        NSString *time = [NSString timeWithTimeIntervalString:dic[@"statistics_time"]];
        [confirmBtn setTitle:[NSString stringWithFormat:@"%@元 %@",dic[@"the_sum_agency"],time] forState:UIControlStateNormal];
        [confirmBtn setTitleColor:RGBA(254,58,3,1) forState:UIControlStateNormal];
        confirmBtn.tintColor = RGBA(254,58,3,1);
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        confirmBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [confirmBtn addTarget:self action:@selector(selectedOtherTime:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:confirmBtn];
        
    }
    return view;
}

- (void)selectedOtherTime:(UIButton *)btn{
    NSMutableArray *dataSource = [NSMutableArray array];
    for (NSDictionary *dic in _tmpMortgage) {
        NSString *time = [NSString timeWithTimeIntervalString:dic[@"statistics_time"]];
        [dataSource addObject:[NSString stringWithFormat:@"%@元 %@",dic[@"the_sum_agency"],time]];
    }
    self.pickerView.dataSource = dataSource;
    self.pickerView.pickerTitle = @"请选择日期";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [btn setTitle:result forState:UIControlStateNormal];
        
        NSInteger row = [[str componentsSeparatedByString:@"/"].lastObject integerValue] - 1;
        NSLog(@"row = %ld", row);
        if (row >= 0) {
            NSDictionary *dic = weakSelf.tmpMortgage[row];
            [weakSelf.mortgage removeAllObjects];
            [weakSelf.mortgage addObject:dic];
        }
        [weakSelf.mainTableView reloadData];
    };
    [self.pickerView show];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([_sectionTitle[section] isEqualToString:@"业绩分成信息"]){
        return 97;
    }if ([_sectionTitle[section] isEqualToString:@"状态信息"]){
        return 1;
    }else{
        return 52;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *sectionUrl = _sectionTitle[indexPath.section];
    if ([sectionUrl isEqualToString:@"财务收付"]) {
        [_slideMenu scrollToIndex:1];
//        //获取图片
//        ChargeDetailViewController *updata = [[ChargeDetailViewController alloc]init];
//        updata.hidesBottomBarWhenPushed = YES;
//        updata.deal_code = self.deal_code;
//        [self.parentViewController.navigationController pushViewController:updata animated:YES];
       
    }else if ([sectionUrl isEqualToString:@"过户状态"]||[sectionUrl isEqualToString:@"贷款状态"]){
        NSLog(@"slideMenu=%@",self.slideMenu);
         NSLog(@"superView=%@",self.view.superview.superview);
        [_slideMenu scrollToIndex:3];
    }
}


#pragma mark -- BasisInformationDelegate
-(void)call:(NSString *)iphone{
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt:%@",iphone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

#pragma mark -- ContractStatusTableViewDelegate
- (void)btnClickContractStatus:(UIButton *)btn{
    NSString *title = @"";
    if (btn.tag == 1) {
        title = @"取消交接";
    }else{
        title = @"确定交接";
    }
    [EBAlert confirmWithTitle:title message:[NSString stringWithFormat:@"是否%@?",title]
                          yes:title action:^{
        if (btn.tag == 1) {
            [self cancle];
        }else{
            [self comfire];
        }
     }];
}

//取消交接
- (void)cancle{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/cancelTransfer?token=%@&deal_id=%@&contract_code=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_deal_id,_deal_code]);
    if (_deal_id == nil) {
        [EBAlert alertError:@"合同id为空" length:2.0f];
        return;
    }
    NSString *urlStr = @"zhpay/cancelTransfer";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"contract_code":_deal_code,
       @"deal_id":_deal_id
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           if ([currentDic[@"code"]integerValue] == 0) {
               NSLog(@"取消交接成功");
               [self refreshHeader];//刷新数据
           }else{
               [EBAlert alertError:currentDic[@"desc"] length:2.0f];
           }
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
       }];

}

//确认交接
- (void)comfire{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/zhpay/contractTransfer?token=%@&deal_id=%@&contract_code=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,_deal_id,_deal_code]);
    if (_deal_id == nil) {
        [EBAlert alertError:@"合同id为空" length:2.0f];
        return;
    }
    NSString *urlStr = @"zhpay/contractTransfer";//需要替换下
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"contract_code":_deal_code,
       @"deal_id":_deal_id
       } success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           
           if ([currentDic[@"code"]integerValue] == 0) {
               NSLog(@"确定交接成功");
               [self refreshHeader];//刷新数据
           }else{
               [EBAlert alertError:currentDic[@"desc"] length:2.0f];
           }
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
       }];
}

@end
