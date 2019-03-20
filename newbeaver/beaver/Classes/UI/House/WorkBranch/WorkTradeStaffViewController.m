//
//  WorkTradeStaffViewController.m
//  beaver
//
//  Created by mac on 18/1/18.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkTradeStaffViewController.h"

@interface WorkTradeStaffViewController ()

@property (nonatomic, strong)UIScrollView *mainScrollView;
@property (nonatomic, strong)UIButton *add_button;//新增
@property (nonatomic, strong)ValuePickerView *pickerView;
@property (nonatomic, strong)NSArray<UIView * > * textsArr;

@property (weak, nonatomic) IBOutlet UITextField *workTitle;//标题
@property (weak, nonatomic) IBOutlet UIButton *selectedType;//工作类型


@property (weak, nonatomic) IBOutlet UITextField *goal_transfer;//本月过户目标
@property (weak, nonatomic) IBOutlet UITextField *truly_transfer;//目前完成情况
@property (weak, nonatomic) IBOutlet UITextField *goal_commission;//本月结佣目标
@property (weak, nonatomic) IBOutlet UITextField *truly_commission;//目前完成情况

@property (weak, nonatomic) IBOutlet UITextField *order_day;//日接单
@property (weak, nonatomic) IBOutlet UITextField *order_month;//接单月累计
@property (weak, nonatomic) IBOutlet UITextField *order_balance;//接单结余

@property (weak, nonatomic) IBOutlet UITextField *transfer_day;//日过户
@property (weak, nonatomic) IBOutlet UITextField *transfer_breach;//过户违约
@property (weak, nonatomic) IBOutlet UITextField *transfer_return;//过户退单
@property (weak, nonatomic) IBOutlet UITextField *transfer_count_month;//过户月累计

@property (weak, nonatomic) IBOutlet UITextField *loan_month;//贷款月累
@property (weak, nonatomic) IBOutlet UITextField *loan_batch;//贷款批贷
@property (weak, nonatomic) IBOutlet UITextField *loan_balance;//贷款结余
@property (weak, nonatomic) IBOutlet UITextField *loan_day;//日贷款

@property (weak, nonatomic) IBOutlet UITextField *lending_day;//日放款
@property (weak, nonatomic) IBOutlet UITextField *lending_month;//放款月累
@property (weak, nonatomic) IBOutlet UITextField *lending_balance;//放款结余

@property (weak, nonatomic) IBOutlet UITextField *commission_day;//日结佣
@property (weak, nonatomic) IBOutlet UITextField *commission_month;//结佣月累
@property (weak, nonatomic) IBOutlet UITextField *commission_no;//未结佣
@property (weak, nonatomic) IBOutlet UITextField *commission_bad;//结佣差钱
@property (weak, nonatomic) IBOutlet UITextField *commission_poor;//结佣差优惠单


@property (weak, nonatomic) IBOutlet UITextView *work_check;//返工情况
@property (weak, nonatomic) IBOutlet UILabel *work_check_tip;

@property (weak, nonatomic) IBOutlet UITextView *work_method;//以上工作中的问题及改进办法
@property (weak, nonatomic) IBOutlet UILabel *work_method_tip;

@property (weak, nonatomic) IBOutlet UITextView *getting;//心得感悟
@property (weak, nonatomic) IBOutlet UILabel *getting_tip;

@property (weak, nonatomic) IBOutlet UITextView *plans;//明日计划
@property (weak, nonatomic) IBOutlet UILabel *plans_tip;

@end

@implementation WorkTradeStaffViewController



//数量统计
- (void)resetData{
       //标题
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
    _workTitle.text = [NSString stringWithFormat:@"%@工作总结【%@】",[EBPreferences sharedInstance].userName,currentDateStr];
    
    self.textsArr =@[_workTitle,_selectedType];
    
    CGFloat radius = 5.0f;
    _work_check.layer.cornerRadius = radius;
    _work_check.clipsToBounds = YES;
    _work_method.layer.cornerRadius = radius;
    _work_method.clipsToBounds = YES;
    _getting.layer.cornerRadius = radius;
    _getting.clipsToBounds = YES;
    _plans.layer.cornerRadius = radius;
    _plans.clipsToBounds = YES;
}


