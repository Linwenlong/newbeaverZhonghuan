//
//  ZHShopManagerController.m
//  中环经纪人助手-工作总结
//
//  Created by 刘海伟 on 2018/1/19.
//  Copyright © 2018年 liuhaiwei. All rights reserved.
//
//  工作总结-店长模块

#import "ZHShopManagerController.h"
#import "MainPushView.h"
#import "NewPushView.h"
#import "IntentionOrderCell.h"
#import "WorkSelectClientCodeViewController.h"

#import "YixiangdangModel.h"
#import "ZhutuiModel.h"
#import "AnnotateView.h"
#import "LSXAlertInputView.h"

#define TextCount1000 1000
#define TextCount500 500
#define MemoHeight 240
//#define ScrollFirstHeight 3284   //scrollView初始高度 3064
#define ScrollFirstHeight 3290   //scrollView初始高度 3064
#define RowHeight 270  //cell的行高

@interface ZHShopManagerController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,MainPushViewDelegate,NewPushViewDelegate,UITextFieldDelegate,IntentionOrderDelegate>

@property (nonatomic, strong)NSArray * mainPushNumsArr;
@property (nonatomic, strong)NSArray * newsPushNumsArr;
@property (weak, nonatomic) IBOutlet UILabel *mainPushTip;
@property (weak, nonatomic) IBOutlet UILabel *newsPushTip;

@property (nonatomic, strong)AnnotateView *annotateView;
@property (nonatomic, strong)AnnotateView *commentView;
@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong)UIView *annotateCommentView;//批注点评
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *add_button_y;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerView_h;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong)ValuePickerView *pickerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vHeight;
@property (weak, nonatomic) IBOutlet UIView *bgView;

/** 记录整个View的高度 */
@property (nonatomic, assign) CGFloat allHeight;

/** view2的高度 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view2Height;
/** 记录整个View2的高度, 方便传递 */
@property (nonatomic, assign) CGFloat allView2Height;

/** 主推房源View */
@property (weak, nonatomic) IBOutlet UIView *mainPushView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainPushHeight;
/** 模拟主推房源View的个数 */
@property (nonatomic, assign) NSInteger mainPushNums;
/** 主推房源View的行数 */
@property (nonatomic, assign) NSInteger mainPushRows;

/** 主推房源新增View */
@property (weak, nonatomic) IBOutlet UIView *NewMainPushView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *NewMainPushHeight;
/** 模拟主推新增View的个数 */
@property (nonatomic, assign) NSInteger NewPushNums;
/** 主推房源新增View的行数 */
@property (nonatomic, assign) NSInteger NewPushRows;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view5Height;
/** 模拟view5 意向单的数据条数 */
@property (nonatomic, assign) NSInteger rows;

@property (nonatomic, strong) NSMutableArray *tmpArr;

@property (nonatomic, strong) NSMutableArray *zhutuiArr;
@property (nonatomic, strong) NSMutableArray *newsZhutuiArr;

/** 第一部分 标题栏 */
@property (weak, nonatomic) IBOutlet UITextField *oneCont1;
@property (weak, nonatomic) IBOutlet UIButton *oneCont2;

/** 第二部分 门店目前情况 */
@property (weak, nonatomic) IBOutlet UITextField *twoCont11; //人员编制
@property (weak, nonatomic) IBOutlet UITextField *twoCont12;
@property (weak, nonatomic) IBOutlet UITextField *twoCont13;
@property (weak, nonatomic) IBOutlet UITextField *twoCont14;

@property (weak, nonatomic) IBOutlet UITextField *twoCont21; //端口编制
@property (weak, nonatomic) IBOutlet UITextField *twoCont22;
@property (weak, nonatomic) IBOutlet UITextField *twoCont23;
@property (weak, nonatomic) IBOutlet UITextField *twoCont24;
@property (weak, nonatomic) IBOutlet UITextField *twoCont25;
@property (weak, nonatomic) IBOutlet UITextField *twoCont26;
@property (weak, nonatomic) IBOutlet UITextField *twoCont27;
@property (weak, nonatomic) IBOutlet UITextField *twoCont28;
@property (weak, nonatomic) IBOutlet UITextField *twoCont29;
@property (weak, nonatomic) IBOutlet UITextField *twoCont310;
@property (weak, nonatomic) IBOutlet UITextField *twoCont311;
@property (weak, nonatomic) IBOutlet UITextField *twoCont312;
@property (weak, nonatomic) IBOutlet UITextField *twoCont313;
@property (weak, nonatomic) IBOutlet UITextField *twoCont314;
@property (weak, nonatomic) IBOutlet UITextField *twoCont315;
@property (weak, nonatomic) IBOutlet UITextField *twoCont316;
@property (weak, nonatomic) IBOutlet UITextField *twoCont317;
@property (weak, nonatomic) IBOutlet UITextField *twoCont318;

@property (nonatomic, strong) MainPushView *pushView;  //主推房源
@property (nonatomic, strong) NewPushView *NewView;   //主推房源新增
@property (weak, nonatomic) IBOutlet UITextView *twoCont31;  //存在问题   textView
@property (weak, nonatomic) IBOutlet UITextField *twoCont41; //客源本月新增
@property (weak, nonatomic) IBOutlet UITextField *twoCont51; //客户来源
@property (weak, nonatomic) IBOutlet UITextField *twoCont52;
@property (weak, nonatomic) IBOutlet UITextField *twoCont53;
@property (weak, nonatomic) IBOutlet UITextField *twoCont54;
@property (weak, nonatomic) IBOutlet UITextView *twoCont61;  //问题及办法  textView
/** 第三部分 月度目标 */
@property (weak, nonatomic) IBOutlet UITextField *threeCont1;
@property (weak, nonatomic) IBOutlet UITextField *threeCont2;
@property (weak, nonatomic) IBOutlet UITextField *threeCont3;
@property (weak, nonatomic) IBOutlet UITextField *threeCont4;
@property (weak, nonatomic) IBOutlet UITextField *threeCont5;
@property (weak, nonatomic) IBOutlet UITextField *threeCont6;
@property (weak, nonatomic) IBOutlet UITextField *threeCont7;
@property (weak, nonatomic) IBOutlet UITextField *threeCont8;
@property (weak, nonatomic) IBOutlet UITextField *threeCont9;
@property (weak, nonatomic) IBOutlet UITextField *threeCont10;
/** 第四部分 今日量化与资源 */
@property (weak, nonatomic) IBOutlet UITextField *fourCont11; //带看,房增...
@property (weak, nonatomic) IBOutlet UITextField *fourCont12;
@property (weak, nonatomic) IBOutlet UITextField *fourCont13;
@property (weak, nonatomic) IBOutlet UITextField *fourCont14;
@property (weak, nonatomic) IBOutlet UITextField *fourCont15;
@property (weak, nonatomic) IBOutlet UITextField *fourCont16;
@property (weak, nonatomic) IBOutlet UITextField *fourCont17;
@property (weak, nonatomic) IBOutlet UITextField *fourCont18;
@property (weak, nonatomic) IBOutlet UITextField *fourCont19;
@property (weak, nonatomic) IBOutlet UITextField *fourCont110;
@property (weak, nonatomic) IBOutlet UITextField *fourCont111;
@property (weak, nonatomic) IBOutlet UITextField *fourCont112;
@property (weak, nonatomic) IBOutlet UITextField *fourCont113;
@property (weak, nonatomic) IBOutlet UITextField *fourCont114;
@property (weak, nonatomic) IBOutlet UITextField *fourCont115;
@property (weak, nonatomic) IBOutlet UITextField *fourCont116;
@property (weak, nonatomic) IBOutlet UITextField *fourCont117;
@property (weak, nonatomic) IBOutlet UITextField *fourCont118;
@property (weak, nonatomic) IBOutlet UITextField *fourCont119; //聚焦成功,失败
@property (weak, nonatomic) IBOutlet UITextField *fourCont120;

