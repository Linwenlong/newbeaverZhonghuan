//
//  ZHDCNewHouseFollowupViewController.m
//  beaver
//
//  Created by mac on 17/6/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "ZHDCNewHouseFollowupViewController.h"
#import "HttpTool.h"
#import "EBPreferences.h"
#import "EBAlert.h"
#import "FolowupModel.h"
#import "FollowupTableViewCell.h"
#import "SDAutoLayout.h"
#import "MJRefresh.h"
#import "UITableView+PlaceHolderView.h"
#import "DefaultView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "EBUpdater.h"
#import "EBController.h"
#import "AESCrypt.h"
#import "ZHDCUpdataPhotoViewController.h"

#import "ZHDCFollowupDetailViewController.h"

@interface ZHDCNewHouseFollowupViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    int page;
    BOOL loadingHeader;
    NSInteger currentIndex;
}
@property (nonatomic, strong)UITableView *mainTableView;
@property (nonatomic, strong)NSMutableArray *dataArray;
@property (nonatomic, copy)NSString *custom_name;
@property (nonatomic, copy)NSString *house_title;
@property (nonatomic, copy)NSString *custom_id;
@property (nonatomic, copy)NSString *house_id;

@end

@implementation ZHDCNewHouseFollowupViewController

- (UITableView*)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    return _mainTableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    [self.view addSubview:self.mainTableView];
    [self refreshHeader];
    [self footerLoading];
    [self.mainTableView registerClass:[FollowupTableViewCell class] forCellReuseIdentifier:@"cell"];
}


-(void)footerLoading{
    self.mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        page += 1;
        loadingHeader = NO;
        [self requestData:self.urlString withPgae:page];
    }];
}
//刷新头部、、MJ
-(void)refreshHeader{
    self.mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        page = 1;
        loadingHeader = YES;
        [self requestData:self.urlString withPgae:page];//加载数据
    }];
    [self.mainTableView.mj_header beginRefreshing];
}

- (void)requestData:(NSString *)typeString withPgae:(int)pageindex{
    
    NSLog(@"recomend=%@",[NSString stringWithFormat:@"http://218.65.86.83:8010/NewHouse/reportsList?token=%@&page=%d&page_size=%d&status=%@",[EBPreferences sharedInstance].token,pageindex,12,typeString]);
    [EBAlert showLoading:@"请求中"];
    NSNumber *number = [NSNumber numberWithInt:pageindex];
    [HttpTool post:@"NewHouse/reportsList"  parameters:@{@"token":[EBPreferences sharedInstance].token,@"page":number,@"page_size":@12,@"status":self.urlString} success:^(id responseObject) {
        [EBAlert hideLoading];
        //是否启用占位图
        _mainTableView.enablePlaceHolderView = YES;
        DefaultView *defaultView = (DefaultView *)_mainTableView.yh_PlaceHolderView;
        defaultView.placeView.image = [UIImage imageNamed:@"无详情"];
        defaultView.placeText.text = @"暂无详情数据";
        //请求到数据移除数组
        if (  loadingHeader ==  YES) {
            [self.dataArray removeAllObjects];
        }
        NSDictionary *dic =  [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSDictionary *data = dic[@"data"];
        NSArray *tmp = data[@"data"];
        for (NSDictionary *dic in tmp) {
            FolowupModel *model = [[FolowupModel alloc]initWithDict:dic];
            [_dataArray addObject:model];
        }
        //刷新
        [_mainTableView.mj_header endRefreshing];
        [_mainTableView reloadData];
        if (tmp.count == 0) {
            [_mainTableView.mj_footer endRefreshingWithNoMoreData];
   
            return ;
        }else{
            [_mainTableView.mj_footer endRefreshing];
        }

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
        [_mainTableView.mj_header endRefreshing];
        [_mainTableView.mj_footer endRefreshing];
    }];
}



#pragma mark -- UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FollowupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    FolowupModel *model = _dataArray[indexPath.row];
    [cell setModel:model];
    cell.btnBack =  ^(NSString *custom_string,NSString *house_title,NSString *document_id,NSString *house_id){
        _custom_name = custom_string;
        _house_title = house_title;
        _custom_id = document_id;
        _house_id = house_id;
        [self updatePhotowithCustom];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FolowupModel *model = _dataArray[indexPath.row];
    return [self.mainTableView cellHeightForIndexPath:indexPath model:model keyPath:@"model" cellClass:[FollowupTableViewCell class] contentViewWidth:kScreenW];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入客户跟进详情
    FolowupModel *model = _dataArray[indexPath.row];
    ZHDCFollowupDetailViewController *dc = [[ZHDCFollowupDetailViewController alloc]init];
    dc.document_id = model.document_id;
    [self.parentViewController.navigationController pushViewController:dc animated:YES];
}

#pragma mark -- 上传图片
- (void)updatePhotowithCustom{
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"手机相册",@"相机", nil];
        [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //调用系统的相册
    // UIImagePickerController 继承  UINavigationController
   UIImagePickerController * _imagePickerController = [[UIImagePickerController alloc]init];
    _imagePickerController.view.backgroundColor = [UIColor orangeColor];
    //检测是否有权限访问相册
    if (buttonIndex == 0) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue]<8.0) {
            ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
            if (status == ALAuthorizationStatusRestricted || status ==ALAuthorizationStatusDenied) {
             
                [EBAlert alertError:@"没有访问相册的权限"];
                return;
            }
        }else{
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status
                == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            
                 [EBAlert alertError:@"没有访问相册的权限"];
                return;
            }
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            NSLog(@"相册可以使用");
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            _imagePickerController.delegate = self;
            [self presentViewController:_imagePickerController animated:YES completion:^{
           
            }];
        }
    }else if (buttonIndex == 1){

        if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
             [EBAlert alertError:@"没有相机"];
            return;
        }
        //相机的访问权限
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus==AVAuthorizationStatusDenied||authStatus==AVAuthorizationStatusRestricted) {
            [EBAlert alertError:@"没有相机访问权限"];
            return;
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
            _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            _imagePickerController.delegate = self;
            [self presentViewController:_imagePickerController animated:YES completion:^{
        
            }];
        }
    }

}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
 
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    UIImage *originalImage = info[@"UIImagePickerControllerOriginalImage"];

    //获取图片
    ZHDCUpdataPhotoViewController *updata = [[ZHDCUpdataPhotoViewController alloc]init];
    updata.document_id = _custom_id;
    updata.image = originalImage;
    updata.house_id = _house_id;
    UINavigationController *updataNC = [[UINavigationController alloc] initWithRootViewController:updata];
    [self presentViewController:updataNC animated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
 
}



@end
