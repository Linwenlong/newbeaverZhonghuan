//
//  ZHDCMeViewController.m
//  beaver
//
//  Created by 林文龙 on 2017/7/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ZHDCMeViewController.h"
#import "ChangePasswordViewController.h"
#import "EBViewFactory.h"
#import "EBAlert.h"
#import "EBController.h"
#import "RTLabel.h"
#import "EBPreferences.h"
#import "EBContact.h"
#import "EBContactManager.h"
#import "EBCache.h"
#import "EBUpdater.h"
#import "EBHttpClient.h"
#import "CustomBadge.h"
#import "AnonymousCallViewController.h"
#import "UITabBar+badge.h"
#import "MapTrackViewController.h"
#import "MyRecommendViewController.h"
#import "MeViewController.h"
#import "ERPWebViewController.h"
#import "MFindViewController.h"
#import "MySettingViewController.h"
#import "DealFunnelViewController.h"
#import "MySeeViewController.h"
#import "MyReconnoitreViewController.h"
#import "SubmitDailyViewController.h"
#import "MyJourneyViewController.h"
#import "MyAchievementViewController.h"
#import "WorkloadViewController.h"
#import "HouseListViewController.h"
#import "ClientListViewController.h"
#import "UIImageView+WebCache.h"
#import "DiSanFangHuJiaoViewController.h"
#import "ZHDCWebViewController.h"

@interface ZHDCMeViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    //LWL
    NSArray *sectionTitles;
    NSMutableArray *sectionForRowTitles;
}

@end

@implementation ZHDCMeViewController

#define SETTING_ROW_HEIGHT 60.0f

- (void)enterDisanfang:(UITapGestureRecognizer *)tap{
    DiSanFangHuJiaoViewController *vc = [[DiSanFangHuJiaoViewController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- 我的资源点击方法
- (void)enterbtn:(UIButton *)btn{
    if (btn.tag == 0 || btn.tag == 1) {
        //进入买卖房源列表
        NSDictionary *parm = nil;
        HouseListViewController *list = [[HouseListViewController alloc]init];
        if (btn.tag == 0) {
            parm = @{
                     @"force_refresh" : @NO,
                     @"type" : @"sale",
                     @"status" : @"有效",
                     @"belong" : @"本人"
                     };
            list.title = @"买卖房源";
        }else{
            parm = @{
                     @"force_refresh" : @NO,
                     @"type" : @"rent",
                     @"status" : @"有效",
                     @"belong" : @"本人"
                     };
            list.title = @"租赁房源";
        }
        list.listType = EHouseListTypeFilter;
        list.appParam = parm;
        list.isLWL = YES;
        list.is_hidden_sort_btn = YES;
        list.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:list animated:YES];
    }else if (btn.tag == 2 || btn.tag == 3){
        //进入买卖房源列表
        NSDictionary *parm = nil;
        ClientListViewController *list = [[ClientListViewController alloc]init];
        if (btn.tag == 2) {
            parm = @{
                     @"force_refresh" : @NO,
                     @"type" : @"sale",
                     @"status" : @"有效",
                     @"belong" : @"本人"
                     };
            list.title = @"买卖客户";
        }else{
            parm = @{
                     @"force_refresh" : @NO,
                     @"type" : @"rent",
                     @"status" : @"有效",
                     @"belong" : @"本人"
                     };
            list.title = @"租赁客户";
        }
        list.listType = EClientListTypeRecent;
        list.appParam = parm;
        list.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:list animated:YES];
    }
}

//tableview的头部视图
- (UIView *)headerView{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 278+47)];
    headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bground"]];
    
    CGFloat imageView_x = 33/2;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageView_x, 30, 70, 70)];
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = CGRectGetWidth(imageView.frame)/2.0;
    imageView.backgroundColor = [UIColor redColor];
    
//    imageView.image = [UIImage imageNamed:@"头像"];
   
    [imageView sd_setImageWithURL:[NSURL URLWithString:[EBPreferences sharedInstance].photo] placeholderImage:[UIImage imageNamed:@"头像"]];
  
    [headerView addSubview:imageView];
    
    //名字跟电话
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+22, 35, headerView.width -  2 * imageView_x-50-22, 20)];
    label1.font = [UIFont systemFontOfSize:17.0f];
    label1.textColor = [UIColor whiteColor];
   
    EBPreferences *pref = [EBPreferences sharedInstance];