@property (weak, nonatomic) IBOutlet UITextField *fourCont21; //驻守位置
@property (weak, nonatomic) IBOutlet UITextField *fourCont22;
@property (weak, nonatomic) IBOutlet UITextField *fourCont23;

@property (weak, nonatomic) IBOutlet UITextView *fourCont31; //问题及办法  textView

/** 第五部分 意向单数据 */
@property (weak, nonatomic) IBOutlet UILabel *intentionOrderTitle;

/** 第六部分 其他部分 */
//工作心得  textView
@property (weak, nonatomic) IBOutlet UITextView *sixCont1;
//对公司建议  textView
@property (weak, nonatomic) IBOutlet UITextView *sixCont2;
//次日计划  textView
@property (weak, nonatomic) IBOutlet UITextView *sixCont3;

//提交按钮
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

/** 主推房源array */
@property (nonatomic, strong) NSMutableArray *pushArray;
/** 主推房源新增array */
@property (nonatomic, strong) NSMutableArray *NewArray;


@property (nonatomic, strong) UILabel *totalLbl1;

@property (nonatomic, strong) UILabel *totalLbl2;

@property (nonatomic, strong) UILabel *totalLbl3;

@property (nonatomic, strong) UILabel *totalLbl4;

@property (nonatomic, strong) UILabel *totalLbl5;

@property (nonatomic, strong) UILabel *totalLbl6;

@property (nonatomic, strong) UILabel *totalLbl7;

@property (nonatomic, strong) UILabel *totalLbl8;


@property (nonatomic, weak)UIButton * annotate;
@property (nonatomic, weak)UIButton * comment;

@end

@implementation ZHShopManagerController

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
    self.scrollView.contentSize = CGSizeMake(kScreenW, self.scrollView.contentSize.height + 320);
}

