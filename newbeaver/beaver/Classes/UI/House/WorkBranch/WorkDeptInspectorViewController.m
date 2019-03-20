//
//  WorkDeptInspectorViewController.m
//  beaver
//
//  Created by mac on 18/1/19.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkDeptInspectorViewController.h"
#import "InspectorTableViewCell.h"
#import "AnnotateView.h"
#import "LSXAlertInputView.h"

@interface WorkDeptInspectorViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *add_button;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *add_button_y;

@property (nonatomic, strong)UIView *annotateCommentView;//批注点评

@property (nonatomic, weak)UIButton * annotate;
@property (nonatomic, weak)UIButton * comment;

@property (nonatomic, strong)AnnotateView *annotateView;
@property (nonatomic, strong)AnnotateView *commentView;

@property (nonatomic, weak)UIView *headerView;
@property (nonatomic, weak)UIView *footerView;

@property (nonatomic, strong)NSMutableArray *dataArray;//数据
@property (nonatomic, strong)NSMutableArray *tmpDataArray;//数据
@property (nonatomic, strong)UITableView *mainTableView;

@property (nonatomic, strong)ValuePickerView *pickerView;


@property (weak, nonatomic) IBOutlet UITextField *workTitle;
@property (weak, nonatomic) IBOutlet UIButton *selectedType;

//数据汇报
@property (weak, nonatomic) IBOutlet UITextField *regional_stores;//区域门店
@property (weak, nonatomic) IBOutlet UITextField *goal_join_month;//本月加盟目标
@property (weak, nonatomic) IBOutlet UITextField *truly_join_month;//本月加盟目标完成
@property (weak, nonatomic) IBOutlet UITextField *regional_personnel;//区域人员
@property (weak, nonatomic) IBOutlet UITextField *not_on_duty_manager;//今日未在岗店长

@property (weak, nonatomic) IBOutlet UITextField *port_total;//端口总数

@property (weak, nonatomic) IBOutlet UITextField *fiveEight_port;//58_port
@property (weak, nonatomic) IBOutlet UITextField *ajk_port;//安居客
@property (weak, nonatomic) IBOutlet UITextField *sf_port;//搜房
//新增
@property (weak, nonatomic) IBOutlet UITextField *three_port;//365
@property (weak, nonatomic) IBOutlet UITextField *twl_port;//泰无聊
@property (weak, nonatomic) IBOutlet UITextField *dibao_port;//地宝
@property (weak, nonatomic) IBOutlet UITextField *gj_port;//赶集


@property (weak, nonatomic) IBOutlet UITextField *goal_month;//月度目标
@property (weak, nonatomic) IBOutlet UITextField *truly_month;//实际完成


@property (weak, nonatomic) IBOutlet UITextField *old_house;//二手房

@property (weak, nonatomic) IBOutlet UITextField *news_house;//一手房
@property (weak, nonatomic) IBOutlet UITextField *zero_stores;//区域未破零门店

@property (weak, nonatomic) IBOutlet UITextField *break_zero_rate_month;//本月破零率
@property (weak, nonatomic) IBOutlet UITextField *signature_today;//今日总签单

