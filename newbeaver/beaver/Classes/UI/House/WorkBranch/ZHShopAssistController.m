//
//  ZHShopAssistController.m
//  中环经纪人助手-工作总结
//
//  Created by 刘海伟 on 2018/1/15.
//  Copyright © 2018年 liuhaiwei. All rights reserved.
//
//  工作总结-店助

#import "ZHShopAssistController.h"
#import "AnnotateView.h"
#import "LSXAlertInputView.h"

#define TextCount1000 1000
#define TextCount500 500
#define MemoHeight 240

@interface ZHShopAssistController ()<UIScrollViewDelegate>

@property (nonatomic, strong)ValuePickerView *pickerView;

@property (nonatomic, strong)AnnotateView *annotateView;
@property (nonatomic, strong)AnnotateView *commentView;

@property (nonatomic, strong)UIView *annotateCommentView;//批注点评

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fiveViewHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *Vheight;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *add_button_y;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottom;//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vWidth;//
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vHeight;//

@property (weak, nonatomic) IBOutlet UIView *bgView;

/** 第一部分 标题栏 */
@property (weak, nonatomic) IBOutlet UILabel *oneTitle1;
@property (weak, nonatomic) IBOutlet UILabel *oneTitle2;
@property (weak, nonatomic) IBOutlet UITextField *oneContent1;
@property (weak, nonatomic) IBOutlet UIButton *oneContent2;

/** 第二部分 业绩栏 */
@property (weak, nonatomic) IBOutlet UILabel *twoTitle;
@property (weak, nonatomic) IBOutlet UILabel *twoTitle1;
@property (weak, nonatomic) IBOutlet UILabel *twoTitle2;
@property (weak, nonatomic) IBOutlet UILabel *twoTitle3;
@property (weak, nonatomic) IBOutlet UILabel *twoTitle4;
@property (weak, nonatomic) IBOutlet UITextField *twoContent1;
@property (weak, nonatomic) IBOutlet UITextField *twoContent2;

/** 第三部分 今日量化与资源 */
//客增, 房增, 带看...
@property (weak, nonatomic) IBOutlet UILabel *threeTitle;

@property (weak, nonatomic) IBOutlet UILabel *threeTitle1;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle2;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle3;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle4;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle5;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle6;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle7;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle8;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle9;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle10; //拍照
//今日: 标题
@property (weak, nonatomic) IBOutlet UILabel *threeTitle11;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle12;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle13;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle14;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle15;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle16;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle17;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle18;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle19;

//本月: 标题
@property (weak, nonatomic) IBOutlet UILabel *threeTitle21;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle22;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle23;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle24;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle25;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle26;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle27;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle28;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle29;

//今日的内容
@property (weak, nonatomic) IBOutlet UITextField *threeContent1;
@property (weak, nonatomic) IBOutlet UITextField *threeContent2;
@property (weak, nonatomic) IBOutlet UITextField *threeContent3;
@property (weak, nonatomic) IBOutlet UITextField *threeContent4;
@property (weak, nonatomic) IBOutlet UITextField *threeContent5;
@property (weak, nonatomic) IBOutlet UITextField *threeContent6;
@property (weak, nonatomic) IBOutlet UITextField *threeContent7;
@property (weak, nonatomic) IBOutlet UITextField *threeContent8;
@property (weak, nonatomic) IBOutlet UITextField *threeContent9;
@property (weak, nonatomic) IBOutlet UITextField *threeContent10; //拍照

//本月的内容
@property (weak, nonatomic) IBOutlet UITextField *threeContent11;
@property (weak, nonatomic) IBOutlet UITextField *threeContent12;
@property (weak, nonatomic) IBOutlet UITextField *threeContent13;
@property (weak, nonatomic) IBOutlet UITextField *threeContent14;
@property (weak, nonatomic) IBOutlet UITextField *threeContent15;
@property (weak, nonatomic) IBOutlet UITextField *threeContent16;
@property (weak, nonatomic) IBOutlet UITextField *threeContent17;
@property (weak, nonatomic) IBOutlet UITextField *threeContent18;
@property (weak, nonatomic) IBOutlet UITextField *threeContent19;