- (void)resetEditData:(NSDictionary *)dic{;
    // 必填
    _oneCont1.text = dic[@"title"];
    _oneCont2.titleLabel.text = dic[@"type"];
    
    _twoCont11.text = dic[@"staff_manager"];
    _twoCont12.text = dic[@"staff_assistant"];
    _twoCont13.text = dic[@"staff_salesman"];
    
    
    _twoCont14.text = [NSString stringWithFormat:@"%d",[dic[@"staff_manager"] intValue]+[dic[@"staff_assistant"] intValue]+[dic[@"staff_salesman"] intValue]];//三个之和
    _twoCont21.text = dic[@"sf_port"];//搜房端口数
    _twoCont22.text = dic[@"sf_type"];//搜房刷新
    _twoCont23.text = dic[@"58_port"];//58端口数
    _twoCont24.text = dic[@"58_type"];//58刷新
    _twoCont25.text = dic[@"ajk_port"];//安居客端口数
    _twoCont26.text = dic[@"ajk_type"];//安居客刷新
    _twoCont27.text = dic[@"365_port"];//365端口数
    _twoCont28.text = dic[@"365_type"];//365刷新
    
    _twoCont29.text = dic[@"twl_port"];//泰无聊端口数
    _twoCont310.text = dic[@"twl_type"];//泰无聊刷新
    _twoCont311.text = dic[@"dibao_port"];//地宝端口数
    _twoCont312.text = dic[@"dibao_type"];//地宝端刷新
    _twoCont313.text = dic[@"gj_port"];//赶集端口数
    _twoCont314.text = dic[@"gj_type"];//赶集刷新量
    _twoCont315.text = dic[@"all_in_stock"];//共库存
    _twoCont316.text = dic[@"fresh_num"];//刷新
    _twoCont317.text = dic[@"per_in_stock"];//人均库存
    _twoCont318.text = dic[@"per_fresh"];//人均刷新

    _twoCont31.text =[dic[@"remain_problem"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"] ;
    self.totalLbl1.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.twoCont31.text.length,TextCount500];
    
    _twoCont41.text = dic[@"client_month_add"];
    _twoCont51.text = dic[@"client_walkin"];
    _twoCont52.text = dic[@"client_network"];
    _twoCont53.text = dic[@"client_58tc"];
    _twoCont54.text = dic[@"client_sf"];
    
    _twoCont61.text = [dic[@"work_method"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    self.totalLbl2.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.twoCont61.text.length,TextCount500];
    
    _threeCont1.text = dic[@"sell_orders"];
    _threeCont2.text = dic[@"complete_sell_orders"];
    _threeCont3.text = dic[@"rent_orders"];
    _threeCont4.text = dic[@"complete_rent_orders"];
    _threeCont5.text = dic[@"many_orders"];
    _threeCont6.text = dic[@"complete_many_orders"];
    _threeCont7.text = dic[@"exclusive_orders"];
    _threeCont8.text = dic[@"complete_exclusive_orders"];
    _threeCont9.text = dic[@"key_orders"];
    _threeCont10.text = dic[@"complete_key_orders"];
    
    _fourCont21.text = dic[@"local"];
    _fourCont22.text = dic[@"local_house"];
    _fourCont23.text = dic[@"local_client"];
    
    _fourCont31.text = [dic[@"process_method"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
     self.totalLbl3.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.fourCont31.text.length,TextCount1000];
  
    _sixCont1.text = [dic[@"getting"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    
    self.totalLbl4.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.sixCont1.text.length,TextCount1000];
    
    _sixCont2.text = [dic[@"advices"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    
    self.totalLbl5.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.sixCont2.text.length,TextCount500];
    _sixCont3.text = [dic[@"plans"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    
     self.totalLbl6.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.sixCont3.text.length,TextCount1000];
    
    _fourCont119.text = dic[@"focus_success"];//聚焦成功
    _fourCont120.text = dic[@"focus_fail"];//聚焦失败
    
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
    _fourCont11.text = dayData[@"clientCount"];
    _fourCont13.text = dayData[@"houseCount"];
    _fourCont15.text = dayData[@"followCount"];
    _fourCont17.text = dayData[@"surveyCount"];
    _fourCont19.text = dayData[@"entrustCount"];
    _fourCont111.text = dayData[@"exclusiveCount"];
    _fourCont113.text = dayData[@"focusCount"];
    _fourCont115.text = dayData[@"keyCount"];
    _fourCont117.text = dayData[@"salePriceCount"];
    
    _fourCont12.text = monthData[@"clientCount"];
    _fourCont14.text = monthData[@"houseCount"];
    _fourCont16.text = monthData[@"followCount"];
    _fourCont18.text = monthData[@"surveyCount"];
    _fourCont110.text = monthData[@"entrustCount"];
    _fourCont112.text = monthData[@"exclusiveCount"];
    _fourCont114.text = monthData[@"focusCount"];
    _fourCont116.text = monthData[@"keyCount"];
    _fourCont118.text = monthData[@"salePriceCount"];

    //标题
    if (self.VcTag == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
        _oneCont1.text = [NSString stringWithFormat:@"%@-%@工作总结【%@】",[EBPreferences sharedInstance].dept_name,[EBPreferences sharedInstance].userName,currentDateStr];
    }
    
}
#pragma mark -- UITextFieldDelegate

- (void)textChangePerson:(UITextField *)textField{
    int totle_count = 0;
    if (_twoCont11.text.length > 0) {
        totle_count += [_twoCont11.text intValue];
    }
    if (_twoCont12.text.length > 0) {
        totle_count += [_twoCont12.text intValue];
    }
    if (_twoCont13.text.length > 0) {
        totle_count += [_twoCont13.text intValue];
    }
    NSLog(@"totle_count =%d",totle_count);
    
    _twoCont14.text = [NSString stringWithFormat:@"%d",totle_count];//三个之和
}


#pragma mark -- 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"店长的工作总结";
//    self.view.backgroundColor = RGB(235, 235, 235);
    self.bgView.backgroundColor = RGB(235, 235, 235);
    self.vWidth.constant = SCReenWidth;
    self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
    self.tmpArr = [NSMutableArray array];
    self.zhutuiArr = [NSMutableArray array];
    self.newsZhutuiArr = [NSMutableArray array];
    //6.0 模拟进入角色, 实际根据接口情况来处理
    if (self.VcTag == 0) { //模拟个人角色进入
        self.view2Height.constant = 1000 +220;
        self.allView2Height = self.view2Height.constant;
        self.mainPushNums = 4;
        
        [self setUpMainPushView];
        self.NewPushNums = 4;
        [self setUpNewPushView];
        
        [self resetAddData:self.dayData month:self.monthData];
        self.vHeight.constant = ScrollFirstHeight - 276;
        
    } else if(self.VcTag == 1){ //模拟有批注,点评权限的人进入
        //1220
        self.vHeight.constant = ScrollFirstHeight + RowHeight *self.rows + 360;
        self.allHeight = self.vHeight.constant;
        self.allView2Height = self.view2Height.constant;
        self.scrollView.contentSize = CGSizeMake(SCReenWidth, self.allHeight);
        
        [_submitBtn setTitle:@"修改" forState:UIControlStateNormal];
        _submitBtn.hidden = YES;
        [self.view addSubview:self.annotateCommentView];
        [self requestData];
    }
    //3.0 处理view5意向单模块的高度
    [self setUpView5Height];
    //4.0 设置界面上All控件的字体大小及颜色
    [self setControlsFontAndColor];
    //5.0 关于textView的设置,并且添加两个label,占位lbl与字数统计lbl (合计6个textView)
    [self setUpTextViewAndAddSixLbls];
    
    [_twoCont11 addTarget:self action:@selector(textChangePerson:) forControlEvents:UIControlEventEditingChanged];
    [_twoCont12 addTarget:self action:@selector(textChangePerson:) forControlEvents:UIControlEventEditingChanged];
    [_twoCont13 addTarget:self action:@selector(textChangePerson:) forControlEvents:UIControlEventEditingChanged];
}
-(void)requestData{
    
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

            self.mainPushNumsArr = currentDic[@"data"][@"recommend_house"];
            
            self.newsPushNumsArr = currentDic[@"data"][@"main_recommend_house"];

            self.view2Height.constant = 1000 +220;
            self.allView2Height = self.view2Height.constant; //初始化记录view2的高度

            [self setupMainPushViewForEdit:self.mainPushNumsArr];
            
            [self setUpNewPushViewForEdit:self.newsPushNumsArr];
            
            for (NSDictionary *dic in currentDic[@"data"][@"wanting"]) {
                YixiangdangModel *model = [[YixiangdangModel alloc]init];
                model.name = dic[@"client_name"];
                model.client = dic[@"client_code"];
                model.textContent = dic[@"remark"];
                [self.tmpArr addObject:model];
            }
            [self.tableView reloadData];
            [self resetScorllView];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"请检查网络" length:2.0f];
        
    }];
    
}
- (void)resetScorllView{
    //刷新意向单合计lbl
    self.intentionOrderTitle.text = [NSString stringWithFormat:@"意向单(%ld)",self.tmpArr.count];

    // 刷新view5的高度
    self.view5Height.constant = 44 + self.tmpArr.count *RowHeight + 70;

    self.vHeight.constant = self.allHeight + self.tmpArr.count *RowHeight+ 420;
//    self.footerView.height += 420;
    self.allHeight = self.vHeight.constant;
    self.scrollView.contentSize = CGSizeMake(SCReenWidth, self.allHeight);
}

- (NSArray *)arrayWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *dic = [NSJSONSerialization JSONObjectWithData:jsonData
        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)setUpNewPushViewForEdit:(NSArray *)arr{
    if (arr.count == 0) {
        self.newsPushTip.hidden = YES;
    }
    
    // 假设一行有2个  创建数据个数4个
    int columns = 2;
    self.NewPushNums = arr.count;
    // 水平方向的间距
    CGFloat marginX = 10;
    // 假设每个view的宽度和高度一定
    CGFloat appW = (SCReenWidth -90 -2 *marginX) *0.5;
    CGFloat appH = 44;
    for (int i = 0; i < arr.count; i++) {
        self.NewView = [NewPushView initNewPushView];
        self.NewView.addBtn.hidden = YES;
        NSDictionary *dic = arr[i];
        self.NewView.contentOne.text = dic[@"h"];
        self.NewView.contentTwo.text = dic[@"r"];
      
        self.NewView.delegate = self;
        // 计算每个pushView所在的列的索引
        int col_idx = i % columns;
        // 计算每个pushView所在的行索引
        int row_idx = i / columns;
        self.NewPushRows = row_idx +1;
        // 计算每个pushView的x和y
        CGFloat appX = 90 +marginX + col_idx * (appW + marginX);
        CGFloat appY =  row_idx * appH ;
        self.NewView.frame = CGRectMake(appX, appY, appW, appH);
        self.NewView.contentOne.backgroundColor = [UIColor whiteColor];
        self.NewView.contentTwo.backgroundColor = [UIColor whiteColor];
        // 把appView添加到界面上
        [self.NewMainPushView addSubview:self.NewView];
    }
    //NSLog(@"主推房源新增View的个数: %ld, 行数: %ld",self.NewPushNums,self.NewPushRows);
    // 为mainPushView添加下划线
    CGFloat lineOneX = 0;
    CGFloat lineOneW = SCReenWidth;
    CGFloat lineOneH = 0.6;
    for (int i = 0; i <self.NewPushRows; i++) {
        UIView *mainPushLine = [[UIView alloc] init];
        CGFloat lineOneY = 44 +i *44;
        [self.NewMainPushView addSubview:mainPushLine];
        
        mainPushLine.frame = CGRectMake(lineOneX, lineOneY, lineOneW, lineOneH);
        mainPushLine.backgroundColor = [UIColor lightGrayColor];
    }
    
    // 刷新主推房源View的高度
    self.NewMainPushHeight.constant = 44 *self.NewPushRows;
    
    // 刷新View2的高度
    if (self.NewPushNums % 2 == 1 && self.NewPushNums > 4) { //新增一行,才加高度
        self.view2Height.constant = self.allView2Height +44;
        self.allView2Height = self.view2Height.constant;
        self.vHeight.constant = self.allHeight +44;
        self.allHeight = self.vHeight.constant;
    }
    
    if (self.NewPushNums <= 2 && self.NewPushNums > 0) {
        self.view2Height.constant = self.allView2Height - 44;
        self.allView2Height = self.view2Height.constant;
        self.vHeight.constant = self.allHeight -44;
        self.allHeight = self.vHeight.constant;
    }
    if (self.NewPushNums <= 0) {
        self.view2Height.constant = self.allView2Height - 88;
        self.allView2Height = self.view2Height.constant;
        self.vHeight.constant = self.allHeight - 88;
        self.allHeight = self.vHeight.constant;
    }
    NSLog(@"self.view2Height.constant=%f",self.view2Height.constant);
//    // 刷新整个scrollView的高度
//    if (self.NewPushNums % 2 == 1) { //新增一行,才加高度
//        self.vHeight.constant = self.allHeight +44;
//        self.allHeight = self.vHeight.constant;
        self.scrollView.contentSize = CGSizeMake(SCReenWidth, self.allHeight);
//    }
}



- (void)setupMainPushViewForEdit:(NSArray *)arr{
    
    if (arr.count == 0) {
        self.mainPushTip.hidden = YES;
    }
    // 假设一行有2个  创建数据个数4个
    int columns = 2;
    // 水平方向的间距
    CGFloat marginX = 10;
    self.mainPushNums = arr.count;
    // 假设每个view的宽度和高度一定
    CGFloat appW = (SCReenWidth -80 -2 *marginX) *0.5;
    CGFloat appH = 44;
    for (int i = 0; i < arr.count; i++) {
        self.pushView = [MainPushView initMainPushView];
        
        self.pushView.addBtn.hidden = YES;
        NSDictionary *dic = arr[i];
        self.pushView.contentOne.text = dic[@"h"];
        self.pushView.contentTwo.text = dic[@"r"];

        self.pushView.delegate = self;
        // 计算每个pushView所在的列的索引
        int col_idx = i % columns;
        // 计算每个pushView所在的行索引
        int row_idx = i / columns;
        self.mainPushRows = row_idx +1;
        
        // 计算每个pushView的x和y
        CGFloat appX = 80 +marginX + col_idx * (appW + marginX);
        CGFloat appY =  row_idx * appH ;
        self.pushView.frame = CGRectMake(appX, appY, appW, appH);
        self.pushView.contentOne.backgroundColor = [UIColor whiteColor];
        self.pushView.contentTwo.backgroundColor = [UIColor whiteColor];
//        self.pushView.titleOne.hidden = NO;
//        self.pushView.titleTwo.hidden = NO;
//        self.pushView.contentOne.hidden = NO;
//        self.pushView.contentTwo.hidden = NO;
        self.pushView.addBtn.hidden = YES;
        
        // 把appView添加到界面上
        [self.mainPushView addSubview:self.pushView];
    }
    //NSLog(@"主推房源View的的个数: %ld, 行数: %ld",self.mainPushNums,self.mainPushRows);
    // 为mainPushView添加下划线
    CGFloat lineOneX = 0;
    CGFloat lineOneW = SCReenWidth;
    CGFloat lineOneH = 0.6;
    for (int i = 0; i <self.mainPushRows; i++) {
        UIView *mainPushLine = [[UIView alloc] init];
        CGFloat lineOneY = 44 +i *44;
        [self.mainPushView addSubview:mainPushLine];
        mainPushLine.frame = CGRectMake(lineOneX, lineOneY, lineOneW, lineOneH);
        mainPushLine.backgroundColor = [UIColor lightGrayColor];
    }
    
    // 刷新主推房源View的高度
    self.mainPushHeight.constant = 44 * self.mainPushRows;
    
    // 刷新View2的高度
    if (self.mainPushNums % 2 == 1 && self.mainPushNums > 4) { //新增一行,才加高度
        self.view2Height.constant = self.allView2Height +44;
        self.allView2Height = self.view2Height.constant;
        self.vHeight.constant = self.allHeight + 44;
        self.allHeight = self.vHeight.constant;
    }
    if (self.mainPushNums <= 2 && self.mainPushNums > 0) {
        self.view2Height.constant = self.allView2Height - 44;
        self.allView2Height = self.view2Height.constant;
        self.vHeight.constant = self.allHeight - 44;
        self.allHeight = self.vHeight.constant;
    }
    //1220-88
    if (self.mainPushNums <= 0) {
        self.view2Height.constant = self.allView2Height - 88;
        self.allView2Height = self.view2Height.constant;
        self.vHeight.constant = self.allHeight - 88;
        self.allHeight = self.vHeight.constant;
    }
    NSLog(@"self.view2Height.constant=%f",self.view2Height.constant);
    
    // 刷新整个scrollView的高度
//    if (self.mainPushNums % 2 == 1) { //新增一行,才加高度
//        self.vHeight.constant = self.allHeight +44;
//        self.allHeight = self.vHeight.constant;
        self.scrollView.contentSize = CGSizeMake(SCReenWidth, self.allHeight);
//    }
    
}

- (void)textChangeModel2:(UITextField *)text{
    if (text.tag < 10000) {
        ZhutuiModel *model = self.newsZhutuiArr[text.tag];
        model.h = text.text;
    }else{
        ZhutuiModel *model = self.newsZhutuiArr[text.tag-10000];
        model.r = text.text;
    }
}

- (void)textChangeModel:(UITextField *)text{
    
    if (text.tag < 10000) {
        ZhutuiModel *model = self.zhutuiArr[text.tag];
        model.h = text.text;
    }else{
        ZhutuiModel *model = self.zhutuiArr[text.tag-10000];
        model.r = text.text;
    }
}

#pragma mark -- 2.0 处理新增主推房源的界面问题 尝试九宫格布局
- (void)setUpMainPushView {
    
    for (UIView *view in self.mainPushView.subviews) {
        if ([view isKindOfClass:[MainPushView class]]) {
            [view removeFromSuperview];
        }
        if (view.tag == 11111){
            [view removeFromSuperview];
        }
    }
    // 假设一行有2个  创建数据个数4个
    int columns = 2;
    // 水平方向的间距
    CGFloat marginX = 10;
    // 假设每个view的宽度和高度一定
    CGFloat appW = (SCReenWidth -80 -2 *marginX) *0.5;
    CGFloat appH = 44;
    for (int i = 0; i < self.mainPushNums; i++) {
        self.pushView = [MainPushView initMainPushView];
        if (i >= self.zhutuiArr.count) {
            ZhutuiModel *model = [[ZhutuiModel alloc]init];
            [self.zhutuiArr addObject:model];
        }else{
            ZhutuiModel *model = self.zhutuiArr[i];
            self.pushView.contentOne.text = model.h;
            self.pushView.contentTwo.text = model.r;
        }
        self.pushView.contentOne.tag = i;
        [self.pushView.contentOne addTarget:self action:@selector(textChangeModel:) forControlEvents:UIControlEventEditingChanged];
        self.pushView.contentTwo.tag = i+10000;
        [self.pushView.contentTwo addTarget:self action:@selector(textChangeModel:) forControlEvents:UIControlEventEditingChanged];
        self.pushView.delegate = self;
        // 计算每个pushView所在的列的索引
        int col_idx = i % columns;
        // 计算每个pushView所在的行索引
        int row_idx = i / columns;
        self.mainPushRows = row_idx +1;
        
        // 计算每个pushView的x和y
        CGFloat appX = 80 +marginX + col_idx * (appW + marginX);
        CGFloat appY =  row_idx * appH ;
        self.pushView.frame = CGRectMake(appX, appY, appW, appH);
        self.pushView.contentOne.backgroundColor = [UIColor whiteColor];
        self.pushView.contentTwo.backgroundColor = [UIColor whiteColor];
        if (i < self.mainPushNums -1) {
            self.pushView.titleOne.hidden = NO;
            self.pushView.titleTwo.hidden = NO;
            self.pushView.contentOne.hidden = NO;
            self.pushView.contentTwo.hidden = NO;
            self.pushView.addBtn.hidden = YES;
            
        } else {
            self.pushView.titleOne.hidden = YES;
            self.pushView.titleTwo.hidden = YES;
            self.pushView.contentOne.hidden = YES;
            self.pushView.contentTwo.hidden = YES;
            self.pushView.addBtn.hidden = NO;
            [self.pushView.contentOne removeFromSuperview];
            [self.pushView.contentTwo removeFromSuperview];
        }
        // 把appView添加到界面上
        [self.mainPushView addSubview:self.pushView];
    }
    NSLog(@"self.data = %ld",self.zhutuiArr.count);
    //NSLog(@"主推房源View的的个数: %ld, 行数: %ld",self.mainPushNums,self.mainPushRows);
    
    // 为mainPushView添加下划线
    CGFloat lineOneX = 0;
    CGFloat lineOneW = SCReenWidth;
    CGFloat lineOneH = 0.6;
    
    for (int i = 0; i <self.mainPushRows; i++) {
        UIView *mainPushLine = [[UIView alloc] init];
        mainPushLine.tag = 11111;
        CGFloat lineOneY = 44 +i *44;
        [self.mainPushView addSubview:mainPushLine];
        mainPushLine.frame = CGRectMake(lineOneX, lineOneY, lineOneW, lineOneH);
        mainPushLine.backgroundColor = [UIColor lightGrayColor];
    }
}

#pragma mark -- 2.1 处理"主推房源新增"的界面问题 尝试九宫格布局
- (void)setUpNewPushView {
    
    for (UIView *view in self.NewMainPushView.subviews) {
        if ([view isKindOfClass:[NewPushView class]]) {
            [view removeFromSuperview];
        }
        if (view.tag == 11111){
            [view removeFromSuperview];
        }
    }
    
    // 假设一行有2个  创建数据个数4个
    int columns = 2;
    // 水平方向的间距
    CGFloat marginX = 10;
    // 假设每个view的宽度和高度一定
    CGFloat appW = (SCReenWidth -90 -2 *marginX) *0.5;
    CGFloat appH = 44;
    for (int i = 0; i < self.NewPushNums; i++) {
        self.NewView = [NewPushView initNewPushView];
        
        if (i >= self.newsZhutuiArr.count) {
            ZhutuiModel *model = [[ZhutuiModel alloc]init];
            //            model.h = @"3";
            //            model.r = @"4";
            [self.newsZhutuiArr addObject:model];
        }else{
            ZhutuiModel *model = self.newsZhutuiArr[i];
            self.NewView.contentOne.text = model.h;
            self.NewView.contentTwo.text = model.r;
        }
        self.NewView.contentOne.tag = i;
        [self.NewView.contentOne addTarget:self action:@selector(textChangeModel2:) forControlEvents:UIControlEventEditingChanged];
        self.NewView.contentTwo.tag = i+10000;
        [self.NewView.contentTwo addTarget:self action:@selector(textChangeModel2:) forControlEvents:UIControlEventEditingChanged];
        
        self.NewView.delegate = self;
        // 计算每个pushView所在的列的索引
        int col_idx = i % columns;
        // 计算每个pushView所在的行索引
        int row_idx = i / columns;
        self.NewPushRows = row_idx +1;
        // 计算每个pushView的x和y
        CGFloat appX = 90 +marginX + col_idx * (appW + marginX);
        CGFloat appY =  row_idx * appH ;
        self.NewView.frame = CGRectMake(appX, appY, appW, appH);
        self.NewView.contentOne.backgroundColor = [UIColor whiteColor];
        self.NewView.contentTwo.backgroundColor = [UIColor whiteColor];
        if (i < self.NewPushNums -1) {
            self.NewView.titleOne.hidden = NO;
            self.NewView.titleTwo.hidden = NO;
            self.NewView.contentOne.hidden = NO;
            self.NewView.contentTwo.hidden = NO;
            self.NewView.addBtn.hidden = YES;
            
        } else {
            self.NewView.titleOne.hidden = YES;
            self.NewView.titleTwo.hidden = YES;
            self.NewView.contentOne.hidden = YES;
            self.NewView.contentTwo.hidden = YES;
            self.NewView.addBtn.hidden = NO;
            [self.NewView.contentOne removeFromSuperview];
            [self.NewView.contentTwo removeFromSuperview];
        }
        
        if (self.newsPushNumsArr.count != 0) {
            self.NewView.addBtn.hidden = NO;
            NSDictionary *dic = self.newsPushNumsArr[i];
            self.NewView.contentOne.text = dic[@"h"];
            self.NewView.contentTwo.text = dic[@"r"];
        }
        // 把appView添加到界面上
        [self.NewMainPushView addSubview:self.NewView];
    }
    //NSLog(@"主推房源新增View的个数: %ld, 行数: %ld",self.NewPushNums,self.NewPushRows);
    // 为mainPushView添加下划线
    CGFloat lineOneX = 0;
    CGFloat lineOneW = SCReenWidth;
    CGFloat lineOneH = 0.6;
    for (int i = 0; i <self.NewPushRows; i++) {
        UIView *mainPushLine = [[UIView alloc] init];
        mainPushLine.tag = 11111;
        CGFloat lineOneY = 44 +i *44;
        [self.NewMainPushView addSubview:mainPushLine];
        
        mainPushLine.frame = CGRectMake(lineOneX, lineOneY, lineOneW, lineOneH);
        mainPushLine.backgroundColor = [UIColor lightGrayColor];
    }
}

#pragma mark -- 点击按钮事件监听
//点击了标题类型
- (IBAction)didClickClassBtn:(UIButton *)sender {
    NSLog(@"点击了标题类型");
    self.pickerView.dataSource = @[@"日常总结",@"一周总结",@"一月总结",@"半年总结",@"一年总结"];
    self.pickerView.pickerTitle = @"请选择类型";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [weakSelf.oneCont2 setTitle:result forState:UIControlStateNormal];
    };
    [self.pickerView show];
}

//点击了提交按钮
- (IBAction)didClickSubmit:(UIButton *)sender {
    NSLog(@"点击了提交按钮");
    NSLog(@"self.tmp = %@",self.tmpArr);
    //模拟网络请求，请求参数配置
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    //1.0 第一部分 标题
    params[@"title"] = self.oneCont1.text;
    params[@"type"] = self.oneCont2.titleLabel.text;

    //2.0 第二部分 门店目前情况
    //2.1 人员编制
    if (self.twoCont11.text.length == 0 || self.twoCont12.text.length == 0 || self.twoCont13.text.length == 0 || self.twoCont14.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写门店人员编制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        params[@"staff_manager"] = self.twoCont11.text;
        params[@"staff_assistant"] = self.twoCont12.text;
        params[@"staff_salesman"] = self.twoCont13.text;
    }

    //2.2 端口编制
    if (self.twoCont21.text.length == 0 || self.twoCont22.text.length == 0 || self.twoCont23.text.length == 0 || self.twoCont24.text.length == 0 || self.twoCont25.text.length == 0 || self.twoCont26.text.length == 0|| self.twoCont315.text.length == 0 || self.twoCont316.text.length == 0 || self.twoCont317.text.length == 0 || self.twoCont318.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写门店端口编制" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        params[@"sf_port"] = self.twoCont21.text;
        params[@"sf_type"] = self.twoCont22.text;
        params[@"58_port"] = self.twoCont23.text;
        params[@"58_type"] = self.twoCont24.text;
        params[@"ajk_port"] = self.twoCont25.text;
        params[@"ajk_type"] = self.twoCont26.text;
        params[@"all_in_stock"] = self.twoCont315.text;
        params[@"fresh_num"] = self.twoCont316.text;
        params[@"per_in_stock"] = self.twoCont317.text;
        params[@"per_fresh"] = self.twoCont318.text;
        
    }
    //非必填
    
    params[@"365_port"] = self.twoCont27.text;
    params[@"365_type"] = self.twoCont28.text;
    params[@"twl_port"] = self.twoCont29.text;
    params[@"twl_type"] = self.twoCont310.text;
    params[@"dibao_port"] = self.twoCont311.text;
    params[@"dibao_type"] = self.twoCont312.text;
    params[@"gj_port"] = self.twoCont313.text;
    params[@"gj_type"] = self.twoCont314.text;
    
    //2.3 主推房源 取出主推房源中的value值
    [self.pushArray removeAllObjects];
    for (id object in [self.mainPushView subviews]) {
        if ([object isKindOfClass:[self.pushView class]]) {

            UIView * view = (UIView *)object;
            for (id obj in [view subviews]) {
                if ([obj isKindOfClass:[UITextField class]]) {
                    UITextField *field = obj;
                    [self.pushArray addObject:field.text];
                }
            }
        }
    }
    NSArray *pushArrM = nil;
    if (self.VcTag == 1) {
        NSRange range = NSMakeRange(self.pushArray.count -self.mainPushNums *2, self.mainPushNums *2);
        pushArrM = [self.pushArray subarrayWithRange:range];
    }else{
        NSRange range = NSMakeRange(self.pushArray.count -(self.mainPushNums -1) *2, (self.mainPushNums -1) *2);
        pushArrM = [self.pushArray subarrayWithRange:range];
    }
    //NSLog(@"range: %@",NSStringFromRange(range));
    
//    NSArray *pushArrM = [self.pushArray subarrayWithRange:range];
    
    NSString *recommend_house = @"";
    for (int i = 0; i < pushArrM.count; i += 2) {
        NSString *str = pushArrM[i];
        NSString *str1 = pushArrM[i+1];
        if (str.length != 0 || str1.length != 0) {
            NSString *tmpStr = [NSString stringWithFormat:@"%@*%@;",str,str1];
            recommend_house = [recommend_house stringByAppendingString:tmpStr];
        }
        
    }
    if (recommend_house.length > 1) {
        recommend_house = [recommend_house substringToIndex:recommend_house.length-1];
    }
    //NSLog(@"pushArrM: %@",pushArrM);
    params[@"recommend_house"] = recommend_house;
    NSLog(@"recommend_house单: %@",recommend_house);
    //2.4 主推房源新增
    [self.NewArray removeAllObjects];
    for (id objects in [self.NewMainPushView subviews]) {
        if ([objects isKindOfClass:[self.NewView class]]) {

            UIView * view = (UIView *)objects;
            for (id obj in [view subviews]) {
                if ([obj isKindOfClass:[UITextField class]]) {
                    
                    UITextField *field = obj;
                    [self.NewArray addObject:field.text];
                }
            }
        }
    }
    NSArray *newArrM = nil;
    if (self.VcTag == 1) {
        NSRange range2 = NSMakeRange(self.NewArray.count -self.NewPushNums *2, self.NewPushNums *2);
        newArrM = [self.NewArray subarrayWithRange:range2];
    }else{
        NSRange range2 = NSMakeRange(self.NewArray.count -(self.NewPushNums -1) *2, (self.NewPushNums -1) *2);
        newArrM = [self.NewArray subarrayWithRange:range2];
    }
 
    
    NSString *main_recommend_house = @"";
    for (int i = 0; i < newArrM.count; i += 2) {
        
        NSString *str = newArrM[i];
        NSString *str1 = newArrM[i+1];
        if (str.length != 0 || str1.length != 0) {
            NSString *tmpStr = [NSString stringWithFormat:@"%@*%@;",str,str1];
            main_recommend_house = [main_recommend_house stringByAppendingString:tmpStr];
        }
    }
    if (main_recommend_house.length > 1) {
        main_recommend_house = [main_recommend_house substringToIndex:main_recommend_house.length-1];
    }
    //NSLog(@"pushArrM: %@",pushArrM);
    params[@"main_recommend_house"] = main_recommend_house;
    NSLog(@"main_recommend_house: %@",main_recommend_house);
    
    //NSLog(@"newArrM: %@",newArrM);
//    params[@"main_recommend_house"] = newArrM;
     params[@"remain_problem"] = self.twoCont31.text;
    params[@"client_month_add"] = self.twoCont41.text;
    params[@"client_walkin"] = self.twoCont51.text;
    params[@"client_network"] = self.twoCont52.text;
    params[@"client_58tc"] = self.twoCont53.text;
    params[@"client_sf"] = self.twoCont54.text;
    params[@"work_method"] = self.twoCont61.text;
    
    params[@"focus_success"] = self.fourCont119.text;   //聚焦
    params[@"focus_fail"] = self.fourCont120.text;
    
    params[@"local"] = self.fourCont21.text;
    params[@"local_house"] = self.fourCont22.text;
    params[@"local_client"] = self.fourCont23.text;
    params[@"process_method"] = self.fourCont31.text;
    params[@"advices"] = self.sixCont2.text;
    
    //3.0 第三部分 月度目标
    if (self.threeCont1.text.length == 0 || self.threeCont2.text.length == 0 || self.threeCont3.text.length == 0 || self.threeCont4.text.length == 0 || self.threeCont5.text.length == 0 || self.threeCont6.text.length == 0 || self.threeCont7.text.length == 0 || self.threeCont8.text.length == 0 || self.threeCont9.text.length == 0 || self.threeCont10.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写月度目标" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        params[@"sell_orders"] = self.threeCont1.text;
        params[@"complete_sell_orders"] = self.threeCont2.text;
        params[@"rent_orders"] = self.threeCont3.text;
        params[@"complete_rent_orders"] = self.threeCont4.text;
        params[@"many_orders"] = self.threeCont5.text;
        params[@"complete_many_orders"] = self.threeCont6.text;
        params[@"exclusive_orders"] = self.threeCont7.text;
        params[@"complete_exclusive_orders"] = self.threeCont8.text;
        params[@"key_orders"] = self.threeCont9.text;
        params[@"complete_key_orders"] = self.threeCont10.text; 

    }

    //5.0 第五部分 意向单
    NSArray *arr = [self.tableView indexPathsForVisibleRows];
    NSLog(@"arr:------%ld",arr.count);
    
    NSString *intentionOrder = @"";
    for (YixiangdangModel *model in self.tmpArr) {
        if (model.textContent.length == 0 || model.name.length == 0) {
            [EBAlert alertError:@"请输入完整意向单内容" length:2.0f];
            return;
        }
        if (![model.textContent isEqualToString:@"选择客源编号"]) {  //选择客源编号
            NSString *tmpStr = [NSString stringWithFormat:@"%@*%@*%@;",model.name,model.client,model.textContent];
            intentionOrder = [intentionOrder stringByAppendingString:tmpStr];
        }
    }
    if (intentionOrder.length > 1) {
        intentionOrder = [intentionOrder substringToIndex:intentionOrder.length-1];
    }
    NSLog(@"意向单: %@",intentionOrder);
    if (_VcTag == 0) {
        params[@"wanting"] = intentionOrder;
    }

    //6.0 第六部分 其他部分
    if (self.sixCont1.text.length == 0 || self.sixCont3.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写其他部分数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    } else {
        params[@"getting"] = self.sixCont1.text;
        
        params[@"plans"] = self.sixCont3.text;
        
    }
    
    if (self.VcTag == 0) {//新增
        [params setObject:@"add" forKey:@"action"];
    }else{                //修改
        [params setObject:@"edit" forKey:@"action"];
        [params setObject:_document_id forKey:@"document_id"];//id
    }
    [params setObject:@"manager" forKey:@"tmp_type"];
    [params setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    
    NSLog(@"params:---%@",params);
    
    [self post:params];
}

#pragma mark -- tableView的数据源和代理
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.tmpArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    NSString *ID = [NSString stringWithFormat:@"Cell%ld%ld", (long)[indexPath section], (long)[indexPath row]];//以indexPath来唯一确定cell
    IntentionOrderCell *cell =[[IntentionOrderCell alloc]init];
//    [tableView dequeueReusableCellWithIdentifier:ID];
//    if (cell == nil) {
//        cell = [[IntentionOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
//        
//    }
    YixiangdangModel *model = self.tmpArr[indexPath.row];
    if (self.VcTag == 1) {
        cell.deleteImage.hidden = YES;
        cell.contentTextView.scrollEnabled = YES;
        [cell.contentTextView setEditable:NO];
        cell.tipLbl.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)model.textContent.length < 200 ?model.textContent.length : 200,200];
    }
    // 添加删除
    cell.deleteImage.tag = indexPath.row;
    UITapGestureRecognizer *tapDelete = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteImage:)];
    [cell.deleteImage addGestureRecognizer:tapDelete];
    
    cell.nameField.text = model.name;
    // 选择客源编号添加监听事件
    cell.chooseClientCodeBtn.tag = indexPath.row;
    [cell.chooseClientCodeBtn addTarget:self action:@selector(selectClientCode:) forControlEvents:UIControlEventTouchUpInside];
    if (model.client != nil) {
        [cell.chooseClientCodeBtn setTitle:model.client forState:UIControlStateNormal];
    }
    
    cell.contentTextView.tag = indexPath.row;
    cell.contentTextView.text = [model.textContent stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    cell.orderDelegate = self;
    //把单元格点击时状态 改为None
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -- orderDeledate
- (void)getContentViewText:(UITextView *)textView{
    YixiangdangModel *model = self.tmpArr[textView.tag];
    model.textContent = textView.text;
}

#pragma mark -- 点击了添加"意向单"
- (IBAction)didClickAddOrder:(UIButton *)sender {
    if (self.VcTag == 1) {
        [EBAlert alertError:@"查看模式下、不支持新增意向单" length:2.f];
        return;
    }
    
    // tableView行数加1
    self.rows++;
    YixiangdangModel *model = [[YixiangdangModel alloc]init];
    [self.tmpArr addObject:model];
    
    [self.tableView reloadData];
    
    //刷新意向单合计lbl
    self.intentionOrderTitle.text = [NSString stringWithFormat:@"意向单(%ld)",self.rows];
    
    // 刷新view5的高度
    self.view5Height.constant = 44 + self.rows *RowHeight + 70;
    
    self.vHeight.constant = self.allHeight + RowHeight;
    self.allHeight = self.vHeight.constant;
    self.scrollView.contentSize = CGSizeMake(SCReenWidth, self.allHeight);
    // 滚动到tableView底部
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows -1 inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
}

#pragma mark -- 点击了删除"意向单"
- (void)deleteImage:(UITapGestureRecognizer *)recognizer{
    NSLog(@"recognizer:--%ld,-----%@",recognizer.view.tag,recognizer.view.superview.superview);
    
    // tableView行数-1
    self.rows--;
    
    [self.tmpArr removeObject:self.tmpArr[recognizer.view.tag]];
    [self.tableView reloadData];
   
    //刷新意向单合计lbl
    self.intentionOrderTitle.text = [NSString stringWithFormat:@"意向单(%ld)",self.rows];
    
    // 刷新view5的高度
    self.view5Height.constant = 44 + self.rows *RowHeight + 70;
    
    self.vHeight.constant = self.allHeight -RowHeight;
    self.allHeight = self.vHeight.constant;
    self.scrollView.contentSize = CGSizeMake(SCReenWidth, self.allHeight);
    
}

#pragma mark -- 选择客源编号
- (void)selectClientCode:(UIButton *)btn{
    NSLog(@"点击了第 %ld 行的客源编号",btn.tag);
    if (_VcTag == 1) {
        [EBAlert alertError:@"查看模式下、不支持修改意向单" length:2.f];
        return;
    }
    // 处理界面跳转
    NSLog(@"btn = %@",btn.superview.superview);
    WorkSelectClientCodeViewController *wscv = [[WorkSelectClientCodeViewController alloc]init];
    wscv.hidesBottomBarWhenPushed = YES;
    wscv.returnBlock = ^(NSString *client_code, NSString * client_name){
        IntentionOrderCell *cell =(IntentionOrderCell *)btn.superview.superview;
        cell.nameField.text = client_name;
        [cell.chooseClientCodeBtn setTitle:client_code forState:UIControlStateNormal];
        
        YixiangdangModel *model = self.tmpArr[btn.tag];
        model.name = client_name;
        model.client = client_code;
        
    };
    [self.navigationController pushViewController:wscv animated:YES];
}


#pragma mark -- 3.0 处理view5意向单模块的高度
- (void)setUpView5Height {
    
    self.tableView.rowHeight = RowHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    //模拟默认行数
    self.rows = 0;
    self.view5Height.constant = 44 + self.rows *RowHeight + 70;
    
    self.vHeight.constant = ScrollFirstHeight -RowHeight + RowHeight *self.rows;
    self.allHeight = self.vHeight.constant;
    self.scrollView.contentSize = CGSizeMake(SCReenWidth, self.allHeight);
    
    self.intentionOrderTitle.text = [NSString stringWithFormat:@"意向单(%ld)",self.rows];
    
}

#pragma mark -- MainPushViewDelegate 主推房源 点击了加号
- (void)mainPushViewDidClickAddButton:(MainPushView *)mainPushView {
    //NSLog(@"点击了新增, 主推房源");
    
    self.mainPushNums++;
    
    [self setUpMainPushView];
    
    // 刷新主推房源View的高度
    self.mainPushHeight.constant = 44 *self.mainPushRows;
    
    // 刷新View2的高度
    if (self.mainPushNums % 2 == 1) { //新增一行,才加高度
        self.view2Height.constant = self.allView2Height +44;
        self.allView2Height = self.view2Height.constant;
        
    }
    
    // 刷新整个scrollView的高度
    if (self.mainPushNums % 2 == 1) { //新增一行,才加高度
        self.vHeight.constant = self.allHeight +44;
        self.allHeight = self.vHeight.constant;
        self.scrollView.contentSize = CGSizeMake(SCReenWidth, self.allHeight);
    }
    
}

#pragma mark -- NewPushViewDelegate 主推房源新增  点击了加号
- (void)NewPushViewDidClickAddButton:(NewPushView *)newPushView {
    //NSLog(@"点击了新增, 主推房源新增");
    
    self.NewPushNums++;
    
    [self setUpNewPushView];
    
    // 刷新主推房源View的高度
    self.NewMainPushHeight.constant = 44 *self.NewPushRows;
    
    // 刷新View2的高度
    if (self.NewPushNums % 2 == 1) { //新增一行,才加高度
        self.view2Height.constant = self.allView2Height +44;
        self.allView2Height = self.view2Height.constant;
    }
    
    // 刷新整个scrollView的高度
    if (self.NewPushNums % 2 == 1) { //新增一行,才加高度
        self.vHeight.constant = self.allHeight +44;
        self.allHeight = self.vHeight.constant;
        self.scrollView.contentSize = CGSizeMake(SCReenWidth, self.allHeight);
    }
    
    
}

#pragma mark -- 4.0 设置界面上All控件的字体大小及颜色
- (void)setControlsFontAndColor {
    CGFloat radius = 3;
    self.sixCont1.layer.cornerRadius = radius;
    self.sixCont1.clipsToBounds = YES;
    
    self.sixCont2.layer.cornerRadius = radius;
    self.sixCont2.clipsToBounds = YES;
    
    self.sixCont3.layer.cornerRadius = radius;
    self.sixCont3.clipsToBounds = YES;
    
    self.twoCont31.layer.cornerRadius = radius;
    self.twoCont31.clipsToBounds = YES;
    
    self.twoCont61.layer.cornerRadius = radius;
    self.twoCont61.clipsToBounds = YES;
    
    self.fourCont31.layer.cornerRadius = radius;
    self.fourCont31.clipsToBounds = YES;
    
}

#pragma mark -- 5.0 关于textView的设置,并且添加两个label,占位lbl与字数统计lbl (合计6个textView)
- (void)setUpTextViewAndAddSixLbls {
    
    UILabel *totalLbl1 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.twoCont31 addSubview:totalLbl1];
    self.totalLbl1 = totalLbl1;
    totalLbl1.text = [NSString stringWithFormat:@"0/%d字",TextCount500];
    totalLbl1.font = FontSys12;
    totalLbl1.textAlignment = NSTextAlignmentRight;
    totalLbl1.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeOne) name:UITextViewTextDidChangeNotification object:self.twoCont31];
    
    UILabel *totalLbl2 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.twoCont61 addSubview:totalLbl2];
    self.totalLbl2 = totalLbl2;
    totalLbl2.text = [NSString stringWithFormat:@"0/%d字",TextCount500];
    totalLbl2.font = FontSys12;
    totalLbl2.textAlignment = NSTextAlignmentRight;
    totalLbl2.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeTwo) name:UITextViewTextDidChangeNotification object:self.twoCont61];
    
    UILabel *totalLbl3 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.fourCont31 addSubview:totalLbl3];
    self.totalLbl3 = totalLbl3;
    totalLbl3.text = [NSString stringWithFormat:@"0/%d字",TextCount1000];
    totalLbl3.font = FontSys12;
    totalLbl3.textAlignment = NSTextAlignmentRight;
    totalLbl3.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeThree) name:UITextViewTextDidChangeNotification object:self.fourCont31];
    
    UILabel *totalLbl4 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.sixCont1 addSubview:totalLbl4];
    self.totalLbl4 = totalLbl4;
    totalLbl4.text = [NSString stringWithFormat:@"0/%d字",TextCount1000];
    totalLbl4.font = FontSys12;
    totalLbl4.textAlignment = NSTextAlignmentRight;
    totalLbl4.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeFour) name:UITextViewTextDidChangeNotification object:self.sixCont1];
    
    
    UILabel *totalLbl5 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.sixCont2 addSubview:totalLbl5];
    self.totalLbl5 = totalLbl5;
    totalLbl5.text = [NSString stringWithFormat:@"0/%d字",TextCount500];
    totalLbl5.font = FontSys12;
    totalLbl5.textAlignment = NSTextAlignmentRight;
    totalLbl5.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeFive) name:UITextViewTextDidChangeNotification object:self.sixCont2];
    
    
    UILabel *totalLbl6 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.sixCont3 addSubview:totalLbl6];
    self.totalLbl6 = totalLbl6;
    totalLbl6.text = [NSString stringWithFormat:@"0/%d字",TextCount1000];
    totalLbl6.font = FontSys12;
    totalLbl6.textAlignment = NSTextAlignmentRight;
    totalLbl6.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeSix) name:UITextViewTextDidChangeNotification object:self.sixCont3];
    
}

