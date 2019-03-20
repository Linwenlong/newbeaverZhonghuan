//
//  WorkTradeCenterViewController.m
//  beaver
//
//  Created by mac on 18/1/18.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkTradeCenterViewController.h"

@interface WorkTradeCenterViewController ()

@property (nonatomic, strong)UIScrollView *mainScrollView;
@property (nonatomic, strong)UIButton *add_button;//新增
@property (nonatomic, strong)ValuePickerView *pickerView;
@property (nonatomic, strong)NSArray<UIView * > * textsArr;

@property (weak, nonatomic) IBOutlet UITextField *workTitle;//标题
@property (weak, nonatomic) IBOutlet UIButton *selectedType;//工作类型

//本月目标
@property (weak, nonatomic) IBOutlet UITextField *day;//今日签单
@property (weak, nonatomic) IBOutlet UITextField *month;//月签单

//其他
@property (weak, nonatomic) IBOutlet UITextView *failureDept;//签单未成功门店
@property (weak, nonatomic) IBOutlet UILabel *failureDeptTip;

@property (weak, nonatomic) IBOutlet UITextView *reason;//原因
@property (weak, nonatomic) IBOutlet UILabel *reasonTip;

@property (weak, nonatomic) IBOutlet UITextView *helpDept;//协助门店谈单
@property (weak, nonatomic) IBOutlet UILabel *helpDeptTip;

@property (weak, nonatomic) IBOutlet UITextView *content;//内容
@property (weak, nonatomic) IBOutlet UILabel *contentTip;

@property (weak, nonatomic) IBOutlet UITextView *tmpQuesion;//接待临时性问题
@property (weak, nonatomic) IBOutlet UILabel *tmpQuesionTip;

@property (weak, nonatomic) IBOutlet UITextView *perception;//心得体会
@property (weak, nonatomic) IBOutlet UILabel *perceptionTip;

@end

@implementation WorkTradeCenterViewController

- (void)resetUI{
    CGFloat radius = 5.0f;
    
    _failureDept.layer.cornerRadius = radius;
    _failureDept.clipsToBounds = YES;
    
    _reason.layer.cornerRadius = radius;
    _reason.clipsToBounds = YES;
    
    _helpDept.layer.cornerRadius = radius;
    _helpDept.clipsToBounds = YES;
    
    _content.layer.cornerRadius = radius;
    _content.clipsToBounds = YES;
    
    _tmpQuesion.layer.cornerRadius = radius;
    _tmpQuesion.clipsToBounds = YES;
    
    _perception.layer.cornerRadius = radius;
    _perception.clipsToBounds = YES;
    
    self.textsArr =@[_workTitle,_selectedType];
    
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
        _mainScrollView.contentSize = CGSizeMake(0, 1450);
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        UIView *backView = [[NSBundle mainBundle]loadNibNamed:@"TradeCenterView" owner:self options:nil].firstObject;
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
    [self resetUI];//
}

#pragma mark -- Method

#pragma mark -- 提交

- (void)addButton:(UIButton*)btn{
    NSLog(@"提交");
    UIView *view = [self verifyTextOfView:self.textsArr];
    if (view != nil) {
        [EBAlert alertError:@"请输入必填信息" length:2.0f];
        CGRect textframe = view.frame;
        [self.mainScrollView scrollRectToVisible:textframe animated:YES];
        return;
    }
    
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    //必填
    [parm setObject:@"add" forKey:@"action"];//操作
    [parm setObject:_workTitle.text forKey:@"title"];//标题
    [parm setObject:_selectedType.titleLabel.text forKey:@"type"];//类型
    [parm setObject:@"trading-sign" forKey:@"tmp_type"];
    
    //非必填
    [parm setObject:_day.text forKey:@"signature_today"];//今日
    [parm setObject:_month.text forKey:@"signature_month"];//月
    [parm setObject:_failureDept.text forKey:@"sign_failed_store"];//签单未成功门店
    [parm setObject:_reason.text forKey:@"sign_failed_cause"];//原因
    [parm setObject:_helpDept.text forKey:@"assistance_note"];//协助门店谈单
    [parm setObject:_content.text forKey:@"assistance_content"];//协助门店谈单内容
    [parm setObject:_tmpQuesion.text forKey:@"temporary_issues"];//接待临时性问题
    [parm setObject:_perception.text forKey:@"getting"];//工作心得体会
    
    [self post:parm];
}

#pragma mark -- 类型

- (IBAction)selectedWorkType:(id)sender {
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
