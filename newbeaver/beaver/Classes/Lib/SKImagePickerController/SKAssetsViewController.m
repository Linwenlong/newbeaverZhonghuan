//
//  SKAssetsViewController.m
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import "SKAssetsViewController.h"
#import "EBStyle.h"
#import "EBViewFactory.h"
#import "SKGridCell.h"
#import "SKGridItem.h"
#import "EBAlert.h"
#import "SKAsset.h"
#import "EBVideoUtil.h"

@interface SKAssetsViewController () <UITableViewDataSource, UITableViewDelegate, SKGridItemDelegate>
{
    NSMutableArray *_skAssets;
    
    UIButton *_nextBtn;
    UITableView *_tableView;
    NSMutableArray *_selectedAssets;
    UILabel *_labelLeaveNum;
}

@end

@implementation SKAssetsViewController

@synthesize selectedAssets = _selectedAssets, skAssets = _skAssets;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavBar];
    [self setHeadView];
    [self setTableView];
    [self loadAssets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)skAssets
{
    if (_skAssets == nil) {
        _skAssets = [[NSMutableArray alloc] init];
    }
    return _skAssets;
}

- (NSMutableArray *)selectedAssets
{
    if (_selectedAssets == nil) {
        _selectedAssets = [[NSMutableArray alloc] init];
    }
    return _selectedAssets;
}

#pragma mark - init
- (void)setNavBar
{
//    [self setNavigationbar];
//    [self addBackNavigationItem];
    [self addLeftNavigationBtnWithImage:[UIImage imageNamed:@"icon_back"] target:self action:@selector(backAction)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"nextstep", nil) target:self action:@selector(commit)];
//    _nextBtn.enabled = self.selectedAssets.count > 0;
    self.navigationItem.rightBarButtonItem.enabled = self.selectedAssets.count > 0;
    self.navigationItem.title = [self.group valueForProperty:ALAssetsGroupPropertyName];
}

- (void)setTableView
{
    CGRect frame = [EBStyle fullScrTableFrame:NO];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + 30, frame.size.width, frame.size.height - 30)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.allowsMultipleSelection = NO;
    _tableView.allowsSelection = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

- (void)setHeadView
{
    CGRect frame = CGRectMake(0, [EBStyle fullScrTableFrame:NO].origin.y, [EBStyle screenWidth], 30);
    UIView *headerView = [[UIView alloc] initWithFrame:frame];
    headerView.backgroundColor = [UIColor colorWithRed:255/255.0 green:169/255.0 blue:34/255.0 alpha:1];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _labelLeaveNum = label;
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    NSInteger maxNumber = self.maxSelect;
    
//    "photo_select_leave_num"       = "当前您还可以选择%d张照片";
    NSString *format = NSLocalizedString(@"photo_select_leave_num", nil);
    label.text = [NSString stringWithFormat:format, maxNumber];
    [headerView addSubview:label];
    [self.view addSubview:headerView];
}

#pragma mark - UITabelViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SK_ITEM_GAP + SK_ITEM_WIDTH;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    double numberOfAssets = (double)self.group.numberOfAssets;
    NSInteger nr = ceil(numberOfAssets / 4);
    return nr;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PhotoCell";
    SKGridCell *cell = (SKGridCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[SKGridCell alloc] initWithViewCtrl:self items:[self itemsForRowAtIndexPath:indexPath] identifier:cellIdentifier];
    }
    else
    {
        cell.items = [self itemsForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (NSMutableArray *)itemsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:4];
    
    NSUInteger startIndex = indexPath.row * 4,
    endIndex = startIndex + 4 - 1;
    if (startIndex < self.skAssets.count)
    {
        if (endIndex > self.skAssets.count - 1)
            endIndex = self.skAssets.count - 1;
        
        for (NSUInteger i = startIndex; i <= endIndex; i++)
        {
            [items addObject:(self.skAssets)[i]];
        }
    }
    
    return items;
}

#pragma mark - action
- (void)commit
{
    
    __weak typeof(self) weakSelf = self;
    [self.navigationController dismissViewControllerAnimated:NO completion:^{
        if (weakSelf.photoSelect) {
            weakSelf.photoSelect(weakSelf.selectedAssets);
        }
    }];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private
- (void)loadAssets
{
    [self.skAssets removeAllObjects];
    [EBAlert showLoading:nil];
    __weak SKAssetsViewController *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       [weakSelf.group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
           if (result) {
               SKAsset *skAsset = [[SKAsset alloc] init];
               skAsset.asset = result;
               skAsset.select = NO;
               [self.skAssets insertObject:skAsset atIndex:0];
           }
           else
           {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [EBAlert hideLoading];
                   [weakSelf reloadData];
               });
           }
       }];
    });
}

- (void)reloadData
{
    [_tableView reloadData];
}

#pragma mark - SKGridItemDelegate
- (void)skGridItem:(SKGridItem *)gridItem didChangeSelectionState:(NSNumber *)selected
{
    if ([selected boolValue]) {
//        if (![EBVideoUtil validVideoSelected:gridItem.skAsset.asset assets:self.selectedAssets]) {
//            [gridItem tap];
//            [EBAlert alertError:@"不能选择多个视频"];
//            return;
//        }
        
        BOOL addFlag = YES;
        for (ALAsset *asset in self.selectedAssets) {
            if (asset == gridItem.skAsset.asset) {
                addFlag = NO;
                break;
            }
        }
        if (addFlag) {
            [self.selectedAssets addObject:gridItem.skAsset.asset];
        }
    } else {
        [self.selectedAssets removeObject:gridItem.skAsset.asset];
    }
    
    NSString *format = NSLocalizedString(@"photo_select_leave_num", nil);
    _labelLeaveNum.text = [NSString stringWithFormat:format, self.maxSelect - self.selectedAssets.count];
//    _nextBtn.enabled = self.selectedAssets.count > 0;
    self.navigationItem.rightBarButtonItem.enabled = self.selectedAssets.count > 0;
}

- (BOOL)skGridItemCanSelect:(SKGridItem *)gridItem
{
    if (self.maxSelect > 0) {
        BOOL existTag = NO;
        for (ALAsset *asset in self.selectedAssets) {
            if (asset == gridItem.skAsset.asset) {
                existTag = YES;
                break;
            }
        }
        if (existTag) {
            return YES;
        }
        else
        {
            return self.selectedAssets.count < self.maxSelect;
        }
    }
    else
    {
        return YES;
    }
}


@end
