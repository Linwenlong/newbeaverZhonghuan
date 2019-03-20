//
//  SubmitDailyViewController.m
//  beaver
//
//  Created by mac on 17/8/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "SubmitDailyViewController.h"

@interface SubmitDailyViewController ()

@property (weak, nonatomic) IBOutlet UILabel *add_house_title;//新增房源
@property (weak, nonatomic) IBOutlet UILabel *add_client_title;//新增客源
@property (weak, nonatomic) IBOutlet UILabel *see_title;//带看
@property (weak, nonatomic) IBOutlet UILabel *follow_title;//跟进
@property (weak, nonatomic) IBOutlet UILabel *phone_title;//取电
@property (weak, nonatomic) IBOutlet UILabel *myDay_title;//今日心得

//新增房源(类型)
@property (weak, nonatomic) IBOutlet UILabel *house_sale_type;
@property (weak, nonatomic) IBOutlet UILabel *house_rent_type;
@property (weak, nonatomic) IBOutlet UILabel *house_salerent_type;
//新增房源(数据)
@property (weak, nonatomic) IBOutlet UILabel *house_sale_num;
@property (weak, nonatomic) IBOutlet UILabel *house_rent_num;
@property (weak, nonatomic) IBOutlet UILabel *house_salerent_num;

//新增客源(类型)
@property (weak, nonatomic) IBOutlet UILabel *client_sale_type;
@property (weak, nonatomic) IBOutlet UILabel *client_rent_type;
//新增客源(数据)
@property (weak, nonatomic) IBOutlet UILabel *client_sale_num;
@property (weak, nonatomic) IBOutlet UILabel *client_rent_num;

//带看(类型)
@property (weak, nonatomic) IBOutlet UILabel *see_sale_type;
@property (weak, nonatomic) IBOutlet UILabel *see_rent_type;
//带看(数据)
@property (weak, nonatomic) IBOutlet UILabel *see_sale_num;
@property (weak, nonatomic) IBOutlet UILabel *see_rent_num;

//跟进(类型)
@property (weak, nonatomic) IBOutlet UILabel *follow_sale_type;
@property (weak, nonatomic) IBOutlet UILabel *follow_rent_type;
@property (weak, nonatomic) IBOutlet UILabel *follow_house_type;
@property (weak, nonatomic) IBOutlet UILabel *reconnoitre_house_type;
//跟进(数据)
@property (weak, nonatomic) IBOutlet UILabel *follow_sale_num;
@property (weak, nonatomic) IBOutlet UILabel *follow_rent_num;
@property (weak, nonatomic) IBOutlet UILabel *follow_house_num;
@property (weak, nonatomic) IBOutlet UILabel *reconnoitre_house_num;

//取电(类型)
@property (weak, nonatomic) IBOutlet UILabel *phone_house_type;
@property (weak, nonatomic) IBOutlet UILabel *phone_sale_type;
@property (weak, nonatomic) IBOutlet UILabel *phone_rent_type;
//取电(数据)
@property (weak, nonatomic) IBOutlet UILabel *phone_house_num;
@property (weak, nonatomic) IBOutlet UILabel *phone_sale_num;
@property (weak, nonatomic) IBOutlet UILabel *phone_rent_num;

//小线条
@property (weak, nonatomic) IBOutlet UIView *small_line1;
@property (weak, nonatomic) IBOutlet UIView *small_line2;
@property (weak, nonatomic) IBOutlet UIView *small_line3;
@property (weak, nonatomic) IBOutlet UIView *small_line4;
@property (weak, nonatomic) IBOutlet UIView *small_line5;

//今日心得
@property (weak, nonatomic) IBOutlet UITextView *mainTextView;

//粗线条
@property (weak, nonatomic) IBOutlet UIView *bigline1;
@property (weak, nonatomic) IBOutlet UIView *bigline2;
@property (weak, nonatomic) IBOutlet UIView *bigline3;
@property (weak, nonatomic) IBOutlet UIView *bigline4;
@property (weak, nonatomic) IBOutlet UIView *bigline5;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *document_id;
@property (nonatomic, assign) BOOL is_Dataload;

@end
//文字字体
#define TITLE_FONT [UIFont systemFontOfSize:13.0f]
#define CONTENT_FONT [UIFont systemFontOfSize:12.0f]

//文字颜色
#define TITLE_COLOR UIColorFromRGB(0x404040)
#define TYPE_COLOR UIColorFromRGB(0x808080)
#define NUM_COLOR UIColorFromRGB(0xff3800)

//背景
#define SMALL_COLOR [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00]
#define BIG_COLOR [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00]

@implementation SubmitDailyViewController

- (void)setUI{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];
    UIView *view = [[NSBundle mainBundle] loadNibNamed:@"SubmitDailyView" owner:self options:nil].firstObject;
 
    view.width = kScreenW;
    scrollView.contentSize = CGSizeMake(0, view.height + 64);
    [scrollView addSubview:view];

    [self setColorAndFont];
    
}





