//
//  TranferProcdureViewController.m
//  beaver
//
//  Created by mac on 17/12/27.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "TranferProcdureViewController.h"
#import "TransferProcdureView.h"
#import "ZHTransferStateCell.h"

@interface TranferProcdureViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *tmpArray;
@property (nonatomic, strong) NSDictionary *tmpDic;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, weak) UILabel *titleLable;
@property (nonatomic, weak) UILabel *contentLale;

@end

#define HeaderHeight 120

@implementation TranferProcdureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tmpArray = [NSMutableArray array];

    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"arr = %@",_arr);
    
    [self analyData];
    //1.0 加载设置顶部的过户节点ScrollView
    [self.view addSubview:self.mainTableView];
}

//获取最近一个节点
- (void)analyData{
    
    for (int i=0; i < _arr.count; i++) {
        NSDictionary *dic = _arr[i];
        if (![dic[@"status"] isEqualToString:@"s"]) {
            if (i == 0) {
                self.index = 0;
            }else{
                self.index = i - 1;
            }
        }else{
            self.index = i;
        }
        NSLog(@"index = %ld",self.index);
        _tmpDic = _arr[self.index];
        _tmpArray = _tmpDic[@"banliDataList"];
    }
    
}

- (UIView *)headerView{
    
    UIView *tableviewHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 196)];
    tableviewHeaderView.backgroundColor = [UIColor whiteColor];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 8)];
    bgView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    
    UIView*line1 =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
    line1.backgroundColor = LWL_LineColor;
    UIView*line2 =[[UIView alloc] initWithFrame:CGRectMake(0, 7, kScreenW, 1)];
    line2.backgroundColor = LWL_LineColor;
    [bgView addSubview:line1];
    [bgView addSubview:line2];
    
    [tableviewHeaderView addSubview:bgView];
    
    UIScrollView *ScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame), kScreenW, HeaderHeight)];
    [tableviewHeaderView addSubview:ScrollView];
    self.scrollView = ScrollView;
    
    //NSLog(@"scale: %.2f",scale);
    ScrollView.contentSize = CGSizeMake((kScreenW/4.0f) *_arr.count, HeaderHeight);  // 设置内容大小
