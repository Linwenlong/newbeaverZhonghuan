//
//  MySettingViewController.m
//  beaver
//
//  Created by mac on 17/7/24.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "MySettingViewController.h"
#import "ChangePasswordViewController.h"
#import "EBAlert.h"
#import "EBCache.h"
#import "EBPreferences.h"
#import "EBController.h"
#import "EBUpdater.h"
#import "EBHttpClient.h"
#import "TMCache.h"
#import "FunctionIntroduceViewController.h"

NSString * const CachePrefix = @"com.tumblr.TMDiskCache";

#define KEY_UPDATE_FORCE @"EB_FORCED_UPDATE"//强制更新
#define KEY_NEW_VERSION @"EB_ONLINE_VERSION"//线上版本
#define KEY_CURRECT_VERSION @"EB_CURRECT_VERSION"//当前版本
#define KEY_NEW_VERSION_URL @"EB_ONLINE_VERSION_URL"//线上版本url

@interface MySettingViewController ()<UITableViewDataSource,UITableViewDelegate>{
        NSMutableArray * sectionArray;
        UITableView *_tableView;
        BOOL isRemove;
}
@end

@implementation MySettingViewController

//缓存多少m
- (CGFloat)cacheSize{
    CGFloat folderSize = 0.0;
    //获取路径
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)firstObject];
    //获取所有文件的数组
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];

    for(NSString *path in files) {
        NSString*filePath = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",path]];
        //累加
        folderSize += [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil].fileSize;
    }
    //转换为M为单位
    CGFloat sizeM = folderSize /1024.0/1024.0;
    NSLog(@"cache = %f",sizeM);
    return sizeM;
}

//缓存多少m
- (CGFloat)TmpSize{
    CGFloat folderSize = 0.0;
    //获取路径
    NSString *cachePath = NSTemporaryDirectory();
    //获取所有文件的数组
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];

    for(NSString *path in files) {
        NSString*filePath = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",path]];
        //累加
        folderSize += [[NSFileManager defaultManager]attributesOfItemAtPath:filePath error:nil].fileSize;
    }
    //转换为M为单位
    CGFloat sizeM = folderSize /1024.0/1024.0;
    NSLog(@"Tmp = %f",sizeM);
    return sizeM;
}

- (void)removeTmp{
    //===============清除临时文件==============
    //获取路径
    NSString *tmpPath = NSTemporaryDirectory();
    //返回路径中的文件数组
    NSArray*files = [[NSFileManager defaultManager]subpathsAtPath:tmpPath];
    for(NSString *p in files){
        NSError*error;
        NSString*path = [tmpPath stringByAppendingString:[NSString stringWithFormat:@"/%@",p]];
        
        if([[NSFileManager defaultManager]fileExistsAtPath:path]){
             isRemove = [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
        }
    }
    [EBAlert alertSuccess:@"清除成功" length:0.5];
}

- (void)removeCache{
    //获取路径
    NSString*cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)objectAtIndex:0];

    //返回路径中的文件数组
    NSArray*files = [[NSFileManager defaultManager]subpathsAtPath:cachePath];
 
    for(NSString *p in files){
        NSError*error;
        NSString*path = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",p]];
        
        if([[NSFileManager defaultManager]fileExistsAtPath:path])
        {
            if (![path containsString:CachePrefix]) {
                isRemove = [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
            }
        }
    }
}

