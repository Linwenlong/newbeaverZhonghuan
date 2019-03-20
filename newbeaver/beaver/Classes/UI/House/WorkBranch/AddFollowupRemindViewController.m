//
//  AddFollowupRemindViewController.m
//  beaver
//
//  Created by mac on 17/9/1.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "AddFollowupRemindViewController.h"

@interface AddFollowupRemindViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resoureType;
@property (weak, nonatomic) IBOutlet UIButton *resoureTypeBtn;
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet UIView *line3;
@property (weak, nonatomic) IBOutlet UILabel *resoureRank;
@property (weak, nonatomic) IBOutlet UIButton *resoureRankBtn;
@property (weak, nonatomic) IBOutlet UILabel *huifan;
@property (weak, nonatomic) IBOutlet UITextField *huifanTextField;
@property (weak, nonatomic) IBOutlet UIButton *comfire;

@property (nonatomic, strong)ValuePickerView *pickerView;


@end

@implementation AddFollowupRemindViewController

- (void)setUI{
    _resoureType.textColor = UIColorFromRGB(0x404040);
    _resoureRank.textColor = UIColorFromRGB(0x404040);
    _huifan.textColor = UIColorFromRGB(0x404040);
    
    [_resoureTypeBtn setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];
     [_resoureRankBtn setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];
    [_huifanTextField setValue:UIColorFromRGB(0x808080)  forKeyPath:@"_placeholderLabel.textColor"];
    _huifanTextField.textColor = UIColorFromRGB(0x808080);
    
    [_comfire setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _comfire.backgroundColor = UIColorFromRGB(0xff3800);
    _comfire.clipsToBounds = YES;
    _comfire.layer.cornerRadius = 5.0f;
    
    _line1.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
    _line2.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
     _line3.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.00];
    self.pickerView = [[ValuePickerView alloc]init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加跟进提醒";
    [self setUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

//选择资源类型
- (IBAction)selectResoureType:(id)sender {
    self.pickerView.dataSource = @[@"出售",@"出租",@"求购",@"求租"];
    self.pickerView.pickerTitle = @"请选择资源类型";
 
    __weak typeof(self) weakSelf = self;
    
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [weakSelf.resoureTypeBtn setTitle:result forState:UIControlStateNormal];
    };
    [self.pickerView show];
}
//选择资源等级

- (IBAction)selectResoureRank:(id)sender {
    self.pickerView.dataSource = @[@"A类",@"B类",@"C类",@"D类"];
    self.pickerView.pickerTitle = @"请选择资源等级";
    
    __weak typeof(self) weakSelf = self;
    
    self.pickerView.valueDidSelect = ^(NSString *str){
          NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [weakSelf.resoureRankBtn setTitle:result forState:UIControlStateNormal];
    };
    [self.pickerView show];
}

//保存btn
- (IBAction)submitBtn:(id)sender {
    
    if ([_resoureTypeBtn.titleLabel.text isEqualToString:@"请选择资源类型"]) {
        [EBAlert alertError:@"请选择资源类型" length:1.0f];
        return;
    }
    if ([_resoureRankBtn.titleLabel.text isEqualToString:@"请选择资源等级"]) {
        [EBAlert alertError:@"请选择资源等级" length:1.0f];
        return;
    }
    if (_huifanTextField.text.length == 0 ) {
        [EBAlert alertError:@"请输入未回访天数" length:1.0f];
        return;
    }
    
    if ([_huifanTextField.text integerValue]>100) {
        [EBAlert alertError:@"请输入回访小于100的天数" length:1.0f];
        return;
    }
    
    //关注小区
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@" http://218.65.86.83:8010/follow/followAdd?token=%@&rank=%@&day_min=%@&type=%@",[EBPreferences sharedInstance].token,_resoureRankBtn.titleLabel.text,_huifanTextField.text,_resoureTypeBtn.titleLabel.text]);
    [EBAlert showLoading:@"添加中..."];
    [HttpTool post:@"follow/followAdd" parameters:
     @{ @"token":[EBPreferences sharedInstance].token,
        @"rank":_resoureRankBtn.titleLabel.text,
        @"day_min":_huifanTextField.text,
        @"type":_resoureTypeBtn.titleLabel.text
        }success:^(id responseObject) {
            [EBAlert hideLoading];
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if ([currentDic[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"添加成功" allowUserInteraction:1.0f];
                [self.navigationController popViewControllerAnimated:YES];
                self.textBlock();//调用block
            }else{
                [EBAlert alertError:currentDic[@"desc"] length:2.0f];
            }
        } failure:^(NSError *error) {
            [EBAlert hideLoading];
            [EBAlert alertError:@"请检查网络" length:2.0f];
        }];
    
}

@end