//    ScrollView.pagingEnabled = YES;
//    ScrollView.bounces = ;
    ScrollView.showsHorizontalScrollIndicator = NO;//滚动的时候是否有水平的滚动条，默认是有的
    
    //滚动到最近的
    CGFloat offset = (self.index)/4;
    NSLog(@"index: %ld,offset: %.2f",self.index,offset);
    
    [UIView animateWithDuration:0.5 animations:^{
        ScrollView.contentOffset = CGPointMake(kScreenW *offset, 0);
    }];
    
    //1.1 添加headerView
    CGFloat marginX = 0;
    CGFloat viewH = HeaderHeight;
    CGFloat viewW = (kScreenW - 3 * marginX) / 4;
    CGFloat viewY = 0;
    for (int i = 0; i < _arr.count; i++) {
        
        NSDictionary *dic = _arr[i];
        
        CGFloat viewX = marginX + i * (viewW + marginX);
    
        TransferProcdureView *headerView = [[TransferProcdureView alloc]initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        headerView.contentLbl.text = dic[@"processName"];
        if ([dic[@"status"] isEqualToString:@"s"]) { //s:成功 f:异常 u:没有办理
            headerView.smallIcon.image = [UIImage imageNamed:@"transfergreen"];
            headerView.contentLbl.textColor = LWL_BlueColor;
            headerView.midLineLeft.backgroundColor = LWL_BlueColor;
            headerView.midLineRight.backgroundColor = LWL_BlueColor;
            
        } else if ([dic[@"status"] isEqualToString:@"f"]) {
            headerView.smallIcon.image = [UIImage imageNamed:@"transfergray"];
            headerView.contentLbl.textColor = LWL_LightGrayColor;
            headerView.midLineLeft.backgroundColor = LWL_LightGrayColor;
            headerView.midLineRight.backgroundColor = LWL_LightGrayColor;
        } else if ([dic[@"status"] isEqualToString:@"u"]) {
            headerView.smallIcon.image = [UIImage imageNamed:@"transfergray"];
            headerView.contentLbl.textColor = LWL_LightGrayColor;
            headerView.midLineLeft.backgroundColor = LWL_LightGrayColor;
            headerView.midLineRight.backgroundColor = LWL_LightGrayColor;
        }
        
        if (i > 0 && i < self.arr.count-1) { //s:成功 f:异常 u:没有办理
            NSDictionary *nextDict = self.arr[i+1]; //后一个字典
            if ([nextDict[@"status"] isEqualToString:@"s"]) {
                headerView.midLineRight.backgroundColor = LWL_BlueColor;
            } else if ([nextDict[@"status"] isEqualToString:@"f"]) {
                headerView.midLineRight.backgroundColor = LWL_LightGrayColor;
            } else if ([nextDict[@"status"] isEqualToString:@"u"]) {
                headerView.midLineRight.backgroundColor = LWL_LightGrayColor;
            }
        }
        headerView.tag = i;
        [headerView addTarget:self action:@selector(didClickNode:) forControlEvents:UIControlEventTouchUpInside];
        [ScrollView addSubview:headerView];
        
        //隐藏第一组左边线和最后一组右边线
        if (i == 0) {
            headerView.midLineLeft.hidden = YES;
        } else if (i == _arr.count -1) {
            headerView.midLineRight.hidden = YES;
        }
    }
    
    UILabel *titleLbl = [[UILabel alloc] init];
    _titleLable = titleLbl;
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.text = @"看档已完成";
    titleLbl.textColor = LWL_BlueColor;
    titleLbl.font = [UIFont systemFontOfSize:14];
    [tableviewHeaderView addSubview:titleLbl];
    
    titleLbl.sd_layout
    .topSpaceToView(ScrollView,5)
    .centerXEqualToView(tableviewHeaderView)
    .widthIs(kScreenW)
    .heightIs(15);
    
    UILabel *contentLbl = [[UILabel alloc] init];
    _contentLale = contentLbl;
    contentLbl.textAlignment = NSTextAlignmentCenter;
    contentLbl.text = @"2017年9月10日已完成看档";
    contentLbl.textColor = LWL_DarkGrayrColor;
    contentLbl.font = [UIFont systemFontOfSize:13];
    [tableviewHeaderView addSubview:contentLbl];
    
    contentLbl.sd_layout
    .topSpaceToView(titleLbl,8)
    .centerXEqualToView(tableviewHeaderView)
    .widthIs(kScreenW)
    .heightIs(15);
    
    //s: 执行，u:未执行 f；异常
    if ([_tmpDic[@"status"] isEqualToString:@"s"]) {
        _titleLable.text = [NSString stringWithFormat:@"%@已完成",_tmpDic[@"processName"]];
        _titleLable.textColor = LWL_BlueColor;
        if (![NSString StringIsNullOrEmpty:_tmpDic[@"addTime"]]) {
            NSInteger timeInt = [_tmpDic[@"addTime"] integerValue]/1000;
            _contentLale.text = [NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",timeInt] format:@"yyyy年MM月dd日"];
        }else{
            _contentLale.text = @"傻鸟,不抛null会死啊";
        }
        
    } else if ([_tmpDic[@"status"] isEqualToString:@"f"]) {
        _titleLable.text = [NSString stringWithFormat:@"%@办理异常",_tmpDic[@"processName"]];
        _contentLale.text = @"交易异常";
        _titleLable.textColor = LWL_DarkGrayrColor;
        
    } else {
        NSLog(@"%@",_tmpDic[@"processName"]);
        
        if (_tmpDic[@"processName"] != nil) {
            _titleLable.text = [NSString stringWithFormat:@"待办理%@",_tmpDic[@"processName"]];
        }else{
            _titleLable.text = @"待办理";
        }

        _contentLale.text = @"请等候办理";
        _titleLable.textColor = LWL_DarkGrayrColor;
    }

    
    
    UIView *bgView1 = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(contentLbl.frame)+20, kScreenW, 8)];
    bgView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    
    UIView*line3 =[[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, 1)];
    line3.backgroundColor = LWL_LineColor;
    UIView*line4 =[[UIView alloc] initWithFrame:CGRectMake(0, 7, kScreenW, 1)];
    line4.backgroundColor = LWL_LineColor;
    [bgView addSubview:line3];
    [bgView addSubview:line4];
    
    [tableviewHeaderView addSubview:bgView1];
    
    return tableviewHeaderView;

}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, -1, kScreenW, kScreenH- 64-40-50)];
        _mainTableView.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableHeaderView = [self headerView];
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _mainTableView;
}


