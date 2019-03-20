//
//  DailyCheckDetailViewController.m
//  beaver
//
//  Created by mac on 17/8/24.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "DailyCheckDetailViewController.h"
#import "DailCheckTableViewCell.h"
#import "SeeTableViewCell.h"
#import "FollowTableViewCell.h"

@interface DailyCheckDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

//headerView

@property (nonatomic, weak)UIView * status_views;//日报状态

@property (weak, nonatomic) IBOutlet UIImageView *stausImage;//状态
//房源
@property (weak, nonatomic) IBOutlet UILabel *house_title;
@property (weak, nonatomic) IBOutlet UILabel *house_sale_type;
@property (weak, nonatomic) IBOutlet UILabel *house_sale_num;
@property (weak, nonatomic) IBOutlet UILabel *house_rent_type;
@property (weak, nonatomic) IBOutlet UILabel *house_rent_num;
@property (weak, nonatomic) IBOutlet UILabel *house_salerent_type;
@property (weak, nonatomic) IBOutlet UILabel *house_salerent_num;

//客源
@property (weak, nonatomic) IBOutlet UILabel *client_title;
@property (weak, nonatomic) IBOutlet UILabel *client_sale_type;
@property (weak, nonatomic) IBOutlet UILabel *client_sale_num;
@property (weak, nonatomic) IBOutlet UILabel *client_rent_type;
@property (weak, nonatomic) IBOutlet UILabel *client_rent_num;


@property (weak, nonatomic) IBOutlet UIView *bigline1;
@property (weak, nonatomic) IBOutlet UIView *bigline2;
@property (weak, nonatomic) IBOutlet UIView *bigline3;

@property (weak, nonatomic) IBOutlet UIView *smallline1;
@property (weak, nonatomic) IBOutlet UIView *smallline2;

//footerView
@property (weak, nonatomic) IBOutlet UIView *line1;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIView *line2;
@property (weak, nonatomic) IBOutlet UILabel *perception_title;//心得
@property (weak, nonatomic) IBOutlet UITextView *perception_TextView;

@property (weak, nonatomic) IBOutlet UILabel *report_title;//批示
@property (weak, nonatomic) IBOutlet UITextView *repost_TextView;
@property (weak, nonatomic) IBOutlet UILabel *comment_title;//点评
@property (weak, nonatomic) IBOutlet UITextView *comment_TextView;

@property (weak, nonatomic) IBOutlet UIButton *report_btn;//批示btn
@property (weak, nonatomic) IBOutlet UIButton *comment_btn;//点评btn


@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, assign)BOOL isClick;//是否被点击
//按钮
@property (nonatomic, strong)UIButton *add_button;//提交批示
@property (nonatomic, strong)NSArray *titleArray;

@property (nonatomic, strong)NSArray *seeArray;
@property (nonatomic, strong)NSArray *followArray;
@property (nonatomic, strong)NSArray *iphoneArray;

@property (nonatomic, assign)BOOL is_instruct;//是否批示
@property (nonatomic, assign)BOOL is_comment;//是否点评
@property (nonatomic, assign)BOOL is_DataLoad;//是否是否加载成功

@property (nonatomic, copy)NSString * status;//日报状态



@end

#define bigFont [UIFont systemFontOfSize:13.0f]
#define smallFont [UIFont systemFontOfSize:12.0f]
#define Color1 UIColorFromRGB(0x404040)
#define Color2 UIColorFromRGB(0x808080)
#define Color3 UIColorFromRGB(0xff3800)

@implementation DailyCheckDetailViewController

- (UIButton *)add_button{
    if (!_add_button) {
        _add_button = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 114, [UIScreen mainScreen].bounds.size.width, 50)];
        _add_button.backgroundColor = AppMainColor(1);
        [_add_button setTitle:@"提交" forState:UIControlStateNormal];
        [_add_button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _add_button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        [_add_button addTarget:self action:@selector(submitComment:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _add_button;
}


- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _status_views = [[NSBundle mainBundle]loadNibNamed:@"DailyCheckHeaderView" owner:self options:nil].firstObject;
        _mainTableView.tableHeaderView = _status_views;
        
        _mainTableView.tableFooterView = [[NSBundle mainBundle]loadNibNamed:@"DailyCheckFooterView" owner:self options:nil].firstObject;
    }
    return _mainTableView;
}

