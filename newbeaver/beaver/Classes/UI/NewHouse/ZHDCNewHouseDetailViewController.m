//
//  ZHDCNewHouseDetailViewController.m
//  beaver
//
//  Created by mac on 17/4/23.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ZHDCNewHouseDetailViewController.h"
#import "ZHDCDetailHeadView.h"
#import "ZHDCDetailTableViewCell.h"
#import "NewHouseListTableViewCell.h"
#import "ZHDCImageViewController.h"
#import "HWPopTool.h"
#import "HttpTool.h"
#import "EBAlert.h"
#import "EBPreferences.h"
#import "NewHouseListModel.h"
#import "HouseModelDetail.h"
#import "FSBasicImageSource.h"
#import "FSImageViewerViewController.h"
#import "FSBasicImage.h"
#import "SDAutoLayout.h"
#import "ZHDCDetailTableViewModel.h"
#import "UITableView+PlaceHolderView.h"
#import "DefaultView.h"
#import "AddView.h"

@interface ZHDCNewHouseDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ZHDCDetailImageClickDelegate>

@property (nonatomic,weak) AddView *popView;
@property (nonatomic,strong)AddView *backView;

@property (nonatomic, strong)NSArray *sectionTitles;
//轮播图
@property (nonatomic, strong)ZHDCDetailHeadView *detailHeadView;
@property (nonatomic, strong)UITableView *mainTableView;
//按钮
@property (nonatomic, strong)UIButton *add_button;//新增报备

//imgaes
@property (nonatomic, strong)NSMutableArray *house_images;//房源图片
@property (nonatomic, strong)NSMutableDictionary *Commissions;//佣金字典
@property (nonatomic, strong)NSMutableDictionary *others;//其他

@property (nonatomic, strong)NSMutableArray *otherArray;//楼盘卖点
@property (nonatomic, strong)NSMutableArray *otherHouses;//其他房源
@property (nonatomic, strong)NSString * news_trends;//最新动态

//uitextField
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *tel;
@property (weak, nonatomic) IBOutlet UITextView *content;
@property (weak, nonatomic) IBOutlet UILabel *start;
@property (weak, nonatomic) IBOutlet UILabel *end;

@property (nonatomic, strong) UIDatePicker *dataPicker;

@property (nonatomic, assign) NSInteger current;
@property (nonatomic, strong)NSDate *startDate;//开始日期
@property (nonatomic, strong)NSDate *endDate;//结束日期


@property (nonatomic, weak)UIView *containView;

@end

@implementation ZHDCNewHouseDetailViewController

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


- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-114) style:UITableViewStyleGrouped];
        _mainTableView.delegate = self;
        _mainTableView.estimatedRowHeight = 80;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.showsHorizontalScrollIndicator = NO;
        _mainTableView.showsVerticalScrollIndicator = NO;
        _mainTableView.tableHeaderView = self.detailHeadView;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _mainTableView;
}

- (ZHDCDetailHeadView *)detailHeadView{
    if (!_detailHeadView) {
        _detailHeadView = [[ZHDCDetailHeadView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 400)   ImageArray:_house_images
    andCommission:_Commissions
                  otherDic:_others];
        _detailHeadView.imageClickDelegate = self;
        _detailHeadView.backgroundColor = [UIColor whiteColor];
    }
    return _detailHeadView;
}