- (UIButton *)add_button{
    if (!_add_button) {
        _add_button = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 114, [UIScreen mainScreen].bounds.size.width, 50)];
        _add_button.backgroundColor = AppMainColor(1);
        [_add_button setTitle:@"提交" forState:UIControlStateNormal];
        [_add_button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _add_button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        [_add_button addTarget:self action:@selector(addButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _add_button;
}


- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
        _mainScrollView.contentSize = CGSizeMake(0, 1750);
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        UIView *backView = [[NSBundle mainBundle]loadNibNamed:@"TradeStaffView" owner:self options:nil].firstObject;
        backView.frame = CGRectMake(0, 0, kScreenW, backView.frame.size.height);
        [_mainScrollView addSubview:backView];
    }
    return _mainScrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"工作总结";
    
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.add_button];
    self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
    [self resetData];
}


#pragma mark -- Method

#pragma mark -- 提交
- (void)addButton:(UIButton*)btn{
    NSLog(@"提交");
    UIView *view = [self verifyTextOfView:self.textsArr];
    if (view != nil) {
        [EBAlert alertError:@"请输入必填信息" length:2.0f];
        CGRect textframe = view.frame;
//        textframe.origin.y -= 15;
        [self.mainScrollView scrollRectToVisible:textframe animated:YES];
        return;
    }

    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    //必填
    [parm setObject:@"add" forKey:@"action"];//操作
    [parm setObject:_workTitle.text forKey:@"title"];//标题
    [parm setObject:_selectedType.titleLabel.text forKey:@"type"];//类型
    [parm setObject:@"trading-staff" forKey:@"tmp_type"];
    
    //非必填
    [parm setObject:_goal_transfer.text forKey:@"goal_transfer"];
    [parm setObject:_truly_transfer.text forKey:@"truly_transfer"];
    [parm setObject:_goal_commission.text forKey:@"goal_commission"];
    [parm setObject:_truly_commission.text forKey:@"truly_commission"];
    
    [parm setObject:_order_day.text forKey:@"order_day"];
    [parm setObject:_order_month.text forKey:@"order_month"];
    [parm setObject:_order_balance.text forKey:@"order_balance"];
    
    [parm setObject:_transfer_day.text forKey:@"transfer_day"];
    [parm setObject:_transfer_breach.text forKey:@"transfer_breach"];
    [parm setObject:_transfer_return.text forKey:@"transfer_return"];
    [parm setObject:_transfer_count_month.text forKey:@"transfer_count_month"];
    
    [parm setObject:_loan_day.text forKey:@"loan_day"];
    [parm setObject:_loan_month.text forKey:@"loan_month"];
    [parm setObject:_loan_batch.text forKey:@"loan_batch"];
    [parm setObject:_loan_balance.text forKey:@"loan_balance"];
    
    [parm setObject:_lending_day.text forKey:@"lending_day"];
    [parm setObject:_lending_month.text forKey:@"lending_month"];
    [parm setObject:_lending_balance.text forKey:@"lending_balance"];
    
    [parm setObject:_commission_day.text forKey:@"commission_day"];
    [parm setObject:_commission_month.text forKey:@"commission_month"];
    [parm setObject:_commission_no.text forKey:@"commission_no"];
    [parm setObject:_commission_bad.text forKey:@"commission_bad"];
    [parm setObject:_commission_poor.text forKey:@"commission_poor"];
    //textview
    [parm setObject:_work_check.text forKey:@"work_check"];
    [parm setObject:_work_method.text forKey:@"work_method"];
    [parm setObject:_getting.text forKey:@"getting"];
    [parm setObject:_plans.text forKey:@"plans"];
    
    
    [self post:parm];
}

#pragma mark -- 类型

- (IBAction)selectedWorkType:(id)sender {
    NSLog(@"选择工作类型");
    NSLog(@"选择工作类型");
    self.pickerView.dataSource = @[@"日常总结",@"一周总结",@"一月总结",@"半年总结",@"一年总结"];
    self.pickerView.pickerTitle = @"请选择类型";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [weakSelf.selectedType setTitle:result forState:UIControlStateNormal];
    };
    [self.pickerView show];
}


@end
