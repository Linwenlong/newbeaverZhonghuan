//
//  CollectiveUpdateViewController.m
//  beaver
//
//  Created by mac on 17/6/27.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "CollectiveUpdateViewController.h"
#import "EBListView.h"
#import "HWPopTool.h"
#import "EBAlert.h"
#import "EBPreferences.h"
#import "HttpTool.h"
#import "CollectiveUpdataModel.h"
#import "UITableView+PlaceHolderView.h"
#import "DefaultView.h"
#import "AddView.h"

@interface CollectiveUpdateViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;

@property (nonatomic, strong)NSMutableArray *selectArray;//选择的数据
@property (nonatomic, strong)UIButton * button;




@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *tel;

@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UILabel *start;
@property (weak, nonatomic) IBOutlet UILabel *end;

@property (nonatomic, strong) UIDatePicker *dataPicker;

@property (nonatomic, assign) NSInteger current;
@property (nonatomic, strong)NSDate *startDate;//开始日期
@property (nonatomic, strong)NSDate *endDate;//结束日期

@property (nonatomic,weak) AddView *popView;
@property (nonatomic, weak)UIView *containView;

@end

@implementation CollectiveUpdateViewController

#pragma mark -- UITableViewDataSource And UITableDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    CollectiveUpdataModel *model = _dataArray[indexPath.row];
    cell.multipleSelectionBackgroundView = [UIView new];
    cell.tintColor = [UIColor redColor];
    cell.textLabel.text = model.house_title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_selectArray.count == 0) {
        _button.layer.borderColor = [[UIColor redColor]colorWithAlphaComponent:1].CGColor;
        [_button setTitleColor:[[UIColor redColor]colorWithAlphaComponent:1] forState:UIControlStateNormal];
         _button.enabled = YES;
    }
    [_selectArray addObject:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"取消选择");
    [_selectArray removeObject:indexPath];
    if (_selectArray.count == 0) {
        _button.layer.borderColor = [[UIColor redColor]colorWithAlphaComponent:0.3].CGColor;
        [_button setTitleColor:[[UIColor redColor]colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
         _button.enabled = NO;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


#pragma mark -- Lasy
- (UIDatePicker *)dataPicker{
    if (!_dataPicker) {
        _dataPicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, kScreenH, [UIScreen mainScreen].bounds.size.width, 250)];
        [_dataPicker addTarget:self action:@selector(change) forControlEvents:UIControlEventValueChanged];
        _dataPicker.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
        _dataPicker.datePickerMode = UIDatePickerModeDateAndTime;
        [_dataPicker setTimeZone:[NSTimeZone localTimeZone]];
    }
    return _dataPicker;
}

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-124) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.editing = YES ;
         _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        
    }
    return _mainTableView;
}



