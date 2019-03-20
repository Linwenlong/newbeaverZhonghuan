//
//  ZHAreaManagerController.m
//  中环经纪人助手-工作总结
//
//  Created by 刘海伟 on 2018/1/22.
//  Copyright © 2018年 liuhaiwei. All rights reserved.
//
//  工作总结-区域经理模块

#import "ZHAreaManagerController.h"
#import "AnnotateView.h"
#import "LSXAlertInputView.h"

@interface ZHAreaManagerController ()<UITextViewDelegate>

@property (nonatomic, strong)ValuePickerView *pickerView;

@property (weak, nonatomic) IBOutlet UILabel *TwoCont114_tip;
@property (weak, nonatomic) IBOutlet UILabel *TwoCont27_tip;
@property (weak, nonatomic) IBOutlet UILabel *TwoCont29_tip;
@property (weak, nonatomic) IBOutlet UILabel *ThreeCont12_tip;
@property (weak, nonatomic) IBOutlet UILabel *ThreeCont22_tip;
@property (weak, nonatomic) IBOutlet UILabel *FourCont1_tip;
@property (weak, nonatomic) IBOutlet UILabel *FourCont2_tip;
@property (weak, nonatomic) IBOutlet UILabel *FourCont3_tip;
@property (weak, nonatomic) IBOutlet UILabel *FourCont4_tip;
@property (weak, nonatomic) IBOutlet UILabel *FourCont5_tip;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerView_h;
@property (weak, nonatomic) IBOutlet UITextField *threeSixFive;
@property (weak, nonatomic) IBOutlet UITextField *taiwuliao;
@property (weak, nonatomic) IBOutlet UITextField *dibao;
@property (weak, nonatomic) IBOutlet UITextField *ganji;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (nonatomic, strong)UIView *annotateCommentView;//批注点评
@property (nonatomic, strong)AnnotateView *annotateView;
@property (nonatomic, strong)AnnotateView *commentView;

@property (nonatomic, weak)UIButton * annotate;
@property (nonatomic, weak)UIButton * comment;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *add_button_y;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vHeight;
@property (weak, nonatomic) IBOutlet UIView *bgView;
/** 第一部分 标题栏 */
@property (weak, nonatomic) IBOutlet UITextField *oneCont1;
@property (weak, nonatomic) IBOutlet UIButton *oneCont2;

/** 第二部分 数据汇报 */
@property (weak, nonatomic) IBOutlet UITextField *twoCont11; //区域数据
@property (weak, nonatomic) IBOutlet UITextField *twoCont12;
@property (weak, nonatomic) IBOutlet UITextField *twoCont13;
@property (weak, nonatomic) IBOutlet UITextField *twoCont14;
@property (weak, nonatomic) IBOutlet UITextField *twoCont15;
@property (weak, nonatomic) IBOutlet UITextField *twoCont16;
@property (weak, nonatomic) IBOutlet UITextField *twoCont17;
@property (weak, nonatomic) IBOutlet UITextField *twoCont18;
@property (weak, nonatomic) IBOutlet UITextField *twoCont19;
@property (weak, nonatomic) IBOutlet UITextField *twoCont110;
@property (weak, nonatomic) IBOutlet UITextField *twoCont111;
@property (weak, nonatomic) IBOutlet UITextField *twoCont112;
@property (weak, nonatomic) IBOutlet UITextField *twoCont113;
@property (weak, nonatomic) IBOutlet UITextView *twoCont114;

@property (weak, nonatomic) IBOutlet UITextField *twoCont21; //本月破零率
@property (weak, nonatomic) IBOutlet UITextField *twoCont22;
@property (weak, nonatomic) IBOutlet UITextField *twoCont23;
@property (weak, nonatomic) IBOutlet UITextField *twoCont24;
@property (weak, nonatomic) IBOutlet UITextField *twoCont25;
@property (weak, nonatomic) IBOutlet UITextField *twoCont26;
@property (weak, nonatomic) IBOutlet UITextView *twoCont27;
@property (weak, nonatomic) IBOutlet UITextField *twoCont28;
@property (weak, nonatomic) IBOutlet UITextView *twoCont29;