- (IBAction)btn:(id)sender {
    _isClick = !_isClick;
    if (_isClick == YES) {
        [_btn setTitle:@"点击收起" forState:UIControlStateNormal];
        _bigline3.hidden = NO;
    }else{
        [_btn setTitle:@"点击展开、跟进、取电数量" forState:UIControlStateNormal];
        _bigline3.hidden = YES;
    }
    [self.mainTableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"日报详情";
    [self.view addSubview:self.mainTableView];
    
//    [self.view addSubview:self.add_button];
    
    [self requestData];
    
    _titleArray = @[@"带看",@"跟进",@"取电"];
    _is_DataLoad = YES;
    _isClick = NO;
    
    [self setLableColorAndFont];
    
    [self.mainTableView registerNib:[UINib nibWithNibName:@"SeeTableViewCell" bundle:nil] forCellReuseIdentifier:@"seeCell"];
    [self.mainTableView registerNib:[UINib nibWithNibName:@"FollowTableViewCell" bundle:nil] forCellReuseIdentifier:@"followCell"];
}

-(void)requestData{
    //日报详情

    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Daily/myDaily?token=%@&document_id=%@",[EBPreferences sharedInstance].token,self.document_id]);
    if (self.document_id == nil) {
        [EBAlert alertError:@"日报id为空"];
        return;
    }
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:@"Daily/myDaily" parameters:
     @{@"token":[EBPreferences sharedInstance].token,
       @"document_id":self.document_id
       }success:^(id responseObject) {
           [EBAlert hideLoading];
           NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
           if ([currentDic[@"code"] integerValue] == 0) {
               NSDictionary *dic = currentDic[@"data"];//
               [self updateLable:dic];
           }else{
                _is_DataLoad = NO;
               [EBAlert alertError:@"请求失败"];
           }
           
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
            _is_DataLoad = NO;
           [EBAlert alertError:@"请检查网络" length:2.0f];
       }];
}
- (void)updateLable:(NSDictionary *)dic{
    _stausImage.hidden = YES;
    //批示跟点评的两种状态
 
    _is_instruct = [dic[@"instruct"] boolValue];
    _is_comment = [dic[@"comment"] boolValue];
    
    if (_is_instruct == NO) {
        _repost_TextView.editable = NO;
    }
    if (_is_comment == NO) {
        _comment_TextView.editable = NO;
    }
    
    NSDictionary *data =  dic[@"data"];
    _status = data[@"status"];
    _perception_TextView.text = data[@"comment"];
    _repost_TextView.text = data[@"verify"];//verify
    _comment_TextView.text = data[@"remark"];
    
    CGFloat spaing = 10;
    CGFloat w = 60;
    CGFloat h = 25;
    CGFloat y = 5;
    CGFloat x = 15;

    if ( [_status isEqualToString:@"未上报"]) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x, y, w, h)];
        imageView.image = [UIImage imageNamed:@"1"];
        [_status_views addSubview:imageView];
        _perception_TextView.text = @"暂无心得";
        _repost_TextView.editable = NO;
        _comment_TextView.editable = NO;
    }else if ([_status isEqualToString:@"已上报"]){
        _stausImage.image = [UIImage imageNamed:@"2"];
        for (int i = 1; i <= 2; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x + (spaing+w) * (i-1), y, w, h)];
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
            [_status_views addSubview:imageView];
        }
    }else if ([_status isEqualToString:@"已批示"]){
        //判断是否已经点评
        if (_comment_TextView.text.length == 0) {
            for (int i = 1; i <= 3; i++) {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x + (spaing + w) * (i-1), y, w, h)];
                imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
                [_status_views addSubview:imageView];
            }
        }else{//已经点评过了
            _comment_TextView.editable = NO;
            _comment_TextView.hidden = YES;
            for (int i = 1; i <= 4; i++) {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x + (spaing+w) * (i-1), y, w, h)];
                imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
                [_status_views addSubview:imageView];
            }
        }
        _repost_TextView.editable = NO;
        _report_btn.hidden = YES;
    }else if ([_status isEqualToString:@"已点评"]){
        //判断是否已经批示
        if (_repost_TextView.text.length == 0) {
            for (int i = 1; i <= 3; i++) {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x + (spaing+w) * (i-1), y, w, h)];
                int current = i;
                if (current == 3) {
                    current = i + 1;
                }
                imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",current]];
                [_status_views addSubview:imageView];
            }
        }else{
            _repost_TextView.editable = NO;
            _report_btn.hidden = YES;
            for (int i = 1; i <= 4; i++) {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(x + (spaing+w) * (i-1), y, w, h)];
                imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d",i]];
                [_status_views addSubview:imageView];
            }
        }
        _comment_TextView.editable = NO;
        _comment_btn.hidden = YES;
    }
    
    NSArray *houseArray = @[_house_sale_num,_house_rent_num,_house_salerent_num];
    NSArray *clientArray = @[_client_sale_num,_client_rent_num];
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
    _seeArray = dic3[@"sub"];
    //跟进
    NSDictionary *dic4 = realTimeReport[@"4"];
    _followArray = dic4[@"sub"];
    //房源新增
    NSDictionary *dic5 = realTimeReport[@"5"];
    _iphoneArray = dic5[@"sub"];
}



