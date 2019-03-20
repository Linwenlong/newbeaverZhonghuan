//
//  HouseCollectionViewController.m
//  beaver
//
//  Created by 林文龙 on 2018/11/14.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "HouseCollectionViewController.h"
#import "HouseItemView.h"
#import "EBViewFactory.h"
#import "EBHttpClient.h"
#import "SwipeableSectionHeader.h"
#import "HouseCreateNewGroupView.h"
#import "HWPopTool.h"
#import "MBProgressHUD.h"
#import "DeleteGroupPopView.h"
#import "EBController.h"

@interface HouseCollectionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView * mainTableView;
@property (nonatomic, strong) NSMutableArray * dataArray;

@end

@implementation HouseCollectionViewController

- (void)addGroup:(UIButton *)btn{
    HouseCreateNewGroupView *createView = [[HouseCreateNewGroupView alloc]initWithFrame:CGRectMake(0, 0, kScreenW-80, 200)];
    
    createView.btnClick = ^(UIButton *btn ,UITextField *groupName) {
        
        if (btn.tag == 1) {
            [self closePop];
            return ;
        }
        
        if (groupName.text.length == 0 || groupName == nil) {
            [EBAlert alertError:@"请输入新分组名称"];
            return ;
        }
        //新增分组
        NSString *url = @"/house/addFavoriteGroup";
        NSDictionary *parm = @{
                               @"token" : [EBPreferences sharedInstance].token,
                               @"favorite_group" : groupName.text
                               };
        NSLog(@"parm = %@",parm);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [HttpTool post:url parameters:parm success:^(id responseObject) {
            NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"dict = %@",dict);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self closePop];
            if ([dict[@"code"] integerValue] == 0) {
                
                if ([dict[@"data"][@"code"] integerValue] == 200) {
                    [EBAlert alertSuccess:@"新建成功"];
                }else{
                    [EBAlert alertError:dict[@"data"][@"desc"]];
                }
            }else{
                [EBAlert alertError:@"请求失败"];
            }
            
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [EBAlert alertSuccess:@"请求失败"];
            [self closePop];
        }];
    };
    MyViewController *vc = [[HWPopTool sharedInstance]showWithPresentView:createView animated:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop)];
    vc.styleView.userInteractionEnabled = YES;
    [vc.styleView addGestureRecognizer:tap];
}

