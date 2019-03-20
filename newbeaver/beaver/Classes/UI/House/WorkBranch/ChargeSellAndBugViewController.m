//
//  ChargeSellAndBugViewController.m
//  beaver
//
//  Created by mac on 17/12/20.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ChargeSellAndBugViewController.h"
#import "ChargeSellAndBuyTableViewCell.h"

@interface ChargeSellAndBugViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;//数据
@property (nonatomic, strong)DefaultView *defaultView;

@end

@implementation ChargeSellAndBugViewController

- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = self.mainTableView.center;
        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];//需要更换
        _defaultView.placeText.text = @"暂无收费信息...";
    }
    return _defaultView;
}


- (UIView *)headerView{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 45)];
    headerView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    UIView *line1 = [UIView new];
    
    line1.backgroundColor = UIColorFromRGB(0xe8e8e8);
    
    UILabel *leftLable = [UILabel new];
    leftLable.textAlignment = NSTextAlignmentLeft;
    leftLable.attributedText = [NSString changeString:[NSString stringWithFormat:@"应收合计: %0.02f",_totel_fee] frontLength:6 frontColor:LWL_LightGrayColor otherColor:LWL_RedColor ];
    leftLable.textColor = UIColorFromRGB(0x404040);
    leftLable.font = [UIFont boldSystemFontOfSize:13.0f];
    

    UILabel *rightLable = [UILabel new];
    rightLable.textAlignment = NSTextAlignmentRight;
    
    rightLable.textColor = UIColorFromRGB(0x404040);
    rightLable.font = [UIFont boldSystemFontOfSize:13.0f];
    
    if (_totel_other > 0) {
        rightLable.text = [NSString stringWithFormat:@"欠费: %0.2f",fabs(_totel_other)];
        rightLable.textColor = LWL_PurpleColor;
    }else if (_totel_other < 0){
        rightLable.text = [NSString stringWithFormat:@"应退: %0.2f",fabs(_totel_other)];
        rightLable.textColor = LWL_YellowColor;
    }else{
        rightLable.text = @"已补齐";
        rightLable.textColor = LWL_GreenColor;
    }
    
    [headerView sd_addSubviews:@[line1,leftLable,rightLable]];
    line1.sd_layout
    .topSpaceToView(headerView,0)
    .leftSpaceToView(headerView,0)
    .rightSpaceToView(headerView,0)
    .heightIs(1);
    
    leftLable.sd_layout
    .topSpaceToView(headerView,15)
    .leftSpaceToView(headerView,15)
    .widthIs(kScreenW/2.0f)
    .heightIs(15);
    
    rightLable.sd_layout
    .topSpaceToView(headerView,15)
    .rightSpaceToView(headerView,15)
    .widthIs(kScreenW/2.0f)
    .heightIs(15);
    
    return headerView;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH- 64-40)];
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.tableHeaderView = [self headerView];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mainTableView];
    [self.mainTableView registerClass:[ChargeSellAndBuyTableViewCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = _arr[indexPath.section];
    ChargeSellAndBuyTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setDic:dic];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 ) {
        return 0;
    }
    return 8;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0 ) {
        return nil;
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 8)];
    view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 7, kScreenW, 1)];
    line2.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    [view addSubview:line2];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 8; //这里是我的headerView和footerView的高度
    if (_mainTableView.contentOffset.y<=sectionHeaderHeight&&_mainTableView.contentOffset.y>=0) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-_mainTableView.contentOffset.y, 0, 0, 0);
    } else if (_mainTableView.contentOffset.y>=sectionHeaderHeight) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

@end