#pragma mark - 监听textView文字改变的通知
- (void)textChangeOne { //存在问题
    //实时显示字数
    self.totalLbl1.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.twoCont31.text.length,TextCount500];
    //字数限制操作
    if (self.twoCont31.text.length >= TextCount500) {
        self.twoCont31.text = [self.twoCont31.text substringToIndex:TextCount500];
        self.totalLbl1.text = [NSString stringWithFormat:@"%d/%d",TextCount500,TextCount500];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount500] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)textChangeTwo { //问题及改进办法
    //实时显示字数
    self.totalLbl2.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.twoCont61.text.length,TextCount500];
    //字数限制操作
    if (self.twoCont61.text.length >= TextCount500) {
        self.twoCont61.text = [self.twoCont61.text substringToIndex:TextCount500];
        self.totalLbl2.text = [NSString stringWithFormat:@"%d/%d",TextCount500,TextCount500];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount500] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)textChangeThree { //量化问题及改进办法
    //实时显示字数
    self.totalLbl3.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.fourCont31.text.length,TextCount1000];
    //字数限制操作
    if (self.fourCont31.text.length >= TextCount1000) {
        self.fourCont31.text = [self.fourCont31.text substringToIndex:TextCount1000];
        self.totalLbl3.text = [NSString stringWithFormat:@"%d/%d",TextCount1000,TextCount1000];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount1000] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)textChangeFour { //今日工作心得
    //实时显示字数
    self.totalLbl4.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.sixCont1.text.length,TextCount1000];
    //字数限制操作
    if (self.sixCont1.text.length >= TextCount1000) {
        self.sixCont1.text = [self.sixCont1.text substringToIndex:TextCount1000];
        self.totalLbl4.text = [NSString stringWithFormat:@"%d/%d",TextCount1000,TextCount1000];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount1000] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)textChangeFive { //对区域和公司的建议
    //实时显示字数
    self.totalLbl5.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.sixCont2.text.length,TextCount500];
    //字数限制操作
    if (self.sixCont2.text.length >= TextCount500) {
        self.sixCont2.text = [self.sixCont2.text substringToIndex:TextCount500];
        self.totalLbl5.text = [NSString stringWithFormat:@"%d/%d",TextCount500,TextCount500];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount500] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)textChangeSix { //次日计划(不低于三条)
    //实时显示字数
    self.totalLbl6.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.sixCont3.text.length,TextCount1000];
    //字数限制操作
    if (self.sixCont3.text.length >= TextCount1000) {
        self.sixCont3.text = [self.sixCont3.text substringToIndex:TextCount1000];
        self.totalLbl6.text = [NSString stringWithFormat:@"%d/%d",TextCount1000,TextCount1000];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount1000] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -- 懒加载
- (NSMutableArray *)pushArray {
    if (_pushArray == nil) {
        _pushArray = [NSMutableArray array];
    }
    return _pushArray;
}
- (NSMutableArray *)NewArray {
    if (_NewArray == nil) {
        _NewArray = [NSMutableArray array];
    }
    return _NewArray;
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