- (UIButton *)add_button{
    if (!_add_button) {
        _add_button = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 114, [UIScreen mainScreen].bounds.size.width, 50)];
        _add_button.backgroundColor = AppMainColor(1);
        [_add_button setTitle:@"新增报备" forState:UIControlStateNormal];
        [_add_button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _add_button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        [_add_button addTarget:self action:@selector(addTargetForButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _add_button;
}

#pragma mark 头视图
- (void)tableViewOfHeadView{
    [self.view addSubview:self.detailHeadView];
}

- (void)requestDatas{
    
   [EBAlert showLoading:@"加载中..."];
    
    NSLog(@"str=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/NewHouse/detail?token=%@&id=%@",[EBPreferences sharedInstance].token,_house_id]);

    [HttpTool post:@"NewHouse/detail" parameters:@{@"token":[EBPreferences sharedInstance].token,
        @"id":_house_id,
       } success:^(id responseObject) {

           [EBAlert hideLoading];
            NSDictionary *currentArray =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           NSDictionary *dic = currentArray[@"data"];
           _house_images = dic[@"imagelist"];
           //佣金
           [_Commissions setValue:dic[@"title"] forKey:@"title"];//房子名字
           NSLog(@"sale_status=%@",_sale_status);
           //图片sale_status
            [_Commissions setValue:_sale_status forKey:@"sale_status"];
           [_Commissions setValue:dic[@"commission_text"] forKey:@"commission_text"];//房子佣金
           [_Commissions setValue:dic[@"purpose"] forKey:@"purpose"];//房子类型
           //其他
            [_others setValue:dic[@"address"] forKey:@"address"];//地址
            [_others setValue:dic[@"primary_user_name"] forKey:@"primary_user_name"];//维护人
            [_others setValue:dic[@"primary_user_tel"] forKey:@"primary_user_tel"];//维护人电话
            [_others setValue:dic[@"start_date"] forKey:@"start_date"];//维护人电话
           //房源列表
           for (NSDictionary *dic1  in dic[@"houselist"]) {
               NewHouseListModel *model = [[NewHouseListModel alloc]initWithDict:dic1];
               [_otherHouses addObject:model];
           }
           //楼盘卖点
           NSString *unitPrice = [NSString stringWithFormat:@"%@元/m²",dic[@"unit_pay"]];
           NSString *area = [NSString stringWithFormat:@"%@-%@m²",dic[@"area_min"],dic[@"area_max"]];
   
           NSArray *tmp =@[@{@"leftType":@"均价",@"leftContent":unitPrice,@"rightType":@"面积",@"rightContent":area},
                           @{@"leftType":@"主力户型",@"leftContent":dic[@"main_house_type"],@"rightType":@"装修",@"rightContent":dic[@"decoration"]},
                           @{@"leftType":@"开发商",@"leftContent":dic[@"developer"],@"rightType":@"物业公司",@"rightContent":dic[@"property"]},
                           @{@"leftType":@"开盘日期",@"leftContent":dic[@"open_date"],@"rightType":@"交房日期",@"rightContent":dic[@"out_date"]}];
           _otherArray = [NSMutableArray array];
           for (NSDictionary *dic in tmp) {
               ZHDCDetailTableViewModel *model = [[ZHDCDetailTableViewModel alloc]initWithDict:dic];
               [_otherArray addObject:model];
           }
           //最新动态
           _news_trends = dic[@"new_trends"];
             [self.view addSubview:self.mainTableView];
           [_mainTableView registerClass:[ZHDCDetailTableViewCell class] forCellReuseIdentifier:@"cell"];
           [_mainTableView registerClass:[NewHouseListTableViewCell class] forCellReuseIdentifier:@"newCell"];
           
           
        } failure:^(NSError *error) {
            [EBAlert hideLoading];
            [EBAlert alertError:@"请检查网络" length:2.0f];
        }];

}

#pragma mark -- LIFE
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //初始化
    _house_images = [NSMutableArray array];
    _Commissions = [NSMutableDictionary dictionary];
    _others = [NSMutableDictionary dictionary];
    _otherHouses = [NSMutableArray array];
    self.title = @"新房详情";
    [self requestDatas];
    _sectionTitles = @[@"楼盘卖点",@"推荐楼盘"];
    
     [self.view addSubview:self.add_button];
  
}



#pragma mark -- Action Method
//提交方法
- (IBAction)updata:(id)sender {
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
    [[HWPopTool sharedInstance]closeWithBlcok:^{
        NSLog(@"关闭");
        _name.text = @"";
        _tel.text = @"";
        _content.text = @"";
        _start.text = @"";
        _end.text = @"";
    }];
    
    [self reportAdd];
}

#pragma mark -- 时间转时间戳
- (NSTimeInterval)timeIntervalWithTimeString:(NSString *)timeString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    NSDate *date = [dateFormatter dateFromString:timeString];
    NSTimeInterval interval = (long)[date timeIntervalSince1970];
    return interval;
}

