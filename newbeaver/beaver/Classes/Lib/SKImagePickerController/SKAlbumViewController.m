//
//  SKAlbumViewController.m
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//
#pragma mark -- 相册控制器
#import "SKAlbumViewController.h"
#import "EBStyle.h"
#import "EBViewFactory.h"
#import "SKAssetsViewController.h"

@interface SKAlbumViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
}

@end

@implementation SKAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNaviBar];
    [self setTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init
- (void)setNaviBar
{
//    [self setNavigationbar];
//    [self addCloseNavigationItem];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    self.navigationItem.title = @"照片";
}

- (void)setTableView
{
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

#pragma mark - action
- (void)close
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SKAssetsViewController *assetViewCtrl = [[SKAssetsViewController alloc] init];
    assetViewCtrl.maxSelect = self.maxSelect;
    assetViewCtrl.photoSelect = self.photoSelect;
    assetViewCtrl.group = self.groupArray[indexPath.row];
    [self.navigationController pushViewController:assetViewCtrl animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.groupArray) {
        return self.groupArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"albumCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:98];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:99];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        [cell addSubview:[EBViewFactory lineWithHeight:70 left:15 right:15]];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        [cell.contentView addSubview:imageView];
        imageView.tag = 98;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 200, 70)];
        titleLabel.textColor = [EBStyle blackTextColor];
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.tag = 99;
        [cell.contentView addSubview:titleLabel];
    }
    ALAssetsGroup *group = self.groupArray[indexPath.row];
    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    NSUInteger numOfAssets = group.numberOfAssets;
    titleLabel.text = [NSString stringWithFormat:@"%@", [group valueForProperty:ALAssetsGroupPropertyName]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", numOfAssets];
    [imageView setImage:[UIImage imageWithCGImage:[(ALAssetsGroup *)self.groupArray[indexPath.row] posterImage]]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

#pragma mark - private




@end