@property (weak, nonatomic) IBOutlet UITextField *twoCont31; //三源统计
@property (weak, nonatomic) IBOutlet UITextField *twoCont32;
@property (weak, nonatomic) IBOutlet UITextField *twoCont33;
@property (weak, nonatomic) IBOutlet UITextField *twoCont34;
@property (weak, nonatomic) IBOutlet UITextField *twoCont35;
@property (weak, nonatomic) IBOutlet UITextField *twoCont36;
@property (weak, nonatomic) IBOutlet UITextField *twoCont37;
@property (weak, nonatomic) IBOutlet UITextField *twoCont38;
@property (weak, nonatomic) IBOutlet UITextField *twoCont39;
@property (weak, nonatomic) IBOutlet UITextField *twoCont310;
@property (weak, nonatomic) IBOutlet UITextField *twoCont311;
@property (weak, nonatomic) IBOutlet UITextField *twoCont312;
@property (weak, nonatomic) IBOutlet UITextField *twoCont313;
@property (weak, nonatomic) IBOutlet UITextField *twoCont314;
@property (weak, nonatomic) IBOutlet UITextField *twoCont315;
@property (weak, nonatomic) IBOutlet UITextField *twoCont316;
@property (weak, nonatomic) IBOutlet UITextField *twoCont317;
@property (weak, nonatomic) IBOutlet UITextField *twoCont318;
@property (weak, nonatomic) IBOutlet UITextField *twoCont319;
@property (weak, nonatomic) IBOutlet UITextField *twoCont320;

/** 第三部分 意向单 */
@property (weak, nonatomic) IBOutlet UITextField *threeCont11; //明日意向单
@property (weak, nonatomic) IBOutlet UITextView *threeCont12;
@property (weak, nonatomic) IBOutlet UITextField *threeCont21; //今日意向单
@property (weak, nonatomic) IBOutlet UITextView *threeCont22;

/** 第四部分 其他 */
@property (weak, nonatomic) IBOutlet UITextView *fourCont1; //今日检查工作
@property (weak, nonatomic) IBOutlet UITextView *fourCont2; //今日其他工作
@property (weak, nonatomic) IBOutlet UITextView *fourCont3; //明日工作安排
@property (weak, nonatomic) IBOutlet UITextView *fourCont4; //今日感悟
@property (weak, nonatomic) IBOutlet UITextView *fourCont5; //建议意见

@property (nonatomic, strong)UIButton *add_button;//新增


@end

#define count 1000

@implementation ZHAreaManagerController


- (AnnotateView *)commentView{
    if (!_commentView) {
        _commentView = [[AnnotateView alloc]initWithFrame:CGRectMake(0, self.footerView_h.constant-self.submitBtn.height, kScreenW, 180)];
        NSLog(@"_commentView=%@",_commentView);
        _commentView.title.text = @"点评";
    }
    return _commentView;
}

- (AnnotateView *)annotateView{
    if (!_annotateView) {
        _annotateView = [[AnnotateView alloc]initWithFrame:CGRectMake(0, self.footerView_h.constant-self.submitBtn.height, kScreenW, 180)];
        NSLog(@"_annotateView=%@",_annotateView);
        _annotateView.title.text = @"批注";;
    }
    return _annotateView;
}

- (UIView *)annotateCommentView{
    if (!_annotateCommentView) {
        _annotateCommentView = [[UIButton alloc]initWithFrame:CGRectMake(0, kScreenH - 114, kScreenW, 50)];
        _annotateCommentView.hidden = YES;
        _annotateCommentView.backgroundColor = [UIColor whiteColor];
        UIButton *annotate = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenW/2.0f, _annotateCommentView.height)];
        self.annotate = annotate;
        self.annotate.hidden = YES;
        annotate.backgroundColor = LWL_GreenColor;
        [annotate setTitle:@"批注" forState:UIControlStateNormal];
        [annotate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [annotate addTarget:self action:@selector(annotate:) forControlEvents:UIControlEventTouchUpInside];
        UIButton *comment = [[UIButton alloc]initWithFrame:CGRectMake(kScreenW/2.0f, 0, kScreenW/2.0f, _annotateCommentView.height)];
        self.comment = comment;
        self.comment.hidden = YES;
        comment.backgroundColor = LWL_RedColor;
        [comment setTitle:@"点评" forState:UIControlStateNormal];
        [comment addTarget:self action:@selector(comment:) forControlEvents:UIControlEventTouchUpInside];
        [comment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_annotateCommentView addSubview:annotate];
        [_annotateCommentView addSubview:comment];
        
        
    }
    return _annotateCommentView;
}

