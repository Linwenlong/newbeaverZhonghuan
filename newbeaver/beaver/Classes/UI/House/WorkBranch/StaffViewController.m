//
//  StaffViewController.m
//  beaver
//
//  Created by mac on 18/1/22.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "StaffViewController.h"
#import "MBProgressHUD.h"
#import "EBCache.h"
#import "EBContactManager.h"
#import "EBContact.h"


@interface StaffViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic, strong)UISearchBar *searchBar;

@property (nonatomic, strong)NSArray *dataArray;
@property (nonatomic, strong)UITableView *mainTableView;

@end

@implementation StaffViewController

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenW-100, 30)];
        _searchBar.placeholder = @"姓名或者部门名称";
        _searchBar.delegate = self;
        _searchBar.tintColor = UIColorFromRGB(0xff3800);
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version == 7.0) {
            _searchBar.backgroundColor = [UIColor clearColor];
            _searchBar.barTintColor = [UIColor clearColor];
        }else{
            for(int i =  0 ;i < _searchBar.subviews.count;i++){
                UIView * backView = _searchBar.subviews[i];
                if ([backView isKindOfClass:NSClassFromString(@"UISearchBarBackground")] == YES) {
                    [backView removeFromSuperview];
                    [_searchBar setBackgroundColor:[UIColor clearColor]];
                    break;
                }else{
                    NSArray * arr = _searchBar.subviews[i].subviews;
                    for(int j = 0;j<arr.count;j++   ){
                        UIView * barView = arr[i];
                        if ([barView isKindOfClass:NSClassFromString(@"UISearchBarBackground")] == YES) {
                            [barView removeFromSuperview];
                            [_searchBar setBackgroundColor:[UIColor clearColor]];
                            break;
                        }
                    }
                }
            }
        }
    }
    return _searchBar;
}


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
    
    self.navigationItem.titleView = self.searchBar;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    [self configureNavigationItem];

    [self.view addSubview:self.mainTableView];
    
    [self buildContactsMap:nil];
    
    
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];

}

#pragma mark -- UISearchBarDelegate


- (void)buildContactsMap:(NSString *)keyword
{
    NSArray *contacts;
    if (keyword.length != 0)
    {
        contacts = [[EBContactManager sharedInstance] contactsByKeyword:keyword];
    }
    else
    {
        contacts = [[EBContactManager sharedInstance] nonAllContacts];
    }
    
    self.dataArray = [contacts sortedArrayUsingComparator:^(EBContact *contact1, EBContact *contact2){
        return  [contact1.pinyin compare:contact2.pinyin];
    }];
    
    if (_mainTableView)
    {
        [_mainTableView reloadData];
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [_searchBar resignFirstResponder];
    [self buildContactsMap:searchBar.text];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
   [self buildContactsMap:searchText];
}


#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
    
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexPath.row = %ld",indexPath.row);
    EBContact *contact = self.dataArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@     %@",contact.name,contact.department];
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
    EBContact *contact = self.dataArray[indexPath.row];
    self.returnBlock(contact.name,contact.userId);
    [self.navigationController popViewControllerAnimated:YES];
        
}
    



@end
