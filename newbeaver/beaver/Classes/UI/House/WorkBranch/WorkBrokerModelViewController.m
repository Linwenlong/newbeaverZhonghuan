//
//  WorkBrokerModelViewController.m
//  beaver
//
//  Created by mac on 18/1/17.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "WorkBrokerModelViewController.h"
#import "WorkBrokerTableViewCell.h"
#import "WorkSelectClientCodeViewController.h"
#import "AnnotateView.h"
#import "BrokerInsertView.h"
#import "LSXAlertInputView.h"

@interface WorkBrokerModelViewController ()<UITextViewDelegate>

@property (nonatomic, strong)UIScrollView *mainScrollView;

@property (nonatomic, strong)NSMutableArray *dataArray;//数据

@property (nonatomic, strong)NSMutableArray *tmpDataArray;//数据
@property (nonatomic, strong)NSMutableDictionary *tmpDateDic;//字典

@property (nonatomic, strong)NSArray<UIView * > * textsArr;

//@property (nonatomic, strong)UIButton *add_button;//新增报备
@property (weak, nonatomic) IBOutlet UIButton *add_button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *add_button_y;

@property (nonatomic, strong)UIView *annotateCommentView;//批注点评

@property (nonatomic, strong)AnnotateView *annotateView;
@property (nonatomic, strong)AnnotateView *commentView;

@property (nonatomic, weak)UIView *headerView;
@property (nonatomic, weak)UIView *footerView;

@property (nonatomic, strong)ValuePickerView *pickerView;

//xib headerView
@property (weak, nonatomic) IBOutlet UITextField *headerTitle;//标题
@property (weak, nonatomic) IBOutlet UIButton *typeButton;//日报类型

@property (weak, nonatomic) IBOutlet UITextField *monthDan;//月度目标
@property (weak, nonatomic) IBOutlet UITextField *dayDan;//实际完成
//resource（后台获取）
@property (weak, nonatomic) IBOutlet UILabel *clientAdd;//客增
@property (weak, nonatomic) IBOutlet UILabel *houseAdd;//房增
@property (weak, nonatomic) IBOutlet UILabel *see;  //带看
@property (weak, nonatomic) IBOutlet UILabel *reconnoitre;  //勘察
@property (weak, nonatomic) IBOutlet UILabel *manyof;   //多家
@property (weak, nonatomic) IBOutlet UILabel *singleof; //独家
@property (weak, nonatomic) IBOutlet UILabel *focus;    //聚焦
@property (weak, nonatomic) IBOutlet UILabel *keyData;//聚焦
@property (weak, nonatomic) IBOutlet UILabel *negotiatePrice;//议价
@property (weak, nonatomic) IBOutlet UITextField *photos;

@property (weak, nonatomic) IBOutlet UITextView *takepictureReason;//拍照情况
@property (weak, nonatomic) IBOutlet UILabel *takepictureReasonTip;

@property (weak, nonatomic) IBOutlet UITextField *garrisonAddress;//驻守位置
@property (weak, nonatomic) IBOutlet UITextView *local_source;
@property (weak, nonatomic) IBOutlet UILabel *local_source_tip;

@property (weak, nonatomic) IBOutlet UITextView *quantifyReason;//量化问题
@property (weak, nonatomic) IBOutlet UILabel *quantifyReasonTip;
//网络端口
@property (weak, nonatomic) IBOutlet UITextField *networkAdd;//新增
@property (weak, nonatomic) IBOutlet UITextField *networkAddReality;//新增完成

@property (weak, nonatomic) IBOutlet UITextField *newworkRefresh;//刷新
@property (weak, nonatomic) IBOutlet UITextField *newworkRefreshReality;//刷新完成
//xib FooterView
@property (weak, nonatomic) IBOutlet UITextView *perception;//工作心得
@property (weak, nonatomic) IBOutlet UILabel *perceptionTip;

@property (weak, nonatomic) IBOutlet UITextView *idea;//意见
@property (weak, nonatomic) IBOutlet UILabel *ideaTip;

@property (weak, nonatomic) IBOutlet UITextView *plan;//计划
@property (weak, nonatomic) IBOutlet UILabel *planTip;