//拍照所遇情况
@property (weak, nonatomic) IBOutlet UILabel *threeTitle02;
@property (weak, nonatomic) IBOutlet UITextView *threeTextView;
//驻守位置
@property (weak, nonatomic) IBOutlet UILabel *threeTitle03;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle04;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle05;
@property (weak, nonatomic) IBOutlet UILabel *threeTitle06;
@property (weak, nonatomic) IBOutlet UITextField *threeContent05; //房
@property (weak, nonatomic) IBOutlet UITextField *threeContent06; //客
@property (weak, nonatomic) IBOutlet UITextField *threeContent07; //驻守位置

//以上量化问题及改进方法
@property (weak, nonatomic) IBOutlet UILabel *threeTitle07;
@property (weak, nonatomic) IBOutlet UITextView *threeTextView02;


/** 第四部分 端口编制 */
@property (weak, nonatomic) IBOutlet UILabel *fourTitle;

/** 搜房--赶集 */
@property (weak, nonatomic) IBOutlet UILabel *fourTitle11;
@property (weak, nonatomic) IBOutlet UILabel *fourTitle12;
@property (weak, nonatomic) IBOutlet UILabel *fourTitle13;
@property (weak, nonatomic) IBOutlet UILabel *fourTitle14;
@property (weak, nonatomic) IBOutlet UILabel *fourTitle15;
@property (weak, nonatomic) IBOutlet UILabel *fourTitle16;
@property (weak, nonatomic) IBOutlet UILabel *fourTitle17;
@property (weak, nonatomic) IBOutlet UITextField *fourCont21; //端口
@property (weak, nonatomic) IBOutlet UITextField *fourCont22;
@property (weak, nonatomic) IBOutlet UITextField *fourCont23;
@property (weak, nonatomic) IBOutlet UITextField *fourCont24;
@property (weak, nonatomic) IBOutlet UITextField *fourCont25;
@property (weak, nonatomic) IBOutlet UITextField *fourCont26;
@property (weak, nonatomic) IBOutlet UITextField *fourCont27;

@property (weak, nonatomic) IBOutlet UITextField *fourCont31; //刷新
@property (weak, nonatomic) IBOutlet UITextField *fourCont32;
@property (weak, nonatomic) IBOutlet UITextField *fourCont33;
@property (weak, nonatomic) IBOutlet UITextField *fourCont34;
@property (weak, nonatomic) IBOutlet UITextField *fourCont35;
@property (weak, nonatomic) IBOutlet UITextField *fourCont36;
@property (weak, nonatomic) IBOutlet UITextField *fourCont37;

/** 共库存-完成 */
@property (weak, nonatomic) IBOutlet UITextField *fourCont41;
@property (weak, nonatomic) IBOutlet UITextField *fourCont42;
@property (weak, nonatomic) IBOutlet UITextField *fourCont43;
@property (weak, nonatomic) IBOutlet UITextField *fourCont44;
@property (weak, nonatomic) IBOutlet UITextField *fourCont45;
@property (weak, nonatomic) IBOutlet UITextField *fourCont46;
@property (weak, nonatomic) IBOutlet UITextField *fourCont47;
@property (weak, nonatomic) IBOutlet UITextField *fourCont48;


/** 第五部分 其他部分 */
@property (weak, nonatomic) IBOutlet UILabel *fiveTitle;

//工作心得体会
@property (weak, nonatomic) IBOutlet UILabel *fiveTitle1;
@property (weak, nonatomic) IBOutlet UITextView *fiveTextView1;
//对门店和区域的建议
@property (weak, nonatomic) IBOutlet UILabel *fiveTitle2;
@property (weak, nonatomic) IBOutlet UITextView *fiveTextView2;
//次日计划
@property (weak, nonatomic) IBOutlet UILabel *fiveTitle3;
@property (weak, nonatomic) IBOutlet UITextView *fiveTextView3;

@property (nonatomic, strong) UILabel *totalLbl1;

@property (nonatomic, strong) UILabel *totalLbl2;

@property (nonatomic, strong) UILabel *totalLbl3;

@property (nonatomic, strong) UILabel *totalLbl4;

@property (nonatomic, strong) UILabel *totalLbl5;

@property (nonatomic, strong) UILabel *totalLbl6;

@property (nonatomic, strong) UILabel *totalLbl7;

@property (nonatomic, weak)UIButton * annotate;
@property (nonatomic, weak)UIButton * comment;

@end

@implementation ZHShopAssistController