@property (weak, nonatomic) IBOutlet UITextField *signature_old_house;//二手房单量
@property (weak, nonatomic) IBOutlet UITextField *signature_new_house;//一手房单量
@property (weak, nonatomic) IBOutlet UITextField *bill_stores_avg_month;//本月店均
@property (weak, nonatomic) IBOutlet UITextField *go_stores_today;//今日走店
@property (weak, nonatomic) IBOutlet UITextView *go_stores_list;//今日走店明细及反馈
@property (weak, nonatomic) IBOutlet UILabel *go_stores_list_tip;
@property (weak, nonatomic) IBOutlet UITextField *news_talk;//新人谈心
@property (weak, nonatomic) IBOutlet UITextView *news_talk_list;//新人谈心明细
@property (weak, nonatomic) IBOutlet UILabel *news_talk_list_tip;
//意向单
@property (weak, nonatomic) IBOutlet UITextField *wish_bill_tomorrow;//明日意向单
@property (weak, nonatomic) IBOutlet UITextView *wish_bill_tomorrow_list;//明日意向单明细
@property (weak, nonatomic) IBOutlet UILabel *wish_bill_tomorrow_list_tip;
@property (weak, nonatomic) IBOutlet UITextField *not_complete_bill_today;//今日未签成意向单
@property (weak, nonatomic) IBOutlet UITextView *not_complete_bill_today_list;//今日未签成意向单明细
@property (weak, nonatomic) IBOutlet UILabel *not_complete_bill_today_list_tip;
//其他
@property (weak, nonatomic) IBOutlet UITextField *dispute_today;//今日纠纷
@property (weak, nonatomic) IBOutlet UITextView *dispute_next;//纠纷下一步
@property (weak, nonatomic) IBOutlet UILabel *dispute_next_tip;
@property (weak, nonatomic) IBOutlet UITextView *work_check;//今日检查工作
@property (weak, nonatomic) IBOutlet UILabel *work_check_tip;
@property (weak, nonatomic) IBOutlet UITextView *work_other;//今日其他工作
@property (weak, nonatomic) IBOutlet UILabel *work_other_tip;
@property (weak, nonatomic) IBOutlet UITextView *plans;//次日计划
@property (weak, nonatomic) IBOutlet UILabel *plans_tip;
@property (weak, nonatomic) IBOutlet UITextView *getting;//工作心得体会
@property (weak, nonatomic) IBOutlet UILabel *getting_tip;
@property (weak, nonatomic) IBOutlet UITextView *advices;//对门店和区域的建议
@property (weak, nonatomic) IBOutlet UILabel *advices_tip;


@property (weak, nonatomic) IBOutlet UILabel *clientAdd;
@property (weak, nonatomic) IBOutlet UILabel *houseAdd;
@property (weak, nonatomic) IBOutlet UILabel *see;
@property (weak, nonatomic) IBOutlet UILabel *reconnoitre;
@property (weak, nonatomic) IBOutlet UILabel *manyof;
@property (weak, nonatomic) IBOutlet UILabel *singleof;
@property (weak, nonatomic) IBOutlet UILabel *focus;
@property (weak, nonatomic) IBOutlet UILabel *keyData;
@property (weak, nonatomic) IBOutlet UILabel *negotiatePrice;

@property (weak, nonatomic) IBOutlet UITextField *twoCont110;


@end

#define titleCount 1000


@implementation WorkDeptInspectorViewController


- (void)textViewDidChange:(UITextView *)textView{

    UITextView *currentLable = nil;
    UILabel *currentLabletip = nil;
    if (textView == _go_stores_list) {
        //实时显示字数
        currentLable = _go_stores_list;
        currentLabletip = _go_stores_list_tip;
    }else if (textView == _news_talk_list){
        currentLable = _news_talk_list;
        currentLabletip = _news_talk_list_tip;
    }else if (textView == _wish_bill_tomorrow_list){
        currentLable = _wish_bill_tomorrow_list;
        currentLabletip = _wish_bill_tomorrow_list_tip;
    }else if (textView == _not_complete_bill_today_list){
        currentLable = _not_complete_bill_today_list;
        currentLabletip = _not_complete_bill_today_list_tip;
    }else if (textView == _dispute_next){
        currentLable = _dispute_next;
        currentLabletip = _dispute_next_tip;
    }else if (textView == _work_check){
        currentLable = _work_check;
        currentLabletip = _work_check_tip;
    }else if (textView == _work_other){
        currentLable = _work_other;
        currentLabletip = _work_other_tip;
    }else if (textView == _plans){
        currentLable = _plans;
        currentLabletip = _plans_tip;
    }else if (textView == _getting){
        currentLable = _getting;
        currentLabletip = _getting_tip;
    }else if (textView == _advices){
        currentLable = _advices;
        currentLabletip = _advices_tip;
    }
    currentLabletip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)currentLable.text.length,titleCount];
    //字数限制操作
    if (currentLable.text.length >= titleCount) {
        currentLable.text = [currentLable.text substringToIndex:titleCount];
        currentLabletip.text = [NSString stringWithFormat:@"%d/%d",titleCount,titleCount];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",titleCount] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
}