@property (weak, nonatomic) IBOutlet UILabel *yixiangdanCount;
@property (nonatomic, assign) NSInteger current;

@property (nonatomic, weak)UIButton * annotate;
@property (nonatomic, weak)UIButton * comment;

@end

@implementation WorkBrokerModelViewController

- (void)resetEditData:(NSDictionary *)dic{;
//    //必填
    _headerTitle.text = dic[@"title"];
    _typeButton.titleLabel.text = dic[@"type"];
    _monthDan.text = dic[@"goal_month"];
    _dayDan.text = dic[@"truly_month"];
    _plan.text = [dic[@"plans"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    self.planTip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_plan.text.length,500];
    _perception.text = [dic[@"getting"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    self.perceptionTip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_perception.text.length,500];
//    //非必填
    _photos.text = dic[@"photos"];
    _takepictureReason.text = [dic[@"photo_problem"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];

    self.takepictureReasonTip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)self.takepictureReason.text.length,500];
    
    _garrisonAddress.text = [dic[@"local"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    
    _local_source.text = dic[@"local_source"];
    self.local_source_tip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_local_source.text.length,500];
    _quantifyReason.text = [dic[@"process_method"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    self.quantifyReasonTip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_quantifyReason.text.length,500];
    _networkAdd.text = dic[@"add_new_num"];
    
    _networkAddReality.text = dic[@"complete_num"];
    _newworkRefresh.text = dic[@"add_fresh_num"];
    _newworkRefreshReality.text = dic[@"fresh_complete_num"];
    
    _idea.text = [dic[@"advices"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    
    self.ideaTip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)_idea.text.length,500];
    
   
    _headerTitle.text = dic[@"title"];
    
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
    if (self.modelType != LWLWorkTypeEdit) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];//当前的日期
        _headerTitle.text = [NSString stringWithFormat:@"%@-%@工作总结【%@】",[EBPreferences sharedInstance].dept_name,[EBPreferences sharedInstance].userName,currentDateStr];
    }
    
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.tag == 10000) {
        BrokerInsertView *inserView = (BrokerInsertView *)textView.superview.superview;
        inserView.tipLable.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)textView.text.length,200];
        //字数限制操作
        if (textView.text.length >= 200) {
            textView.text = [textView.text substringToIndex:200];
           inserView.tipLable.text = [NSString stringWithFormat:@"%d/%d",200,200];
            //给个弹框提示
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入200个字"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        return;
    }
    UITextView *currentLable = nil;
    UILabel *currentLabletip = nil;
    if (textView == _takepictureReason) {
        //实时显示字数
        currentLable = _takepictureReason;
        currentLabletip = _takepictureReasonTip;
    }else if (textView == _local_source){
        currentLable = _local_source;
        currentLabletip = _local_source_tip;
    }else if (textView == _quantifyReason){
        currentLable = _quantifyReason;
        currentLabletip = _quantifyReasonTip;
    }else if (textView == _idea){
        currentLable = _idea;
        currentLabletip = _ideaTip;
    }else if (textView == _plan){
        currentLable = _plan;
        currentLabletip = _planTip;
    }else if (textView == _perception){
        currentLable = _perception;
        currentLabletip = _perceptionTip;
    }
    currentLabletip.text = [NSString stringWithFormat:@"%lu/%d字", (unsigned long)currentLable.text.length,500];
    //字数限制操作
    if (currentLable.text.length >= 500) {
        currentLable.text = [currentLable.text substringToIndex:500];
        currentLabletip.text = [NSString stringWithFormat:@"%d/%d",500,500];
        //给个弹框提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"最多输入%d个字",500] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
}

