//
//  HouseMessageTemplateViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/7/23.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseMessageTemplateViewController.h"

@interface HouseMessageTemplateViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
}
@property (nonatomic, strong)NSMutableArray *dataArray;//数据
@property (nonatomic, strong)DefaultView *defaultView;

@end

@implementation HouseMessageTemplateViewController

- (DefaultView *)defaultView{
    if (!_defaultView) {
        _defaultView = [[DefaultView alloc]initWithFrame:CGRectMake(0, 0, 250, 110)];
        _defaultView.center = _tableView.center;
        _defaultView.top -= 40;
        _defaultView.placeView.image = [UIImage imageNamed:@"contract"];
        _defaultView.placeText.text = @"暂未短信模版";
    }
    return _defaultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.title = @"短信模版";
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
    //    _tableView.backgroundColor = UIColorFromRGB(0xff3800);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView setLayoutMargins:UIEdgeInsetsZero];
    _tableView.separatorColor = UIColorFromRGB(0xe8e8e8);
    [self.view addSubview:_tableView];
    
    [self refreshHeader];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)requestData{
    
    
    NSString *urlStr = @"call/getMsgTpl";
    
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    //    _dept_id
    [HttpTool get:urlStr parameters:
     @{@"token":[EBPreferences sharedInstance].token,

       } success:^(id responseObject) {
           [EBAlert hideLoading];
           NSLog(@"responseObject=%@",responseObject);
           _dataArray = responseObject[@"data"];
           [_tableView.mj_header endRefreshing];
           [_tableView reloadData];
           
       } failure:^(NSError *error) {
           [EBAlert hideLoading];
           [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
           [_tableView.mj_header endRefreshing];
       }];
    
}

//刷新头部、、MJ
-(void)refreshHeader{
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
 
        [self requestData];//加载数据
    }];
    [_tableView.mj_header beginRefreshing];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}

#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *dic = _dataArray[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",dic[@"model_context"]];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = _dataArray[indexPath.row];
    self.returnBlock(dic[@"model_type"],dic[@"model_context"]);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
