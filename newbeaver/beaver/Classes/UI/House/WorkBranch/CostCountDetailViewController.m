//
//  CostCountDetailViewController.m
//  beaver
//
//  Created by mac on 17/10/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "CostCountDetailViewController.h"
#import "ToConfirmedView.h"
#import "EBAlert.h"
#import "HWPopTool.h"
#import "LWLAlertView.h"
#import "CostCountDetailTwoViewController.h"
#import "AppDelegate.h"

@interface CostCountDetailViewController ()<LWLAlertViewDelegate,ToConfirmedViewDelegate>

@property (nonatomic, strong) LWLAlertView *alertView;
//按钮
@property (nonatomic, strong)UIButton *add_button;//新增报备

@end

@implementation CostCountDetailViewController

- (UIButton *)add_button{
    if (!_add_button) {
        _add_button = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64-80-50, [UIScreen mainScreen].bounds.size.width, 50)];
        _add_button.backgroundColor = AppMainColor(1);
        [_add_button setTitle:@"确认" forState:UIControlStateNormal];
        [_add_button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _add_button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        //只有在待确认的时候才显示按钮，其他的时候隐藏 得判断下
        if ([self.dic[@"finance_status"]isEqualToString:@"已审核"]) {
            _add_button.hidden = NO;
        }else{
            _add_button.hidden = YES;//待确认yes
        }
        [_add_button addTarget:self action:@selector(addTargetForButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _add_button;
}


- (LWLAlertView *)alertView{
    if (!_alertView) {
        _alertView = [[LWLAlertView alloc]initWithFrame:CGRectMake(0, 0, 280, 170)];
        _alertView.backgroundColor = [UIColor blackColor];
        _alertView.clipsToBounds = YES;
        _alertView.layer.cornerRadius = 5.0f;
        _alertView.alertViewDelegate = self;
    }
    return _alertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    NSDictionary *fee = _dic[@"fee"];
    NSLog(@"fee = %@",_feedickeys);
    
//    ToConfirmedView *cofiremedView = [[ToConfirmedView alloc]initWithFrame:self.view.bounds titleArr:fee.allKeys numArr:fee.allValues titleColor:UIColorFromRGB(0x808080) numColor:UIColorFromRGB(0x404040) other:self.dic];
     ToConfirmedView *cofiremedView = [[ToConfirmedView alloc]initWithFrame:self.view.bounds titleArr:_feedickeys numArr:fee.allValues titleColor:UIColorFromRGB(0x808080) numColor:UIColorFromRGB(0x404040) other:self.dic];
     cofiremedView.confirmdDelegate = self;
    [self.view addSubview:cofiremedView];
   
    [self.view addSubview:self.add_button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addTargetForButton:(id)sender{
    
    [[HWPopTool sharedInstance] showWithPresentView:self.alertView animated:YES];
    
}

#pragma mark -- LWLAlertViewDelegate

- (void)alertViewSelectedBtn:(UIButton *)btn{
    switch (btn.tag) {
        case 1:
            [self close:1];
            break;
        case 2:
            [self close:2];
            break;
            
        default:
            break;
    }
    
}
//
- (void)close:(NSInteger)tag{
   
    if (tag == 2) {
        //跟新数据
        [[HWPopTool sharedInstance] closeWithBlcok:^{
            [self updataData];
        }];
        
    }else{
        [[HWPopTool sharedInstance] closeWithBlcok:^{
            
        }];
    }
}


#pragma mark -- ToConfirmedViewDelegate

- (void)viewDidClick:(UITapGestureRecognizer *)tap{
    
    CostCountDetailTwoViewController *costT = [[CostCountDetailTwoViewController alloc]init];
    
    for (UIView *view in tap.view.subviews) {
        if ([view isKindOfClass:[UILabel class]] && view.tag == 1000) {
            UILabel *lable = (UILabel *)view;
            costT.config_type = lable.text;
            costT.type = self.type;
            costT.month = self.month;
        }
    }
    costT.statistics = self.statistics;
    costT.month_half = self.month_half;
    costT.dic = self.dic;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:costT];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:nav animated:YES completion:nil];
}

- (void)updataData{
 
    NSLog(@"statistics=%@",_statistics);
    if (self.dic[@"document_id"]== nil) {
        [EBAlert alertError:@"数据加载错误,请重新加载" length:2.0f];
        return;
    }
    //更新数据
    //关注小区
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/finance/Approval?token=%@&changestatus=confirm&document_id=%@&statistics=%@",[EBPreferences sharedInstance].token,self.dic[@"document_id"],_statistics]);
    
    [EBAlert showLoading:@"确认中..."];
    [HttpTool post:@"finance/Approval" parameters:
     @{ @"token":[EBPreferences sharedInstance].token,
        @"document_id":self.dic[@"document_id"],
        @"changestatus":@"confirm",
        @"statistics":_statistics
        }success:^(id responseObject) {
            [EBAlert hideLoading];
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([currentDic[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"确认成功" length:2.0f];
                self.textBlock();//调用block
            }else{
                [EBAlert alertError:currentDic[@"desc"] length:2.0f];
                [self performSelector:@selector(updataDataforTextBlcok) withObject:nil afterDelay:2.0f];
//                self.textBlock();//调用block
            }
        } failure:^(NSError *error) {
            [EBAlert hideLoading];
            [EBAlert alertError:@"请检查网络" length:2.0f];
        }];
}

- (void)updataDataforTextBlcok{
    self.textBlock();//调用block
}

@end