- (void)clearMemony:(UITabBarItem *)tab{
    [self cacheSize];
    [self TmpSize];
    return ;
    [self removeCache];//移除缓存
    [self removeTmp];//移除临时文件
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    sectionArray =[NSMutableArray arrayWithArray:@[@[@"修改密码"],
                     @[@"同步公司数据",
                      @"无图模式", @"检查更新",
                       @"清除缓存",
                       ],@[@"功能介绍"],@[@"退出登录"]]];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView setLayoutMargins:UIEdgeInsetsZero];
    [self.view addSubview:_tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *tmpArray = sectionArray[section];
    return tmpArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    cell.textLabel.textColor = UIColorFromRGB(0x5d5d5d);
    NSArray *tmpSection = sectionArray[indexPath.section];//第一层数组
    NSString *text = tmpSection[indexPath.row];//第二层数组
    cell.textLabel.text = text;
    //修改图片尺寸大小
    UIImage *icon = [UIImage imageNamed:text];
    CGFloat big = 1.5;
    CGSize itemSize = CGSizeMake(icon.size.width/big, icon.size.height/big);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //添加线条
    if (indexPath.section == 0 || indexPath.section == 2) {
        UIGraphicsEndImageContext();
        UIImageView *accessory = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 7, 11)];
        accessory.image = [UIImage imageNamed:@"jiantou"];
        cell.accessoryView = accessory;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 10)];
        view.backgroundColor = UIColorFromRGB(0xf5f5f5);
        return view;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return 10;
    }else{
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //点击事件
    if (indexPath.section == 0) {//修改密码
        ChangePasswordViewController *controller = [[ChangePasswordViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        //友盟统计改密码的次数
        [EBTrack event:EVENT_CLICK_SETTINGS_CHANGE_PASSWORD];
    }else if (indexPath.section == 1 && indexPath.row == 0){
        //        "toast_sync_data" = "正在同步数据...";
        [EBAlert showLoading:NSLocalizedString(@"toast_sync_data", nil)];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[EBCache sharedInstance] synchronizeCompanyData:^(BOOL success)
             {
                 [EBAlert hideLoading];
                 if (success)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                        [EBAlert alertSuccess:NSLocalizedString(@"sync_success", nil)];
                     });
                 }
             }];
        });
        //同步公司数据 （通讯录，小区信息）
       
    }else if (indexPath.section == 1 && indexPath.row == 1){
        EBPreferences *pref = [EBPreferences sharedInstance];
        NSInteger choice = 0;
        if (pref.rememberNoneImageChoice){
            choice = pref.allowImageDownloadViaWan ? 2 : 1;
        }
        NSArray *choices = @[NSLocalizedString(@"none_image_mode_0", nil),
                             NSLocalizedString(@"none_image_mode_1", nil), NSLocalizedString(@"none_image_mode_2", nil)];
        [[EBController sharedInstance] promptChoices:choices withChoice:choice title:NSLocalizedString(@"none_image_mode_setting_title", nil)            header:NSLocalizedString(@"none_image_mode_setting_hint", nil)
             footer:NSLocalizedString(@"none_image_mode_desc", nil) completion:^(NSInteger rightChoice)
         {
             if (rightChoice == 0){
                 pref.rememberNoneImageChoice = NO;
             }else{
                 pref.rememberNoneImageChoice = YES;
                 pref.allowImageDownloadViaWan = rightChoice == 2;
             }
             [pref writePreferences];
//             [_tableView reloadData];//先不刷新
         }];
    }else if (indexPath.section == 1 && indexPath.row == 2){
        //更新版本
        [EBAlert showLoading:nil];
        [[EBHttpClient wapInstance] wapRequest:nil checkUpdate:^(BOOL success, id result)
         {
             [EBAlert hideLoading];
             if (success){
                 NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                 NSString *newVersion = result[@"version"];
                 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                 [defaults setObject:result[@"version"] forKey:KEY_NEW_VERSION];
                 [defaults setObject:result[@"url"] forKey:KEY_NEW_VERSION_URL];
                 [defaults setBool:[result[@"force"] boolValue] forKey:KEY_UPDATE_FORCE];
                 [defaults synchronize];
                 if (![currentVersion isEqualToString:newVersion]) {
                     if (![result[@"force"] boolValue]) {
                         [EBAlert alertWithTitle:nil message:NSLocalizedString(@"force_update_or", nil) yes:NSLocalizedString(@"force_update_confirm",nil) no:@"取消" confirm:^{
                             [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:[EBUpdater newVersionUrl]]];
                         }];
                     }else{
                         [EBUpdater newVersionAvailable:result[@"version"] url:result[@"url"] force:[result[@"force"] boolValue]];
                         
                         [EBAlert alertWithTitle:nil message:NSLocalizedString(@"force_update", nil) yes:NSLocalizedString(@"force_update_confirm",nil) confirm:^{
                             [[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString:[EBUpdater newVersionUrl]]];
                         }];
                        
                     }
                     [self setupSettingArray];
//                     [_tableView reloadData];  //需要刷新
                 }else{
                     [EBAlert alertSuccess:NSLocalizedString(@"update_no_new", nil)];
                 }
             }
         }];
    
    }else if (indexPath.section == 1 && indexPath.row == 3){
        [self removeCache];//移除缓存
        [self removeTmp];//移除临时文件
    }else if (indexPath.section == 2){
        
//        [EBAlert confirmWithTitle:@"温馨提示" message:@"功能还在开发中"
//                              yes:@"好的" action:^{
//                                  
//        }];

        FunctionIntroduceViewController *fivc = [[FunctionIntroduceViewController alloc]init];
        fivc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:fivc animated:YES];
      
    }else if (indexPath.section == 3){
        [EBAlert confirmWithTitle:NSLocalizedString(@"logout", nil) message:NSLocalizedString(@"confirm_logout", nil)
                              yes:NSLocalizedString(@"confirm_logout_yes", nil) action:^{
                                  [EBController accountLoggedOut];
                              }];
        [EBTrack event:EVENT_CLICK_SETTINGS_LOG_OUT];
    }
}


- (void)setupSettingArray
{
    NSString *checkUpdate;
    if ([EBUpdater hasUpdate])
    {
        checkUpdate = [NSString stringWithFormat:NSLocalizedString(@"update_download", nil), [EBUpdater currentOnlineVersion]];
    }
    else
    {
        checkUpdate = NSLocalizedString(@"update_check", nil);
    }
}



@end