#pragma mark -- 4

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tmpArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = _tmpArray[indexPath.row];
    
    ZHTransferStateCell *cell = [ZHTransferStateCell cellWithTableView:tableView];
    
    //把单元格点击时状态 改为None
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //设置标题的文字颜色
    cell.titleOneLbl.textColor = LWL_DarkGrayrColor;
    cell.titleOneLbl.text = [NSString stringWithFormat:@"%@:%@",dic[@"name"],dic[@"value"]];
    //设置内容的文字颜色
    cell.contentOneLbl.textColor = LWL_LightGrayColor;
    
    if (![NSString StringIsNullOrEmpty:dic[@"addTime"]]) {
        NSInteger timeInt = [dic[@"addTime"] integerValue]/1000;
        cell.contentOneLbl.text = [NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",timeInt] format:@"yyyy年MM月dd日"];
    }else{
        cell.contentOneLbl.text = @"时间戳能不能不要来null";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 44)];
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, kScreenW-30, 24)];
    lable.font = [UIFont boldSystemFontOfSize:13.0f];
    lable.text = @"任务办理结果";
    lable.textAlignment = NSTextAlignmentLeft;
    lable.textColor = LWL_DarkGrayrColor;
    [view addSubview:lable];
    
    return view;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 44; //这里是我的headerView和footerView的高度
    if (_mainTableView.contentOffset.y<=sectionHeaderHeight&&_mainTableView.contentOffset.y>=0) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-_mainTableView.contentOffset.y, 0, 0, 0);
    } else if (_mainTableView.contentOffset.y>=sectionHeaderHeight) {
        _mainTableView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


- (void)didClickNode:(UIControl *)tap{
    NSLog(@"tap = %ld",tap.tag);
    NSDictionary *dic = _arr[tap.tag];
    
    //滚动到最近的
    CGFloat offset = (tap.tag)/4;
    [UIView animateWithDuration:0.5 animations:^{
        self.scrollView.contentOffset = CGPointMake(kScreenW *offset, 0);
    }];
    
    //s: 执行，u:未执行 f；异常
    if ([dic[@"status"] isEqualToString:@"s"]) {
        _titleLable.text = [NSString stringWithFormat:@"%@已完成",dic[@"processName"]];
        _titleLable.textColor = LWL_BlueColor;
        if (![NSString StringIsNullOrEmpty:dic[@"addTime"]]) {
            NSInteger timeInt = [dic[@"addTime"] integerValue]/1000;
            _contentLale.text = [NSString timeWithTimeIntervalString:[NSString stringWithFormat:@"%ld",timeInt] format:@"yyyy年MM月dd日"];
        }else{
            _contentLale.text = @"傻鸟,不抛null会死啊";
        }
        
    } else if ([dic[@"status"] isEqualToString:@"f"]) {
        _titleLable.text = [NSString stringWithFormat:@"%@办理异常",dic[@"processName"]];
        _contentLale.text = @"交易异常";
        _titleLable.textColor = LWL_DarkGrayrColor;
        
    } else {
        _titleLable.text = [NSString stringWithFormat:@"待办理%@",dic[@"processName"]];
        _contentLale.text = @"请等候办理";
        _titleLable.textColor = LWL_DarkGrayrColor;
    }
    _tmpArray = dic[@"banliDataList"];

    [_mainTableView reloadData];
    
    
    
}

- (void)lwl{
    NSLog(@"lwl");
}

@end
