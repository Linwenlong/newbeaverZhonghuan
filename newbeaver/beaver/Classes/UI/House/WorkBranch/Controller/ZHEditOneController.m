//
//  ZHEditOneController.m
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  选择费用类型one

#import "ZHEditOneController.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/ 255.0 green:g/ 255.0 blue:b/ 255.0 alpha:1.0]
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ZHEditOneController ()<UIPickerViewDataSource,UIPickerViewDelegate>;
/** 选中的省份 */
@property (nonatomic, copy) NSString *selectProvince;

@end

@implementation ZHEditOneController

#pragma mark -- 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择费用类型";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    [self.view addSubview:topView];
    topView.backgroundColor = RGB(250, 59, 29);
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 40, 25)];
    [topView addSubview:cancelBtn];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [cancelBtn addTarget:self action:@selector(didClickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth -40 -15, 10, 40, 25)];
    [topView addSubview:sureBtn];
    [sureBtn setTitle:@"确认" forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [sureBtn addTarget:self action:@selector(didClickSureBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIPickerView *pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, ScreenWidth, 216)];
    pickView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pickView];
    pickView.dataSource = self;
    pickView.delegate = self;
    
    // 2. 设置默认选中省份和城市的文字显示
    [pickView selectRow:0 inComponent:0 animated:YES];
    [self pickerView:pickView didSelectRow:0 inComponent:0];
    
}
- (void)didClickCancelBtn {
    self.selectProvince = @"";
    NSLog(@"点击取消: %@",self.selectProvince);
    
    if ([self.delegate respondsToSelector:@selector(EditOneControllerDidClickCancelBtn:)]) {
        [self.delegate EditOneControllerDidClickCancelBtn:self];
    }
    
}
- (void)didClickSureBtn {
    NSLog(@"点击确认: %@",self.selectProvince);
    
    if ([self.delegate respondsToSelector:@selector(EditOneControllerDidClickSureBtn:withProvince:)]) {
        [self.delegate EditOneControllerDidClickSureBtn:self withProvince:self.selectProvince];
    }
    
}

#pragma mark --- pickView数据源及代理
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 3;
}
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//
//    NSDictionary *dict = self.provinces[row];
//    
//    return dict[@"name"];
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label = [[UILabel alloc] init];
    
    if (row == 0) {
        label.text = @"盈利";
        
    } else if (row == 1) {
        label.text = @"非盈利";
        
    } else {
        label.text = @"保证金";
    }
    
    label.textAlignment = NSTextAlignmentCenter;
    
    //  设置横线的颜色，实现显示或者隐藏
    ((UIView *)[pickerView.subviews objectAtIndex:1]).backgroundColor = [UIColor orangeColor];
    ((UIView *)[pickerView.subviews objectAtIndex:2]).backgroundColor = [UIColor orangeColor];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (row == 0) {
        self.selectProvince = @"盈利";
        
    } else if (row == 1) {
        self.selectProvince = @"非盈利";
        
    } else {
        self.selectProvince = @"保证金";
    }
    
    //NSLog(@"选中的费用类型:%@",self.selectProvince);
    
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 44;
}


@end
