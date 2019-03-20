//
//  DiSanFangHuJiaoViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/7/6.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "DiSanFangHuJiaoViewController.h"
#import "HuaFeiXiaoFeiViewController.h"
#import "YueZuFeiViewController.h"
#import "DuanXinViewController.h"

#import "YueZuChongzhiViewController.h"
#import "ZHTestViewController.h"
#import "DuanXinChongzhiViewController.h"
#import "ChongZhiViewController.h"
#import "DiSanFangHuJiaoTableViewCell.h"

@interface DiSanFangHuJiaoViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    //LWL
    NSArray *sectionTitles;
    NSArray *sectionImages;
    NSMutableArray *sectionForRowTitles;
    NSDictionary *resultDic;
}

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, assign)BOOL firstRecharge;

@end

@implementation DiSanFangHuJiaoViewController


//刷新头部、、MJ
-(void)refreshHeader{
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];//加载数据
    }];
    [_tableView.mj_header beginRefreshing];
}

- (void)requestData{
   
    NSString *urlStr = @"call/getUserCallInfo";
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    NSDictionary *param = @{
                            @"token":[EBPreferences sharedInstance].token,
                            };
    NSLog(@"param=%@",param);
    [HttpTool get:urlStr parameters:param success:^(id responseObject) {
        [EBAlert hideLoading];
        NSLog(@"responseObject=%@",responseObject);
        
        if ([responseObject[@"code"]integerValue] == 0) {
            resultDic = responseObject[@"data"];
            _firstRecharge = [resultDic[@"firstRecharge"] integerValue];
            [_tableView.mj_header endRefreshing];
            [_tableView reloadData];
        }else{
            [EBAlert alertError:@"加载失败" length:2.0f];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"加载失败,请重新再试" length:2.0f];
    }];

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的呼叫管理";
    sectionTitles = @[@"账号",@"充值",@"消费记录"];
    sectionImages = @[@"hidden_zhanghao",@"hidden_chongzhi",@"hidden_xiaofei"];
    sectionForRowTitles = [NSMutableArray array];
    [sectionForRowTitles addObject:@[@"账号"]]; //第一个
    [sectionForRowTitles addObject:@[@"话费充值",@"短信充值",@"充值记录"]]; //第一个
    [sectionForRowTitles addObject:@[@"月租费消费记录",@"话费消费记录",@"短信消费记录"]]; //第一个
    //请求成功了加载tableview
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
    //    _tableView.backgroundColor = UIColorFromRGB(0xff3800);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView setLayoutMargins:UIEdgeInsetsZero];
    _tableView.separatorColor = UIColorFromRGB(0xe8e8e8);
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _tableView.bounces = YES;
    _tableView.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [self.view addSubview:_tableView];
    [_tableView registerNib:[UINib nibWithNibName:@"DiSanFangHuJiaoTableViewCell" bundle:nil] forCellReuseIdentifier:@"zhanghao"];
    
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshHeader];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 48)];
        view.backgroundColor = [UIColor whiteColor];
        UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
        line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
        [view addSubview:line1];
        
        UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(15, 8, 32, 32)];
        icon.image = [UIImage imageNamed:sectionImages[section]];
        [view addSubview:icon];
        
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame)+3, 13, kScreenW/2, 21)];
        lable.text = sectionTitles[section];
        lable.textAlignment = NSTextAlignmentLeft;
        lable.textColor = UIColorFromRGB(0x333333);
        lable.font = [UIFont systemFontOfSize:18.0f];
        [view addSubview:lable];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 47, kScreenW, 1)];
        line.backgroundColor = UIColorFromRGB(0xe8e8e8);
        [view addSubview:line];
        return view;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
        view.backgroundColor = UIColorFromRGB(0xe8e8e8);
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return 48;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 10)];
    view.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    return view;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sectionForRowTitles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *tmp = sectionForRowTitles[section];
    return tmp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.section == 0) {//如果是第一个直接返回
        DiSanFangHuJiaoTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"zhanghao" forIndexPath:indexPath];
        cell.zhanghao.textColor = UIColorFromRGB(0x333333);
        cell.zhanghaoactucl.textColor =  UIColorFromRGB(0xa9a9a9);
        cell.icon.image = [UIImage imageNamed:sectionImages.firstObject];
        cell.zhanghao.text =@"账号";
        cell.zhanghao.font = [UIFont systemFontOfSize:18.0];
        cell.zhanghaoactucl.font = [UIFont systemFontOfSize:18.0];
        cell.zhanghaoactucl.text = resultDic != nil ? resultDic[@"bind_phone"] : @"";
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.textColor = UIColorFromRGB(0x333333);
    
    cell.detailTextLabel.textColor =  UIColorFromRGB(0xa9a9a9);
    NSArray *tmp = sectionForRowTitles[indexPath.section];//第一层数组
    NSString *str = tmp[indexPath.row];
    cell.textLabel.text = str;
    
    if (indexPath.section == 0) {
        cell.textLabel.font = [UIFont systemFontOfSize:18.0];
        cell.imageView.image = [UIImage imageNamed:sectionImages.firstObject];
        
        CGSize itemSize = CGSizeMake(32, 32);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.textLabel.mj_x = CGRectGetMaxX(cell.imageView.frame)+3;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:18.0];
        cell.detailTextLabel.text = resultDic != nil ? resultDic[@"bind_phone"] : @"";
    }else
        if (indexPath.section == 1){
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
            if (indexPath.row ==0){
            cell.detailTextLabel.text = resultDic != nil ?[NSString stringWithFormat:@"%@元",resultDic[@"balanceInfo"][@"money"]] : @"";
        }else if (indexPath.row == 1){
            cell.detailTextLabel.text = resultDic != nil ?[NSString stringWithFormat:@"%@条",resultDic[@"balanceInfo"][@"msg_count"]]  : @"";
        }
    }else if (indexPath.section == 2){
        cell.textLabel.font = [UIFont systemFontOfSize:15.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
        if (indexPath.row == 0) {
         
        }else if (indexPath.row == 1){

        }else if (indexPath.row == 2){
        }
    }
    if (indexPath.section != 0) {
        UIImageView *accessory = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 7, 11)];
        accessory.image = [[UIImage imageNamed:@"jiantou"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [accessory setTintColor:UIColorFromRGB(0xF7684C)];
        cell.accessoryView = accessory;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([resultDic[@"bind_phone"] isEqualToString:@""]) {
        [EBAlert alertError:@"该账号未绑定第三方账号,请联系管理员绑定" length:2.0f];
        return;
    }
    
    
    if (indexPath.section == 1) {
            if (indexPath.row == 0){//话费充值
            ZHTestViewController *vc = [[ZHTestViewController alloc]init];
            vc.firstRecharge = _firstRecharge;
            vc.bind_phone = resultDic[@"bind_phone"];
            vc.totle_price = resultDic[@"balanceInfo"][@"money"];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 1){//短信充值
            DuanXinChongzhiViewController *vc = [[DuanXinChongzhiViewController alloc]init];
            vc.bind_phone = resultDic[@"bind_phone"];
            vc.msg_count = resultDic[@"balanceInfo"][@"msg_count"];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 2){
            ChongZhiViewController *vc = [[ChongZhiViewController alloc]init];
            vc.bind_phone = resultDic[@"bind_phone"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {//月租费消费记录
            YueZuFeiViewController *vc = [[YueZuFeiViewController alloc]init];
            vc.bind_phone = resultDic[@"bind_phone"];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 1){//话费消费记录
            HuaFeiXiaoFeiViewController *vc = [[HuaFeiXiaoFeiViewController alloc]init];
            vc.bind_phone = resultDic[@"bind_phone"];
            [self.navigationController pushViewController:vc animated:YES];
        }else if (indexPath.row == 2){//短信消费记录
            DuanXinViewController *vc = [[DuanXinViewController alloc]init];
            vc.shengyuDuanxin = resultDic[@"balanceInfo"][@"msg_count"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}


@end
