//
//  AddNewHousingDevelopmentViewController.m
//  beaver
//
//  Created by mac on 17/8/17.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "AddNewHousingDevelopmentViewController.h"
#import "AddNewHousingDevelopmentTableViewCell.h"
#import "EBCache.h"
#import "MBProgressHUD.h"
#import "CommuityModel.h"

@interface AddNewHousingDevelopmentViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSArray *_sectionIndexTitles;
    UISearchBar *_searchBar;
    BOOL isSearchBarActive;//是否响应
}
@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSMutableArray *indexArray;
@property (nonatomic, strong) NSMutableArray * letterResultArr;
@property (nonatomic, strong) NSMutableArray * tmpArr;;
@property (nonatomic, strong) NSMutableArray * searchHistory;

@end

@implementation AddNewHousingDevelopmentViewController

#pragma mark -- lasy

-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        if ([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_mainTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        if ([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_mainTableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
        }
        //去除多余的下划线
        _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mainTableView;
}

- (void)loadData{
    _indexArray =[NSMutableArray arrayWithArray:[[EBCache sharedInstance]objectForKey:EB_CACHE_KEY_COMMUITYS_INDEX]] ;
    _letterResultArr = [NSMutableArray arrayWithArray:[[EBCache sharedInstance]objectForKey:EB_CACHE_KEY_COMMUITYS]];
    _tmpArr = [NSMutableArray arrayWithArray:[[EBCache sharedInstance]objectForKey:EB_CACHE_KEY_COMMUITYS_ALL]];

    NSArray *tmpArray = @[@"搜索信息",@"搜索信息",@"搜索信息",@"搜索信息",@"搜索信息"];
    _searchHistory = [NSMutableArray arrayWithArray:tmpArray];
}
- (void)setUI{

    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, kScreenW-100, 30)];
    _searchBar.placeholder = @"小区名称或拼音首字母";
    _searchBar.delegate = self;
 
    self.navigationItem.titleView = _searchBar;
    [self.view addSubview:self.mainTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = @"选择小区";
    isSearchBarActive = NO;
    
    [self loadData];
    [self setUI];
 
    [_mainTableView registerNib:[UINib nibWithNibName:@"AddNewHousingDevelopmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"historyCell"];
}

#pragma mark -- UISearchBarDelegate


//if (keyword && keyword.length > 0) {
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"deptTel contains %@",keyword];
//    resultArray = [[_allContactsArray filteredArrayUsingPredicate:predicate] mutableCopy];
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    if (searchText.length>0) {
        isSearchBarActive  =  YES;
        //    改变了
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"commuity_name contains %@",searchText];
        _letterResultArr = [[_tmpArr filteredArrayUsingPredicate:predicate] mutableCopy];
    }else{
         isSearchBarActive = NO;
          _letterResultArr = [NSMutableArray arrayWithArray:[[EBCache sharedInstance]objectForKey:EB_CACHE_KEY_COMMUITYS]];//还原数据
    }
    [self.mainTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    //刷新tableview
    //改变状态
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    
    _letterResultArr = [NSMutableArray arrayWithArray:[[EBCache sharedInstance]objectForKey:EB_CACHE_KEY_COMMUITYS]];//还原数据
    
    isSearchBarActive = NO;
    [self.mainTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //刷新tableview
    [_searchBar resignFirstResponder];
    isSearchBarActive = YES;
    [self.mainTableView reloadData];
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    isSearchBarActive = YES;
    [self.mainTableView reloadData];//刷新数据
    [UIView animateWithDuration:0.3 animations:^{
        _searchBar.showsCancelButton = YES;
        for (id obj in [searchBar subviews]) {
            if ([obj isKindOfClass:[UIView class]]) {
                for (id obj2 in [obj subviews]) {
                    if ([obj2 isKindOfClass:[UIButton class]]) {
                        UIButton *btn = (UIButton *)obj2;
                        [btn setTitle:@"取消" forState:UIControlStateNormal];
                        btn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
                        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                }
            }
        }
    }];
}

#pragma mark -- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (isSearchBarActive == YES) {//搜索框被激活
        return 1;
    }else{
        return [self.letterResultArr count];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isSearchBarActive == YES) {//搜索框被激活
        if (_searchBar.text.length > 0) {
            return self.letterResultArr.count;
        }else{
            return 0;
        }
    }else{
       return [[self.letterResultArr objectAtIndex:section] count];
    }
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (isSearchBarActive == YES) {//搜索框被激活
        if (_searchBar.text.length > 0) {
            AddNewHousingDevelopmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
            //获得对应的Person对象<替换为你自己的model对象>
            CommuityModel *model = [self.letterResultArr objectAtIndex:indexPath.row];
            [cell setModel:model];
            return cell;
        }
            else{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
            cell.textLabel.text = _searchHistory[indexPath.row];
            cell.textLabel.font = [UIFont systemFontOfSize:13.0f];
            cell.textLabel.textColor = UIColorFromRGB(0x404040);
            return cell;
        }
       
    }else{
        AddNewHousingDevelopmentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        //获得对应的Person对象<替换为你自己的model对象>
        CommuityModel *model = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [cell setModel:model];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isSearchBarActive == YES) {//搜索框被激活
        if (_searchBar.text.length > 0) {
            //获得对应的Person对象<替换为你自己的model对象>
            CommuityModel *model = [self.letterResultArr objectAtIndex:indexPath.row];
            //调用接口返回
            [self backForModel:model];
        }else{
//         历史搜索的事件
        }
    
    }else{
    
        //获得对应的Person对象<替换为你自己的model对象>
        CommuityModel *model = [[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [self backForModel:model];
    }
}

- (void)backForModel:(CommuityModel *)model{
 
    NSString *address = model.address;
    if (address.length == 0) {
        address= [NSString stringWithFormat:@"%@-%@",model.ppname,model.pname];
    }
    
    //关注小区
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/Community/communityAdd?token=%@&community_id=%@&community=%@&address=%@",[EBPreferences sharedInstance].token,model.commuity_id,model.commuity_name,address]);
    [EBAlert showLoading:@"添加中..."];
    [HttpTool post:@"Community/communityAdd" parameters:
     @{ @"token":[EBPreferences sharedInstance].token,
        @"community_id":model.commuity_id,
        @"community":model.commuity_name,
        @"address":address
        }success:^(id responseObject) {
            [EBAlert hideLoading];
            NSDictionary *currentDic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            
            if ([currentDic[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"关注成功" allowUserInteraction:1.0f];
                [self.navigationController popViewControllerAnimated:YES];
                self.textBlock();//调用block
            }else{
                [EBAlert alertError:currentDic[@"desc"] length:2.0f];
            }
        } failure:^(NSError *error) {
            [EBAlert hideLoading];
            [EBAlert alertError:@"请检查网络" length:2.0f];
        }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isSearchBarActive==YES) {
        if (_searchBar.text.length > 0) {
            return 60;
        }else{
            return 50;
        }
    }else{
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (isSearchBarActive==YES) {
        if (_searchBar.text.length > 0) {
            return 20;
        }else{
             return 0;
        }
    }else{
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (isSearchBarActive == YES) {//搜索框被激活
//        if (_searchBar.text.length > 0) {
            return nil;
//        }else{
//            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 40)];
//            view.backgroundColor = UIColorFromRGB(0xf1f1f1);
//            UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 200, 40)];
//            lable.textColor = UIColorFromRGB(0x404040);
//            lable.backgroundColor = UIColorFromRGB(0xf1f1f1);
//            lable.textAlignment = NSTextAlignmentLeft;
//            lable.font = [UIFont boldSystemFontOfSize:15.0f];
//            lable.text = @"历史搜索";
//            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(kScreenW-20-15, 10, 20, 20)];
//            imageView.backgroundColor = [UIColor redColor];
//            [view addSubview:lable];
//            [view addSubview:imageView];
//            return view;
//        }
    }else{
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 20)];
        view.backgroundColor = [UIColor whiteColor];
        UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, kScreenW-15, 20)];
        lable.textColor = UIColorFromRGB(0xff3800);
        lable.backgroundColor = [UIColor whiteColor];
        lable.textAlignment = NSTextAlignmentLeft;
        lable.font = [UIFont boldSystemFontOfSize:15.0f];
        lable.text = [self.indexArray objectAtIndex:section];
        [view addSubview:lable];
        return view;
    }
}


-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (isSearchBarActive == NO) {
         return self.indexArray;
    }
    return nil;
}
#pragma mark 索引列点击事件
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    //点击索引，列表跳转到对应索引的行
    [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self showMessage:title toView:self.view];
    return index;
}

#pragma mark 显示一些信息
- (void)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 1秒之后再消失
    [hud hide:YES afterDelay:0.7];
}


@end
