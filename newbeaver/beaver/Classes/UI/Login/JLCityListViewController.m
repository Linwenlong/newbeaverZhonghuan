//
//  JLCityListViewController.m
//  chow
//
//  Created by eall_linger on 16/4/15.
//  Copyright © 2016年 eallcn. All rights reserved.
//
//  选择城市控制器

#import "JLCityListViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "HttpTool.h"

@interface JLCityListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy)UITableView *listTableView;

@end

@implementation JLCityListViewController
{
    NSArray *_data;
    NSMutableArray *allCitiesArray;
  
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title  = @"选择城市";
    self.view.backgroundColor = [UIColor whiteColor];
    //2.0 创建加载tableView
    [self createMainView];
//    if ([self isFileExist:@"cityList.plist"] == NO) {
         [self createData];
//    }else{
//        _data = [self readFile];
//        [_listTableView reloadData];
//    }
//    [self createData];
    NSLog(@"%d",[self isFileExist:@"cityList.plist"]) ;
}

- (NSArray *)getLocalCityList{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"LocalCityList" ofType:@"plist"];
    NSArray *arr = [[NSArray alloc]initWithContentsOfFile:filePath];
    NSLog(@"arr = %@",arr);
    return arr;
}

- (void)createData
{
    NSString *url = @"customer/getCityData";
    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:url parameters:nil success:^(id responseObject) {
        [EBAlert hideLoading];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dic[@"code"] integerValue] == 0) {
            NSLog(@"加载成功");
            _data = dic[@"data"][@"city_list"];
//          [self writeFile:_data];
            [_listTableView reloadData];//从新加载数据
        }else{
            //如果失败就加载默认本地的
            _data = [self getLocalCityList];
            [_listTableView reloadData];//从新加载数据
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        _data = [self getLocalCityList];
        [_listTableView reloadData];//从新加载数据
    }];
}

//写入本地
- (void)writeFile:(NSArray *)data{
    NSString *docPath =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
    // 拼接要保存的地方的路径
    NSString *filePath = [docPath stringByAppendingPathComponent:@"cityList.plist"];
    [data writeToFile:filePath atomically:YES];
}

//读取本地
- (NSArray *)readFile{
    NSString *docPath =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)[0];
    // 拼接要保存的地方的路径
    NSString *filePath = [docPath stringByAppendingPathComponent:@"cityList.plist"];
    NSArray *city = [NSArray arrayWithContentsOfFile:filePath];
    return city;
}


//文件是否存在
-(BOOL)isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    return result;
}

- (void)createMainView
{
    _listTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH - 64)];
    _listTableView.dataSource = self;
    _listTableView.delegate   = self;
    [_listTableView setSeparatorInset:UIEdgeInsetsZero];
    [_listTableView setLayoutMargins:UIEdgeInsetsZero];
    _listTableView.backgroundColor = [UIColor whiteColor];
    _listTableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_listTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
      
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    NSDictionary *dict = _data[indexPath.row];
    if ([dict[@"name"] isEqualToString:_current_city]) {
        cell.textLabel.textColor = UIColorFromRGB(0xff3800);
    }else{
         cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.textLabel.text =dict[@"name"];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44 ;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = _data[indexPath.row];
    self.returnBlock(dict[@"name"],dict[@"code"]);
    [self.navigationController popViewControllerAnimated:YES];
}

@end