-(void)addComment:(NSDictionary *)dic{
    //批注
    CGFloat height = 180;
    
    [self.footerView addSubview:self.annotateView];
    _annotateView.mainTextView.text = [dic[@"opinion"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    //    self.footerView.height += height;
    self.footerView_h.constant += height;
    NSLog(@"self.bgView.height=%f",self.bgView.height);
    NSLog(@"self.bgView.height=%f",self.bgView.height);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.add_button_y.constant += height;
    }];
    
    [self.footerView addSubview:self.commentView];
    
    _commentView.mainTextView.text = [dic[@"comment"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    //    self.footerView.height += height;
    self.footerView_h.constant += height;
    NSLog(@"self.bgView.height=%f",self.bgView.height);
    NSLog(@"self.bgView.height=%f",self.bgView.height);
    [UIView animateWithDuration:0.5f animations:^{
        self.add_button_y.constant += height;
    }];
    self.footerView_h.constant += 100;
    self.scrollView.contentSize = CGSizeMake(kScreenW, self.scrollView.contentSize.height + 460);
    
    self.vHeight.constant += 460;
}

- (void)resetEditData:(NSDictionary *)dic{;
    // 必填
    _oneCont1.text = dic[@"title"];
    _oneCont2.titleLabel.text = dic[@"type"];
    
    _twoCont11.text = dic[@"regional_stores"];
    _twoCont12.text = dic[@"regional_personnel"];
    _twoCont13.text = dic[@"not_on_duty_manager"];
    _twoCont14.text = dic[@"port_total"];
    _twoCont15.text = dic[@"58_port"];
    _twoCont16.text = dic[@"ajk_port"];
    _twoCont17.text = dic[@"sf_port"];

    _threeSixFive.text = dic[@"365_port"];
    _taiwuliao.text = dic[@"twl_port"];
    _dibao.text = dic[@"dibao_port"];
    _ganji.text = dic[@"gj_port"];
    
    _twoCont18.text = dic[@"goal_month"];
    _twoCont19.text = dic[@"truly_month"];
    
    float totle_count = [_twoCont19.text floatValue]/[_twoCont18.text floatValue]*100;
    _twoCont110.text = [NSString stringWithFormat:@"%.02f%@",totle_count,@"%"];
    
    _twoCont111.text = dic[@"old_house"];
    _twoCont112.text = dic[@"new_house"];
    _twoCont113.text = dic[@"zero_stores"];
    
    _twoCont114.text = [dic[@"zero_stores_list"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    
    _TwoCont114_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_twoCont114.text.length,count];

    _twoCont21.text = dic[@"break_zero_rate_month"];
    _twoCont22.text = dic[@"signature_today"];
    _twoCont23.text = dic[@"signature_old_house"];
    _twoCont24.text = dic[@"signature_new_house"];
    _twoCont25.text = dic[@"bill_stores_avg_month"];
    _twoCont26.text = dic[@"go_stores_today"];
    _twoCont27.text = [dic[@"go_stores_list"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _TwoCont27_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_twoCont27.text.length,count];
    _twoCont28.text = dic[@"new_talk"];
    _twoCont29.text = [dic[@"new_talk_list"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _TwoCont29_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_twoCont29.text.length,count];
    

    _threeCont11.text = dic[@"wish_bill_tomorrow"];
    _threeCont12.text = [dic[@"wish_bill_tomorrow_list"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
     _ThreeCont12_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_threeCont12.text.length,count];
    _threeCont21.text = dic[@"not_complete_bill_today"];
    _threeCont22.text = [dic[@"not_complete_bill_today_list"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _ThreeCont22_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_threeCont22.text.length,count];
    
    _fourCont1.text = [dic[@"work_check"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _FourCont1_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_fourCont1.text.length,count];
    _fourCont2.text = [dic[@"work_other"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _FourCont2_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_fourCont2.text.length,count];
    _fourCont3.text = [dic[@"plans"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _FourCont3_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_fourCont3.text.length,count];
    _fourCont4.text = [dic[@"getting"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _FourCont4_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_fourCont4.text.length,count];
    _fourCont5.text = [dic[@"advices"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _FourCont5_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_fourCont5.text.length,count];
 
    _oneCont1.text = dic[@"title"];
    //权限
    if ([dic[@"can_edit"] intValue] == 1) {
        _submitBtn.hidden = NO;
    }
    if ([dic[@"can_opinion"] intValue] == 1) {
        self.annotate.hidden = NO;
        _annotateCommentView.hidden = NO;
        if ([dic[@"can_comment"] intValue] == 0) {
            self.annotate.frame = CGRectMake(0, 0, kScreenW, 50);
        }
    }
    if ([dic[@"can_comment"] intValue] == 1) {
        self.comment.hidden = NO;
        _annotateCommentView.hidden = NO;
        if ([dic[@"can_opinion"] intValue] == 0) {
            self.comment.frame = CGRectMake(0, 0, kScreenW, 50);
        }
    }
    
    
}


//新增和编辑
- (void)resetAddData:(NSDictionary *)dayData month:(NSDictionary *)monthData{
    _twoCont31.text = dayData[@"clientCount"];
    _twoCont33.text = dayData[@"houseCount"];
    _twoCont35.text = dayData[@"followCount"];
    _twoCont37.text = dayData[@"surveyCount"];
    _twoCont39.text = dayData[@"entrustCount"];
    _twoCont311.text = dayData[@"exclusiveCount"];
    _twoCont313.text = dayData[@"focusCount"];
    _twoCont315.text = dayData[@"keyCount"];
    _twoCont317.text = dayData[@"salePriceCount"];
    
    _twoCont32.text = monthData[@"clientCount"];
    _twoCont34.text = monthData[@"houseCount"];
    _twoCont36.text = monthData[@"followCount"];
    _twoCont38.text = monthData[@"surveyCount"];
    _twoCont310.text = monthData[@"entrustCount"];
    _twoCont312.text = monthData[@"exclusiveCount"];
    _twoCont314.text = monthData[@"focusCount"];
    _twoCont316.text = monthData[@"keyCount"];
    _twoCont318.text = monthData[@"salePriceCount"];
    //标题
    if (self.VcTag == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
        _oneCont1.text = [NSString stringWithFormat:@"%@-%@工作总结【%@】",[EBPreferences sharedInstance].dept_name,[EBPreferences sharedInstance].userName,currentDateStr];
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"区域经理的工作总结";
    self.view.backgroundColor = UIColorFromRGB(0xEBEBEB);
    self.bgView.backgroundColor = UIColorFromRGB(0xEBEBEB);
    self.vWidth.constant = kScreenW;
  
    self.vHeight.constant = 3116;
    self.scrollView.contentSize = CGSizeMake(kScreenW, self.vHeight.constant);

    self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
    
    if (self.VcTag == 0) { //新增
        self.vHeight.constant = 3148;
        [self resetAddData:self.dayData month:self.monthData];
    } else if (self.VcTag == 1) { //有批注,点评权限的人进入
        [_submitBtn setTitle:@"修改" forState:UIControlStateNormal];
        _submitBtn.hidden = YES;
        [self.view addSubview:self.annotateCommentView];
        [self requestData];
    }
    //2.0 设置界面上All控件的字体大小及颜色
    [self setControlsFontAndColor];
    
    [_twoCont18 addTarget:self action:@selector(textChangePerson:) forControlEvents:UIControlEventEditingChanged];
    [_twoCont19 addTarget:self action:@selector(textChangePerson:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark -- UITextFieldDelegate

- (void)textChangePerson:(UITextField *)textField{
    if (_twoCont18.text.length>0 &&  _twoCont19.text.length>0) {
        float totle_count = [_twoCont19.text floatValue]/[_twoCont18.text floatValue]*100;
        _twoCont110.text = [NSString stringWithFormat:@"%.02f%@",totle_count,@"%"];
    }
}

- (void)requestData{
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    [parm setObject:_document_id forKey:@"document_id"];
    [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    
    NSLog(@"parm = %@",parm);
    NSString *urlStr = @"jobsummary/jobSummaryDetail";//工作总结模版
    [EBAlert showLoading:@"加载详情中..." allowUserInteraction:NO];
    [HttpTool post:urlStr parameters:parm success:^(id responseObject) {
        [EBAlert hideLoading];
        
        NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"currentDic=%@",currentDic);
        if ([currentDic[@"code"] integerValue] != 0) {
            [EBAlert alertError:currentDic[@"desc"] length:2.0f];
            return ;
        }else{
            [self resetEditData:currentDic[@"data"]];
            [self resetAddData:currentDic[@"data"][@"quantification"][@"dayData"] month:currentDic[@"data"][@"quantification"][@"monthData"]];
            [self addComment:currentDic[@"data"]];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"请检查网络" length:2.0f];
        
    }];
    
}

#pragma mark -- 事件监听
//点击了类型按钮
- (IBAction)didClickClassBtn:(UIButton *)sender {
    NSLog(@"点击了类型");
    self.pickerView.dataSource = @[@"日常总结",@"一周总结",@"一月总结",@"半年总结",@"一年总结"];
    self.pickerView.pickerTitle = @"请选择类型";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [weakSelf.oneCont2 setTitle:result forState:UIControlStateNormal];
    };
    [self.pickerView show];
    
}


- (IBAction)btnClick:(id)sender {
    NSLog(@"点击了提交");
    //模拟网络请求，请求参数配置
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = [EBPreferences sharedInstance].token;
    params[@"tmp_type"] = @"regional-manager";
    params[@"title"] = self.oneCont1.text;
    params[@"type"] = self.oneCont2.titleLabel.text;
    
    if (self.VcTag == 0) {//新增
        [params setObject:@"add" forKey:@"action"];
    }else{                //修改
        [params setObject:@"edit" forKey:@"action"];
        [params setObject:_document_id forKey:@"document_id"];//id
    }
    //2.0 第二部分 业绩部分3,148
    if (self.twoCont11.text.length == 0||self.twoCont12.text.length == 0||self.twoCont13.text.length == 0||self.twoCont14.text.length == 0||self.twoCont15.text.length == 0||self.twoCont16.text.length == 0||self.twoCont17.text.length == 0||self.twoCont18.text.length == 0||self.twoCont19.text.length == 0||self.twoCont111.text.length == 0||self.twoCont112.text.length == 0||self.twoCont113.text.length == 0||self.twoCont114.text.length == 0    ||self.twoCont21.text.length == 0||self.twoCont22.text.length == 0||self.twoCont23.text.length == 0||self.twoCont24.text.length == 0||self.twoCont25.text.length == 0||self.twoCont26.text.length == 0||self.twoCont27.text.length == 0||self.twoCont28.text.length == 0||self.twoCont29.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写数据汇报" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        params[@"regional_stores"] = self.twoCont11.text;   //区域数据
        params[@"regional_personnel"] = self.twoCont12.text;
        params[@"not_on_duty_manager"] = self.twoCont13.text;
        params[@"port_total"] = self.twoCont14.text;
        params[@"58_port"] = self.twoCont15.text;
        params[@"ajk_port"] = self.twoCont16.text;
        params[@"sf_port"] = self.twoCont17.text;
        
        params[@"goal_month"] = self.twoCont18.text;
        params[@"truly_month"] = self.twoCont19.text;
        //        params[@"twoCont110"] = self.twoCont110.text;//完成率
        
        params[@"old_house"] = self.twoCont111.text;
        params[@"new_house"] = self.twoCont112.text;
        
        params[@"zero_stores"] = self.twoCont113.text;
        params[@"zero_stores_list"] = self.twoCont114.text;//区域未破零门店明细
        params[@"break_zero_rate_month"] = self.twoCont21.text;  //本月破零率
        params[@"signature_today"] = self.twoCont22.text;
        params[@"signature_old_house"] = self.twoCont23.text;
        params[@"signature_new_house"] = self.twoCont24.text;
        params[@"bill_stores_avg_month"] = self.twoCont25.text;
        params[@"go_stores_today"] = self.twoCont26.text;
        params[@"go_stores_list"] = self.twoCont27.text;
        params[@"new_talk"] = self.twoCont28.text;
        params[@"new_talk_list"] = self.twoCont29.text;
    }
    //3.0 第三部分 业绩部分
    if (self.threeCont11.text.length == 0 || self.threeCont12.text.length == 0 || self.threeCont21.text.length == 0 || self.threeCont22.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写意向单" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        params[@"wish_bill_tomorrow"] = self.threeCont11.text;
        params[@"wish_bill_tomorrow_list"] = self.threeCont12.text;
        params[@"not_complete_bill_today"] = self.threeCont21.text;
        params[@"not_complete_bill_today_list"] = self.threeCont22.text;
    }
    //4.0 第四部分 其他部分
    if (self.fourCont1.text.length == 0 || self.fourCont2.text.length == 0 || self.fourCont3.text.length == 0 || self.fourCont4.text.length == 0 || self.fourCont5.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写其他部分数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        params[@"work_check"] = self.fourCont1.text;
        params[@"work_other"] = self.fourCont2.text;
        params[@"plans"] = self.fourCont3.text;
        params[@"getting"] = self.fourCont4.text;
        params[@"advices"] = self.fourCont5.text;
    }
    
    params[@"365_port"] = _threeSixFive.text;
    params[@"twl_port"] = _taiwuliao.text;
    params[@"dibao_port"] = _dibao.text;
    params[@"gj_port"] = _ganji.text;
    
    NSLog(@"params=%@",params);
    [self post:params];
    
}

- (void)textViewDidChange:(UITextView *)textView{
    
    
    UITextView *currentLable = nil;
    UILabel *currentLabletip = nil;
    if (textView == _twoCont114) {
        //实时显示字数
        currentLable = _twoCont114;
        currentLabletip = _TwoCont114_tip;
    }else if (textView == _twoCont27){
        currentLable = _twoCont27;
        currentLabletip = _TwoCont27_tip;
    }else if (textView == _twoCont29){
        currentLable = _twoCont29;
        currentLabletip = _TwoCont29_tip;
    }else if (textView == _threeCont12){
        currentLable = _threeCont12;
        currentLabletip = _ThreeCont12_tip;
    }else if (textView == _threeCont22){
        currentLable = _threeCont22;
        currentLabletip = _ThreeCont22_tip;
    }else if (textView == _fourCont1){
        currentLable = _fourCont1;
        currentLabletip = _FourCont1_tip;
    }else if (textView == _fourCont2){
        currentLable = _fourCont2;
        currentLabletip = _FourCont2_tip;
    }else if (textView == _fourCont3){
        currentLable = _fourCont3;
        currentLabletip = _FourCont3_tip;
    }else if (textView == _fourCont4){
        currentLable = _fourCont4;
        currentLabletip = _FourCont4_tip;
    }else if (textView == _fourCont5){
        currentLable = _fourCont5;
        currentLabletip = _FourCont5_tip;
    }
    currentLabletip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)currentLable.text.length,count];
    //字数限制操作
    if (currentLable.text.length >= count) {
        currentLable.text = [currentLable.text substringToIndex:count];
        currentLabletip.text = [NSString stringWithFormat:@"%d/%d",count,count];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",count] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}
#pragma mark -- 2.0 设置界面上All控件的字体大小及颜色
- (void)setControlsFontAndColor {
    
    CGFloat radius = 5.0f;
    _twoCont114.layer.cornerRadius = radius;
    _twoCont114.delegate = self;
    _twoCont114.clipsToBounds = YES;
    
    _twoCont27.layer.cornerRadius = radius;
    _twoCont27.delegate = self;
    _twoCont27.clipsToBounds = YES;
    
    _twoCont29.layer.cornerRadius = radius;
    _twoCont29.delegate = self;
    _twoCont29.clipsToBounds = YES;
    
    _threeCont12.layer.cornerRadius = radius;
    _threeCont12.delegate = self;
    _threeCont12.clipsToBounds = YES;
    
    _threeCont22.layer.cornerRadius = radius;
    _threeCont22.delegate = self;
    _threeCont22.clipsToBounds = YES;
    
    _fourCont1.layer.cornerRadius = radius;
    _fourCont1.delegate = self;
    _fourCont1.clipsToBounds = YES;
    
    _fourCont2.layer.cornerRadius = radius;
    _fourCont2.delegate = self;
    _fourCont2.clipsToBounds = YES;
    
    _fourCont3.layer.cornerRadius = radius;
    _fourCont3.delegate = self;
    _fourCont3.clipsToBounds = YES;
    
    _fourCont4.layer.cornerRadius = radius;
    _fourCont4.delegate = self;
    _fourCont4.clipsToBounds = YES;
    
    _fourCont5.layer.cornerRadius = radius;
    _fourCont5.delegate = self;
    _fourCont5.clipsToBounds = YES;
}

#pragma mark -- 点评 批注

//点评
- (void)comment:(UIButton *)btn{
    LSXAlertInputView * alert=[[LSXAlertInputView alloc]initWithTitle:@"点评" PlaceholderText:@"请输入文字" WithKeybordType:LSXKeyboardTypeDefault CompleteBlock:^(NSString *contents) {
        
        NSLog(@"-----%@",contents);
        
        NSMutableDictionary *parm = [NSMutableDictionary dictionary];
        [parm setObject:_document_id forKey:@"document_id"];
        [parm setObject:contents forKey:@"comment"];
        [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
        [parm setObject:@"comment" forKey:@"action"];
        NSLog(@"parm = %@",parm);
        
        NSString *urlStr = @"jobsummary/jobSummaryOperated";//工作总结模版
        
        [EBAlert showLoading:@"点评中..." allowUserInteraction:NO];
        [HttpTool post:urlStr parameters:parm success:^(id responseObject) {
            [EBAlert hideLoading];
            
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"currentDic=%@",currentDic);
            if ([currentDic[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"点评成功" length:2.0f];
                self.commentView.mainTextView.text = contents;
                return ;
            }else{
                [EBAlert alertError:@"点评失败" length:2.0f];
            }
            
        } failure:^(NSError *error) {
            [EBAlert hideLoading];
            [EBAlert alertError:@"请检查网络" length:2.0f];
        }];
        
    }];
    [alert show];
}

//批注
- (void)annotate:(UIButton *)btn{
    LSXAlertInputView * alert=[[LSXAlertInputView alloc]initWithTitle:@"批注" PlaceholderText:@"请输入文字" WithKeybordType:LSXKeyboardTypeDefault CompleteBlock:^(NSString *contents) {
        
        NSLog(@"-----%@",contents);
        
        NSMutableDictionary *parm = [NSMutableDictionary dictionary];
        [parm setObject:_document_id forKey:@"document_id"];
        [parm setObject:contents forKey:@"opinion"];
        [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
        [parm setObject:@"opinion" forKey:@"action"];
        NSLog(@"parm = %@",parm);
        
        NSString *urlStr = @"jobsummary/jobSummaryOperated";//工作总结模版
        
        [EBAlert showLoading:@"批注中..." allowUserInteraction:NO];
        [HttpTool post:urlStr parameters:parm success:^(id responseObject) {
            [EBAlert hideLoading];
            
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"currentDic=%@",currentDic);
            if ([currentDic[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"批注成功" length:2.0f];
                self.annotateView.mainTextView.text = contents;
                return ;
            }else{
                [EBAlert alertError:@"批注失败" length:2.0f];
            }
            
        } failure:^(NSError *error) {
            [EBAlert hideLoading];
            [EBAlert alertError:@"请检查网络" length:2.0f];
        }];
        
        
    }];
    [alert show];
}



@end