- (void)resetUI{
    self.textsArr =@[_headerTitle,_typeButton,_monthDan,_dayDan,_perception,_plan];
    CGFloat radius = 5.0f;
    _takepictureReason.layer.cornerRadius = radius;
    _takepictureReason.clipsToBounds = YES;
    
    _takepictureReason.delegate = self;
    
    _local_source.layer.cornerRadius = radius;
    _local_source.clipsToBounds = YES;
    
     _local_source.delegate = self;
    
    _quantifyReason.layer.cornerRadius = radius;
    _quantifyReason.clipsToBounds = YES;
    _quantifyReason.delegate = self;
    
    _idea.layer.cornerRadius = radius;
    _idea.clipsToBounds = YES;
    _idea.delegate = self;
    
    _plan.layer.cornerRadius = radius;
    _plan.clipsToBounds = YES;
    _plan.delegate = self;
    
    _perception.layer.cornerRadius = radius;
    _perception.clipsToBounds = YES;
    _perception.delegate = self;
    
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

- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
      
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        UIView *headerView = [[NSBundle mainBundle] loadNibNamed:@"BrokerHeaderView" owner:self options:nil].firstObject;
        headerView.frame = CGRectMake(0, 0, kScreenW, headerView.frame.size.height);
        self.headerView = headerView;
        UIView *footerView = [[NSBundle mainBundle] loadNibNamed:@"BrokerFooterView" owner:self options:nil].firstObject;
        footerView.frame = CGRectMake(0, headerView.height, kScreenW, footerView.frame.size.height);
        self.footerView = footerView;
        
        [_mainScrollView addSubview:headerView];
        [_mainScrollView addSubview:footerView];
        if (self.modelType == LWLWorkTypeEdit) {
            _mainScrollView.contentSize = CGSizeMake(0, _headerView.height+_footerView.height + 120);
        }else{
            _mainScrollView.contentSize = CGSizeMake(0, _headerView.height+_footerView.height + 60);
        }
    }
    return _mainScrollView;
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
            //添加意向单
            [self addEditYixiangdan:currentDic[@"data"][@"wanting"]];
            //添加批注，点评
            [self addComment:currentDic[@"data"]];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"请检查网络" length:2.0f];
        
    }];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"经纪人工作总结";
    NSLog(@"useid=%@",[EBPreferences sharedInstance].userId);
    
    self.dataArray = [NSMutableArray array];
    self.tmpDataArray = [NSMutableArray array];
    self.tmpDateDic = [NSMutableDictionary dictionary];
    _current = 0;
    [self.view addSubview:self.mainScrollView];
    self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
    [self resetUI];
    if (self.modelType == LWLWorkTypeEdit) {
        [_add_button setTitle:@"修改" forState:UIControlStateNormal];
        _add_button.hidden = YES;
        [self.view addSubview:self.annotateCommentView];
        [self requestData];
    }else{
        [_add_button setTitle:@"提交" forState:UIControlStateNormal];
        [self resetAddData:self.dayData month:self.monthData];
    }
}

- (void)deleteData:(UITapGestureRecognizer *)tap{
 
    [tap.view.superview removeFromSuperview];//移除单前的view
    [self.tmpDateDic removeObjectForKey:[NSNumber numberWithInteger:tap.view.tag]];
    for (NSNumber *num in self.tmpDateDic) {
        BrokerInsertView *brokerView = [self.tmpDateDic objectForKey:num];
        if (brokerView.deleteImage.tag > tap.view.tag) {
            brokerView.top -= 290;
        }
        
    }
    self.footerView.top -= 290;
    self.headerView.height -= 290;
    _mainScrollView.contentSize = CGSizeMake(0, _mainScrollView.contentSize.height - 290);
    _yixiangdanCount.text = [NSString stringWithFormat:@"意向单(%ld)",self.tmpDateDic.count];
    
}