#pragma mark -- life
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"报备列表";
    _selectArray = [NSMutableArray array];
    _dataArray = [NSMutableArray array];
    [self.view addSubview:self.mainTableView];
    [self addUpdateButon];
    [self requestData];
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)requestData{
    NSString *urlString = [NSString stringWithFormat:@"%@/NewHouse/getAllList?token=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token];
    NSLog(@"urlString=%@",urlString);
    [EBAlert showLoading:@"请求中..."];
    [HttpTool post:urlString parameters:nil success:^(id responseObject) {
        [EBAlert hideLoading];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *tmpArray = dic[@"data"][@"data"];
        for (NSDictionary *dic in tmpArray) {
            CollectiveUpdataModel *model = [[CollectiveUpdataModel alloc]initWithDict:dic];
            [_dataArray addObject:model];
        }
        [self.mainTableView reloadData];
    } failure:^(NSError *error) {
        if (_dataArray.count == 0) {
            //是否启用占位图
            _mainTableView.enablePlaceHolderView = YES;
            DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
            defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
            defaultView.placeText.text = @"数据获取失败";
            [_mainTableView reloadData];
        }
        [EBAlert alertError:@"请求失败" length:2.0];
    } ];
}

#pragma mark -- 报备按钮

- (void)addUpdateButon{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenH-124, kScreenW, 60)];
    view.backgroundColor = [UIColor  whiteColor];
   _button =[[UIButton alloc]initWithFrame:CGRectMake(20, 10, kScreenW-40, 40)];
    [_button setTitle:@"报备" forState:UIControlStateNormal];
    _button.backgroundColor = [UIColor clearColor];
    _button.layer.borderColor = [[UIColor redColor]colorWithAlphaComponent:0.3].CGColor;
    [_button setTitleColor:[[UIColor redColor]colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
    _button.layer.borderWidth = 1.0f;
    _button.layer.cornerRadius = 5.0f;
    _button.enabled = NO;
    [_button addTarget:self
               action:@selector(updataData:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_button];
    [self.view addSubview:view];
}

- (void)updataData:(UIButton *)btn{
    
    for (NSIndexPath *path in _selectArray) {
        NSLog(@"path = %ld",path.row);
    }
    [self addTargetForButton];
}

- (void)addTargetForButton{
    AddView *backView = [[AddView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
    self.popView = backView;
    backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *testTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(test)];
    backView.userInteractionEnabled = YES;
    [backView addGestureRecognizer:testTap];
    
    UIView* view = [[[NSBundle mainBundle]loadNibNamed:@"CollectiveUpdate" owner:self options:nil]lastObject];
    _containView = view;
    view.clipsToBounds = YES;
    view.center  =backView.center;
    view.layer.cornerRadius = 5.0f;
    
    [backView addSubview:view];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeDatapicker:)];
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
    
    //实现弹出方法
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    window.windowLevel = UIWindowLevelNormal;
    
    backView.alpha = 0;
    view.alpha = 0;
    
    [window addSubview:backView];
    [self.popView popView:_containView];

        //姓名跟电话
    _name.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;

    _name.layer.borderWidth = 1.0;
    _name.layer.cornerRadius = 3.0f;
    _tel.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
    _tel.delegate = self;
    _tel.layer.borderWidth = 1.0;
    _tel.layer.cornerRadius = 3.0f;
    
    //备注标签
    _content.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
    _content.layer.borderWidth = 1.0;
    _content.layer.cornerRadius = 3.0f;
    [_content.layer setMasksToBounds:YES];
    
    //开始跟结束标签
    _start.tag = 1;
    _start.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
    _start.layer.borderWidth = 1.0;
    _start.layer.cornerRadius = 3.0f;
    _end.tag = 2;
    _end.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
    _end.layer.borderWidth = 1.0;
    _end.layer.cornerRadius = 3.0f;
    
    //开始标签跟结束标签的手势事件
    UITapGestureRecognizer *startGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startAndEnd:)];
    _start.userInteractionEnabled = YES;
    [_start addGestureRecognizer:startGR];
    UITapGestureRecognizer *endGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startAndEnd:)];
    _end.userInteractionEnabled = YES;
    [_end addGestureRecognizer:endGR];
    
     //添加日期
    [window addSubview:self.dataPicker];
    [window bringSubviewToFront:_dataPicker];
}

- (void)test{
    [_name resignFirstResponder];
    [_tel resignFirstResponder];
    [_content resignFirstResponder];
    if (_dataPicker.top != kScreenH) {
        [UIView animateWithDuration:0.2 animations:^{
            _popView.top += 20;
            _dataPicker.top = kScreenH;
        }];
    }
}


#pragma mark -- 发送请求
- (void)reportAdd{
    //先取得最后一个
    NSIndexPath *first = _selectArray[0];
    CollectiveUpdataModel *model = _dataArray[first.row];
    NSString *house_id = model.house_id;
    for (int i=1; i<_selectArray.count; i++) {
        NSIndexPath * current = _selectArray[i];
        CollectiveUpdataModel *model = _dataArray[current.row];
        house_id = [house_id stringByAppendingFormat:@";%@",model.house_id];
    }
    NSLog(@"http://218.65.86.83:8010/newHouse/batchReport?token=%@&house_ids=%@&custom_name=%@&custom_phone=%@&custom_remarks=%@&visit_start=%@&visit_end=%@",[EBPreferences sharedInstance].token,house_id,_name.text,_tel.text,_content.text,[NSNumber numberWithDouble:[self timeIntervalWithTimeString:_start.text]],[NSNumber numberWithDouble:[self timeIntervalWithTimeString:_end.text]]);
    
    [EBAlert showLoading:@"添加中"];
    [HttpTool post:@"newHouse/batchReport" parameters:@{
            @"token":[EBPreferences sharedInstance].token,
            @"house_ids":house_id,
            @"custom_name":_name.text,
            @"custom_phone":_tel.text,
            @"custom_remarks":_content.text,
            @"visit_start":[NSNumber numberWithDouble:[self timeIntervalWithTimeString:_start.text]],
            @"visit_end":[NSNumber numberWithDouble:[self timeIntervalWithTimeString:_end.text]]
            } success:^(id responseObject) {
                [EBAlert hideLoading];
                NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    if ([dic[@"code"] intValue] == 0) {
                        [EBAlert alertSuccess:@"添加成功" length:2.0];
                    }else{
                        [EBAlert alertError:dic[@"desc"] length:2.0];
                    }
            } failure:^(NSError *error) {
                    [EBAlert hideLoading];
                    [EBAlert alertError:@"请检查网络" length:2.0f];
            }];

}