#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_isClick == YES) {
        return _titleArray.count;
    }else{
        return 0;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        SeeTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"seeCell" forIndexPath:indexPath];
        [cell setArray:_seeArray];
        return cell;
    }else{
        FollowTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"followCell" forIndexPath:indexPath];
        if (indexPath.section == 1) {
            [cell setArray:_followArray];
        }else{
            [cell setArray:_iphoneArray];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 46;
    }else{
        return 70;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 47;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 47)];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 5)];
    line.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    [view addSubview:line];
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(20, 13, 100, 15)];
    title.font = [UIFont systemFontOfSize:13.0f];
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = UIColorFromRGB(0x404040);
    title.text = _titleArray[section];
    [view addSubview:title];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 46, kScreenW, 1)];
    line2.backgroundColor =[UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    [view addSubview:line2];
    return view;
}


- (void)setLableColorAndFont{
    
    _bigline1.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    _bigline2.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    _bigline3.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    _line1.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    _line2.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.00];
    _smallline1.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    _smallline2.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00];
    
    _house_title.textColor = Color1;
    _house_title.font = bigFont;
    _client_title.textColor = Color1;
    _client_title.font = bigFont;
    _perception_title.textColor =Color1;
    _perception_title.font = bigFont;
    _report_title.textColor = Color1;
    _report_title.font = bigFont;
    _comment_title.textColor = Color1;
    _comment_title.font = bigFont;
    
    _house_sale_type.textColor = Color2;
    _house_sale_type.font = smallFont;
    _house_rent_type.textColor = Color2;
    _house_rent_type.font = smallFont;
    _house_salerent_type.textColor = Color2;
    _house_salerent_type.font = smallFont;
    
    _house_sale_num.textColor
    = Color3;
    _house_sale_num.font = smallFont;
    _house_rent_num.textColor
    = Color3;
    _house_rent_num.font = smallFont;
    _house_salerent_num.textColor
    = Color3;
    _house_salerent_num.font = smallFont;
    
    _client_sale_type.textColor = Color2;
    _client_sale_type.font = smallFont;
    _client_rent_type.textColor = Color2;
    _client_rent_type.font = smallFont;
    
    _client_rent_num.textColor
    = Color3;
    _client_rent_num.font = smallFont;
    _client_sale_num.textColor
    = Color3;
    _client_sale_num.font = smallFont;
    
    _perception_TextView.editable = NO;
    _perception_TextView.textColor = Color2;
    _repost_TextView.textColor = Color2;
    _repost_TextView.layer.borderWidth = 1.0;
    _repost_TextView.layer.borderColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00].CGColor;
    _comment_TextView.textColor = Color2;
    _comment_TextView.layer.borderWidth = 1.0;
    _comment_TextView.layer.borderColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1.00].CGColor;
    [_btn setTitle:@"点击展开、跟进、取电数量" forState:UIControlStateNormal];
    [_btn setTitleColor:Color2 forState:UIControlStateNormal];
    _btn.titleLabel.font = smallFont;
    
    _bigline3.hidden = YES;
    
    [_report_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _report_btn.backgroundColor = UIColorFromRGB(0xff3800);
    _report_btn.layer.cornerRadius = 5.0f;
    
    [_comment_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _comment_btn.backgroundColor = UIColorFromRGB(0xff3800);
    _comment_btn.layer.cornerRadius = 5.0f;
}

- (void)submitComment:(UIButton *)btn{
    
    if (_is_DataLoad == NO) {
        [EBAlert alertError:@"数据加载失败,无法提交数据" length:2.0];
        return;
    }
    if(_is_instruct == NO || _is_comment == NO){
        [EBAlert alertError:@"您无权限批示或者点评日报" length:2.0f];
        return;
    }
    
    //进入添加关注小区地方
    if([_status isEqualToString:@"未上报"]){
        [EBAlert alertError:@"日报未上报,不能批示或者点评" length:2.0f];
        return;
    }
    
    if (_repost_TextView.text.length == 0 || _comment_TextView.text.length == 0 ) {
        [EBAlert alertError:@"请输入批示或者点评的内容" length:2.0f];
        return;
    }else{
        [self updataDaily];
    }

//    if(_is_instruct == YES || _is_comment == YES){
//        [self updataDaily];
//    }else{
//        [EBAlert alertError:@"您无权限批示或者点评日报" length:2.0f];
//        return;
//    }
}
- (void)updataDaily{
    //提交日报 状态判断
    if (_repost_TextView.editable == YES || _comment_TextView.editable == YES   ) {
        //提交点评或者批示
        NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Daily/saveVerifyRemark?token=%@&remark=%@&verify=%@&document_id=%@",[EBPreferences sharedInstance].token,_comment_TextView.text,_repost_TextView.text,self.document_id]);
        if (self.document_id == nil) {
            [EBAlert alertError:@"日报id为空"];
            return;
        }
        NSString *urlStr = @"Daily/saveVerifyRemark";
        
        [EBAlert showLoading:@"提交中..." allowUserInteraction:NO];
        [HttpTool post:urlStr parameters:
         @{@"token":[EBPreferences sharedInstance].token,
              @"remark":_comment_TextView.text,
              @"verify":_repost_TextView.text,
              @"document_id":self.document_id
           }success:^(id responseObject) {
               [EBAlert hideLoading];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               if ([currentDic[@"code"] integerValue] == 0) {
                    [EBAlert alertSuccess:@"提交成功" length:2.0];
                   [self requestData];
//                   [self.navigationController popViewControllerAnimated:YES];
               }else{
                   [EBAlert alertError:@"提交失败"];
               }
           } failure:^(NSError *error) {
               [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
           }];
    }else{
        [EBAlert alertError:@"该日报已经批示或者点评'" length:2.0f];
        return;
    }
    
}

//批示点击事件_is_instruct是否批示 _is_comment是否点评
- (IBAction)reportAction:(id)sender {
    if (_is_DataLoad == NO) {
        [EBAlert alertError:@"数据加载失败,无法提交数据" length:2.0];
        return;
    }
    
    //进入添加关注小区地方
    if([_status isEqualToString:@"未上报"]){
        [EBAlert alertError:@"日报未上报,不能批示" length:2.0f];
        return;
    }
    
    if(_is_instruct == NO){
        [EBAlert alertError:@"您无权批示" length:2.0f];
        return;
    }
    
    if (_repost_TextView.text.length == 0) {
        [EBAlert alertError:@"请输入批示内容" length:2.0f];
        return;
    }else{
        NSLog(@"批示中");
        [self updataDaily];
    }

}
//批示点击事件
- (IBAction)commentAction:(id)sender {
    if (_is_DataLoad == NO) {
        [EBAlert alertError:@"数据加载失败,无法提交数据" length:2.0];
        return;
    }
    
    //进入添加关注小区地方
    if([_status isEqualToString:@"未上报"]){
        [EBAlert alertError:@"日报未上报,不能点评" length:2.0f];
        return;
    }
    
    if(_is_comment == NO){
        [EBAlert alertError:@"您无权点评日报" length:2.0f];
        return;
    }
    
    if (_comment_TextView.text.length == 0 ) {
        [EBAlert alertError:@"请输入点评的内容" length:2.0f];
        return;
    }else{
        NSLog(@"点评中");
        [self updataDaily];
    }

}




@end
