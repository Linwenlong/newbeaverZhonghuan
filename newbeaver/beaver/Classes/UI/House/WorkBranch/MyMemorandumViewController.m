//
//  MyMemorandumViewController.m
//  beaver
//
//  Created by mac on 17/8/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MyMemorandumViewController.h"
#import "AddMyMemoradumViewController.h"
#import "MyMemorandumTableViewCell.h"
#import "MyMemorandumDetailViewController.h"
#import "MJRefresh.h"
#import "HttpTool.h"
#import "EBPreferences.h"
#import "EBAlert.h"
#import "MyMemoranduModel.h"

@interface MyMemorandumViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
//新增备忘录
@property (nonatomic, strong)UIButton *add_button;
@property (nonatomic, strong)NSMutableArray *selectArray;//选择的数据
@property (nonatomic, strong)UIButton *complete_button;

@property (nonatomic, strong)UILabel * headerLable;

@end

@implementation MyMemorandumViewController

- (UIButton *)complete_button{
    if (!_complete_button) {
        _complete_button = [[UIButton alloc]initWithFrame:CGRectMake(20,10 , 50, 30)];
        
        _complete_button.backgroundColor = [UIColor clearColor];
        [_complete_button setTitle:@"全选" forState:UIControlStateNormal];
//        _complete_button.titleLabel.textAlignment = NSTextAlignmentLeft;//这句没用
        _complete_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_complete_button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _complete_button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        _complete_button.hidden = YES;
        _complete_button.layer.borderWidth = 1.0f;
        _complete_button.layer.borderColor = [UIColor whiteColor].CGColor;
        [_complete_button addTarget:self action:@selector(selectAllBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _complete_button;
}

- (UIButton *)add_button{
    if (!_add_button) {
        _add_button = [[UIButton alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 114, [UIScreen mainScreen].bounds.size.width, 50)];
        
        _add_button.backgroundColor = AppMainColor(1);
        [_add_button setTitle:@"新增备忘录" forState:UIControlStateNormal];
        [_add_button setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
        _add_button.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        [_add_button addTarget:self action:@selector(addNewMyMemoradum:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _add_button;
}

- (UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-114)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
        _mainTableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
        _headerLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 40)];
        _headerLable.text = @"暂无备忘";
        _headerLable.font = [UIFont systemFontOfSize:14.0f];
        _headerLable.textColor =  UIColorFromRGB(0xa4a4a4);
        _headerLable.textAlignment = NSTextAlignmentCenter;
        _mainTableView.tableHeaderView = _headerLable;
    }
    return _mainTableView;
}

- (void)deleteDatas{
  
    NSMutableArray *array = [NSMutableArray array];
    for (MyMemoranduModel *model in _selectArray) {
        [array addObject:model.document_id];
    }
    NSString *str = [array componentsJoinedByString:@";"];

    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Memo/memoDel?token=%@&document_id=%@",[EBPreferences sharedInstance].token,str]);
    [EBAlert showLoading:@"删除中..." allowUserInteraction:NO];
    [HttpTool post:@"Memo/memoDel" parameters:
         @{@"token":[EBPreferences sharedInstance].token,
           @"document_id":str                                                                             }success:^(id responseObject) {
               [EBAlert hideLoading];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               if ([currentDic[@"code"] integerValue] == 0) {
                   [EBAlert alertSuccess:@"删除成功" allowUserInteraction:1.0f];
                   [_selectArray removeAllObjects];
                   //删除成功 刷新
                   [self refreshHeader];//刷新
               }else{
                   NSLog(@"删除失败");
               }
               [self.mainTableView reloadData];
           } failure:^(NSError *error) {
               [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
    }];
    
}

- (void)addNewMyMemoradum:(UIButton *)btn{
    if (self.mainTableView.editing) {
        NSLog(@"删除");
        if (_selectArray.count>0) {
            [self deleteDatas];
        }
    }else{
        //跳转到新建备忘录界面
        AddMyMemoradumViewController *addMmvc = [[AddMyMemoradumViewController alloc]initWithNibName:@"AddMyMemoradumViewController" bundle:nil];
        addMmvc.hidesBottomBarWhenPushed = YES;
        addMmvc.title = @"新增";
        addMmvc.textBlock = ^{
            //删除ui
            [self refreshHeader];
        };
        [self.navigationController pushViewController:addMmvc animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title = @"我的备忘";
    _selectArray = [NSMutableArray array];
    _dataArray = [NSMutableArray array];
    [self addRightNavigationBtnWithTitle:@"编辑" target:self action:@selector(editing:)];
    [self.view addSubview:self.mainTableView];
    [self.view addSubview:self.add_button];
    [self.add_button addSubview:self.complete_button];
    
    [self refreshHeader];

    [self.mainTableView registerNib:[UINib nibWithNibName:@"MyMemorandumTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}
//刷新头部、、MJ
-(void)refreshHeader{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];//加载数据
    }];
    [self.mainTableView.mj_header beginRefreshing];
}

#pragma mark -- RequestData
- (void)requestData{
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Memo/getMemoList?token=%@",[EBPreferences sharedInstance].token]);
    [EBAlert showLoading:@"加载中..." allowUserInteraction:NO];
    [HttpTool post:@"Memo/getMemoList" parameters:
            @{@"token":[EBPreferences sharedInstance].token,}
           success:^(id responseObject) {
               //是否启用占位图
               _mainTableView.enablePlaceHolderView = YES;
               DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
               defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
               defaultView.placeText.text = @"暂无详情数据";
               
               [EBAlert hideLoading];
               [_dataArray removeAllObjects];
               NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
               NSDictionary *dic = currentDic[@"data"];
               _headerLable.text = [NSString stringWithFormat:@"共%@条备忘录",dic[@"statistic"][@"count"]];
               NSArray *tmpArray = dic[@"data"];
               
               //判断是否为空显示没有时的东西
               for (NSDictionary *dic in tmpArray) {
                   MyMemoranduModel *model  = [[MyMemoranduModel alloc]initWithDict:dic];
                   [_dataArray addObject:model];
               }
               [self.mainTableView.mj_header endRefreshing];
               [self.mainTableView reloadData];
           } failure:^(NSError *error) {
               if (_dataArray.count == 0) {
                   //是否启用占位图
                   _mainTableView.enablePlaceHolderView = YES;
                   DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
                   defaultView.placeView.image = [UIImage imageNamed:@"数据获取失败"];
                   defaultView.placeText.text = @"数据获取失败";
                   [self.mainTableView reloadData];
               }
               [EBAlert hideLoading];
               [EBAlert alertError:@"请检查网络" length:2.0f];
               [self.mainTableView.mj_header endRefreshing];
           }];
    
}


#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
        return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyMemorandumTableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MyMemoranduModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    //多选时的颜色
    cell.multipleSelectionBackgroundView = [UIView new];
    cell.tintColor = [UIColor redColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row % 2 != 0) {
//        return UITableViewCellEditingStyleDelete |UITableViewCellEditingStyleInsert;
//    }else{
//        return UITableViewCellEditingStyleDelete & UITableViewCellEditingStyleInsert;
//    }
//}

//删除
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
    
}

////删除
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.row % 2 != 0) {
//        return YES;
//    }else{
//        return NO;
//    }
//}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
//    http://218.65.86.83:8010/Memo/memoDel?token=7376fba5040a7d30006ca5fd5f8473ee&document_id=34
    if (editingStyle == UITableViewCellEditingStyleDelete) {//删除
        //调用接口删除
         MyMemoranduModel *model = _dataArray[indexPath.row];
         NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Memo/memoDel?token=%@&document_id=%@",[EBPreferences sharedInstance].token,model.document_id]);
         NSString *urlStr = @"Memo/memoDel";
        [EBAlert showLoading:@"删除中..."];
        [HttpTool post:urlStr parameters:
         @{@"token":[EBPreferences sharedInstance].token,
            @"document_id":model.document_id                                                                              }success:^(id responseObject) {
               [EBAlert hideLoading];
                   NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if ([currentDic[@"code"] integerValue] == 0) {
                    [EBAlert alertSuccess:@"删除成功" allowUserInteraction:1.0f];
                    
                     [_dataArray removeObjectAtIndex:indexPath.row];
                    _headerLable.text = [NSString stringWithFormat:@"共%ld条备忘录",_dataArray.count];
                }else{
                    NSLog(@"删除失败");
                }
                   [self.mainTableView reloadData];
               } failure:^(NSError *error) {
                   [EBAlert hideLoading];
                   [EBAlert alertError:@"请检查网络" length:2.0f];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.mainTableView.editing) {
         [_selectArray addObject:[self.dataArray objectAtIndex:indexPath.row]];
        [_add_button setTitle:@"删除" forState:UIControlStateNormal];
        _complete_button.hidden = NO;
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        MyMemorandumDetailViewController *detailVC = [[MyMemorandumDetailViewController alloc]initWithNibName:@"MyMemorandumDetailViewController" bundle:nil];
        MyMemoranduModel *model = _dataArray[indexPath.row];
        detailVC.model = model;
        detailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_selectArray removeObject:[self.dataArray objectAtIndex:indexPath.row]];
}

//编辑
- (void)editing:(id)sender{
    //tableView进入编辑状态
    //支持同时选中多行
    self.mainTableView.allowsMultipleSelectionDuringEditing = YES;
//    [self.mainTableView setEditing:!self.mainTableView.editing animated:YES];
    self.mainTableView.editing = !self.mainTableView.editing;
    
    if (self.mainTableView.editing) {
          [_add_button setTitle:@"删除" forState:UIControlStateNormal];
        _complete_button.hidden = NO;
        self.navigationItem.rightBarButtonItem.title = @"完成";
    }else{
        [_selectArray removeAllObjects];//返回时清空数据
        
        [_add_button setTitle:@"新增备忘录" forState:UIControlStateNormal];
        _complete_button.hidden = YES;
        self.navigationItem.rightBarButtonItem.title = @"编辑";
    }
}

- (void)selectAllBtnClick:(UIButton *)button {
    
    //    [self.tableView reloadData];
    if ([button.titleLabel.text isEqualToString:@"全选"]) {
        [button setTitle:@"取消全选" forState:UIControlStateNormal];
        for (int i = 0; i < self.dataArray.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.mainTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
        [self.selectArray addObjectsFromArray:self.dataArray];

    }else{
        [button setTitle:@"全选" forState:UIControlStateNormal];
        for (int i = 0; i < self.dataArray.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.mainTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
         [self.selectArray removeAllObjects];
    }
   
}



@end
