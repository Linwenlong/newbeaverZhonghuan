
//
//  ZHFundEditController.m
//  财务收款项目
//
//  Created by 刘海伟 on 2017/11/26.
//  Copyright © 2017年 liuhaiwei. All rights reserved.
//
//  编辑控制器

#import "ZHFundEditController.h"
#import "ZHCover.h"
#import "ZHPopMenu.h"
#import "ZHEditOneController.h"
#import "ZHEditTwoController.h"
#import "FinancialDetailViewController.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define RGB(r,g,b) [UIColor colorWithRed:r/ 255.0 green:g/ 255.0 blue:b/ 255.0 alpha:1.0]

@interface ZHFundEditController ()<UIScrollViewDelegate,ZHCoverDelegate,EditOneControllerDelegate,EditTwoControllerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vHeight;

// 各标题lbl,共8行
@property (weak, nonatomic) IBOutlet UILabel *titleLblOne;
@property (weak, nonatomic) IBOutlet UILabel *titleLblTwo;
@property (weak, nonatomic) IBOutlet UILabel *titleLblThree;
@property (weak, nonatomic) IBOutlet UIButton *titleBtnFour;
@property (weak, nonatomic) IBOutlet UIButton *titleBtnFive;
@property (weak, nonatomic) IBOutlet UIButton *titleBtnSix;
@property (weak, nonatomic) IBOutlet UIButton *titleBtnSeven;
@property (weak, nonatomic) IBOutlet UIButton *titleBtnEight;

// 各内容lbl,共8行
@property (weak, nonatomic) IBOutlet UITextField *contentFieldOne;
@property (weak, nonatomic) IBOutlet UITextField *contentFieldTwo;
@property (weak, nonatomic) IBOutlet UITextField *contentFieldThree;
@property (weak, nonatomic) IBOutlet UITextField *contentFieldFour;
@property (weak, nonatomic) IBOutlet UITextField *contentFieldFive;
@property (weak, nonatomic) IBOutlet UIButton *contentBtnSix1;
@property (weak, nonatomic) IBOutlet UIButton *contentBtnSix2;
@property (weak, nonatomic) IBOutlet UITextField *contentFieldSeven;
@property (weak, nonatomic) IBOutlet UITextField *contentFieldEight;
/** 用来记录创建 "日期选择器" */
@property (nonatomic, weak) UIDatePicker *datePicker;
/** 点击选择收款日期field弹出半透明的背景 */
@property (nonatomic, weak) UIButton *coverView;

/** 备注及textView */
@property (weak, nonatomic) IBOutlet UILabel *remarkLbl;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) UILabel *placeHolderLbl;
@property (nonatomic, strong) UILabel *totalLbl;

/** 提交按钮 */
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

@property (nonatomic, strong) ZHEditOneController *editOneVC; //费用类型控制器
@property (nonatomic, strong) ZHEditTwoController *editTwoVC; //费用名称控制器
@property (nonatomic, strong) ZHCover *cover;
@property (nonatomic, strong) ZHPopMenu *menu;

@property (nonatomic, copy) NSString *dateCurrentDay; //当前日期 beginDay
@property (nonatomic, copy) NSString *costType; //接收的费用类型

@property (nonatomic, copy) NSString *token;


@end

@implementation ZHFundEditController

#pragma mark -- 懒加载
- (ZHEditOneController *)editOneVC {
    if (_editOneVC == nil) {
        _editOneVC = [[ZHEditOneController alloc] init];
        _editOneVC.delegate = self;
    }
    return _editOneVC;
}
- (ZHEditTwoController *)editTwoVC {
    if (_editTwoVC == nil) {
        _editTwoVC = [[ZHEditTwoController alloc] init];
        _editTwoVC.delegate = self;
    }
    return _editTwoVC;
}
-(ZHCover *)cover {
    if (_cover == nil) {
        _cover = [[ZHCover alloc] init];
    }
    return _cover;
}