- (AnnotateView *)commentView{
    if (!_commentView) {
        _commentView = [[AnnotateView alloc]initWithFrame:CGRectMake(0, self.footerView.height-self.submitBtn.height, kScreenW, 180)];
        NSLog(@"_commentView=%@",_commentView);
        _commentView.title.text = @"点评";
    }
    return _commentView;
}

- (AnnotateView *)annotateView{
    if (!_annotateView) {
        _annotateView = [[AnnotateView alloc]initWithFrame:CGRectMake(0, self.footerView.height-self.submitBtn.height, kScreenW, 180)];
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
    self.footerView.height += height;
    NSLog(@"self.bgView.height=%f",self.bgView.height);

    NSLog(@"self.bgView.height=%f",self.bgView.height);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.add_button_y.constant += height;
    }];
    
    [self.footerView addSubview:self.commentView];
   
    _commentView.mainTextView.text =[dic[@"comment"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"] ;
    self.footerView.height += height;
    NSLog(@"self.bgView.height=%f",self.bgView.height);
    NSLog(@"self.bgView.height=%f",self.bgView.height);
    [UIView animateWithDuration:0.5f animations:^{
        self.add_button_y.constant += height+20;
    }];
    self.scrollView.contentSize = CGSizeMake(kScreenW, self.scrollView.contentSize.height + 60);
}
- (void)resetEditData:(NSDictionary *)dic{;
    // 必填
    _oneContent1.text = dic[@"title"];
    _oneContent2.titleLabel.text = dic[@"type"];
    _twoContent1.text = dic[@"goal_month"];
    _twoContent2.text = dic[@"truly_month"];
    
    _threeContent10.text = dic[@"photos"];//照片
    
    _threeTextView.text = [dic[@"photo_problem"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];//拍照遇到的情况
     self.totalLbl1.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.threeTextView.text.length,TextCount1000];
    _threeContent07.text = dic[@"local"];//驻守位置
    _threeContent05.text = dic[@"local_house"];//驻守房
    _threeContent06.text = dic[@"local_client"];//驻守客
    _threeTextView02.text = [dic[@"process_method"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];//量化数据问题
    self.totalLbl2.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.threeTextView02.text.length,TextCount1000];
    
    //端口
    _fourCont21.text = dic[@"sf_port"];    //搜房端口
    _fourCont22.text = dic[@"58_port"];    //58端口
    _fourCont23.text = dic[@"ajk_port"];   //安居客端口
    
    _fourCont31.text = dic[@"sf_type"];    //搜房刷新
    _fourCont32.text = dic[@"58_type"];    //58刷新
    _fourCont33.text = dic[@"ajk_type"];   //安居客刷新
    
    _fourCont41.text = dic[@"all_in_stock"];    //共库存
    _fourCont42.text = dic[@"fresh_num"];    //刷新
    _fourCont43.text = dic[@"per_in_stock"];   //人均库存
    _fourCont44.text = dic[@"per_fresh"];   //人均刷新
    _fourCont45.text = dic[@"add_new_goal"];   //新增目标
    _fourCont46.text = dic[@"complete_new_goal"]; //新增目标完成
    _fourCont47.text = dic[@"add_fresh_num"];    //刷新目标
    _fourCont48.text = dic[@"fresh_complete_num"];    //完成目标（刷新）
    _fiveTextView1.text = [dic[@"getting"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"] ;  //工作心得体会
    
    _fiveTextView2.text = [dic[@"advices"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];  //对门店和区域的建议
    _fiveTextView3.text = [dic[@"plans"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];  //次日计划
    
    self.totalLbl3.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.fiveTextView1.text.length,TextCount1000];
    self.totalLbl4.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.fiveTextView2.text.length,TextCount500];
    self.totalLbl5.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.fiveTextView3.text.length,TextCount1000];
    //非必填
    _fourCont24.text = dic[@"365_port"];   //365端口
    _fourCont25.text = dic[@"twl_port"];   //泰无聊端口
    _fourCont26.text = dic[@"dibao_port"]; //地保端口
    _fourCont27.text = dic[@"gj_port"];    //赶集端口
    _fourCont34.text = dic[@"365_type"];   //365刷新
    _fourCont35.text = dic[@"twl_type"];   //泰无聊刷新
    _fourCont36.text = dic[@"dibao_type"]; //地保刷新
    _fourCont37.text = dic[@"gj_type"];    //赶集刷新
    
    
    _oneContent1.text = dic[@"title"];
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
    _threeContent1.text = dayData[@"clientCount"];
    _threeContent2.text = dayData[@"houseCount"];
    _threeContent3.text = dayData[@"followCount"];
    _threeContent4.text = dayData[@"surveyCount"];
    _threeContent5.text = dayData[@"entrustCount"];
    _threeContent6.text = dayData[@"exclusiveCount"];
    _threeContent7.text = dayData[@"focusCount"];
    _threeContent8.text = dayData[@"keyCount"];
    _threeContent9.text = dayData[@"salePriceCount"];
    
    _threeContent11.text = monthData[@"clientCount"];
    _threeContent12.text = monthData[@"houseCount"];
    _threeContent13.text = monthData[@"followCount"];
    _threeContent14.text = monthData[@"surveyCount"];
    _threeContent15.text = monthData[@"entrustCount"];
    _threeContent16.text = monthData[@"exclusiveCount"];
    _threeContent17.text = monthData[@"focusCount"];
    _threeContent18.text = monthData[@"keyCount"];
    _threeContent19.text = monthData[@"salePriceCount"];
    //标题
    if (self.VcTag == 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
        _oneContent1.text = [NSString stringWithFormat:@"%@-%@工作总结【%@】",[EBPreferences sharedInstance].dept_name,[EBPreferences sharedInstance].userName,currentDateStr];
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

#pragma mark -- 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"店助的工作总结";
//    self.view.backgroundColor = RGB(235, 235, 235);
    self.bgView.backgroundColor = RGB(235, 235, 235);
    self.footerView.backgroundColor = [UIColor whiteColor];
    self.vWidth.constant = SCReenWidth;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
    if (self.VcTag == 0) { //新增
        
        self.vHeight.constant = 2568-360;
        [self resetAddData:self.dayData month:self.monthData];
    } else if (self.VcTag == 1) { //有批注,点评权限的人进入
        [_submitBtn setTitle:@"修改" forState:UIControlStateNormal];
        _submitBtn.hidden = YES;
        [self.view addSubview:self.annotateCommentView];
        [self requestData];

    }
    //2.0 关于textView的设置,并且添加两个label,占位lbl与字数统计lbl (合计5个textView)
    [self setUpTextViewAndAddTwoLbls];
    
    //3.0 设置界面上All控件的字体大小及颜色
    [self setControlsFontAndColor];
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

#pragma mark -- 点击事件监听
- (IBAction)didClickTaskClass:(UIButton *)sender {
    NSLog(@"点击了工作类型");
    
    self.pickerView.dataSource = @[@"日常总结",@"一周总结",@"一月总结",@"半年总结",@"一年总结"];
    self.pickerView.pickerTitle = @"请选择类型";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [weakSelf.oneContent2 setTitle:result forState:UIControlStateNormal];
    };
    [self.pickerView show];
}
- (IBAction)didClickSubmit:(UIButton *)sender {
    NSLog(@"点击了提交");
    
    //模拟网络请求，请求参数配置
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.VcTag == 0) {//新增
        [params setObject:@"add" forKey:@"action"];
    }else{                //修改
        [params setObject:@"edit" forKey:@"action"];
        [params setObject:_document_id forKey:@"document_id"];//id
    }
    //1.0 第一部分 标题
    [params setObject:@"assistant" forKey:@"tmp_type"];
    [params setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    
    params[@"title"] = self.oneContent1.text;
    params[@"type"] = self.oneContent2.titleLabel.text;
    
    //2.0 第二部分 业绩部分
    if (self.twoContent1.text.length == 0 || self.twoContent2.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写业绩数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
        
    } else {
        params[@"goal_month"] = self.twoContent1.text;
        params[@"truly_month"] = self.twoContent2.text;
    }
    
    //房增-议价，传过来
    params[@"photos"] = self.threeContent10.text;
        
    params[@"photo_problem"] = self.threeTextView.text; //拍照所遇情况
    params[@"local"] = self.threeContent07.text; //驻守位置
        params[@"local_house"] = self.threeContent05.text;
    params[@"local_client"] = self.threeContent06.text;
    params[@"process_method"] = self.threeTextView02.text; //量化问题及改进方法

    //4.0 第四部分 端口编制
    if (self.fourCont21.text.length == 0 || self.fourCont22.text.length == 0 || self.fourCont23.text.length == 0 || self.fourCont31.text.length == 0 || self.fourCont32.text.length == 0 || self.fourCont33.text.length == 0 || self.fourCont41.text.length == 0 || self.fourCont42.text.length == 0 || self.fourCont43.text.length == 0 || self.fourCont44.text.length == 0 || self.fourCont45.text.length == 0 || self.fourCont46.text.length == 0 || self.fourCont47.text.length == 0 || self.fourCont48.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写端口编制数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
         return;
    } else {
        params[@"sf_port"] = self.fourCont21.text;
        params[@"58_port"] = self.fourCont22.text;
        params[@"ajk_port"] = self.fourCont23.text;
        

        params[@"sf_type"] = self.fourCont31.text;
        params[@"58_type"] = self.fourCont32.text;
        params[@"ajk_type"] = self.fourCont33.text;
       
        
        params[@"all_in_stock"] = self.fourCont41.text;
        params[@"fresh_num"] = self.fourCont42.text;
        params[@"per_in_stock"] = self.fourCont43.text;
        params[@"per_fresh"] = self.fourCont44.text;
        params[@"add_new_goal"] = self.fourCont45.text;
        params[@"complete_new_goal"] = self.fourCont46.text;
        params[@"add_fresh_num"] = self.fourCont47.text;
        params[@"fresh_complete_num"] = self.fourCont48.text;
        
    }
    
    params[@"365_port"] = self.fourCont24.text;
    params[@"twl_port"] = self.fourCont25.text;
    params[@"dibao_port"] = self.fourCont26.text;
    params[@"gj_port"] = self.fourCont27.text;
    params[@"365_type"] = self.fourCont34.text;
    params[@"twl_type"] = self.fourCont35.text;
    params[@"dibao_type"] = self.fourCont36.text;
    params[@"gj_type"] = self.fourCont37.text;
    
    //5.0 第五部分 其他部分
    if (self.fiveTextView1.text.length == 0 || self.fiveTextView3.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请您填写其他部分数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
         return;
    } else {
        params[@"getting"] = self.fiveTextView1.text;
  
        params[@"plans"] = self.fiveTextView3.text;
    }
    params[@"advices"] = self.fiveTextView2.text;
    NSLog(@"params:---%@",params);
    [self post:params];
}

#pragma mark -- 2.0 关于textView的设置,并且添加两个label,占位lbl与字数统计lbl (合计5个textView)
- (void)setUpTextViewAndAddTwoLbls {
    
    //2.1 第三部分-1 拍照所遇情况textView, 设置占位label和字数统计label
    UILabel *totalLbl1 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.threeTextView addSubview:totalLbl1];
    self.totalLbl1 = totalLbl1;
    totalLbl1.text = [NSString stringWithFormat:@"0/%d字",TextCount1000];
    totalLbl1.font = FontSys12;
    totalLbl1.textAlignment = NSTextAlignmentRight;
    totalLbl1.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeOne) name:UITextViewTextDidChangeNotification object:self.threeTextView];
    
    //2.2 第三部分-2 以上量化问题及改进方法, 设置占位label和字数统计label
    UILabel *totalLbl2 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.threeTextView02 addSubview:totalLbl2];
    self.totalLbl2 = totalLbl2;
    totalLbl2.text = [NSString stringWithFormat:@"0/%d字",TextCount1000];
    totalLbl2.font = FontSys12;
    totalLbl2.textAlignment = NSTextAlignmentRight;
    totalLbl2.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeTwo) name:UITextViewTextDidChangeNotification object:self.threeTextView02];
    
    //2.3 第五部分-1 工作心得体会, 设置占位label和字数统计label
    
    UILabel *totalLbl3 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.fiveTextView1 addSubview:totalLbl3];
    self.totalLbl3 = totalLbl3;
    totalLbl3.text = [NSString stringWithFormat:@"0/%d字",TextCount1000];
    totalLbl3.font = FontSys12;
    totalLbl3.textAlignment = NSTextAlignmentRight;
    totalLbl3.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeThree) name:UITextViewTextDidChangeNotification object:self.fiveTextView1];
    
    //2.4 第五部分-2 对门店和区域的建议, 设置占位label和字数统计label
    
    UILabel *totalLbl4 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.fiveTextView2 addSubview:totalLbl4];
    self.totalLbl4 = totalLbl4;
    totalLbl4.text = [NSString stringWithFormat:@"0/%d字",TextCount500];
    totalLbl4.font = FontSys12;
    totalLbl4.textAlignment = NSTextAlignmentRight;
    totalLbl4.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeFour) name:UITextViewTextDidChangeNotification object:self.fiveTextView2];
    
    //2.5 第五部分-3 次日计划(不低于三条), 设置占位label和字数统计label
    UILabel *totalLbl5 = [[UILabel alloc] initWithFrame:CGRectMake(SCReenWidth -30 -80, 82, 80, 22)];
    [self.fiveTextView3 addSubview:totalLbl5];
    self.totalLbl5 = totalLbl5;
    totalLbl5.text = [NSString stringWithFormat:@"0/%d字",TextCount1000];
    totalLbl5.font = FontSys12;
    totalLbl5.textAlignment = NSTextAlignmentRight;
    totalLbl5.textColor = RGB128;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChangeFive) name:UITextViewTextDidChangeNotification object:self.fiveTextView3];
}