//    EBContact *me = [[EBContactManager sharedInstance] contactById:pref.userId];
    
     NSMutableAttributedString *text1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@（%@）", pref.userName,pref.userAccount]] ;
    label1.attributedText = text1;
    [headerView addSubview:label1];
    
    //后面的公司名称
     UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame)+22, CGRectGetMaxY(label1.frame)+10, headerView.width -  2 * imageView_x-50-22, 40)];
    label2.numberOfLines = 0;
    label2.font = [UIFont systemFontOfSize:13.0f];
    label2.textColor = [UIColor whiteColor];
    NSMutableAttributedString *text2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r\n%@", pref.companyName, pref.dept_name]] ;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;//行距
    [text2 addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text2.length)];
    label2.attributedText = text2;
    [headerView addSubview:label2];
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(label2.frame)+35, kScreenW, 47)];
    view1.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterDisanfang:)];
    
    [view1 addGestureRecognizer:tap];
    
    view1.backgroundColor = [UIColor whiteColor];
    
    UIImageView *disanfangimageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 30, 30)];
    disanfangimageView.image = [UIImage imageNamed:@"我的呼叫管理"];
    [view1 addSubview:disanfangimageView];
    
    UILabel *lable3 = [[UILabel alloc]initWithFrame:CGRectMake(15 + 20 + 5 + 3, 13, kScreenW/2, 21)];
    lable3.text = @"我的呼叫管理";
    lable3.textAlignment = NSTextAlignmentLeft;
    lable3.textColor = [UIColor colorWithRed:0.59 green:0.59 blue:0.60 alpha:1.00];
    lable3.font = [UIFont systemFontOfSize:19.0f];
    [view1 addSubview:lable3];
    [headerView addSubview:view1];
    
    UIImageView *accessory = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenW - 7 - 15 , (47-11)/2.0 , 7, 11)];
    accessory.image = [UIImage imageNamed:@"jiantou"];
    [view1 addSubview:accessory];
    
    UIView *line3 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(view1.frame), kScreenW, 1)];
    line3.backgroundColor = UIColorFromRGB(0xefefef);
    [headerView addSubview:line3];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line3.frame), kScreenW, 47)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, kScreenW/2, 21)];
    lable.text = @"我的资源";
    lable.textAlignment = NSTextAlignmentLeft;
    lable.textColor = UIColorFromRGB(0x5d5d5d);
    lable.font = [UIFont systemFontOfSize:15.0f];
    [view addSubview:lable];
    [headerView addSubview:view];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(view.frame), kScreenW, 1)];
    line1.backgroundColor = UIColorFromRGB(0xefefef);
    [headerView addSubview:line1];
    
    
    //后面的按钮
    // 此步设置之后_autoWidthViewsContainer的高度可以根据子view自适应
//    UIView *btnViews = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame), kScreenW, 85)];
    
    UIScrollView *btnViews = [[UIScrollView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame), kScreenW, 85)];
    btnViews.contentSize = CGSizeMake(kScreenW, 85);
    btnViews.pagingEnabled = YES;
    btnViews.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:btnViews];
    
    CGFloat x = (85-60)/2;
    CGFloat y = x;
    CGFloat margin = 20;
    CGFloat w = (kScreenW - 2 * x-3 * margin)/4.0f;
    CGFloat h = 60;
    NSArray *tmp = @[@"买卖房源",@"租赁房源",@"买卖客户",@"租赁客户"];
    //添加四个按钮
    for (int i = 0; i < tmp.count; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(x+(w+margin)*i,y, w, h)];
        button.tag = i;
        [button setTitle:tmp[i] forState:UIControlStateNormal];
        [button setTitleColor:UIColorFromRGB(0x808080) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [button addTarget:self action:@selector(enterbtn:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [UIImage imageNamed:tmp[i]];
        [button setImage:image forState:UIControlStateNormal];
        CGSize imageSize = button.imageView.frame.size;
        CGSize titleSize = button.titleLabel.frame.size;
        
        CGSize textSize = [button.titleLabel.text sizeWithFont:button.titleLabel.font];
        CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
        if (titleSize.width + 0.5 < frameSize.width) {
            titleSize.width = frameSize.width;
        }
        CGFloat spacing = 10;
        CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
        button.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height),0.0, 0.0, - titleSize.width);
        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
        [btnViews addSubview:button];
        
    }
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(btnViews.frame), kScreenW, 10)];
    line2.backgroundColor = UIColorFromRGB(0xefefef);
    [headerView addSubview:line2];
    
    return headerView;
}

- (UIView *)footerView{
    
    UIView *viewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 30)];
    viewFooter.backgroundColor = UIColorFromRGB(0xefefef);
    return viewFooter;
}

- (void)loadView{
    [super loadView];
    self.navigationItem.title = @"我";
    [self.tabBarController.tabBar hideBadgeOnItemIndex:3];
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"设置"] target:self action:@selector(enterSetting:)];
    sectionTitles = @[@"行程",@"业绩",@"推荐",@"发现"];
    sectionForRowTitles = [NSMutableArray array];
    
    NSString *dept_id = [EBPreferences sharedInstance].dept_id;
    NSString *prefernces = [dept_id componentsSeparatedByString:@"_"].firstObject;
    NSLog(@"EBPreferences=%@",[EBPreferences sharedInstance].dept_id);
    
    if ([prefernces isEqualToString:@"25759122"]||//福州
        [prefernces isEqualToString:@"25759052"]||//泰州
        [prefernces isEqualToString:@"25759192"]||//九江
        [prefernces isEqualToString:@"25758422"])//济南
    {
        [sectionForRowTitles addObject:@[@"我的行程",@"我的带看",@"我的实勘"]]; //第一个
    }else{
        [sectionForRowTitles addObject:@[@"我的行程",@"我的带看",@"我的实勘",@"成交漏斗"]]; //第一个
    }
    
    [sectionForRowTitles addObject:@[@"业绩明细"]]; //第二个
    [sectionForRowTitles addObject:@[@"我要推荐"]]; //第三个
    [sectionForRowTitles addObject:@[@"我要举报"]]; //第三个
    [sectionForRowTitles addObject:@[@"发现"]]; //第四个
    
    
    [_tableView reloadData];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64-50)];
    _tableView.backgroundColor = UIColorFromRGB(0xff3800);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView setLayoutMargins:UIEdgeInsetsZero];
    _tableView.separatorColor = UIColorFromRGB(0xe8e8e8);
    _tableView.bounces = NO;
    [self.view addSubview:_tableView];
    
    _tableView.tableHeaderView = [self headerView];
    _tableView.tableFooterView = [self footerView];
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