#pragma mark -- 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setUpTextViewAndAddTwoLbls];
    // 模拟界面跳转 vcTag 0:新增 1:编辑
    if (self.vcTag == 0) { //从主界面跳转而来
        self.title = @"新增";
        self.contentFieldThree.text = @"";
        self.contentFieldFour.text = @"";
        self.contentFieldFive.text = @"";
        self.contentFieldSeven.text = @"";
    } else if (self.vcTag == 1) { //从查看界面跳转而来
        self.title = @"编辑";
        NSLog(@"传递至编辑界面的字典数据: %@",self.checkDic);
        self.contentFieldOne.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_charge"]];  //1. 收付类型
        self.contentFieldTwo.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_way"]];  //2. 缴费方式
        self.contentFieldThree.text = [NSString stringWithFormat:@"%@",self.checkDic[@"credit_card_fees"]];  //3. 刷卡手续费
        self.contentFieldFour.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_type"]];  //4. 费用类型
        self.costType = self.contentFieldFour.text;
        
        self.contentFieldFive.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_name"]];  //5. 费用名称
        
        NSString *fee_user = [NSString stringWithFormat:@"%@",self.checkDic[@"fee_user"]]; //6. 缴费人
        if ([fee_user isEqualToString:@"客户"]) { //1.客户 2.业主
            self.contentBtnSix1.selected = YES;
            self.contentBtnSix2.selected = NO;
            
        } else {
            self.contentBtnSix2.selected = YES;
            self.contentBtnSix1.selected = NO;
        }
        
        self.contentFieldSeven.text = [NSString stringWithFormat:@"%@",self.checkDic[@"price_num"]];  //7. 收款金额
        NSString *time = [NSString stringWithFormat:@"%@",self.checkDic[@"finance_date"]];
        self.contentFieldEight.text = [self timeWithTimeIntervalString:time];  //8. 收款日期
        if ([self.checkDic[@"memo"] isEqualToString:@""]) {
            _placeHolderLbl.hidden = NO;
        }else{
            _textView.text = self.checkDic[@"memo"];
            _placeHolderLbl.hidden = YES;
        }
    }
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.vWidth.constant = ScreenWidth;
    self.vHeight.constant = 700;
    self.scrollView.contentSize = CGSizeMake(ScreenWidth, self.vHeight.constant);
    
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.clipsToBounds = YES;
    
    //1.0 设置导航栏
    [self setUpNavgationBar];
    
    //2.0 设置各子控件的字体大小颜色
    [self setAllControlsFontColor];
    
    //4.0 创建选择日期弹出的datePicker
    [self setUpDatePicker];
    
//    //5.0 关于textView的设置,并且添加两个label, 占位lbl与字数统计lbl
//    [self setUpTextViewAndAddTwoLbls];
    
    //6.0 发送通知
    //发送监听通知来时刻观察收款日期textField开始编辑变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldBeginEdit) name:UITextFieldTextDidBeginEditingNotification object:self.contentFieldEight];
}

#pragma mark -- 1.0 设置导航栏
- (void)setUpNavgationBar {
    UIBarButtonItem *leftItemBack = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(leftItemBack)];
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSpace.width = -5;
    self.navigationItem.leftBarButtonItems = @[leftSpace,leftItemBack];
}