- (void)reportAdd{
    NSLog(@"http://218.65.86.83:8010/newHouse/reportAdd?token=%@&new_house_id=%@&custom_name=%@&custom_phone=%@&new_house_title=%@&custom_remarks=%@&visit_start=%@&visit_end=%@",[EBPreferences sharedInstance].token,_house_id,_name.text,_tel.text,_house_title,_content.text,[NSNumber numberWithDouble:[self timeIntervalWithTimeString:_start.text]],[NSNumber numberWithDouble:[self timeIntervalWithTimeString:_end.text]]);
    [EBAlert showLoading:@"添加中" allowUserInteraction:NO];
    [HttpTool post:@"newHouse/reportAdd" parameters:@{
        @"token":[EBPreferences sharedInstance].token,
        @"new_house_id":_house_id,
        @"custom_name":_name.text,
        @"custom_phone":_tel.text,
        @"new_house_title":_house_title,
        @"custom_remarks":_content.text,
        @"visit_start":[NSNumber numberWithDouble:[self timeIntervalWithTimeString:_start.text]],
        @"visit_end":[NSNumber numberWithDouble:[self timeIntervalWithTimeString:_end.text]]
    } success:^(id responseObject) {
        [EBAlert hideLoading];
        NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
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

//取消
- (IBAction)close:(id)sender {
    [[HWPopTool sharedInstance]closeWithBlcok:^{
        NSLog(@"关闭");
    }];
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

-(AddView *)backView{
    if (!_backView) {
        _backView = [[AddView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH)];
        self.popView = _backView;
        UIView* view = [[[NSBundle mainBundle]loadNibNamed:@"AddView" owner:self options:nil]lastObject];
        _containView = view;
        view.clipsToBounds = YES;
        view.center  =_backView.center;
        view.layer.cornerRadius = 5.0f;
        
        [_backView addSubview:view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeDatapicker:)];
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tap];
        
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
        
        

    }
    return _backView;
}

- (void)addTargetForButton:(id)sender {
    
    [[HWPopTool sharedInstance]showWithPresentView:self.backView animated:YES];
    [[HWPopTool sharedInstance].getMainController.view addSubview:self.dataPicker];
    [[HWPopTool sharedInstance].getMainController.view bringSubviewToFront:_dataPicker];
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

#pragma mark -- Method
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

#pragma mark -- DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return _otherArray.count;
    }else{
      return _otherHouses.count;
    }
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ZHDCDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.tag = indexPath.row;
        ZHDCDetailTableViewModel *model = _otherArray[indexPath.row];
        [cell setModel:model];
        return cell;
    }else{
        NewHouseListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newCell" forIndexPath:indexPath];
        NewHouseListModel *model = _otherHouses[indexPath.row];
        [cell setModel:model];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        return 124;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ZHDCDetailTableViewModel *model = _otherArray[indexPath.row];
        return [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[ZHDCDetailTableViewCell class] contentViewWidth:kScreenW];
    }else{
        return 140;
    }
}

//section head
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 50)];
    UIView *startLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
    startLine.backgroundColor =  ContentColor;
    [view addSubview:startLine];
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 200, 30)];
    lable.font = TitleFont;
    lable.textAlignment = NSTextAlignmentLeft;
    lable.text = _sectionTitles[section];
    [view addSubview:lable];
    UIView *endline = [[UIView alloc]initWithFrame:CGRectMake(0, 49, kScreenW, 1)];
    endline.backgroundColor =  ContentColor;
    [view addSubview:endline];
    return view;
}

- (CGFloat)sizeToHeight:(UIFont *)font content:(NSString *)content{
    CGSize size = CGSizeMake(kScreenW,MAXFLOAT);
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize  actualsize =[content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;;
    return actualsize.height;
}

//section Foot
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 120)];
        view.backgroundColor = [UIColor whiteColor];
        UIView *firstView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 10)];
        firstView.backgroundColor =  ContentColor;
        [view addSubview:firstView];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(firstView.frame)+10, kScreenW, 30)];
        lable.text = @"最新动态";
        lable.font = TitleFont;
        lable.textColor = TitleColor;
        [view addSubview:lable];
        UILabel *content = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(lable.frame)+4, kScreenW-40, 50)];
        content.numberOfLines = 0;
        if (_news_trends.length == 0) {
            _news_trends = @"暂无最新动态";
        }
        content.text = _news_trends;
        content.font = ContentFont;
         [view addSubview:content];
        UIView *secondView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(content.frame)+10, kScreenW, 10)];
        secondView.backgroundColor =  ContentColor;
        view.height = CGRectGetMaxY(secondView.frame);
        [view addSubview:secondView];
        return view;
    }
    return nil;
}
#pragma mark -- Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        NewHouseListModel *model = _otherHouses[indexPath.row];
        //进入详情控制器
        ZHDCNewHouseDetailViewController *detailVC = [[ZHDCNewHouseDetailViewController alloc]init];
        detailVC.house_id =  model.house_id;
        detailVC.house_title = model.house_name;
        detailVC.sale_status = model.sale_status;
        [self.navigationController pushViewController:detailVC animated:YES];
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

#pragma mark -- ZHDCDetailImageClickDelegate

- (void)image:(UIImageView *)imageView imageTitle:(NSString *)imageTitle images:(NSArray *)images{
    //进入新的图片控制器
     NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (NSString *str  in self.house_images)
    {
        [photos addObject:[[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:str] name:nil]];
    }
    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:photos];
    FSImageViewerViewController *controller = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:imageView.tag];
    controller.fixTitle = @"图片详情";
    [self.navigationController pushViewController:controller animated:YES];
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
