//
//  DealFunnelViewController.m
//  beaver
//
//  Created by mac on 17/8/16.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "DealFunnelViewController.h"
#import "SDAutoLayout.h"
#import "DealFunnerlHeaderView.h"
#import "HooDatePicker.h"
#import "WSDropMenuView.h"
#import "EBCache.h"

@interface DealFunnelViewController ()<DealFunnerlHeaderViewDelegate,HooDatePickerDelegate,WSDropMenuViewDataSource,WSDropMenuViewDelegate,WSButtonClickDelegate>


@property (nonatomic, strong)NSString *currentDate;//当前的日期
@property (nonatomic, strong)NSString *current_id;  //当前的id

@property (nonatomic, strong)HooDatePicker *datePicker;  //日期选择控制器

@property (nonatomic, strong)NSMutableArray  *dept_Array;  //日期选择控制器
@property (nonatomic, strong)WSDropMenuView *dropMenu;

@property (nonatomic, strong)NSMutableArray *lableArray;


@end

#define Font [UIFont systemFontOfSize:14]

@implementation DealFunnelViewController

#pragma mark -- DealFunnerlHeaderViewDelegate

- (void)selected:(NSInteger)tag{
    
    if (tag == 1) {
        NSLog(@"部门");
    }else{
        
        NSLog(@"月份");
    }
}

- (void)CreateData{
    
    _lableArray = [NSMutableArray array];
    _dept_Array = [NSMutableArray arrayWithArray:[[EBCache sharedInstance] objectForKey:EB_CACHE_KEY_DEPT_ALL]];
 
    //初始化数据
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    _currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    
    NSString *dept_id = [EBPreferences sharedInstance].dept_id;
    _current_id = [dept_id componentsSeparatedByString:@"_"].lastObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"成交漏斗";
    [self CreateData];
    [self setUI];
    [self requestDate];
}


#pragma mark -- HooDatePickerDelegate
- (void)datePicker:(HooDatePicker *)datePicker dateDidChange:(NSDate *)date{
    
}
- (void)datePicker:(HooDatePicker *)datePicker didCancel:(UIButton *)sender{
    NSLog(@"取消");
}
- (void)datePicker:(HooDatePicker *)dataPicker didSelectedDate:(NSDate *)date{
    NSLog(@"选择了日期");
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSString *currentOlderOneDateStr = [dateFormatter stringFromDate:date];

    if ([date compare:[NSDate date]] < 0) {
        _currentDate = currentOlderOneDateStr;
    }else{
        [EBAlert alertError:@"请选择小于本月的月份" length:2.0 ];
        return;
    }
    //获取当前的日期比较，如果是相当就本月
    NSDate *currentDate = [NSDate date];
    NSString *currentDateStr = [dateFormatter stringFromDate:currentDate];
    _currentDate = currentOlderOneDateStr;
    //_current_id 不为空
    if (_current_id.length != 0) {
        _datePicker.date = date;
        [self requestDate];
        if ([currentOlderOneDateStr isEqualToString:currentDateStr]) {
            NSLog(@"本月");
            [_dropMenu.rightButton setTitle:@"本月" forState:UIControlStateNormal];
        }else{
            [_dropMenu.rightButton setTitle:_currentDate forState:UIControlStateNormal];
        }
    }else{
         [EBAlert alertError:@"请选择门店" length:2.0f];
    }
    
}

- (void)setUI{
    NSArray *  titleArray  =  @[@"新增客户",@"带看数",@"带看比例",@"成交数",@"成交带看比"];
    NSArray *contentArray = @[@"",@"0%",@"0%",@"0",@"0%"];
    NSArray *colorArray = @[[UIColor colorWithRed:1.00 green:0.40 blue:0.27 alpha:1.00],[UIColor colorWithRed:1.00 green:0.75 blue:0.24 alpha:1.00],[UIColor colorWithRed:0.54 green:0.62 blue:1.00 alpha:1.00],[UIColor colorWithRed:0.54 green:0.86 blue:0.42 alpha:1.00],[UIColor colorWithRed:0.00 green:0.84 blue:0.69 alpha:1.00]];
    CGFloat view_h = 40;
    CGFloat spacing = 15;
    CGFloat offset = 12;
    for (int i = 0; i<titleArray.count; i++) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake((kScreenW-200-15-60)/2.0+offset * i, 100 + (view_h+spacing)*i, 200-offset*2*i, view_h)];// 坐标可以自行修改
        [self.view addSubview:view];
        [self drawBackViewWithView:view BackColor:colorArray[i] LabelText:contentArray[i] withContentText:titleArray[i]];
    }
    _dropMenu = [[WSDropMenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    _dropMenu.dataSource = self;
    _dropMenu.delegate  =self;
    _dropMenu.btnDelegate = self;
    [self.view addSubview:_dropMenu];
     [_dropMenu.leftButton setTitle:[EBPreferences sharedInstance].dept_name forState:UIControlStateNormal];
}

- (HooDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[HooDatePicker alloc] initWithSuperView:self.view];
        _datePicker.delegate = self;
        _datePicker.datePickerMode = HooDatePickerModeYearAndMonth;
    }
    return _datePicker;
}

#pragma mark -- WSBtnDelegate
- (void)btnClick:(UIButton *)btn{
    [self.datePicker show];
}