- (void)closePop{
    [[HWPopTool sharedInstance]closeWithBlcok:^{
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"房源收藏";
    
    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor blueColor];
    _dataArray = [NSMutableArray array];
    
    self.mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 10, kScreenW, kScreenH-115) style:UITableViewStylePlain];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    UIButton *addGroup = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 60)];
    addGroup.backgroundColor = UIColorFromRGB(0xff3800);
    [addGroup setTitle:@"新增分组" forState:UIControlStateNormal];
    [addGroup setImage:[UIImage imageNamed:@"房源收藏_新增"] forState:UIControlStateNormal];
    [addGroup.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [addGroup setTitleEdgeInsets:UIEdgeInsetsMake(0, -addGroup.imageView.bounds.size.width, 0, addGroup.imageView.bounds.size.width)];
    [addGroup setImageEdgeInsets:UIEdgeInsetsMake(0, addGroup.titleLabel.bounds.size.width+5, 0, -addGroup.titleLabel.bounds.size.width)];
    [addGroup addTarget:self action:@selector(addGroup:) forControlEvents:UIControlEventTouchUpInside];
    self.mainTableView.tableHeaderView = addGroup;
    
    self.mainTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
  
    [self.view addSubview:self.mainTableView];
    
    [self.mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    
    [self refreshHeader];
    
}

- (void)requestData{
    
    //新增分组
    NSString *url = @"house/favoriteGroupHouse";
    NSDictionary *parm = @{
                           @"token" : [EBPreferences sharedInstance].token,
                           };
    NSLog(@"parm = %@",parm);
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [HttpTool get:url parameters:parm success:^(id responseObject) {
        NSLog(@"responseObject = %@",responseObject);
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject[@"code"] integerValue] == 0) {
            if ([responseObject[@"data"] isKindOfClass:[NSArray class]]) {
                [self.dataArray removeAllObjects];
                
                NSArray *tmpArr = responseObject[@"data"];
                
//                for (NSDictionary *dic in tmpArr) {
//                    EBHouse *house = [MTLJSONAdapter modelOfClass:[EBHouse class] fromJSONDictionary:dic error:nil];
//                    NSLog(@"house=%@",house);
//                    [self.dataArray addObject:house];
//                }
                
                
                [self.dataArray addObjectsFromArray:tmpArr];
                NSLog(@"dataArray=%@",self.dataArray);
                
                [_mainTableView.mj_header endRefreshing];
                [self.mainTableView reloadData];
            }else{
               [EBAlert alertError:@"请求失败"];
            }
        }else{
            [EBAlert alertError:@"请求失败"];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [EBAlert alertSuccess:@"请求失败"];
    }];
    return;
//    [[EBHttpClient sharedInstance] houseRequest:@{@"collect":@(1)} collect:^(BOOL success, id result)
//     {
//         NSLog(@"result=%@",result);
//         if (success == YES) {
//             if (result != nil && [result isKindOfClass:[NSArray class]]) {
////                 EBHouse
//
//                 NSLog(@"result = %@",result);
//                 [self.dataArray removeAllObjects];
//
//                 NSArray *sortDesc = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"group_id" ascending:YES]];
//
//                 NSArray *sortedArr = [result sortedArrayUsingDescriptors:sortDesc];
//
//                 NSLog(@"sortedArr = %@",sortedArr);
//
//                 NSInteger biaoqiao;
//                 NSString *favorite_group;
//
//                 NSMutableArray *tmpArray = [NSMutableArray array];
//
//                 if (sortedArr.count > 1) {
//                     EBHouse *tmpDic = sortedArr.firstObject;
//                     biaoqiao = [tmpDic.group_id integerValue];
//
//                     favorite_group = tmpDic.favorite_group == nil ? @"未分组" : tmpDic.favorite_group;
//
//                     NSMutableArray *middenArray = [NSMutableArray array];
//                     for (EBHouse *house in sortedArr) {
//                         if ([house.group_id integerValue] == biaoqiao) {//等于放入数组
//                             [middenArray addObject:house];
//                         }else{//不等于的时候赋值biaoqiao和清空middenarray
//                             //清空之前先把数组加入tmpArray
//                             NSLog(@"middenArray=%@",middenArray);
//                           NSDictionary *dic = @{@"group_name" : favorite_group,
//                                                 @"group_id" : [NSNumber numberWithInteger:biaoqiao],
//                                                 @"isShow" : @0,
//                                                 @"houses":[middenArray mutableCopy]
//                                                 };
//                             [tmpArray addObject:dic];
//                             //添加了清空
//                             biaoqiao = [house.group_id integerValue];
//                             favorite_group = house.favorite_group == nil ? @" " : house.favorite_group;
//                             [middenArray removeAllObjects];
//                             [middenArray addObject:house];//将最后一个加入
//                         }
//                     }
//                     //循环玩最后添加进来
//                     NSDictionary *dic = @{@"group_name" : favorite_group,
//                                           @"group_id" : [NSNumber numberWithInteger:biaoqiao],
//                                           @"isShow" : @0,
//                                           @"houses":[middenArray mutableCopy]
//                                           };
//                     [tmpArray addObject:dic];
//
//                 }
//
//                 NSLog(@"tmpArray=%@",tmpArray);
//                [self.dataArray addObjectsFromArray:tmpArray];
//             }
//             [_mainTableView.mj_header endRefreshing];
//             [self.mainTableView reloadData];
//         }
//
//     }];
}