-(void)requestData{
    //日报详情
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Daily/myDaily?token=%@",[EBPreferences sharedInstance].token]);
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:@"Daily/myDaily" parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       }success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           if ([currentDic[@"code"] integerValue] == 0) {
               NSDictionary *dic = currentDic[@"data"];//
               [self updateLable:dic];
           }else{
               [EBAlert alertError:@"请您先登录ERP产生日报"];
           }
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请检查网络" length:2.0f];
       }];
}

- (void)submit{
  
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Daily/dailySave?token=%@&document_id=%@&comment=%@",[EBPreferences sharedInstance].token,_document_id,_mainTextView.text]);
    
    if (_is_Dataload == NO) {
        [EBAlert alertError:@"数据请求失败,无法提交" length:2.0];
        return;
    }
    //解决document_id 为 (null)
    if (_document_id == nil) {
        [EBAlert alertError:@"详情数据请求失败,无法提交" length:2.0];
        return;
    }
    if (_mainTextView.text.length<=0) {
         [EBAlert alertError:@"请输入心得内容" length:2.0];
        return;
    }
    
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
     NSString *urlStr = @"Daily/dailySave";
    [HttpTool post:urlStr parameters:
     @{  @"token":[EBPreferences sharedInstance].token,
            @"document_id":_document_id,
            @"comment":_mainTextView.text
       }success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           if ([currentDic[@"code"] integerValue] == 0) {
               _status = @"已上报";
               [EBAlert alertSuccess:@"提交成功" length:2.0f];
               [self.navigationController popViewControllerAnimated:YES];
           }else{
               [EBAlert alertSuccess:@"提交失败" length:2.0f];
           }
           
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请检查网络" length:2.0f];
       }];

}