#pragma mark - 监听textView文字改变的通知
- (void)textChangeOne { //拍照所遇情况
    //实时显示字数
    self.totalLbl1.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.threeTextView.text.length,TextCount1000];
    //字数限制操作
    if (self.threeTextView.text.length >= TextCount1000) {
        self.threeTextView.text = [self.threeTextView.text substringToIndex:TextCount1000];
        self.totalLbl1.text = [NSString stringWithFormat:@"%d/%d",TextCount1000,TextCount1000];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount1000] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)textChangeTwo { //量化问题及改进方法
    //实时显示字数
    self.totalLbl2.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.threeTextView02.text.length,TextCount1000];
    //字数限制操作
    if (self.threeTextView02.text.length >= TextCount1000) {
        self.threeTextView02.text = [self.threeTextView02.text substringToIndex:TextCount1000];
        self.totalLbl2.text = [NSString stringWithFormat:@"%d/%d",TextCount1000,TextCount1000];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount1000] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)textChangeThree { //工作心得体会
    //实时显示字数
    self.totalLbl3.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.fiveTextView1.text.length,TextCount1000];
    //字数限制操作
    if (self.fiveTextView1.text.length >= TextCount1000) {
        self.fiveTextView1.text = [self.fiveTextView1.text substringToIndex:TextCount1000];
        self.totalLbl3.text = [NSString stringWithFormat:@"%d/%d",TextCount1000,TextCount1000];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount1000] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)textChangeFour { //对门店和区域的建议
    //实时显示字数
    self.totalLbl4.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.fiveTextView2.text.length,TextCount500];
    //字数限制操作
    if (self.fiveTextView2.text.length >= TextCount500) {
        self.fiveTextView2.text = [self.fiveTextView2.text substringToIndex:TextCount500];
        self.totalLbl4.text = [NSString stringWithFormat:@"%d/%d",TextCount500,TextCount500];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount500] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}
- (void)textChangeFive { //次日计划
    //实时显示字数
    self.totalLbl5.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.fiveTextView3.text.length,TextCount1000];
    //字数限制操作
    if (self.fiveTextView3.text.length >= TextCount1000) {
        self.fiveTextView3.text = [self.fiveTextView3.text substringToIndex:TextCount1000];
        self.totalLbl5.text = [NSString stringWithFormat:@"%d/%d",TextCount1000,TextCount1000];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",TextCount1000] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- 3.0 设置界面上All控件的字体大小及颜色
- (void)setControlsFontAndColor {
    self.threeTextView.layer.cornerRadius = 3;
    self.threeTextView.clipsToBounds = YES;

    self.threeTextView02.layer.cornerRadius = 3;
    self.threeTextView02.clipsToBounds = YES;

    self.fiveTextView1.layer.cornerRadius = 3;
    self.fiveTextView1.clipsToBounds = YES;

    self.fiveTextView2.layer.cornerRadius = 3;
    self.fiveTextView2.clipsToBounds = YES;

    self.fiveTextView3.layer.cornerRadius = 3;
    self.fiveTextView3.clipsToBounds = YES;
}


@end