#pragma mark -- enteRecommend

- (void)enterSetting:(id)recommend{
    //设置
    MySettingViewController *vc = [[MySettingViewController alloc]init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    //隐藏左边leftBarButtonItem
    [self hiddenleftNVItem];
}
//隐藏左箭头
- (void)hiddenleftNVItem
{
    self.navigationItem.leftBarButtonItem=nil;
}

//点击cell事件

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //进入我的行程
            MyJourneyViewController *mjvc = [[MyJourneyViewController alloc]init];
            mjvc.hidesBottomBarWhenPushed  =YES;
            [self.navigationController pushViewController:mjvc animated:YES];
        }else if (indexPath.row == 1){
            //进入我的带看
            MySeeViewController *mvc = [[MySeeViewController alloc]init];
            mvc.hidesBottomBarWhenPushed  =YES;
            [self.navigationController pushViewController:mvc animated:YES];
        }else if (indexPath.row == 2){
            //进入我的勘察
            MyReconnoitreViewController *mvc = [[MyReconnoitreViewController alloc]init];
            mvc.hidesBottomBarWhenPushed  =YES;
            [self.navigationController pushViewController:mvc animated:YES];
        }else if (indexPath.row == 3){
            //进入成交漏斗
            DealFunnelViewController *dvc = [[DealFunnelViewController alloc]init];
            dvc.hidesBottomBarWhenPushed  =YES;
            [self.navigationController pushViewController:dvc animated:YES];
        }
//        else if (indexPath.row == 4){
//            //进入成交漏斗
//            DealFunnelViewController *dvc = [[DealFunnelViewController alloc]init];
//            dvc.hidesBottomBarWhenPushed  =YES;
//            [self.navigationController pushViewController:dvc animated:YES];
//        }
    }else if (indexPath.section == 1){
        MyAchievementViewController *mavc = [[MyAchievementViewController alloc]init];
        mavc.hidesBottomBarWhenPushed  =YES;
        [self.navigationController pushViewController:mavc animated:YES];
    }else if (indexPath.section == 2){
        MyRecommendViewController *rc = [[MyRecommendViewController alloc]init];
        rc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:rc animated:YES];
    }else if(indexPath.section == 3){
        NSLog(@"我要举报");
        ZHDCWebViewController *webVC = [[ZHDCWebViewController alloc] init];
        webVC.hidesBottomBarWhenPushed = YES;
        NSString *tittleString = @"中环地产";
        webVC.homeUrl =[NSURL URLWithString:@"http://www.zhdclink.com/report?from=mobile"];
        NSLog(@"homeUrl = %@",webVC.homeUrl);
        webVC.title = tittleString;
        NSLog(@"nav1 = %@",self.navigationController);
        [self.navigationController pushViewController:webVC animated:YES];
    }else{
        MFindViewController *mFindVc = [[MFindViewController alloc] init];
        mFindVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:mFindVc animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SETTING_ROW_HEIGHT;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 48)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 13, kScreenW/2, 21)];
        lable.text = sectionTitles[section];
        lable.textAlignment = NSTextAlignmentLeft;
        lable.textColor = UIColorFromRGB(0x5d5d5d);
        lable.font = [UIFont systemFontOfSize:15.0f];
        [view addSubview:lable];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 47, kScreenW, 1)];
        line.backgroundColor = UIColorFromRGB(0xe8e8e8);
        [view addSubview:line];
        return view;
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 10)];
        view.backgroundColor = UIColorFromRGB(0xe8e8e8);
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 48;
    }else{
        return 10;
    }
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = UIColorFromRGB(0x808080);
    
    NSArray *tmp = sectionForRowTitles[indexPath.section];//第一层数组
    NSString *str = tmp[indexPath.row];
        cell.textLabel.text = str;
        //修改图片尺寸大小
    UIImage *icon = [UIImage imageNamed:str];
    CGSize itemSize = CGSizeMake(20, 20);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *accessory = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 7, 11)];
    accessory.image = [UIImage imageNamed:@"jiantou"];
    cell.accessoryView = accessory;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


@end
