//
//  ZHDCFollowupDetailViewController.m
//  beaver
//
//  Created by mac on 17/6/29.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ZHDCFollowupDetailViewController.h"
#import "HttpTool.h"
#import "EBPreferences.h"
#import "FollowupDetailModel.h"
#import "SDAutoLayout.h"
#import "FollowupDetailTableViewCell.h"
#import "EBAlert.h"
#import "UITableView+PlaceHolderView.h"
#import "DefaultView.h"


@interface ZHDCFollowupDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong)UITableView *mainTabelView;
@property (nonatomic, strong)NSMutableArray *dataArray;

@property (nonatomic, copy) NSString *house_title;//新房标题

@property (nonatomic, copy) NSString *custom_name;//客户姓名

@property (nonatomic, copy) NSString *custom_phone;//手机号

@end

@implementation ZHDCFollowupDetailViewController

- (UIView *)getHeaderView{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 100)];
    UILabel *custom_lable = [UILabel new];
    custom_lable.textAlignment = NSTextAlignmentLeft;
    custom_lable.textColor = UIColorFromRGB(0x00618D);
    custom_lable.font = [UIFont boldSystemFontOfSize:17.f];

    custom_lable.text = [NSString stringWithFormat:@"%@    %@",_custom_name,_custom_phone];
    UILabel *house_title = [UILabel new];
    house_title.font = [UIFont systemFontOfSize:16.0f];
    house_title.textAlignment = NSTextAlignmentLeft;
    house_title.textColor  = UIColorFromRGB(0x747476);
    house_title.text = _house_title;
    UIView *lastView = [UIView new];
    lastView.backgroundColor = UIColorFromRGB(0xEAEAEC);
    [view sd_addSubviews:@[custom_lable,house_title,lastView]];
    
    CGFloat x = 20;
    CGFloat top = 15;
    CGFloat margin = 10;
    custom_lable.sd_layout
    .topSpaceToView(view,top)
    .leftSpaceToView(view,x)
    .rightSpaceToView(view,x)
    .heightIs(30);
    
    house_title.sd_layout
    .topSpaceToView(custom_lable,margin)
    .leftSpaceToView(view,x)
    .rightSpaceToView(view,x)
    .heightIs(30);
    lastView.sd_layout
    .bottomSpaceToView(view,0)
    .leftSpaceToView(view,0)
    .rightSpaceToView(view,0)
    .heightIs(1);
    return view;
}

- (UITableView *)mainTabelView{
    if (!_mainTabelView) {
        _mainTabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, (_dataArray.count+1)*100) style:UITableViewStylePlain];
        _mainTabelView.delegate = self;
        _mainTabelView.dataSource = self;
        _mainTabelView.tableHeaderView = [self getHeaderView];
        [_mainTabelView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTabelView setLayoutMargins:UIEdgeInsetsZero];
        [_mainTabelView registerClass:[FollowupDetailTableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _mainTabelView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"报备状态";
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [NSMutableArray array];
    [self requestData];
    

}

- (void)requestData{
    NSString *urlString = @"NewHouse/recordsConfirmList";
    NSLog(@"urlString = %@",[NSString stringWithFormat:@"%@?token=%@&records_id=%@",urlString,[EBPreferences sharedInstance].token,_document_id]);
    NSDictionary *dic = @{
                            @"token":[EBPreferences sharedInstance].token,
                           @"records_id":_document_id
                            };
    [EBAlert showLoading:@"请求中..."];
    [HttpTool post:urlString parameters:dic success:^(id responseObject) {
        [EBAlert hideLoading];
        //是否启用占位图
        _mainTabelView.enablePlaceHolderView = YES;
        DefaultView *defaultView = (DefaultView *)_mainTabelView.yh_PlaceHolderView;
        defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
        defaultView.placeText.text = @"暂无详情数据";
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSArray *tmpArray = dic[@"data"][@"data"];
        for (NSDictionary *dic in tmpArray) {
            FollowupDetailModel *model = [[FollowupDetailModel alloc]initWithDict:dic];
            _custom_name = model.custom_name;
            _custom_phone = model.custom_phone;
            _house_title = model.house_title;
            [_dataArray addObject:model];
        }
        //创建tableview
        [self.view addSubview:self.mainTabelView];
        
    } failure:^(NSError *error) {
        if (_dataArray.count == 0) {
            //是否启用占位图
            _mainTabelView.enablePlaceHolderView = YES;
            DefaultView *defaultView = (DefaultView *)_mainTabelView.yh_PlaceHolderView;
            defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
            defaultView.placeText.text = @"数据获取失败";
            [_mainTabelView reloadData];
        }

        [EBAlert hideLoading];
        [EBAlert alertError:@"请求失败" length:2.0];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
    
}

#pragma mark -- UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FollowupDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    FollowupDetailModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


@end