//刷新头部、、MJ
-(void)refreshHeader{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestData];//加载数据
    }];
    [self.mainTableView.mj_header beginRefreshing];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *dic =self.dataArray[section];
    if ([dic[@"is_show"] integerValue] == 0) {
        return 0;
    }
    NSArray *tmpArr = dic[@"houses"];
    return tmpArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 84;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    HouseItemView *itemView;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        itemView = [[HouseItemView alloc] initWithFrame:CGRectMake(0.0, 0.0, [EBStyle screenWidth], 84.0)];
        
//        itemView.backgroundColor = [UIColor redColor];
        
        itemView.tag = 88;
      
        [cell.contentView addSubview:itemView];
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:84.0 leftMargin:5.0]];
        
        if (tableView.isEditing)
        {
            UIView *selectedView = [[UIView alloc] init];
            [selectedView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:84.5 leftMargin:43.0]];
            cell.selectedBackgroundView = selectedView;
        }
    }
    else
    {
        itemView = (HouseItemView *)[cell.contentView viewWithTag:88];
    }
//    itemView.showImage = _showImage;
//    itemView.targetClientId = self.filter.clientId;
    NSDictionary *dic =self.dataArray[indexPath.section];
    NSArray *tmpArr = dic[@"houses"];
    
    NSDictionary *tmpDic = tmpArr[indexPath.row];
  
    itemView.house = [MTLJSONAdapter modelOfClass:[EBHouse class] fromJSONDictionary:tmpDic error:nil];
    
   
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //第二组可以左滑删除
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}


- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"转移" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {//title可自已定义
        NSLog(@"转移");
        NSDictionary *dic =self.dataArray[indexPath.section];
        NSArray *tmpArr = dic[@"houses"];
        NSDictionary *tmpDic = tmpArr[indexPath.row];
        EBHouse *house =[MTLJSONAdapter modelOfClass:[EBHouse class] fromJSONDictionary:tmpDic error:nil];
        [self transferHouses:@[house]];
        
    }];
    deleteRoWAction.backgroundColor = RGB(210, 207, 209);
    //此处是iOS8.0以后苹果最新推出的api，UITableViewRowAction，Style是划出的标签颜色等状态的定义，这里也可自行定义
    UITableViewRowAction *editRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"删除");
        NSDictionary *dic =self.dataArray[indexPath.section];
        NSArray *tmpArr = dic[@"houses"];
        NSDictionary *tmpDic = tmpArr[indexPath.row];
        EBHouse *house =[MTLJSONAdapter modelOfClass:[EBHouse class] fromJSONDictionary:tmpDic error:nil];
        [self deleteHouses:@[house] group:100000000];
        
    }];
    editRowAction.backgroundColor = [UIColor redColor];//可以定义RowAction的颜色
    return @[editRowAction,deleteRoWAction];//最后返回这俩个RowAction 的数组
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic =self.dataArray[indexPath.section];
    NSArray *tmpArr = dic[@"houses"];
    NSDictionary *tmpDic = tmpArr[indexPath.row];
    EBHouse *house =[MTLJSONAdapter modelOfClass:[EBHouse class] fromJSONDictionary:tmpDic error:nil];
    [[EBController sharedInstance] showHouseDetail:house];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSDictionary *ratate = _dataArray[section];
    NSLog(@"ratate=%@",ratate);
    SwipeableSectionHeader *view = [[SwipeableSectionHeader alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 80) section:section imgRatate:[ratate[@"is_show"]intValue] title:ratate[@"text"]];
    view.userInteractionEnabled = YES;
    view.sectionTapClick = ^(UIView *view) {
  
        NSLog(@"view = %ld",view.tag);
        NSLog(@"selfdataArray = %@",self.dataArray);
        NSDictionary *dic = _dataArray[section];
        
        NSMutableDictionary *tmpDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        [_dataArray removeObject:dic];
        [tmpDic[@"is_show"] integerValue] == 0 ? [tmpDic setObject:@1 forKey:@"is_show"] : [tmpDic setObject:@0 forKey:@"is_show"];
        NSLog(@"tmpDic = %@",tmpDic);
        [_dataArray insertObject:tmpDic atIndex:section];
        
        [_mainTableView reloadData];
    };
    
    view.btnClick = ^(UIButton *view) {
        if (view.tag == 1) {//转移
            NSLog(@"section = %ld",section);
            //转移多个房源
            [self transferHouses:ratate[@"houses"]];
        }else if (view.tag == 2){//删除
            
            if ([ratate.allKeys containsObject:@"id"] && [ratate[@"id"] integerValue] == 0) {
                [EBAlert alertError:@"该分组不能删除"];
                return ;
            }
            
            [self deleteHouses:ratate[@"houses"] group:[ratate[@"id"] integerValue]];
            NSLog(@"section = %ld",section);
        }
    };
    
    view.longTapClick = ^(UIView *view) {
        NSLog(@"view = %ld",view.tag);
        if ([ratate.allKeys containsObject:@"id"] && [ratate[@"id"] integerValue] == 0) {
            [EBAlert alertError:@"该分组不能修改"];
            return ;
        }
        
        HouseCreateNewGroupView *createView = [[HouseCreateNewGroupView alloc]initWithFrame:CGRectMake(0, 0, kScreenW-80, 200) title:@"修改分组" placeholder:ratate[@"text"]];
        
        createView.btnClick = ^(UIButton *btn ,UITextField *groupName) {
            
            if (btn.tag == 1) {
                [self closePop];
                return ;
            }
            
            if (groupName.text.length == 0 || groupName == nil) {
                [EBAlert alertError:@"请输入分组名称"];
                return ;
            }
            if (ratate[@"id"] == nil || [ratate[@"id"] isEqual:[NSNull null]]) {
                [EBAlert alertError:@"分组id无效"];
                return ;
            }
            //新增分组
            NSString *url = @"/house/modifyFavoriteGroup";
            NSDictionary *parm = @{
                                   @"token" : [EBPreferences sharedInstance].token,
                                   @"group_id":ratate[@"id"],
                                   @"favorite_group" : groupName.text
                                   };
            NSLog(@"parm = %@",parm);
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [HttpTool post:url parameters:parm success:^(id responseObject) {
                NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"dict = %@",dict);
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self closePop];
                if ([dict[@"code"] integerValue] == 0) {
                    [EBAlert alertSuccess:@"修改成功"];
                    [self refreshHeader];
                }else{
                    [EBAlert alertError:@"修改失败"];
                }
                
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [EBAlert alertSuccess:@"请求失败"];
                [self closePop];
            }];
        };
        MyViewController *vc = [[HWPopTool sharedInstance]showWithPresentView:createView animated:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop)];
        vc.styleView.userInteractionEnabled = YES;
        [vc.styleView addGestureRecognizer:tap];
        
    };
    
    return view;
}

- (void)transferHouses:(NSArray *)houses group:(NSInteger)group{
    
    if (houses != nil && [houses isKindOfClass:[NSArray class]] && houses.count > 0) {
        NSMutableArray *tmpArr = [NSMutableArray array];
        for (EBHouse * house in houses) {
            if ([house isKindOfClass:[EBHouse class]]) {
                [tmpArr addObject:house.id];
            }else if([house isKindOfClass:[NSDictionary class]]){
                NSDictionary *tmpDic = (NSDictionary *)house;
                EBHouse *house1 =[MTLJSONAdapter modelOfClass:[EBHouse class] fromJSONDictionary:tmpDic error:nil];
                [tmpArr addObject:house1.id];
            }
            
        }
        NSString *ids = [tmpArr componentsJoinedByString:@";"];
        NSLog(@"ids=%@",ids);
        
        //新增分组
        NSString *url = @"/house/moveFavoriteHouse";
        NSDictionary *parm = @{
                               @"token" : [EBPreferences sharedInstance].token,
                               @"group_id" :[NSNumber numberWithInteger:group],
                               @"ids" : ids
                               };
        NSLog(@"parm = %@" , parm);
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [HttpTool post:url parameters:parm success:^(id responseObject) {
            NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"dict = %@",dict);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self closePop];
            if ([dict[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"转移成功"];
                [self refreshHeader];
            }else{
                [EBAlert alertError:@"请求失败"];
            }
            
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [EBAlert alertSuccess:@"请求失败"];
            [self closePop];
        }];
        
    }
}