//导航栏上item事件的监听
- (void)leftItemBack {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认放弃编辑信息并返回上一页" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- 2.0 设置各子控件的字体大小颜色
- (void)setAllControlsFontColor {
    //设置八个标题及备注,提交按钮的文字颜色
    self.titleLblOne.textColor = RGB(64, 64, 64);
    self.titleLblTwo.textColor = RGB(64, 64, 64);
    self.titleLblThree.textColor = RGB(64, 64, 64);
    [self.titleBtnFour setTitleColor:RGB(64, 64, 64) forState:UIControlStateNormal];
    [self.titleBtnFive setTitleColor:RGB(64, 64, 64) forState:UIControlStateNormal];
    [self.titleBtnSix setTitleColor:RGB(64, 64, 64) forState:UIControlStateNormal];
    [self.titleBtnSeven setTitleColor:RGB(64, 64, 64) forState:UIControlStateNormal];
    [self.titleBtnEight setTitleColor:RGB(64, 64, 64) forState:UIControlStateNormal];
    self.remarkLbl.textColor = RGB(64, 64, 64);
    
    //设置八个内容的文字颜色
    self.contentFieldOne.textColor = RGB(128, 128, 128);
    self.contentFieldTwo.textColor = RGB(128, 128, 128);
    self.contentFieldThree.textColor = RGB(254, 56, 0);
    self.contentFieldFour.textColor = RGB(128, 128, 128);
    self.contentFieldFive.textColor = RGB(128, 128, 128);
    
    self.contentBtnSix1.layer.cornerRadius = 3;
    self.contentBtnSix1.clipsToBounds = YES;
    self.contentBtnSix2.layer.cornerRadius = 3;
    self.contentBtnSix2.clipsToBounds = YES;
    
    self.contentFieldSeven.textColor = RGB(254, 56, 0);
    self.contentFieldEight.textColor = RGB(128, 128, 128);
    
    //获取当前日期, 并赋值, 提升体验
    [self getCurrentDay];
//    self.contentFieldEight.text = self.dateCurrentDay;
}

#pragma mark -- 3.0 费用类型,费用名称,客户业主,收款日期,提交 五个按钮事件监听
#pragma mark -- 3.1 点击了"费用类型"按钮
- (IBAction)didClickBtnOne:(UIButton *)sender {
    //收起键盘
    [self.view endEditing:YES];
    
    // 弹出蒙板 弹出pop菜单
    [self createCoverAndMenuOne];
    
}
- (void)createCoverAndMenuOne {
    // 让控制器的view做相应的平移
    [UIView animateWithDuration:0.50 animations:^{
        // 弹出蒙板
        _cover = [ZHCover show];
        _cover.dimBackground = YES;
        _cover.delegate = self;
        // 弹出pop菜单
        CGFloat popW = ScreenWidth;
        CGFloat popX = 0;
        CGFloat popH = 260;
        //CGFloat popY = ScreenHeight - popH;
        ZHPopMenu *menu = [ZHPopMenu showInRect:CGRectMake(popX, ScreenHeight, popW, popH)];
        self.menu = menu;
        menu.contentView = self.editOneVC.view;
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        menu.transform = CGAffineTransformMakeTranslation(0, -popH);
    }];

}
// 点击蒙板的时候调用
- (void)coverDidClickCover:(ZHCover *)cover {
    
    [UIView animateWithDuration:0.50 animations:^{
        self.menu.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        // 隐藏pop菜单
        [ZHPopMenu hide];
    }];
}
#pragma mark -- 3.2 点击了"费用名称"按钮
- (IBAction)didClickBtnTwo:(UIButton *)sender {
    //收起键盘
    [self.view endEditing:YES];
    if (self.contentFieldFour.text.length == 0) {  //判断是否已选定费用类型
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请您先选择费用类型" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // 弹出蒙板 弹出pop菜单
        [self createCoverAndMenuTwo];
    }
    
}
- (void)createCoverAndMenuTwo {
    // 让控制器的view做相应的平移
    [UIView animateWithDuration:0.50 animations:^{
        // 弹出蒙板
        _cover = [ZHCover show];
        _cover.dimBackground = YES;
        _cover.delegate = self;
        // 弹出pop菜单
        CGFloat popW = ScreenWidth;
        CGFloat popX = 0;
        CGFloat popH = 260;
        //CGFloat popY = ScreenHeight - popH;
        ZHPopMenu *menu = [ZHPopMenu showInRect:CGRectMake(popX, ScreenHeight, popW, popH)];
        self.menu = menu;
        self.editTwoVC.costType = self.costType;
        self.editTwoVC.token = self.token;
        menu.contentView = self.editTwoVC.view;
        
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        menu.transform = CGAffineTransformMakeTranslation(0, -popH);
    }];
    
}

#pragma mark -- 3.3.1 点击了"客户"按钮   客户six1  业主six2
- (IBAction)didClickBtnThree1:(UIButton *)sender {
    
    //收起键盘
    [self.view endEditing:YES];
    
    sender.selected = !sender.isSelected;
    self.contentBtnSix2.selected = NO;
    
}

#pragma mark -- 3.3.2 点击了"业主"按钮
- (IBAction)didClickBtnThree2:(UIButton *)sender {
    
    //收起键盘
    [self.view endEditing:YES];
    
    sender.selected = !sender.isSelected;
    self.contentBtnSix1.selected = NO;
}


#pragma mark -- 3.5 点击了"提交"按钮
- (IBAction)didClickBtnFive:(UIButton *)sender {
    
    //收起键盘
    [self.view endEditing:YES];
    
    if (self.contentFieldFour.text.length == 0 || self.contentFieldFive.text.length == 0 || self.contentFieldSeven.text.length == 0 || self.contentFieldEight.text.length == 0 || (self.contentBtnSix1.selected == NO && self.contentBtnSix2.selected == NO)) {
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请您填写所有必填信息" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        // 发起"提交"网络请求
        [self sendNetworkdates];
       
    }
    
}

#pragma mark -- 4.0 创建选择日期弹出的datePicker
- (void)setUpDatePicker {
    
    // 1. 创建一个datePicker
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-Hans"];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker = datePicker;
    self.contentFieldEight.inputView = datePicker;
    
    // 2. 创建一个工具栏
    UIToolbar *toolBar = [[UIToolbar alloc] init];
    toolBar.barTintColor = RGB(254, 56, 0);
    toolBar.frame = CGRectMake(0, 0, 0, 44);
    
    UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(didClickCancelButton)];
    UIBarButtonItem *itemSpring = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *itemDone = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(didClickDoneButton)];
    
    NSDictionary * attrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:15], NSForegroundColorAttributeName:[UIColor whiteColor]};
    [itemCancel setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [itemDone setTitleTextAttributes:attrs forState:UIControlStateNormal];
    
    toolBar.items = @[itemCancel, itemSpring, itemDone];
    self.contentFieldEight.inputAccessoryView = toolBar;
    
}