- (void)resetUI{
    
    CGFloat radius = 5.0f;
    _go_stores_list.layer.cornerRadius = radius;
    _go_stores_list.clipsToBounds = YES;
    _go_stores_list.delegate = self;
    
    _news_talk_list.layer.cornerRadius = radius;
    _news_talk_list.clipsToBounds = YES;
    _news_talk_list.delegate = self;
    
    _wish_bill_tomorrow_list.layer.cornerRadius = radius;
    _wish_bill_tomorrow_list.clipsToBounds = YES;
    _wish_bill_tomorrow_list.delegate = self;
    
    _not_complete_bill_today_list.layer.cornerRadius = radius;
    _not_complete_bill_today_list.clipsToBounds = YES;
    _not_complete_bill_today_list.delegate = self;
    
    _dispute_next.layer.cornerRadius = radius;
    _dispute_next.clipsToBounds = YES;
    _dispute_next.delegate = self;
    
    _work_check.layer.cornerRadius = radius;
    _work_check.clipsToBounds = YES;
    _work_check.delegate = self;
    
    _work_other.layer.cornerRadius = radius;
    _work_other.clipsToBounds = YES;
    _work_other.delegate = self;
    
    _plans.layer.cornerRadius = radius;
    _plans.clipsToBounds = YES;
    _plans.delegate = self;
    
    _getting.layer.cornerRadius = radius;
    _getting.clipsToBounds = YES;
    _getting.delegate = self;
    
    _advices.layer.cornerRadius = radius;
    _advices.clipsToBounds = YES;
    _advices.delegate = self;
    
}


- (AnnotateView *)commentView{
    if (!_commentView) {
        _commentView = [[AnnotateView alloc]initWithFrame:CGRectMake(0, self.footerView.height-self.add_button.height, kScreenW, 180)];
        NSLog(@"_commentView=%@",_commentView);
        _commentView.title.text = @"点评";
    }
    return _commentView;
}

- (AnnotateView *)annotateView{
    if (!_annotateView) {
        _annotateView = [[AnnotateView alloc]initWithFrame:CGRectMake(0, self.footerView.height-self.add_button.height, kScreenW, 180)];
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



- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        UIView *headerView = [[NSBundle mainBundle] loadNibNamed:@"DeptInsepectorHeaderView" owner:self options:nil].firstObject;
        self.headerView = headerView;
        _mainTableView.tableHeaderView = headerView;
        UIView *footerView = [[NSBundle mainBundle] loadNibNamed:@"DeptInspectorView" owner:self options:nil].firstObject;
        self.footerView = footerView;
        if (self.modelType == LWLWorkInsperctorTypeEdit) {
             [self addComment];
        }
        _mainTableView.tableFooterView = footerView;
    }
    return _mainTableView;
}

