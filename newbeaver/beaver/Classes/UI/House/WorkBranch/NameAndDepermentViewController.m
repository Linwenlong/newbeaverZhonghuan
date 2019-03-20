//
//  NameAndDepermentViewController.m
//  beaver
//
//  Created by mac on 17/9/7.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "NameAndDepermentViewController.h"
#import "MBProgressHUD.h"
#import "EBCache.h"

@interface NameAndDepermentViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)UITableView *mainTableView;

@end

@implementation NameAndDepermentViewController

#define HEIGHT_BTN_AREA 56.0

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _mainTableView;
}


- (void)configureNavigationItem {
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0, 0, 20, 20)];
    [backButton addTarget:self action:@selector(clickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [backButtonItem setTintColor:UIColorFromRGB(0xAAAAAA)];
    self.navigationItem.leftBarButtonItem = backButtonItem;
}

- (void)clickBackButton:(id)sender {
    [self goBack];
}

- (void)goBack {
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"门店筛选";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    [self configureNavigationItem];
    NSMutableSet *set = [[EBCache sharedInstance]objectForKey:EB_CACHE_KEY_DEPARMENTS];
    NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
    _dataArray = [set sortedArrayUsingDescriptors:sortDesc];
    
    [self.view addSubview:self.mainTableView];
//    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_search"] target:self action:@selector(searchContact:)];
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;

    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *str = _dataArray[indexPath.row];
    NSLog(@"str = %@",str);
    cell.textLabel.text = [str componentsSeparatedByString:@"-"].firstObject;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *str = _dataArray[indexPath.row];
    NSLog(@"str = %@",str);
    self.returnBlock([str componentsSeparatedByString:@"_"].lastObject,[str componentsSeparatedByString:@"-"].firstObject);
    [self.navigationController popViewControllerAnimated:YES];

}

@end