#pragma mark -- 时间转时间戳
- (NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate *date = [dateFormatter dateFromString:timeString];
    NSTimeInterval interval = (long)[date timeIntervalSince1970];
    return interval;
}


- (IBAction)comfirm:(id)sender {
    
    NSArray *array = @[_name.text,_tel.text,_start.text,_end.text];
    NSArray *tips = @[@"客户姓名",@"客户电话",@"预计开始",@"预计结束"];
    for (int i=0; i<array.count; i++) {
        NSString *text = array[i];
        if (!text.length) {
            NSString *str = [NSString stringWithFormat:@"请输入%@",tips[i]];
             [EBAlert alertError:str length:2.0];
            return;
        }
    }
    
    if ([self checkTel:_tel.text] == NO) {
        [EBAlert alertError:@"请输入正确的手机号" length:2.0];
        return;
    }
    //关闭
    [self.popView close:_containView];

    //上传报备
    [self reportAdd];
}



- (IBAction)close:(id)sender {
      [self.popView close:_containView];
}

#pragma mark -- 判断的方法

- (void)change{
    //改变上面的时间
    NSDate *newDate = [_dataPicker.date dateByAddingTimeInterval:8*60*60];
    //    NSString *string1 = [NSString alloc]initwithd
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"       yyyy/MM/dd HH:mm"];
    NSString *string = [formatter stringFromDate:_dataPicker.date];
    if (_current == 1) {
        _startDate = newDate;
        if ([_startDate compare:_endDate] > 0) {
            [EBAlert alertError:@"开始日期比结束日期大"];
            return;
        }else{
            _start.text = string;
        }
    }else{
        _endDate = newDate;
        if ([_endDate compare:_startDate] <= 0) {
            [EBAlert alertError:@"结束日期比开始日期小"];
            return;
        }else{
            _end.text = string;
        }
    }
}

#pragma mark -- TextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (_dataPicker.top != kScreenH) {
        [UIView animateWithDuration:0.2 animations:^{
            _popView.top += 20;
            _dataPicker.top = kScreenH;
        }];
    }
    return YES;
}

- (void)startAndEnd:(UITapGestureRecognizer *)tap{
    _current = tap.view.tag;
    [_name resignFirstResponder];
    [_tel resignFirstResponder];
    [_content resignFirstResponder];
    //弹出pickview
    if (_dataPicker.top == kScreenH) {
        [UIView animateWithDuration:0.2 animations:^{
            _popView.top -= 20;
            _dataPicker.top = kScreenH - _dataPicker.height;
        }];
    }
}

//关闭日期控制器和键盘
- (void)closeDatapicker:(UITapGestureRecognizer *)tap{
    [_name resignFirstResponder];
    [_tel resignFirstResponder];
    [_content resignFirstResponder];
    if (_dataPicker.top != kScreenH) {
        [UIView animateWithDuration:0.2 animations:^{
            _popView.top += 20;
            _dataPicker.top = kScreenH;
        }];
    }
}

///正则
- (BOOL)checkTel:(NSString *)str

{
    NSString *regex = @"^((17[0-9])|(13[0-9])|(147)|(15[^4,\\D])|(18[0-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        [EBAlert alertError:@"请输入正确的手机号码"];
        return NO;
    }
    return YES;
}


@end