// 点击了 "取消" 按钮
- (void)didClickCancelButton {
    [self didClickCoverView:self.coverView];
}

// 点击了 "完成" 按钮
- (void)didClickDoneButton {
    [self didClickCoverView:self.coverView];
    NSDate *date = self.datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *strDate = [formatter stringFromDate:date];
    self.contentFieldEight.text = strDate;
    
}

#pragma mark -- 5.0 关于textView的设置,并且添加两个label, 占位lbl与字数统计lbl
- (void) setUpTextViewAndAddTwoLbls {
    self.textView.backgroundColor = RGB(238, 238, 238);
    self.textView.textColor = RGB(64, 64, 64);
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.layer.cornerRadius = 3;
    self.textView.clipsToBounds = YES;
    
    //5.1 占位label
    UILabel *placeHolderLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 6, 140, 22)];
    [self.textView addSubview:placeHolderLbl];
    self.placeHolderLbl = placeHolderLbl;
    placeHolderLbl.text = @"请输入备注信息";
    placeHolderLbl.font = [UIFont systemFontOfSize:13];
    placeHolderLbl.textAlignment = NSTextAlignmentLeft;
    placeHolderLbl.textColor = RGB(128, 128, 128);
    
    //5.2 字数统计label
    UILabel *totalLbl = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth -35 -80, 184, 80, 22)];
    [self.textView addSubview:totalLbl];
    self.totalLbl = totalLbl;
    totalLbl.text = @"0/200字";
    totalLbl.font = [UIFont systemFontOfSize:13];
    totalLbl.textAlignment = NSTextAlignmentRight;
    totalLbl.textColor = RGB(128, 128, 128);
    
}