//转移房源
- (void)transferHouses:(NSArray *)houses{
    
    //分组 如果houses多个的时候，提醒用户
    
    //新增分组
    NSString *url = @"/house/getFavoriteGroup";
    NSDictionary *parm = @{
                           @"token" : [EBPreferences sharedInstance].token,
                           };
    NSLog(@"parm = %@" , parm);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [HttpTool post:url parameters:parm success:^(id responseObject) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"dict = %@",dict);
        if ([dict[@"code"] integerValue] == 0) {
            NSArray *group = dict[@"data"];
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择分组" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            if (group != nil && [group isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dic in group) {
                    [alertVC addAction:[UIAlertAction actionWithTitle:dic[@"text"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"分组id = %@",dic[@"value"]);
                        [self transferHouses:houses group:[dic[@"value"]integerValue]];
                    }]];
                }
            }
            [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alertVC animated:YES completion:nil];
        }else{
            [EBAlert alertError:@"分组加载失败"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [EBAlert alertSuccess:@"请求失败"];
        [self closePop];
    }];
    return;
}

- (void)delete:(NSArray *)houses group:(NSInteger)group_id{
    if (houses != nil && [houses isKindOfClass:[NSArray class]]) {
        NSMutableArray *tmpArr = [NSMutableArray array];
        for (EBHouse * house in houses) {
            if ([house isKindOfClass:[EBHouse class]]) {
                [tmpArr addObject:house.id];
            }else if([house isKindOfClass:[NSDictionary class]]){
                NSDictionary *tmpDic = (NSDictionary *)house;
                EBHouse *house1 =[MTLJSONAdapter modelOfClass:[EBHouse class] fromJSONDictionary:tmpDic error:nil];
                [tmpArr addObject:house1.id];
            }
        }
        
        NSString *ids = [tmpArr componentsJoinedByString:@";"];
        NSLog(@"ids=%@",ids);
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        //新增分组
        NSString *url = @"/house/deleteFavorite";
        NSDictionary *parm = nil;
        if (group_id == 100000000) {
            parm = @{
                     @"token" : [EBPreferences sharedInstance].token,
                     @"ids" :  ids,
                     };
        }else{
            parm = @{
                     @"token" : [EBPreferences sharedInstance].token,
                     @"ids" :  ids,
                     @"group_id" : [NSNumber numberWithInteger:group_id]
                     };
        }
        
        
        NSLog(@"parm = %@" , parm);
        
        [HttpTool post:url parameters:parm success:^(id responseObject) {
            NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"dict = %@",dict);
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([dict[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:@"删除成功"];
                [self refreshHeader];
            }else{
                [EBAlert alertError:@"删除失败"];
            }
            
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [EBAlert alertSuccess:@"请求失败"];
        }];
    }
}

//删除房源
- (void)deleteHouses:(NSArray *)houses group:(NSInteger)group_id{
    
    if (group_id != 100000000) {
        DeleteGroupPopView *createView = [[DeleteGroupPopView alloc]initWithFrame:CGRectMake(0, 0, kScreenW-80, 245)];
        createView.backgroundColor = [UIColor whiteColor];
        createView.btnClick = ^(UIButton *btn) {
             [self closePop];
            if (btn.tag == 1) {
                return ;
            }else{//确定删除
                [self delete:houses group:group_id];
            }
            
        };
        MyViewController *vc = [[HWPopTool sharedInstance]showWithPresentView:createView animated:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop)];
        vc.styleView.userInteractionEnabled = YES;
        [vc.styleView addGestureRecognizer:tap];
    }else{
         [self delete:houses group:group_id];//直接删除
    }
    
    
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"编辑模式");
    }
}

@end
