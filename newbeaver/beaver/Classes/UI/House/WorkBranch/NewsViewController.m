//
//  NewsViewController.m
//  beaver
//
//  Created by 林文龙 on 2017/7/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "NewsViewController.h"
#import "EBPreferences.h"
#import "ERPWebViewController.h"
#import "HouseListViewController.h"
#import "EBAppAnalyzer.h"
#import "NewHousingDevelopmentViewController.h"
#import "FollowupRemindViewController.h"

@interface NewsViewController ()<UITableViewDelegate,UITableViewDataSource>

{
    NSMutableArray * sectionArray;
    UITableView *_tableView;
}

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"消息";
    
    NSDictionary *menu = [EBPreferences sharedInstance].workBenchDatas[@"menu"];
    NSArray *tmp = menu[@"message"];
    
    sectionArray = [NSMutableArray array];
    for (NSDictionary *dic  in tmp) {
        if (![dic[@"name"] isEqualToString:@"我的备忘"]&&![dic[@"name"] isEqualToString:@"通知撤单"]) {
            [sectionArray addObject:dic];
        }
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView setLayoutMargins:UIEdgeInsetsZero];
    [self.view addSubview:_tableView];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    NSDictionary *tmp = sectionArray[indexPath.row];//第一层数组
    cell.textLabel.text = tmp[@"name"];
    
    //修改图片尺寸大小
    UIImage *icon = [UIImage imageNamed:tmp[@"name"]];
    CGSize itemSize = CGSizeMake(30, 30);
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
      NSDictionary *dic = sectionArray[indexPath.row];//第一层
    if ([dic[@"is_wap"] integerValue] == 1) {
        if (indexPath.row == 0) {
            NewHousingDevelopmentViewController *nc = [[NewHousingDevelopmentViewController alloc]init];
            nc.hidesBottomBarWhenPushed = YES;
            nc.title = @"小区新上";
            [self.navigationController pushViewController:nc animated:YES];
        }else
            if (indexPath.row == 2){
            FollowupRemindViewController *followup = [[FollowupRemindViewController alloc]init];
            followup.hidesBottomBarWhenPushed = YES;
            followup.title = @"跟进提醒";
            [self.navigationController pushViewController:followup animated:YES];
        }else
        {
            ERPWebViewController *webVc = [ERPWebViewController  sharedInstance];
            [webVc openWebPage:@{@"title":dic[@"name"],@"url":dic[@"url"]}];
            webVc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:webVc animated:YES];
        }
    } else {
        // 打开的是本地的控制器,根据 item.url 判断
        EBAppAnalyzer *analyzer = [[EBAppAnalyzer alloc] initWithJSON:dic[@"url"]];
        UIViewController *vc = [analyzer toViewController];
        NSLog(@"vc=%@",vc);
        if (vc) {
            vc.title = dic[@"name"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

@end