#pragma mark - WSDropMenuView DataSource -
- (NSInteger)dropMenuView:(WSDropMenuView *)dropMenuView numberWithIndexPath:(WSIndexPath *)indexPath{
    //WSIndexPath 类里面有注释
    if (indexPath.column == 0 && indexPath.row == WSNoFound) {
        
        return _dept_Array.count;
    }
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item == WSNoFound) {
        //row
        NSDictionary *dic = _dept_Array[indexPath.row];
        NSArray *array = dic[@"children"];
        return array.count;
    }
    //row  item
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item != WSNoFound && indexPath.rank == WSNoFound) {
        //row
        NSDictionary *dic = _dept_Array[indexPath.row];
        NSArray *array = dic[@"children"];
        NSDictionary *nextDic = array[indexPath.item];
        NSArray *nextArray = nextDic[@"children"];
        return nextArray.count;
    }
    return 0;
}

- (NSString *)dropMenuView:(WSDropMenuView *)dropMenuView titleWithIndexPath:(WSIndexPath *)indexPath{

    //左边 第一级
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item == WSNoFound) {
        NSDictionary *dic = _dept_Array[indexPath.row];
        return dic[@"dept_name"];
    }
    
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item != WSNoFound && indexPath.rank == WSNoFound) {
        NSDictionary *dic = _dept_Array[indexPath.row];
        NSArray *array = dic[@"children"];
        NSDictionary *nextDic = array[indexPath.item];
        
        return nextDic[@"dept_name"];
    }
    
    if (indexPath.column == 0 && indexPath.row != WSNoFound && indexPath.item != WSNoFound && indexPath.rank != WSNoFound) {
        NSDictionary *dic = _dept_Array[indexPath.row];
        NSArray *array = dic[@"children"];
        NSDictionary *nextDic = array[indexPath.item];
        NSArray *nextArray = nextDic[@"children"];
        NSString *tmpStr = nextArray[indexPath.rank];
        NSArray *tmpArr = [tmpStr componentsSeparatedByString:@"-"];
        return tmpArr.lastObject;
        
    }
    return @" ";
}

#pragma mark - WSDropMenuView Delegate -

- (void)dropMenuView:(WSDropMenuView *)dropMenuView didSelectWithIndexPath:(WSIndexPath *)indexPath{
 
        //调用接口  获取数据
    NSDictionary *dic = _dept_Array[indexPath.row];
    NSArray *array = dic[@"children"];
    NSDictionary *nextDic = array[indexPath.item];
    NSArray *nextArray = nextDic[@"children"];
    NSString *tmpStr = nextArray[indexPath.rank];
    NSArray *tmpArr = [tmpStr componentsSeparatedByString:@"-"];
    _current_id  = tmpArr.firstObject;
    //调用接口数据(刷新接口)
    [self requestDate];
}

- (void)requestDate{
    NSLog(@"_current_id ＝ %@",_current_id);
    if (_current_id == nil) {
        [EBAlert alertError:@"部门的ID为空,请重新登录" length:2.0f];
        return;
    }
    //成交漏斗
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/HouseDeal/myFunnelData?token=%@&month=%@&depid=%@",[EBPreferences sharedInstance].token,_currentDate,_current_id]);
    NSString *urlStr = @"HouseDeal/myFunnelData";
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"month":_currentDate,
       @"depid":_current_id
       }success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           if ([currentDic[@"code"] integerValue] == 0) {

               NSDictionary *dic = currentDic[@"data"];//
               [self updateLable:dic];
           }else{
                 [EBAlert alertError:currentDic[@"desc"]];
           }
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请检查网络" length:2.0f];
       }];
}

- (void)updateLable:(NSDictionary *)dic{
    NSMutableArray *tmpArr = [NSMutableArray arrayWithObjects:dic[@"custom_add"], dic[@"visit_add"],dic[@"visit_percent"], dic[@"deal_num"],dic[@"deal_percent"], nil];
    if (_lableArray && _lableArray.count > 0) {
        for (int i = 0; i < _lableArray.count; i++) {
            id object = _lableArray[i];
            if ([object isKindOfClass:[UILabel class]]) {
                UILabel *lable = object;
                lable.text = tmpArr[i];
            }
        }
    }
}

#pragma mark 画不规则矩形(梯形)背景 部分尺寸大小可自行修改
- (void)drawBackViewWithView:(UIView *)view BackColor:(UIColor *) color LabelText:(NSString *)string withContentText:(NSString *)content
{
    CGSize finalSize = CGSizeMake(CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds));
    CGFloat layerHeight = finalSize.height;
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *bezier = [UIBezierPath bezierPath];
    
    [bezier moveToPoint:CGPointMake(0, finalSize.height - layerHeight)];
    [bezier addLineToPoint:CGPointMake(10, finalSize.height-1)];
    [bezier addLineToPoint:CGPointMake(finalSize.width - 10, finalSize.height - 1)];
    [bezier addLineToPoint:CGPointMake(finalSize.width, finalSize.height - layerHeight)];
    
    [bezier addLineToPoint:CGPointMake(0,0)];
    layer.path = bezier.CGPath;
    layer.fillColor = color.CGColor;
    [view.layer addSublayer:layer];
    UILabel *labe = [[UILabel alloc]initWithFrame:CGRectMake(0, (CGRectGetHeight(view.frame)-20)/2.0, CGRectGetWidth(view.bounds), 20)];
    labe.text = string;
    [_lableArray addObject:labe];
    labe.textColor = [UIColor whiteColor];
    labe.textAlignment = NSTextAlignmentCenter;
    labe.font = [UIFont systemFontOfSize:15];
    [view addSubview:labe];
    
    UILabel *labe1 = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(view.frame)+15, CGRectGetMidY(view.frame)-10,[self sizeToWith:Font content:content], 20)];
    labe1.text = content;
    labe1.textColor = UIColorFromRGB(0x808080);
    labe1.textAlignment = NSTextAlignmentCenter;
    labe1.font = Font;
    [self.view addSubview:labe1];
}

- (CGFloat)sizeToWith:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW-100,100);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.width;
}

@end