//提交日报
- (void)submitDaily:(id)sender{
    //提交
    NSLog(@"提交日报");
    if ([_status isEqualToString:@"已上报"]) {
        [EBAlert alertError:@"已上报,请勿多次提交" length:2.0f];
    }else{
        [self submit];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    _is_Dataload = YES;
     self.title  = @"提交日报";
    [self requestData];
    [self addRightNavigationBtnWithTitle:@"提交" target:self action:@selector(submitDaily:)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


- (void)setColorAndFont{
    
    _add_house_title.font = TITLE_FONT;
    _add_house_title.textColor = TITLE_COLOR;
    _add_client_title.font = TITLE_FONT;
    _add_client_title.textColor = TITLE_COLOR;
    _see_title.font = TITLE_FONT;
    _see_title.textColor = TITLE_COLOR;
    _follow_title.font = TITLE_FONT;
    _follow_title.textColor = TITLE_COLOR;
    _phone_title.font = TITLE_FONT;
    _phone_title.textColor = TITLE_COLOR;
    _myDay_title.font = TITLE_FONT;
    _myDay_title.textColor = TITLE_COLOR;
    
    _house_sale_type.textColor = TYPE_COLOR;
    _house_sale_type.font  = CONTENT_FONT;
    _house_rent_type.textColor = TYPE_COLOR;
    _house_rent_type.font  = CONTENT_FONT;
    _house_salerent_type.textColor = TYPE_COLOR;
    _house_salerent_type.font  = CONTENT_FONT;
  
    _client_sale_type.textColor = TYPE_COLOR;
    _client_sale_type.font  = CONTENT_FONT;
    _client_rent_type.textColor = TYPE_COLOR;
    _client_rent_type.font  = CONTENT_FONT;
    
    _see_sale_type.textColor = TYPE_COLOR;
    _see_sale_type.font  = CONTENT_FONT;
    _see_rent_type.textColor = TYPE_COLOR;
    _see_rent_type.font  = CONTENT_FONT;

    _follow_sale_type.textColor = TYPE_COLOR;
    _follow_sale_type.font  = CONTENT_FONT;
    _follow_rent_type.textColor = TYPE_COLOR;
    _follow_rent_type.font  = CONTENT_FONT;
    _follow_house_type.textColor = TYPE_COLOR;
    _follow_house_type.font  = CONTENT_FONT;
    _reconnoitre_house_type.textColor = TYPE_COLOR;
    _reconnoitre_house_type.font  = CONTENT_FONT;
    
    _phone_house_type.textColor = TYPE_COLOR;
    _phone_house_type.font  = CONTENT_FONT;
    _phone_sale_type.textColor = TYPE_COLOR;
    _phone_sale_type.font  = CONTENT_FONT;
    _phone_rent_type.textColor = TYPE_COLOR;
    _phone_rent_type.font  = CONTENT_FONT;

    _house_sale_num.textColor = NUM_COLOR;
    _house_sale_num.font = CONTENT_FONT;
    _house_rent_num.textColor = NUM_COLOR;
    _house_rent_num.font = CONTENT_FONT;
    _house_salerent_num.textColor = NUM_COLOR;
    _house_salerent_num.font = CONTENT_FONT;
    
    _client_sale_num.textColor = NUM_COLOR;
    _client_sale_num.font  = CONTENT_FONT;
    _client_rent_num.textColor = NUM_COLOR;
    _client_rent_num.font  = CONTENT_FONT;
    
    _see_sale_num.textColor = NUM_COLOR;
    _see_sale_num.font  = CONTENT_FONT;
    _see_rent_num.textColor = NUM_COLOR;
    _see_rent_num.font  = CONTENT_FONT;
    
    _follow_sale_num.textColor = NUM_COLOR;
    _follow_sale_num.font  = CONTENT_FONT;
    _follow_rent_num.textColor = NUM_COLOR;
    _follow_rent_num.font  = CONTENT_FONT;
    _follow_house_num.textColor = NUM_COLOR;
    _follow_house_num.font  = CONTENT_FONT;
    _reconnoitre_house_num.textColor = NUM_COLOR;
    _reconnoitre_house_num.font  = CONTENT_FONT;
    
    _phone_house_num.textColor = NUM_COLOR;
    _phone_house_num.font  = CONTENT_FONT;
    _phone_sale_num.textColor = NUM_COLOR;
    _phone_sale_num.font  = CONTENT_FONT;
    _phone_rent_num.textColor = NUM_COLOR;
    _phone_rent_num.font  = CONTENT_FONT;
    
    _small_line1.backgroundColor = SMALL_COLOR;
     _small_line2.backgroundColor = SMALL_COLOR;
     _small_line3.backgroundColor = SMALL_COLOR;
     _small_line4.backgroundColor = SMALL_COLOR;
     _small_line5.backgroundColor = SMALL_COLOR;
    
    _bigline1.backgroundColor = BIG_COLOR;
    _bigline2.backgroundColor = BIG_COLOR;
    _bigline3.backgroundColor = BIG_COLOR;
    _bigline4.backgroundColor = BIG_COLOR;
    _bigline5.backgroundColor = BIG_COLOR;
    
    _mainTextView.layer.borderColor = SMALL_COLOR.CGColor;
    _mainTextView.layer.borderWidth = 1.0f;
}

- (void)updateLable:(NSDictionary *)dic{
    
    NSArray *houseArray = @[_house_sale_num,_house_rent_num,_house_salerent_num];
    NSArray *clientArray = @[_client_sale_num,_client_rent_num];
    NSArray *seeArray = @[_see_sale_num,_see_rent_num];
    NSArray *followArray = @[_follow_sale_num,_follow_rent_num,_follow_house_num,_reconnoitre_house_num];
    NSArray *iphoneArray = @[_phone_house_num,_phone_sale_num,_phone_rent_num];
    //闪退解决
    if (![dic[@"data"] isKindOfClass:[NSDictionary class]]) {
        [EBAlert alertError:@"您无提交日报的权限" length:2.0f];
        return;
    }
    
    NSDictionary *data = dic[@"data"];
    
    _document_id = data[@"document_id"];
    if ([data[@"status"] isEqualToString:@"已上报"]) {
        _mainTextView.text = data[@"comment"];
        _status = data[@"status"];
        _mainTextView.editable = NO;
    }
    
    NSDictionary *realTimeReport = dic[@"realTimeReport"];
    
    //房源新增
    NSDictionary *dic1 = realTimeReport[@"1"];
    NSArray *arr1 = dic1[@"sub"];
    for (int i = 0; i < arr1.count; i++) {
        NSDictionary *tmpdic = arr1[i];
        UILabel *lable = (UILabel *)houseArray[i];
        lable.text = [NSString stringWithFormat:@"%@",tmpdic[@"value"]];
    }
    
    //客源
    NSDictionary *dic2 = realTimeReport[@"2"];
    NSArray *arr2 = dic2[@"sub"];
    for (int i = 0; i < arr2.count; i++) {
        NSDictionary *tmpdic = arr2[i];
        UILabel *lable = (UILabel *)clientArray[i];
        lable.text = [NSString stringWithFormat:@"%@",tmpdic[@"value"]];
    }
    //带看
    NSDictionary *dic3 = realTimeReport[@"3"];
    NSArray *arr3 = dic3[@"sub"];
    for (int i = 0; i < arr3.count; i++) {
        NSDictionary *tmpdic = arr3[i];
        UILabel *lable = (UILabel *)seeArray[i];
        lable.text = [NSString stringWithFormat:@"%@",tmpdic[@"value"]];
    }
    //跟进
    NSDictionary *dic4 = realTimeReport[@"4"];
    NSArray *arr4 = dic4[@"sub"];
    for (int i = 0; i < arr4.count; i++) {
        NSDictionary *tmpdic = arr4[i];
        UILabel *lable = (UILabel *)followArray[i];
        lable.text = [NSString stringWithFormat:@"%@",tmpdic[@"value"]];
    }
    //房源新增
    NSDictionary *dic5 = realTimeReport[@"5"];
    NSArray *arr5 = dic5[@"sub"];
    for (int i = 0; i < arr5.count; i++) {
        NSDictionary *tmpdic = arr5[i];
        UILabel *lable = (UILabel *)iphoneArray[i];
        lable.text = [NSString stringWithFormat:@"%@",tmpdic[@"value"]];
    }
}
@end