#pragma mark -- 6.0 监听通知处理 观察收款日期textField开始编辑变化
- (void)textFieldBeginEdit {
    // 1. 创建一个和屏幕一样大小的半透明UIView, 用来遮盖整个界面
    UIButton *coverView = [[UIButton alloc] init];
    coverView.backgroundColor = [UIColor blackColor];
    coverView.alpha = 0.0;
    coverView.frame = self.view.bounds;
    // 为半透明背景添加一个单击事件
    [coverView addTarget:self action:@selector(didClickCoverView:) forControlEvents:UIControlEventTouchUpInside];
    self.coverView = coverView;
    [[UIApplication sharedApplication].keyWindow addSubview:coverView];
    
    [UIView animateWithDuration:0.35 animations:^{
        coverView.alpha = 0.3;
        self.view.transform = CGAffineTransformMakeTranslation(0, -150);
        
    }];
}
// 点击了"半透明背景"按钮
- (void)didClickCoverView:(UIButton *)sender {
    
    [UIView animateWithDuration:0.35 animations:^{
        self.coverView.alpha = 0.0;
        [self.contentFieldEight resignFirstResponder];
        
    } completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        self.view.transform = CGAffineTransformIdentity;
        
    }];
}
//移除通知
-(void)dealloc{
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma mark -- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    //NSLog(@"textView输入文字: %@", textView.text);
    
    self.placeHolderLbl.hidden = YES;
    
    //实时显示字数
    self.totalLbl.text = [NSString stringWithFormat:@"%lu/200字", (unsigned long)textView.text.length];
    
    //字数限制操作
    if (textView.text.length >= 200) {
        textView.text = [textView.text substringToIndex:200];
        self.totalLbl.text = @"200/200";
        
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"备注最多输入200个字" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    //取消按钮点击权限，并显示提示文字
    if (textView.text.length == 0) {
        self.placeHolderLbl.hidden = NO;
        
    }
    
}

#pragma mark -- EditOneControllerDelegate 实现费用类型控制器代理
- (void)EditOneControllerDidClickCancelBtn:(ZHEditOneController *)pickVC {
    [UIView animateWithDuration:0.50 animations:^{
        self.menu.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        // 隐藏pop菜单
        [ZHPopMenu hide];
        
        [_cover removeFromSuperview];
    }];
    
}
- (void)EditOneControllerDidClickSureBtn:(ZHEditOneController *)pickVC withProvince:(NSString *)province {
    [UIView animateWithDuration:0.50 animations:^{
        self.menu.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        // 隐藏pop菜单
        [ZHPopMenu hide];
        
        [_cover removeFromSuperview];
        
        // 接收传递过来的数据
        self.contentFieldFour.text = province;
        self.costType = province;
        
        //清空费用名称
        self.contentFieldFive.text = @"";
        NSLog(@"新增编辑界面接收的费用类型: %@",province);
    }];
    
    
}
#pragma mark -- EditTwoControllerDelegate 实现费用名称控制器代理
- (void)EditTwoControllerDidClickCancelBtn:(ZHEditTwoController *)pickVC {
    [UIView animateWithDuration:0.50 animations:^{
        self.menu.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        // 隐藏pop菜单
        [ZHPopMenu hide];
        
        [_cover removeFromSuperview];
    }];
    
}
- (void)EditTwoControllerDidClickSureBtn:(ZHEditTwoController *)pickVC withProvince:(NSString *)province {
    [UIView animateWithDuration:0.50 animations:^{
        self.menu.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        // 隐藏pop菜单
        [ZHPopMenu hide];
        
        [_cover removeFromSuperview];
        
        // 接收传递过来的数据
        self.contentFieldFive.text = province;
        NSLog(@"新增编辑界面接收的费用名称: %@",province);
    }];
    
    
}

//获取当前日期
- (void)getCurrentDay {
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *lastMonthComps = [[NSDateComponents alloc] init];
    
    [lastMonthComps setMonth:0];
    NSDate *newdate = [calendar dateByAddingComponents:lastMonthComps toDate:currentDate options:0];
    NSString *dateDay = [formatter stringFromDate:newdate];
    self.dateCurrentDay = dateDay;
    //NSLog(@"当前日期:%@", self.dateCurrentDay);
    
}

#pragma mark -- 发起"提交"网络请求
- (void)sendNetworkdates {

    //1.0 收付类型
    NSString *one = self.contentFieldOne.text;
    
    //2.0 缴费方式
    NSString *two = self.contentFieldTwo.text;
    
    //3.0 刷卡手续费
    NSString *three = self.contentFieldThree.text;
    
    //4.0 费用类型
    NSString *four = self.contentFieldFour.text;
    
    //5.0 费用名称
    NSString *five = self.contentFieldFive.text;
    
    //6.0 缴费人
    NSString *six;
    if (self.contentBtnSix1.isSelected) {              //客户six1  业主six2
        six = self.contentBtnSix1.titleLabel.text;
        
    } else if (self.contentBtnSix2.isSelected) {
        six = self.contentBtnSix2.titleLabel.text;
        
    }
    
    //7.0 收款金额
    NSString *seven = self.contentFieldSeven.text;
    
    //8.0 收款日期
    NSString *eightTime = self.contentFieldEight.text;
    double time = [self timeIntervalWithTimeString:eightTime];
    NSString *eight = [NSString stringWithFormat:@"%f",time];
    
    NSLog(@"收款日期时间戳: %@",eight);
    
    //9.0 备注textView
    NSString *nine = self.textView.text;
    // vcTag 0:新增 1:编辑
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = [EBPreferences sharedInstance].token;  //token
    params[@"price_charge"] = one;   //收付类型
    params[@"price_way"] = two; //收款方式
    params[@"credit_card_fees"] = three;  //刷卡手续费
    params[@"price_type"] = four;  //费用类型
    params[@"price_name"] = five;  // 费用名称
    params[@"fee_user"] = six;  //缴费人
    params[@"price_num"] = seven; //收款金额
    params[@"finance_date"] = eight; //收取时间
    params[@"memo"] = nine;    //备注
    params[@"user_id"] = [[EBPreferences sharedInstance].userId componentsSeparatedByString:@"_"].lastObject;   //操作人ID
    params[@"deal_id"] = self.deal_id;    //合同ID
    params[@"deal_type"] = self.deal_type;   //合同类型  先测试
    if (self.vcTag == 0) {  //新增界面 提交
        NSLog(@"新增params: %@",params);
        [EBAlert showLoading:@"加载中..." allowUserInteraction:YES];
        [HttpTool post:@"zhpay/collectPayAdd" parameters:params success:^(id responseObject) {
            [EBAlert hideLoading];
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"currentDic=%@",currentDic);
            if ([currentDic[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"新增成功" length:2.0f];
                [self.navigationController popViewControllerAnimated:YES];
                self.returnBlock();
            }else{
                if ([currentDic.allKeys containsObject:@"desc"]) {
                    [EBAlert alertError:currentDic[@"desc"] length:2.0f];
                }
                
            }
            
        } failure:^(NSError *error) {
            [EBAlert hideLoading];
            [EBAlert alertError:@"网络繁忙,请稍后再试" length:2.0f];
        }];
        
    } else if (self.vcTag == 1) {
        params[@"document_id"] = self.checkDic[@"document_id"];  //主键ID
        NSLog(@"编辑params: %@",params);
        [EBAlert showLoading:@"修改中..." allowUserInteraction:YES];
        [HttpTool post:@"zhpay/collectPayModify" parameters:params success:^(id responseObject) {
            [EBAlert hideLoading];
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"currentDic=%@",currentDic);
            if ([currentDic[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"修改成功" length:2.0f];
                
                NSLog(@"viewcontrols = %@",self.navigationController.viewControllers);
                for (UIViewController *viewcontrol in self.navigationController.viewControllers) {
                    if ([viewcontrol isKindOfClass:[FinancialDetailViewController class]]) {
                        FinancialDetailViewController *detailVC = (FinancialDetailViewController *)viewcontrol;
                        [detailVC refreshHeader];
                        [self.navigationController popToViewController:viewcontrol animated:YES];
                    }
                }
                
                
                //[self refreshHeader];//回调前面
            }else{
                if ([currentDic.allKeys containsObject:@"desc"]) {
                    [EBAlert alertError:currentDic[@"desc"] length:2.0f];
                }
            }
            
        } failure:^(NSError *error) {
            [EBAlert hideLoading];
            [EBAlert alertError:@"网络繁忙,请稍后再试" length:2.0f];
        }];

    }
    
    
}

// 转时间戳
- (NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:timeString];
    NSTimeInterval interval = (long)[date timeIntervalSince1970];
    return interval;
}

//时间戳转日期
- (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

@end
