- (void)resetDataComment:(NSDictionary *)dic{
    _annotateView.mainTextView.text = [dic[@"opinion"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _commentView.mainTextView.text = [dic[@"comment"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
}

-(void)addComment{
    //批注
    CGFloat height = 180;
    
    [self.footerView addSubview:self.annotateView];
    
    self.footerView.height += height;

    [UIView animateWithDuration:0.5f animations:^{
        self.add_button_y.constant += height;
    }];
    //点评
    [self.footerView addSubview:self.commentView];
    self.footerView.height += height+60;
    [UIView animateWithDuration:0.5f animations:^{
        self.add_button_y.constant += height;
    }];
//    NSLog(@"%f",self.mainTableView.contentSize.height);
//    self.mainTableView.contentSize = CGSizeMake(kScreenW, self.mainTableView.contentSize.height+400);
//    NSLog(@"%f",self.mainTableView.contentSize.height);
    
}

//新增和编辑
- (void)resetAddData:(NSDictionary *)dayData month:(NSDictionary *)monthData{
    _clientAdd.text = [NSString  stringWithFormat:@"今日: %@                           本月：%@",dayData[@"clientCount"],monthData[@"clientCount"]];
    _houseAdd.text = [NSString  stringWithFormat:@"今日: %@                           本月：%@",dayData[@"houseCount"],monthData[@"houseCount"]];
    _see.text = [NSString  stringWithFormat:@"今日: %@                           本月：%@",dayData[@"followCount"],monthData[@"followCount"]];
    _reconnoitre.text = [NSString  stringWithFormat:@"今日: %@                           本月：%@",dayData[@"surveyCount"],monthData[@"surveyCount"]];
    _manyof.text = [NSString  stringWithFormat:@"今日: %@                           本月：%@",dayData[@"entrustCount"],monthData[@"entrustCount"]];
    _singleof.text = [NSString  stringWithFormat:@"今日: %@                           本月：%@",dayData[@"exclusiveCount"],monthData[@"exclusiveCount"]];
    _focus.text = [NSString  stringWithFormat:@"今日: %@                           本月：%@",dayData[@"focusCount"],monthData[@"focusCount"]];
    _keyData.text = [NSString  stringWithFormat:@"今日: %@                           本月：%@",dayData[@"keyCount"],monthData[@"keyCount"]];
    _negotiatePrice.text = [NSString  stringWithFormat:@"今日: %@                           本月：%@",dayData[@"salePriceCount"],monthData[@"salePriceCount"]];
    //标题
    if (self.modelType != LWLWorkInsperctorTypeEdit) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
        _workTitle.text = [NSString stringWithFormat:@"%@-%@工作总结【%@】",[EBPreferences sharedInstance].dept_name,[EBPreferences sharedInstance].userName,currentDateStr];
    }
    
    [self.mainTableView reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"区域总监工作总结";
    self.tmpDataArray = [NSMutableArray array];
    [self.view addSubview:self.mainTableView];
     self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
     [self resetUI];
    if (self.modelType == LWLWorkInsperctorTypeEdit) {
        [_add_button setTitle:@"修改" forState:UIControlStateNormal];
        _add_button.hidden = YES;
        self.dataArray = [NSMutableArray array];
        [self.view addSubview:self.annotateCommentView];
        [self requestData];
    }else{
        [_add_button setTitle:@"提交" forState:UIControlStateNormal];
         self.dataArray = [NSMutableArray arrayWithArray:self.regionList];
        [self resetAddData:self.dayData month:self.monthData];
    }
    
    [_goal_month addTarget:self action:@selector(textChangePerson:) forControlEvents:UIControlEventEditingChanged];
    [_truly_month addTarget:self action:@selector(textChangePerson:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textChangePerson:(UITextField *)textField{
    if (_goal_month.text.length>0 &&  _truly_month.text.length>0) {
        float totle_count = [_truly_month.text floatValue]/[_goal_month.text floatValue]*100;
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
            //添加批注，点评
            [self resetDataComment:currentDic[@"data"]];
            
            self.dataArray = [NSMutableArray arrayWithArray:currentDic[@"data"][@"zero_stores_list"]];
            [self.mainTableView reloadData];
            
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"请检查网络" length:2.0f];
        
    }];
    
}

- (void)resetEditData:(NSDictionary *)dic{;
    //必填
    _workTitle.text = dic[@"title"];
    _selectedType.titleLabel.text = dic[@"type"];
    
    _regional_stores.text = dic[@"regional_stores"];
    _goal_join_month.text = dic[@"goal_join_month"];
    _truly_join_month.text = dic[@"truly_join_month"];
    _regional_personnel.text = dic[@"regional_personnel"];
    _not_on_duty_manager.text = dic[@"not_on_duty_manager"];
    
    //端口
    _port_total.text = dic[@"port_total"];
    _fiveEight_port.text = dic[@"58_port"];
    _ajk_port.text = dic[@"ajk_port"];
    _sf_port.text = dic[@"sf_port"];
    
    _three_port.text = dic[@"365_port"];
    _twl_port.text = dic[@"twl_port"];
    _dibao_port.text = dic[@"dibao_port"];
    _gj_port.text = dic[@"gj_port"];

    
    _goal_month.text = dic[@"goal_month"];
    _truly_month.text = dic[@"truly_month"];                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
    
    float totle_count = [_truly_month.text floatValue]/[_goal_month.text floatValue]*100;
    _twoCont110.text = [NSString stringWithFormat:@"%.02f%@",totle_count,@"%"];
    
    _old_house.text = dic[@"old_house"];
    _news_house.text = dic[@"new_house"];
    
    _zero_stores.text = dic[@"zero_stores"];
    _break_zero_rate_month.text = dic[@"break_zero_rate_month"];
    _zero_stores.text = dic[@"zero_stores"];
    _break_zero_rate_month.text = dic[@"break_zero_rate_month"];
    _signature_today.text = dic[@"signature_today"];
    _signature_old_house.text = dic[@"signature_old_house"];
    
    _signature_new_house.text = dic[@"signature_new_house"];
    _bill_stores_avg_month.text = dic[@"bill_stores_avg_month"];
    
    _go_stores_today.text = dic[@"go_stores_today"];
    _go_stores_list.text = [dic[@"go_stores_list"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _go_stores_list_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_go_stores_list.text.length,titleCount];

    _news_talk.text = dic[@"new_talk"];
    _news_talk_list.text = [dic[@"new_talk_list"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _news_talk_list_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_news_talk_list.text.length,titleCount];
    
    _wish_bill_tomorrow.text = dic[@"wish_bill_tomorrow"];
    _wish_bill_tomorrow_list.text = [dic[@"wish_bill_tomorrow_list"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _wish_bill_tomorrow_list_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_wish_bill_tomorrow_list.text.length,titleCount];
    
    _not_complete_bill_today.text = dic[@"not_complete_bill_today"];
    _not_complete_bill_today_list.text = [dic[@"not_complete_bill_today_list"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _not_complete_bill_today_list_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_not_complete_bill_today_list.text.length,titleCount];

    _dispute_today.text = dic[@"dispute_today"];
    _dispute_next.text = [dic[@"dispute_next"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _dispute_next_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_not_complete_bill_today_list.text.length,titleCount];

    _work_check.text = [dic[@"work_check"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    
    _work_check_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_work_check.text.length,titleCount];

    _work_other.text = [dic[@"work_other"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    
    _work_other_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_work_other.text.length,titleCount];
    
    _plans.text = [dic[@"plans"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _plans_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_plans.text.length,titleCount];
    
    _getting.text = [dic[@"getting"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _getting_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_getting.text.length,titleCount];
    
    _advices.text = [dic[@"advices"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    _advices_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_advices.text.length,titleCount];
    //权限
    if ([dic[@"can_edit"] intValue] == 1) {
        _add_button.hidden = NO;
    }
    if ([dic[@"can_opinion"] intValue] == 1) {
        _annotateCommentView.hidden = NO;
        self.annotate.hidden = NO;
        if ([dic[@"can_comment"] intValue] == 0) {
            self.annotate.frame = CGRectMake(0, 0, kScreenW, 50);
        }
    }
    if ([dic[@"can_comment"] intValue] == 1) {
        _annotateCommentView.hidden = NO;
        self.comment.hidden = NO;
        if ([dic[@"can_opinion"] intValue] == 0) {
            self.comment.frame = CGRectMake(0, 0, kScreenW, 50);
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)addButton:(id)sender {
    NSLog(@"提交");
    //模拟网络请求，请求参数配置
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"token"] = [EBPreferences sharedInstance].token;
    params[@"tmp_type"] = @"director";
    params[@"type"] = self.selectedType.titleLabel.text;
    if (self.workTitle.text == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写标题" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }else{
        params[@"title"] = self.workTitle.text;
    }
    
   
    //1.0 第一部分 标题
    if (self.modelType == LWLWorkInsperctorTypeEdit) {
        [params setObject:@"edit" forKey:@"action"];//编辑
        [params setObject:_document_id forKey:@"document_id"];//id
        
    }else{
        [params setObject:@"add" forKey:@"action"];//新增
    }
    
    NSLog(@"%@",self.tmpDataArray);
    
    NSString *zero_stores_list = @"";
    for (InspectorTableViewCell *cell in self.tmpDataArray) {
        if (cell.textField.text.length == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写数据回报" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }else{
            NSString *tmpStr = [NSString stringWithFormat:@"%@*%@;",cell.nameTitle.text,cell.textField.text];
            zero_stores_list = [zero_stores_list stringByAppendingString:tmpStr];
        }
    }
    if (zero_stores_list.length > 1) {
        zero_stores_list = [zero_stores_list substringToIndex:zero_stores_list.length-1];
        NSLog(@"zero_stores_list = %@",zero_stores_list);
        
        [params setObject:zero_stores_list forKey:@"zero_stores_list"];//区域数据
    }
    
    if (self.regional_stores.text.length == 0 || self.goal_join_month.text.length == 0 || self.truly_join_month.text.length == 0 || self.regional_personnel.text.length == 0||self.not_on_duty_manager.text.length == 0 || self.port_total.text.length == 0 || self.fiveEight_port.text.length == 0 || self.ajk_port.text.length == 0||self.sf_port.text.length == 0|| self.goal_month.text.length == 0||self.truly_month.text.length == 0||self.old_house.text.length == 0 || self.news_house.text.length == 0 || self.zero_stores.text.length == 0 || self.break_zero_rate_month.text.length == 0||self.signature_today.text.length == 0 || self.signature_old_house.text.length == 0 || self.signature_new_house.text.length == 0 || self.bill_stores_avg_month.text.length == 0||self.go_stores_today.text.length == 0 || self.go_stores_list.text.length == 0 || self.news_talk.text.length == 0 || self.news_talk_list.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写数据回报" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        params[@"regional_stores"] = self.regional_stores.text;   //区域数据
        params[@"goal_join_month"] = self.goal_join_month.text;   //区域数据
        params[@"truly_join_month"] = self.truly_join_month.text;   //区域数据
        params[@"regional_personnel"] = self.regional_personnel.text;
        params[@"not_on_duty_manager"] = self.not_on_duty_manager.text;
        params[@"port_total"] = self.port_total.text;
        params[@"58_port"] = self.fiveEight_port.text;
        params[@"ajk_port"] = self.ajk_port.text;
        params[@"sf_port"] = self.sf_port.text;
       
        params[@"goal_month"] = self.goal_month.text;
        params[@"truly_month"] = self.truly_month.text;
        params[@"old_house"] = self.old_house.text;
        params[@"new_house"] = self.news_house.text;
        params[@"zero_stores"] = self.zero_stores.text;
        params[@"break_zero_rate_month"] = self.break_zero_rate_month.text;  //本月破零率
        params[@"signature_today"] = self.signature_today.text;
        params[@"signature_old_house"] = self.signature_old_house.text;
        params[@"signature_new_house"] = self.signature_new_house.text;
        params[@"bill_stores_avg_month"] = self.bill_stores_avg_month.text;
        params[@"go_stores_today"] = self.go_stores_today.text;
        params[@"go_stores_list"] = self.go_stores_list.text;
        params[@"new_talk"] = self.news_talk.text;
        params[@"new_talk_list"] = self.news_talk_list.text;
    }
    
    params[@"365_port"] = self.three_port.text;
    params[@"twl_port"] = self.twl_port.text;
    params[@"dibao_port"] = self.dibao_port.text;
    params[@"gj_port"] = self.gj_port.text;
    
    //3.0 意向单
    if (self.wish_bill_tomorrow.text.length == 0 || self.wish_bill_tomorrow_list.text.length == 0 || self.not_complete_bill_today.text.length == 0 || self.not_complete_bill_today_list.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写意向单" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        //意向单
        params[@"wish_bill_tomorrow"] = self.wish_bill_tomorrow.text;
        params[@"wish_bill_tomorrow_list"] = self.wish_bill_tomorrow_list.text;
        params[@"not_complete_bill_today"] = self.not_complete_bill_today.text;
        params[@"not_complete_bill_today_list"] = self.not_complete_bill_today_list.text;
    }
    
    //3.0 其他
    if (self.dispute_today.text.length == 0 || self.dispute_next.text.length == 0 || self.work_check.text.length == 0 || self.work_other.text.length == 0|| self.plans.text.length == 0 || self.getting.text.length == 0 || self.advices.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写其他部门" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        //其他
        params[@"dispute_today"] = self.dispute_today.text;
        params[@"dispute_next"] = self.dispute_next.text;
        params[@"work_check"] = self.work_check.text;
        params[@"work_other"] = self.work_other.text;
        params[@"plans"] = self.plans.text;
        params[@"getting"] = self.getting.text;
        params[@"advices"] = self.advices.text;
    }
    NSLog(@"params=%@",params);
    [self post:params];
}


- (IBAction)selectedTypeClick:(id)sender {
    NSLog(@"选择工作类型");
    self.pickerView.dataSource = @[@"日常总结",@"一周总结",@"一月总结",@"半年总结",@"一年总结"];
    self.pickerView.pickerTitle = @"请选择类型";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [weakSelf.selectedType setTitle:result forState:UIControlStateNormal];
    };
    [self.pickerView show];
}

#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section], (long)[indexPath row]];//以indexPath来唯一确定cell
    InspectorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[InspectorTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [self.tmpDataArray addObject:cell];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.modelType == LWLWorkInsperctorTypeAdd) {
        cell.nameTitle.text = self.dataArray[indexPath.row];
    }else{
        NSDictionary *dic = self.dataArray[indexPath.row];
        cell.nameTitle.text = dic[@"n"];
        cell.textField.text =[NSString stringWithFormat:@"%@",dic[@"v"]];
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
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
