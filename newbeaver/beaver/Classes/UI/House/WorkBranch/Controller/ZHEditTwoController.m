//
//  ZHEditTwoController.m
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  选择费用名称two

#import "ZHEditTwoController.h"

#define RGB(r,g,b) [UIColor colorWithRed:r/ 255.0 green:g/ 255.0 blue:b/ 255.0 alpha:1.0]
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ZHEditTwoController ()<UIPickerViewDataSource,UIPickerViewDelegate>;
/** 用来承装数据的数组 */
@property (nonatomic, strong) NSMutableArray *provinces;
/** 用来承装dic的数组,计算行数 */
@property (nonatomic, strong) NSMutableArray *arrayRows;
/** 选中的省份 */
@property (nonatomic, copy) NSString *selectProvince;

@property (nonatomic, strong) UIPickerView *pickView;
@property (nonatomic, assign) NSInteger rows;


@end

@implementation ZHEditTwoController

#pragma mark - 懒加载数据
- (NSMutableArray *)provinces {
    if (_provinces == nil) {
        _provinces = [NSMutableArray array];
    }
    return _provinces;
}
- (NSMutableArray *)arrayRows {
    if (_arrayRows == nil) {
        _arrayRows = [NSMutableArray array];
    }
    return _arrayRows;
}

#pragma mark -- 初始化
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"传递至费用名称--费用类型: %@  %@",self.costType,self.token);
    
    self.title = @"选择费用名称";
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
    self.pickView = pickView;
    pickView.dataSource = self;
    pickView.delegate = self;
    
    //3.0 发起网络请求, 获取费用名称
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = [EBPreferences sharedInstance].token;
    params[@"type"] = self.costType;
    [HttpTool post:@"zhpay/getFeeName" parameters:params success:^(id responseObject) {
        [self.provinces removeAllObjects];
        
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"currentDic=%@",currentDic);
        if ([currentDic[@"code"] integerValue] == 0) {
            [self.provinces addObjectsFromArray:currentDic[@"data"][@"data"]];
        }else{
             [EBAlert alertError:@"请求数据失败" length:2.0f];
        }
        //NSLog(@"provinces: %@",self.provinces);
        
        [self.arrayRows removeAllObjects];
        for (NSDictionary *dic in self.provinces) {
            [self.arrayRows addObject:dic];
            
        }
        self.rows = self.arrayRows.count;
        //刷新pickView
        [self.pickView reloadAllComponents];
        
        // 2. 设置默认选中省份和城市的文字显示
        [pickView selectRow:0 inComponent:0 animated:YES];
        [self pickerView:pickView didSelectRow:0 inComponent:0];
    } failure:^(NSError *error) {
        [EBAlert alertError:@"请求失败,请重新再试" length:2.0f];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didClickCancelBtn {
    self.selectProvince = @"";
    NSLog(@"点击取消: %@",self.selectProvince);
    
    if ([self.delegate respondsToSelector:@selector(EditTwoControllerDidClickCancelBtn:)]) {
        [self.delegate EditTwoControllerDidClickCancelBtn:self];
    }
    
}
- (void)didClickSureBtn {
    NSLog(@"点击确认: %@",self.selectProvince);
    
    if ([self.delegate respondsToSelector:@selector(EditTwoControllerDidClickSureBtn:withProvince:)]) {
        [self.delegate EditTwoControllerDidClickSureBtn:self withProvince:self.selectProvince];
    }
}

#pragma mark --- pickView数据源及代理
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return self.rows;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *label = [[UILabel alloc] init];
    
    label.text = self.provinces[row][@"name"];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    //  设置横线的颜色，实现显示或者隐藏
    ((UIView *)[pickerView.subviews objectAtIndex:1]).backgroundColor = [UIColor orangeColor];
    ((UIView *)[pickerView.subviews objectAtIndex:2]).backgroundColor = [UIColor orangeColor];
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.selectProvince = self.provinces[row][@"name"];
    
    //NSLog(@"选中的省份:%@",self.selectProvince);
    
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    
    return 44;
}


@end