- (void)addEditYixiangdan:(NSArray *)arr{
    for (NSDictionary *dic in arr) {
         BrokerInsertView *brokerView = [[BrokerInsertView alloc]initWithFrame:CGRectMake(0, self.headerView.height, kScreenW, 290)];
        brokerView.deleteImage.hidden = YES;
        brokerView.tipLable.hidden = YES;
        brokerView.contentTextView.scrollEnabled = YES;
        [brokerView.contentTextView setEditable:NO];
//        brokerView.chooseClientCode.enabled = NO;
        brokerView.nameField.text = dic[@"client_name"];
        [brokerView.chooseClientCode setTitle:dic[@"client_code"] forState:UIControlStateNormal];
        brokerView.contentTextView.text = [dic[@"remark"] stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
        [self.headerView addSubview:brokerView];
        self.headerView.height += 290;
        self.footerView.top += 290;
        _mainScrollView.contentSize = CGSizeMake(0, _mainScrollView.contentSize.height + 290);
        
    }
   
   _yixiangdanCount.text = [NSString stringWithFormat:@"意向单(%ld)",arr.count];
}

-(void)addComment:(NSDictionary *)dic{
    //批注
    CGFloat height = 180;
    self.mainScrollView.contentSize = CGSizeMake(kScreenW, self.mainScrollView.contentSize.height+height);
    
    [self.footerView addSubview:self.annotateView];
    _annotateView.mainTextView.text = [dic[@"opinion"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    self.footerView.height += height;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.add_button_y.constant += height;
    }];
    
    //点评
    self.mainScrollView.contentSize = CGSizeMake(kScreenW, self.mainScrollView.contentSize.height + height);
    
    [self.footerView addSubview:self.commentView];
    _commentView.mainTextView.text = [dic[@"comment"]stringByReplacingOccurrencesOfString:@"_" withString:@"\n"];
    self.footerView.height += height;
    
    [UIView animateWithDuration:0.5f animations:^{
        self.add_button_y.constant += height;
    }];
}

- (IBAction)addYixiangdan:(id)sender {
    if (self.modelType == LWLWorkTypeEdit) {
        [EBAlert alertError:@"查看模式下、不支持新增意向单" length:2.f];
        return;
    }
    _current ++ ;
    if (self.tmpDateDic.count>5) {
        [EBAlert alertError:@"意向单最多为5个" length:2.f];
        return;
    }
    BrokerInsertView *brokerView = [[BrokerInsertView alloc]initWithFrame:CGRectMake(0, self.headerView.height, kScreenW, 290)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(deleteData:)];
    brokerView.deleteImage.userInteractionEnabled = YES;
    brokerView.deleteImage.tag = _current;
    [brokerView.chooseClientCode addTarget:self action:@selector(selectClientCode:) forControlEvents:UIControlEventTouchUpInside];
    [brokerView.deleteImage addGestureRecognizer:tap];
    brokerView.chooseClientCode.tag = _current;
    brokerView.contentTextView.delegate = self;
    brokerView.contentTextView.tag = 10000;
    [self.headerView addSubview:brokerView];

    [self.tmpDateDic setObject:brokerView forKey:[NSNumber numberWithInteger:_current]];
    
    self.headerView.height += 290;
    self.footerView.top += 290;
    _mainScrollView.contentSize = CGSizeMake(0, _mainScrollView.contentSize.height + 290);
    _yixiangdanCount.text = [NSString stringWithFormat:@"意向单(%ld)",self.tmpDateDic.count];
}

- (IBAction)addButton:(id)sender {
    NSLog(@"提交");
    UIView *view = [self verifyTextOfView:self.textsArr];
    if (view != nil) {
        [EBAlert alertError:@"请输入必填信息" length:2.0f];
        CGRect textframe = view.frame;
        if (![view isKindOfClass:[UITextView class]]) {//如果是footerView
             self.mainScrollView.contentOffset = CGPointMake(0, textframe.origin.y-20);
        }
        return;
    }
    NSLog(@"tmp = %@",self.tmpDateDic);
    NSString *yixiangdan = @"";
    for (NSNumber *num in self.tmpDateDic.allKeys) {
        BrokerInsertView *cell = [self.tmpDateDic objectForKey:num];
        if (cell.contentTextView.text.length == 0||cell.chooseClientCode.titleLabel.text == 0 || cell.nameField.text.length == 0) {
            [EBAlert alertError:@"请输入完整意向单内容" length:2.0f];
            return;
        }
        if (![cell.chooseClientCode.titleLabel.text isEqualToString:@"请选择客源编号"]) {
            NSString *tmpStr = [NSString stringWithFormat:@"%@*%@*%@;",cell.nameField.text,cell.chooseClientCode.titleLabel.text,cell.contentTextView.text];
            yixiangdan = [yixiangdan stringByAppendingString:tmpStr];
        }
    }
    if (yixiangdan.length>1) {
        yixiangdan = [yixiangdan substringToIndex:yixiangdan.length-1];
        NSLog(@"yixiangdan = %@",yixiangdan);
    }
    NSMutableDictionary *parm = [NSMutableDictionary dictionary];
    
    [parm setObject:[EBPreferences sharedInstance].token forKey:@"token"];
    //必填
    [parm setObject:_headerTitle.text forKey:@"title"];//标题
    [parm setObject:_typeButton.titleLabel.text forKey:@"type"];//类型
    [parm setObject:_monthDan.text forKey:@"goal_month"];//月度目标
    [parm setObject:_dayDan.text forKey:@"truly_month"];//实际完成（单）
    [parm setObject:_plan.text forKey:@"plans"];    //次日计划
    [parm setObject:_perception.text forKey:@"getting"];//心得
    [parm setObject:@"agent" forKey:@"tmp_type"];
    //非必填
    
    
    
    [parm setObject:_photos.text.length != 0 ? _photos.text : @" "  forKey:@"photos"];//拍照多少组
    
    [parm setObject:_takepictureReason.text.length != 0 ? _takepictureReason.text : @" " forKey:@"photo_problem"];//拍照所遇情况
//      return;
    [parm setObject:_garrisonAddress.text.length != 0 ? _garrisonAddress.text : @" " forKey:@"local"];
    [parm setObject:_local_source.text.length != 0 ? _local_source.text : @" " forKey:@"local_source"];
    [parm setObject:_quantifyReason.text.length != 0 ? _quantifyReason.text : @" " forKey:@"process_method"];
    [parm setObject:_networkAdd.text.length != 0 ? _networkAdd.text : @" " forKey:@"add_new_num"];
    [parm setObject:_networkAddReality.text.length != 0 ? _networkAddReality.text : @" " forKey:@"complete_num"];
    [parm setObject:_newworkRefresh.text.length != 0 ? _newworkRefresh.text : @" " forKey:@"add_fresh_num"];
    [parm setObject:_newworkRefreshReality.text.length != 0 ? _newworkRefreshReality.text : @" " forKey:@"fresh_complete_num"];
    [parm setObject:_idea.text.length != 0 ? _idea.text : @" " forKey:@"advices"];
    
    if (self.modelType == LWLWorkTypeEdit) {
        [parm setObject:@"edit" forKey:@"action"];//编辑
        [parm setObject:_document_id forKey:@"document_id"];//id
        
    }else{
        [parm setObject:@"add" forKey:@"action"];//新增
        [parm setObject:yixiangdan forKey:@"wanting"];//意向单
    }
    [self post:parm];
}


#pragma mark -- 选择客源编号
- (void)selectClientCode:(UIButton *)btn{
    
    if (self.modelType == LWLWorkTypeEdit) {
        [EBAlert alertError:@"查看模式下、不支持修改意向单" length:2.f];
        return;
    }
    
    WorkSelectClientCodeViewController *wscv = [[WorkSelectClientCodeViewController alloc]init];
    wscv.hidesBottomBarWhenPushed = YES;
    wscv.returnBlock = ^(NSString *client_code, NSString * client_name){
        BrokerInsertView *cell = [self.tmpDateDic objectForKey:[NSNumber numberWithInteger:btn.tag]];
        cell.nameField.text = client_name;
        [cell.chooseClientCode setTitle:client_code forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:wscv animated:YES];
}

//选择工作总结类型
- (IBAction)typeBtnClick:(id)sender {
    NSLog(@"选择工作类型");
    self.pickerView.dataSource = @[@"日常总结",@"一周总结",@"一月总结",@"半年总结",@"一年总结"];
    self.pickerView.pickerTitle = @"请选择类型";
    __weak typeof(self) weakSelf = self;
    self.pickerView.valueDidSelect = ^(NSString *str){
        NSString *result = [str componentsSeparatedByString:@"/"].firstObject;
        [weakSelf.typeButton setTitle:result forState:UIControlStateNormal];
    };
    [self.pickerView show];
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
