//
//  HouseDetailViewController.m
//  beaver
// 房源详情
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseDetailViewController.h"
#import "EBHouse.h"
#import "EBViewFactory.h"
#import "RTLabel.h"
#import "EBIconLabel.h"
#import "EBPrice.h"
#import "EBContact.h"
#import "KIImagePager.h"
#import "EBFilter.h"
#import "EBPhoneButton.h"
#import "EBHttpClient.h"
#import "EBCrypt.h"
#import "UIActionSheet+Blocks.h"
#import "ShareManager.h"
#import "EBContactManager.h"
#import "SnsViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "EBCache.h"
#import "EBAlert.h"
#import "FSImageViewerViewController.h"
#import "FSBasicImage.h"
#import "FSBasicImageSource.h"
#import "HouseVisitLogViewController.h"
#import "HouseFollowLogViewController.h"
#import "EBCallEventHandler.h"
#import "UIImage+Alpha.h"
#import "ChangeStatusViewController.h"
#import "ChangeRecTagViewController.h"
#import "ReportViewController.h"
#import "EBBusinessConfig.h"
#import "AGImagePickerController.h"
#import "HousePhotoPreUploadViewController.h"
#import "HouseVideoPreUploadViewController.h"
#import "EBHousePhotoUploader.h"
#import "HouseEditViewController.h"
#import <MapKit/MapKit.h>
#import "UIAlertView+Blocks.h"
#import "GatherHouseDetailViewController.h"
#import "GatherHouseAddFinishViewController.h"
#import "GatherHouseAddViewController.h"
#import "GatherHouseAddSecondViewController.h"
#import "GatherHouseAddThirdViewController.h"
#import "HouseAddFirstStepViewController.h"
#import "HouseAddSecondStepViewController.h"
#import "HouseAddViewController.h"
#import "HouseAddFinishViewController.h"
#import "SKImageController.h"
#import "EBVideoUtil.h"
#import "EBVideoUpload.h"
#import "VideoListViewController.h"

#import <UShareUI/UShareUI.h>

//lwl
#import "HouseForceFollowupViewController.h"
#import "HouseNewForceFollowUpViewController.h"
#import "HouseCallRecordViewController.h"
#import "HouseMessageTemplateViewController.h"
#import "HouseHiddenMessageView.h"
#import "HWPopTool.h"
#import "HouseNewFollowLogViewController.h"
#import "HouseCreateNewGroupView.h"
#import "HouseDetailCountDownView.h"

#define COLLECTION_CELL_LABEL_IDENTIFIER  @"collectionLabelIdentifier"

#define isHidden YES

@interface HouseDetailViewController () <UITableViewDelegate, UITableViewDataSource, RTLabelDelegate,
KIImagePagerDataSource, KIImagePagerDelegate, EGORefreshTableHeaderDelegate>
{
    UITableView *_tableView;
    UIView *_tagsView;
    UIView *_noteView;
    UIView *_contentView;
    UIView *_numbersView;
    UIView *_picturesView;
    KIImagePager *_imagePager;
    EGORefreshTableHeaderView *_refreshHeaderView;
    UIView *_accessView;
    UIView *_phoneNumberView;
    UIView *_delegationView;
    UIView *_addressView;
    NSMutableArray *_houseOperations;
    BOOL _isHasOperatePhoto;
    
    //是否开启了查看电话强制写跟进的权限
    BOOL forceFollowUpOfCheckPhoneNumber;//查看电话强制写跟进
    BOOL hasFirstFollowUp;//上一次查看电话没有写跟进的房源
    
    BOOL isUploadPhoto;
    
    NSInteger hidden_times;
    dispatch_source_t _gcdTimer; //定时器
    NSTimer *timer; //定时器
}

@property (nonatomic, strong) UIView * phoneHiddenNumberView;
@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong)ValuePickerView *pickerView;

@property (nonatomic, weak) UIButton * collectBtn;//收藏按钮

@property (nonatomic, weak) HouseDetailCountDownView *countDown;

@property (nonatomic, strong) NSDictionary * call_follow;

@end

@implementation HouseDetailViewController



- (UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize{
    return [UIImage imageNamed:@""];
}
//
-(void)loadView
{
    [super loadView];
    
    self.title = _houseDetail.contractCode;

    _numStatus = [[EBNumberStatus alloc] init];
    _isHasOperatePhoto = NO;
    
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"btn_menu"] target:self action:@selector(showMoreFunctionList:)];
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_share"] target:self action:@selector(share:)];
    [self setRightButton:0 hidden:YES];
    
    UIButton *collectBtn = [self addRightNavigationBtnWithDynamicImage:[UIImage imageNamed:@"nav_btn_collect_n"] checkedImage:[UIImage imageNamed:@"nav_btn_collect_p"] target:self action:@selector(taggedCollect:) badge:nil];
    _collectBtn = collectBtn;
    if(self.houseDetail.collected)
    {
        collectBtn.selected = YES;
    }
    else
    {
        collectBtn.selected = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化hidden_times
    hidden_times = 30;
//    _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    self.pickerView = [[ValuePickerView alloc]initShowClear:NO];
    isUploadPhoto = YES;
    
    [self numbersView];
    [self buildAddressView];
    
    [self buildTagsView];

    
    [EBController observeNotification:NOTIFICATION_UPLOADING_PHOTO from:self selector:@selector(uploadingPhotoNotify:)];
    [EBController observeNotification:NOTIFICATION_UPLOADING_PHOTO_FINISHED from:self selector:@selector(uploadingPhotoNotify:)];
//    [self refreshHouseDetail:YES];
}


- (void)uploadingPhotoNotify:(NSNotification *)notification{

    if([notification.name isEqualToString:NOTIFICATION_UPLOADING_PHOTO_FINISHED]){
        NSLog(@"上传图片完成");
        //刷新
        if (!_picturesView) {
            [self picturesView];
        }
        [self refreshHouseDetail:YES];
        __weak typeof(self) weakSelf = self;
        
        [[EBHttpClient sharedInstance] accountRequest:nil getNumberStatus:^(BOOL success, id result)
         {
             if (success)
             {
                 _numStatus = result;
                 [weakSelf refreshDetail];
                 isUploadPhoto = YES;
             }
         }];
    }else{
        NSLog(@"正在上传图片");
        isUploadPhoto = NO;
    }
}


- (void)dealloc
{
    if (_imagePager) {
        _imagePager.delegate = nil;
        _imagePager.dataSource = nil;
        [_imagePager clearData];
        _imagePager = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_picturesView) {
        [self picturesView];
    }
    [self refreshHouseDetail:YES];
    __weak typeof(self) wealSelf = self;
    [[EBHttpClient sharedInstance] accountRequest:nil getNumberStatus:^(BOOL success, id result)
     {
         if (success)
         {
             _numStatus = result;
             [wealSelf refreshDetail];
         }
     }];
}

- (void)hiddenFollowup{
    //判断是否需要写跟进
    NSLog(@"call_follow=%d",_houseDetail.call_follow);
    if (_houseDetail.call_follow == YES) {  //房源详情隐号通话权限及通话跟进,
        NSLog(@"call_follow_info = %@ ", _houseDetail.call_follow_info);
        NSString *str = [NSString  stringWithFormat:@"请补充上次隐号通话房源%@的跟进,否则无法继续隐号通话",_houseDetail.call_follow_info[@"contract_code"]];
         __weak typeof(self) wealSelf = self;
        [EBAlert alertWithTitle:@"提示" message:str
                              confirm:^{
            HouseNewForceFollowUpViewController *house = [[HouseNewForceFollowUpViewController alloc]init];
            house.isForceFollow = YES;//这里进去的是强制跟进
            house.hidesBottomBarWhenPushed = YES;
            NSLog(@"fk_id = %@",_houseDetail.call_follow_info[@"id"]);
            house.followUptype = ZHForceFollowUpTypeYES;
            house.house_id = _houseDetail.call_follow_info[@"id"];//房源id
            house.house_code = _houseDetail.call_follow_info[@"contract_code"];//房源编号
            house.call_flags = _houseDetail.call_follow_info[@"call_flags"];//隐号通话标志
            house.returnBlock = ^(BOOL succeed){
            if (succeed == YES) {   //成功
               NSLog(@"跟进提交成功");
            }else{
               [EBAlert alertError:@"跟进提交失败,暂无法查看电话"];
            }
        };
            [wealSelf.navigationController pushViewController:house animated:YES];
        }];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_isUplaodForNewHouse && (_isHasOperatePhoto == NO))
    {
        _isHasOperatePhoto = YES;
        [self getPhoto:_houseDetail];
    }
    if (_pageOpenType == EHouseDetailOpenTypeAdd)
    {
        NSMutableArray *controllerArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        NSInteger count = controllerArr.count;
        for (int i = 0; i < count; )
        {
            if ([controllerArr[i] isKindOfClass:[HouseAddFinishViewController class]] || [controllerArr[i] isKindOfClass:[HouseAddFirstStepViewController class]] || [controllerArr[i] isKindOfClass:[HouseAddSecondStepViewController class]] || [controllerArr[i] isKindOfClass:[HouseAddViewController class]])
            {
                [controllerArr removeObjectAtIndex:i];
                count --;
            }
            else
            {
                i ++;
            }
        }
        [self.navigationController setViewControllers:controllerArr];
    }
    else if (_pageOpenType == EHouseDetailOpenTypeGatherToErp)
    {
//        NSArray array = [[NSArray alloc] initWithObjects:@"GatherHou", nil];
        NSMutableArray *controllerArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        NSInteger count = controllerArr.count;
        for (int i = 0; i < count; )
        {
            if ([controllerArr[i] isKindOfClass:[GatherHouseAddFinishViewController class]] || [controllerArr[i] isKindOfClass:[GatherHouseAddViewController class]] || [controllerArr[i] isKindOfClass:[GatherHouseAddSecondViewController class]] || [controllerArr[i] isKindOfClass:[GatherHouseAddThirdViewController class]])
            {
                [controllerArr removeObjectAtIndex:i];
                count --;
            }
            else
            {
                i ++;
            }
        }
        [self.navigationController setViewControllers:controllerArr];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldPopOnBack
{
    if (_pageOpenType == EHouseDetailOpenTypeCommon)
    {
        return YES;
    }
    else if (_pageOpenType == EHouseDetailOpenTypeAdd)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
    else if (_pageOpenType == EHouseDetailOpenTypeGatherToErp)
    {
        NSArray *viewControllers = self.navigationController.viewControllers;
        UIViewController *popToViewController = nil;
        for (UIViewController *viewController in viewControllers)
        {
            if ([viewController isKindOfClass:[GatherHouseDetailViewController class]])
            {
                popToViewController = viewController;
                break;
            }
        }
        if (popToViewController)
        {
            __weak typeof(self) weakSelf = self;
            dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
                           {
                               [weakSelf.navigationController popToViewController:popToViewController animated:YES];
                           });
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return YES;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger total = [self tableView:tableView numberOfRowsInSection:0];
    
    NSInteger contentStart = 2;
    
    if (row == 0)
    {
        NSMutableString *text = [[NSMutableString alloc] initWithString:_houseDetail.title ? : @""];
        if (_houseDetail.media && _houseDetail.media.length > 0 && ![_houseDetail.media isEqualToString:@"0"])
        {
            [text appendString:@"\r\n"];
            [text appendString:[NSString stringWithFormat:NSLocalizedString(@"house_gather_source_fromat", nil), _houseDetail.media]];
            
        }
        CGSize size= [EBViewFactory textSize:text font:[UIFont systemFontOfSize:18.0] bounding:CGSizeMake(300.0, MAXFLOAT)];
        return  60.0 + size.height - 22.0;
    }
    else if (row == 1)
    {
        return 173;
    }
    else if (row == contentStart)
    {
        return _numbersView.frame.size.height;
    }
    else if (row == contentStart + 1)
    {
        return _tagsView.frame.size.height; //tag view
    }
    else if (row == contentStart + 2)
    {
        return _contentView.frame.size.height;
    }
    else if (row == contentStart + 3)
    {
        return _addressView.frame.size.height;//address
    }
    else if (row == contentStart + 4)
    {
        return _noteView.frame.size.height;
    }else{
        if (_houseDetail.implicit_call_pri == YES) {//开启了隐号通话
            if (row == total - 5){
                return 77; //是否有隐号通话
            }
            else if (row == total - 4)
            {
                return 77;//number view lwl
            }
            else if (row == total - 3)
            {
                return 167.0; //accessory view
            }
            else if (row == total - 2)
            {
                return _delegationView.frame.size.height;
            }
            else if (row == total - 1)
            {
                return 360.0;
            }
        }else{//没有开启隐号通话
            if (row == total - 4)
            {
                return 77;//number view lwl
            }
            else if (row == total - 3)
            {
                return 167.0; //accessory view
            }
            else if (row == total - 2)
            {
                return _delegationView.frame.size.height;
            }
            else if (row == total - 1)
            {
                return 360.0;
            }
        }
        
        return 0.0;
    }
    

    
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self cell:tableView row:[indexPath row]];
    
    return  cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_houseDetail.implicit_call_pri == YES) {//开启了隐号通话
        NSInteger count = 12;
        return count;
    }else{
        NSInteger count = 11;
        return count;
    }
}

#pragma mark - get cell

- (UITableViewCell *)cell:(UITableView *)tableView row:(NSInteger)row
{
    NSInteger total = [self tableView:tableView numberOfRowsInSection:0];
    
    NSInteger contentStart = 2, _noteRow = _noteView == nil ? -1 : 6;
    
    NSString *cellIdentifier;
    if (row == 0)
    {
        cellIdentifier = @"header_cell";
    }
    else if (row == 1)
    {
        cellIdentifier = @"image_cell";
    }
    else if (row == _noteRow)
    {
        cellIdentifier = @"note_cell";
    }
    else if (row == contentStart)
    {
        cellIdentifier = @"numbers_cell";//电话
    }
    else if (row == contentStart + 1)
    {
        cellIdentifier = @"tags_cell";
    }
    else if (row == contentStart + 2)
    {
        cellIdentifier = @"content_cell";
    }
    else if (row == contentStart + 3)
    {
        cellIdentifier = @"address_cell";
    }
    else if (row == total - 3)
    {
        cellIdentifier = @"accessory_cell";
    }
    else if (row == total - 2)
    {
        cellIdentifier = @"delegation_cell";
    }
    else if (row == total - 1)
    {
        cellIdentifier = @"qrcode_cell";
    }
    else
    {
        if (_houseDetail.phoneNumbers.count == 0)
        {
            cellIdentifier = @"cell_get_phone";
        }
        else
        {
            cellIdentifier = @"cell_phone";
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self subView:row forCell:cell total:total];
    }
    else if ([cellIdentifier isEqualToString:@"header_cell"])
    {
        [self headerView:cell];
    }
    else if ([cellIdentifier isEqualToString:@"tags_cell"])
    {
        [cell.contentView addSubview:_tagsView];
    }
    else if ([cellIdentifier isEqualToString:@"content_cell"])
    {
        [cell.contentView addSubview:_contentView];
    }
    else if ([cellIdentifier isEqualToString:@"delegation_cell"])
    {
        [cell.contentView addSubview:_delegationView];
    }
    else if ([cellIdentifier isEqualToString:@"image_cell"] && ![_picturesView superview]) {
        [cell.contentView addSubview:_picturesView];
    }
    
    if(_houseDetail.implicit_call_pri == YES){//开启了隐号通话
        if (row == total - 4 )
        {
            [[cell.contentView viewWithTag:88] removeFromSuperview];
            [cell.contentView addSubview:[self getPhoneNumberView]];
        }
        if (row == total - 5) {
//            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 50, 40)];
//            btn.backgroundColor = [UIColor redColor];
//            [btn addTarget:self action:@selector(text) forControlEvents:UIControlEventTouchUpInside];
//            [cell.contentView addSubview:btn];
            NSLog(@"cell.contentView=%@",cell.contentView.subviews);
            [[cell.contentView viewWithTag:88] removeFromSuperview];
            [cell.contentView addSubview:[self phoneHiddenNumberView]];
            
        }
    }else{//没有开启隐号通话
        if (row == total - 4 )
        {
            [[cell.contentView viewWithTag:88] removeFromSuperview];
            [cell.contentView addSubview:[self getPhoneNumberView]];
        }
    }
    return cell;
}

- (void)text{
    NSLog(@"test");
}

- (void)hiddenCall:(NSString *)document_id{
    NSLog(@"document_id=%@",document_id);
    //隐号通话
    NSLog(@"httpUrl=%@",[NSString stringWithFormat:@"%@/call/implicitCall?document_id=%@&fk_id=%@&sort=%@&fk_code=%@",NewHttpBaseUrl,document_id,_houseDetail.id,@"房源",_houseDetail.contractCode]);
    if (document_id == nil) {
        [EBAlert alertError:@"电话id为空" length:2.0f];
        return;
    }
    NSDictionary *param = @{
                            @"token":[EBPreferences sharedInstance].token,
                            @"document_id":document_id,
                            @"fk_id":_houseDetail.id,
                            @"sort":@"房源",
                            @"fk_code":_houseDetail.contractCode
                            };
    NSLog(@"param=%@",param);
    NSString *urlStr = @"call/implicitCall";
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    [HttpTool get:urlStr parameters:param success:^(id responseObject) {
        [EBAlert hideLoading];
        NSLog(@"responseObject=%@",responseObject);
        if ([responseObject[@"code"]integerValue] == 0) {
            NSDictionary *data = responseObject[@"data"];
            if ([data[@"code"] integerValue] == 0) {
                [EBAlert alertSuccess:data[@"msg"] length:2.0f];
                
                
//                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:data[@"msg"] preferredStyle:UIAlertControllerStyleAlert];
//                [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    
//                }]];
//                [self presentViewController:alertVC animated:YES completion:nil];
                __weak typeof(self) weakSelf = self;
                if ([data[@"call_follow"] isKindOfClass:[NSDictionary class]] ) {
                    NSDictionary *call_follow = data[@"call_follow"];
                    if ([call_follow.allKeys containsObject:@"call_flags"]) {

                        HouseNewForceFollowUpViewController *house = [[HouseNewForceFollowUpViewController alloc]init];
                        house.isForceFollow = YES;//这里进去的是强制跟进
                        house.hidesBottomBarWhenPushed = YES;
                        //            house.params = params;
                        NSLog(@"fk_id = %@",call_follow[@"house_id"]);
                        house.followUptype = ZHForceFollowUpTypeYES;
                        house.house_id = call_follow[@"house_id"];//房源id
                        house.house_code = _houseDetail.contractCode;//房源编号
                        house.call_flags = call_follow[@"call_flags"];//隐号通话标志
                        house.returnBlock = ^(BOOL succeed){
                            if (succeed == YES) {//成功
                                NSLog(@"跟进提交成功");
                            }else{
                               [EBAlert alertError:@"跟进提交失败,暂无法查看电话"];
                            }
                        };
         
            
                    [weakSelf.navigationController pushViewController:house animated:YES];

                    }
                }
                
            }else{
                [EBAlert alertError:data[@"msg"] length:2.0f];
            }
            
        }else{
            [EBAlert alertError:@"呼叫失败" length:2.0f];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"呼叫失败,请重新再试" length:2.0f];
    }];

}

//打电话
- (void)callPhone:(NSString *)phoneNumber {
    NSString * device = [UIDevice currentDevice].model;
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if ([device isEqualToString:@"iPhone"]) {
        NSString * phoneNum = nil;
        if (version >= 6.0){
            phoneNum = [NSString stringWithFormat:@"telprompt://%@",phoneNumber];
        } else {
            phoneNum = [NSString stringWithFormat:@"tel://%@",phoneNumber];
        }
        if (version >= 6.0) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNum]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNum]];
            }
            else {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"该设备不支持打电话" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert show];
            }
            
        } else {
            UIWebView * callPhone = [[UIWebView alloc] initWithFrame:CGRectZero];
            NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:phoneNum]];
            [callPhone loadRequest:request];
        }
        
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"该设备不支持打电话" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}


- (void)timer{
    hidden_times--;
//    NSLog(@"%@", [NSThread currentThread]);
    if (hidden_times < 0) {//30秒后移除
        [self closePop];
        [self refreshHouseDetail:YES];
        hidden_times = 30;
        if (timer != nil) {
            [timer invalidate];
            timer = nil;//释放
        }
//        // 终止定时器
//        dispatch_suspend(_gcdTimer);
//        dispatch_source_cancel(_gcdTimer);
        return ;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{//主线程更新UI
        NSString *mintus = [NSString stringWithFormat:@"%ld秒",hidden_times];
        NSMutableAttributedString *mintusAttribute = [[NSMutableAttributedString alloc]initWithString:mintus];
        
        [mintusAttribute addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xcc0515) range:NSMakeRange(0, mintus.length - 1)];
        [mintusAttribute addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x000000) range:NSMakeRange(mintus.length - 1, 1)];
        
        [mintusAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:40.0f] range:NSMakeRange(0, mintus.length - 1)];
        [mintusAttribute addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15.0f] range:NSMakeRange(mintus.length - 1, 1)];
        _countDown.countMintus.attributedText = mintusAttribute;
    });
}



- (UIView *)phoneHiddenNumberView{
    if (!_phoneHiddenNumberView) {
        NSArray *phoneNumbers = _houseDetail.implicit_call;
        
        NSLog(@"phoneNumbers=%@",phoneNumbers);

        _phoneHiddenNumberView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 77)];
        EBPhoneButton *callBtn = [[EBPhoneButton alloc] initWithFrameHidden:CGRectMake(0, 0, [EBStyle screenWidth], 72)];
        callBtn.isHouse = YES;
        if ([phoneNumbers count] == 1)
        {
            callBtn.contactName = _houseDetail.name;
            callBtn.phoneNumberDic = [phoneNumbers objectAtIndex:0];
            callBtn.isMutliPhone = NO;
            callBtn.phoneNumber = [phoneNumbers objectAtIndex:0][@"document_id"];
            callBtn.isorNotHidden = YES;
            callBtn.view = self.view;
            [callBtn setNeedsLayout];
        }
        else if([phoneNumbers count] > 0)
        {
            callBtn.contactName = _houseDetail.name;
            callBtn.phoneNumber = NSLocalizedString(@"mutli_phonenum", nil);
            callBtn.isMutliPhone = YES;
            callBtn.isorNotHidden = YES;
            callBtn.phoneNumbers = phoneNumbers;
            callBtn.view = self.view;
            [callBtn setNeedsLayout];
        }else{
            callBtn.contactName = _houseDetail.name;
            callBtn.phoneNumber = NSLocalizedString(@"no_phonenum", nil);
            callBtn.isMutliPhone = YES;
            callBtn.isorNotHidden = YES;
            callBtn.phoneNumbers = phoneNumbers;
            callBtn.view = self.view;
            [callBtn setNeedsLayout];
        }
        callBtn.HiddenClickCall = ^(NSString *document_id,NSString *cust_name) {
            //新的弹窗
            //请求短信模版
            NSString *urlStr = @"call/directDialing";
            if (document_id == nil || [document_id isEqual:[NSNull null]]) {
                [EBAlert alertError:@"用户document_id为空"];
                return ;
            }
            NSLog(@"%@/call/directDialing?token=%@&document_id=%@&fk_id=%@&sort=房源&fk_code=%@",NewHttpBaseUrl,[EBPreferences sharedInstance].token,document_id,_houseDetail.id,_houseDetail.contractCode);
            
            NSDictionary *param = @{
                                    @"token":[EBPreferences sharedInstance].token,
                                    @"document_id":document_id,
                                    @"fk_id":_houseDetail.id,
                                    @"sort":@"房源",
                                    @"fk_code":_houseDetail.contractCode
                                    };
            [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
            [HttpTool get:urlStr parameters:param success:^(id responseObject) {
                [EBAlert hideLoading];
                NSLog(@"responseObject = %@",responseObject);
                
                if ([responseObject[@"code"] intValue] == 0) {
                    
                    if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                        NSString *phone = nil;
                        if (responseObject[@"data"] != nil && ![responseObject[@"data"] isEqual:[NSNull null]]) {
                            NSDictionary *data = responseObject[@"data"];
                            if ([data[@"code"] intValue ] == 0) {
                                phone = responseObject[@"data"][@"data"];
//                                _call_follow =
                            }else{
                                [EBAlert alertError:data[@"msg"]];
                                return ;
                            }
                        }else{
                            phone = @"";
                            [EBAlert alertError:@"请求异常"];
                            return;
                        }
                        __weak typeof(self) weakSelf = self;
                        HouseDetailCountDownView *countDown = [[HouseDetailCountDownView alloc]initWithFrame:CGRectMake(0, 0,  kScreenW-100, 320) withPhone:phone];
                        _countDown = countDown;
                        countDown.call_click = ^(NSString *phoneNumber) {
                            //拨打电话
                            NSLog(@"phoneNumber = %@",phoneNumber);
                            [weakSelf callPhone:phoneNumber];
                        };
                        [[HWPopTool sharedInstance]showWithPresentView:countDown animated:YES];

                        countDown.img_click = ^{
                            hidden_times = 30;
                            if (timer != nil) {
                                [timer invalidate];
                                timer = nil;//释放
                            }
                            [weakSelf closePop];
                             [self refreshHouseDetail:YES];
                            
                        };
                        
                        /** 设置定时器
                         * para2: 任务开始时间
                         * para3: 任务的间隔
                         * para4: 可接受的误差时间，设置0即不允许出现误差
                         * Tips: 单位均为纳秒
                         */
                        
                        if (timer == nil) {
                            timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakSelf selector:@selector(timer) userInfo:nil repeats:YES];
                        }
                        
                        
                        
//                        _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
//
//                        dispatch_source_set_timer(_gcdTimer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
        
//                        dispatch_source_set_event_handler(_gcdTimer, ^{
//
//                        });
//                        // 启动任务，GCD计时器创建后需要手动启动
//                        dispatch_resume(_gcdTimer);
                    }else{
                        [EBAlert alertError:@"获取直呼号码失败,请重新获取"];
                    }
                }else{
                    [EBAlert alertError:@"获取直呼号码失败,请重新获取"];
                }
           
            } failure:^(NSError *error) {
                [EBAlert hideLoading];
                [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
            }];
            
            return ;
            //判断是否需要写跟进
            if (_houseDetail.call_follow == YES) {  //房源详情隐号通话权限及通话跟进,
                NSLog(@"call_follow_info = %@ ", _houseDetail.call_follow_info);
                    NSString *str = [NSString  stringWithFormat:@"请补充上次隐号通话房源%@的跟进,否则无法继续隐号通话",_houseDetail.call_follow_info[@"contract_code"]];
                    [EBAlert confirmWithTitle:@"提示" message:str
                                      yes:@"补充跟进" action:^{
                    HouseNewForceFollowUpViewController *house = [[HouseNewForceFollowUpViewController alloc]init];
                    house.isForceFollow = YES;//这里进去的是强制跟进
                    house.hidesBottomBarWhenPushed = YES;
                                          //            house.params = params;
                    NSLog(@"fk_id = %@",_houseDetail.call_follow_info[@"id"]);
                    house.followUptype = ZHForceFollowUpTypeYES;
                    house.house_id = _houseDetail.call_follow_info[@"id"];//房源id
                    house.house_code = _houseDetail.call_follow_info[@"contract_code"];//房源编号
                    house.call_flags = _houseDetail.call_follow_info[@"call_flags"];//隐号通话标志
                    house.returnBlock = ^(BOOL succeed){
                    if (succeed == YES) {//成功
                        NSLog(@"跟进提交成功");
                    }else{
                        [EBAlert alertError:@"跟进提交失败,暂无法查看电话"];
                    }
                };
                    [self.navigationController pushViewController:house animated:YES];
                }];
                
            }else{//没有需要强制写跟进的房源
                //弹窗
                __weak typeof(self) weakSelf = self;
                NSString *str = [NSString stringWithFormat:@"即将为您隐号接通%@的电话，确定拨号吗？",cust_name];
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:str preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    //拨打电话
                    [weakSelf hiddenCall:document_id];
                }]];
                [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }]];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            }
            
            
            
        };
        
        callBtn.HiddenClickSms = ^(NSString *document_id) {
            
            NSLog(@"document_id=%@",document_id);
            //请求短信模版
            NSString *urlStr = @"call/getMsgTpl";
            
            [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
            //    _dept_id
            [HttpTool get:urlStr parameters:
             @{
               @"token":[EBPreferences sharedInstance].token,
               } success:^(id responseObject) {
                   [EBAlert hideLoading];
                   NSLog(@"responseObject=%@",responseObject);
                   NSArray * dataArray = responseObject[@"data"];
                   //弹窗视图
                  HouseHiddenMessageView *messageView = [[HouseHiddenMessageView alloc]initWithFrame:CGRectMake(0, 0, kScreenW-20, 400) withTempate:dataArray];
                   __weak typeof(self) weakSelf = self;
                   messageView.imageClick = ^{
                       [weakSelf closePop];
                   };
                   
                   messageView.modelClick = ^(UIButton *btn,UITableView *listTableView,CGFloat list_h) {
                       
                       NSLog(@"hidden = %d",listTableView.hidden);
                       
                       [UIView animateWithDuration:0.5 animations:^{
                           listTableView.hidden = listTableView.hidden == YES ? NO : YES;
                       }];
                       
                   };
                   
                   messageView.submitClick = ^(UIButton *btn,UIButton *tempateBtn,UITextView *contentView) {
                       //提交按钮
                       //发送请求
                       if (document_id == nil) {
                           [EBAlert alertError:@"电话id为空" length:2.0f];
                           return;
                       }
                       if (tempateBtn.titleLabel.text.length == 0 || contentView.text.length == 0) {
                           [EBAlert alertError:@"请输入必填信息" length:2.0f];
                           return;
                       }
                       
                       NSDictionary *param = @{
                                               @"token":[EBPreferences sharedInstance].token,
                                               @"document_id":document_id,
                                               @"fk_id":_houseDetail.id,
                                               @"type":@"房源",
                                               @"fk_code":_houseDetail.contractCode,
                                               @"message":contentView.text,
                                               @"template":tempateBtn.titleLabel.text
                                               };
                       NSLog(@"param=%@",param);
                       
                       NSString *urlStr = @"call/sendMsg";
                       [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
                       [HttpTool get:urlStr parameters:param success:^(id responseObject) {
                           [EBAlert hideLoading];
                           NSLog(@"responseObject=%@",responseObject);
                           __weak typeof(self) weakSelf = self;
                           [weakSelf closePop];
                           if ([responseObject[@"code"]integerValue] == 0) {
                               NSDictionary *data = responseObject[@"data"];
                               if ([data[@"code"] integerValue] == 0) {
                                   [EBAlert alertSuccess:data[@"msg"] length:2.0f];
                               }else{
                                   [EBAlert alertError:responseObject[@"data"][@"msg"] length:2.0f];
                                  
                               }
                           }else{
                                [EBAlert alertError:@"发送失败" length:2.0f];
                           }
                       } failure:^(NSError *error) {
                           [EBAlert hideLoading];
                           [EBAlert alertError:@"发送失败,请重新再试" length:2.0f];
                       }];
                   };
    
                   MyViewController *vc = [[HWPopTool sharedInstance]showWithPresentView:messageView animated:YES];
                   UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:weakSelf action:@selector(closePop)];
                   vc.styleView.userInteractionEnabled = YES;
                   [vc.styleView addGestureRecognizer:tap];
                   
               } failure:^(NSError *error) {
                   [EBAlert hideLoading];
                   [EBAlert alertError:@"请求数据失败,请重新再试" length:2.0f];
            }];
        };

        
        [_phoneHiddenNumberView addSubview:callBtn];
        
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 76, kScreenW, 1)];
        line.backgroundColor = UIColorFromRGB(0xE6E6E6);
        [_phoneHiddenNumberView addSubview:line];
    }
    return _phoneHiddenNumberView;
}

- (void)closePop{
    [[HWPopTool sharedInstance]closeWithBlcok:^{
        NSLog(@"已经关闭");
    }];
}

- (void)subView:(NSInteger)row forCell:(UITableViewCell *)cell total:(NSInteger)total
{
    NSInteger contentStart = 2, _noteRow = _noteView == nil ? -1 : 6;
    
    if (row == 0)
    {
        [self headerView:cell];
    }
    else if (row == 1)
    {
        [cell.contentView addSubview:[self picturesView]];
    }
    else if (row == _noteRow)
    {
        [cell.contentView addSubview:_noteView];
    }
    else if (row == contentStart)
    {
        [cell.contentView addSubview:_numbersView];
    }
    else if (row == contentStart + 1)
    {
        [cell.contentView addSubview:_tagsView];
    }
    else if (row == contentStart + 2)
    {
        [cell.contentView addSubview:_contentView];
    }
    else if (row == contentStart + 3)
    {
        [cell.contentView addSubview:_addressView];
    }
    else if (row == total - 3)
    {
        //old
//        _accessView = [EBViewFactory accessoryView:self action:@selector(showList:) forHouse:YES];
        //new
        _accessView = [EBViewFactory accessoryNewView:self action:@selector(showList:)];
        [self refreshAccessView];
        [cell.contentView addSubview:_accessView];
    }
    else if (row == total - 2)
    {
        [cell.contentView addSubview:_delegationView];
    }
    else if(row == total - 1)
    {
        UIView *qrCodeView = [EBViewFactory qrCodeNumberView:[EBCrypt encryptHouse:_houseDetail]];
        UILabel *label = (UILabel *)[qrCodeView viewWithTag:88];
        label.text = NSLocalizedString(@"pr_scan_house", nil);
        [cell.contentView addSubview:qrCodeView];
    }
    else if(row == total - 4)
    {
        [[cell.contentView viewWithTag:88] removeFromSuperview];
        [cell.contentView addSubview:[self getPhoneNumberView]];
    }
}

#pragma mark - View

- (void)refreshDetail
{
    self.title = _houseDetail.contractCode;
 
    if (_houseDetail.collected == YES) {
        _collectBtn.selected = YES;
    }else{
        _collectBtn.selected = NO;
    }
    [self getHouseOperations];
    if (_houseOperations && _houseOperations.count > 0)
    {
        [self setRightButton:0 hidden:NO];
    }
    else
    {
        [self setRightButton:0 hidden:YES];
    }
    [self numbersView];
    [self buildTagsView];
    [self buildContentView];
    [self buildNoteView];
    [self buildAddressView];
    [self getPhoneNumberView];
    [self refreshAccessView];
    [self buildDelegationView];
    
    if (_houseDetail.pictures.count > 0)
    {
        if (_imagePager)
        {
            [_imagePager reloadData];
            [_imagePager setCurrentPage:0 animated:NO];
            UILabel *emptyView = (UILabel *)[_imagePager viewWithTag:9999];
            emptyView.text = @"";
        }
    }
    else
    {
        if (_imagePager)
        {
            UILabel *emptyView = (UILabel *)[_imagePager viewWithTag:9999];
            emptyView.text = NSLocalizedString(@"no_picture", nil);
        }
    }
    [_tableView reloadData];
}

- (void)buildNoteView
{
    if (_houseDetail.memo.length == 0 && _houseDetail.coreMemo.length == 0)
    {
        _noteView = nil;
    }
    else
    {
        if (_noteView == nil)
        {
            _noteView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        
        for (UIView *subView in  _noteView.subviews)
        {
            [subView removeFromSuperview];
        }
        CGFloat yOffset = 15;
        if (_houseDetail.memo.length > 0)
        {
            yOffset += [EBViewFactory addNote:_houseDetail.memo toView:_noteView withYOffset:yOffset];
        }
        if (_houseDetail.coreMemo.length > 0)
        {
            yOffset += yOffset > 15 ? 10 : 0;
            yOffset += [EBViewFactory addNote:_houseDetail.coreMemo toView:_noteView withYOffset:yOffset];
        }
        if (yOffset > 15)
        {
            _noteView.frame = CGRectMake(0, 0, [EBStyle screenWidth], yOffset += 15);
            [self parentView:_noteView addLine:yOffset - 0.5];
        }
        [_noteView setNeedsLayout];
    }
}

- (void)buildDelegationView
{
    if (_delegationView == nil)
    {
        _delegationView = [[UIView alloc] init];
    }
    else
    {
        for (UIView *subView in _delegationView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    CGFloat yOffset = 15;
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_source", nil)
                          value:_houseDetail.source
                      linkValue:nil yOffset:yOffset];
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_inputuser", nil)
                          value:[self getAgentString:_houseDetail.inputAgent]
                      linkValue:[self getAgentLinkString:_houseDetail.inputAgent]
                        yOffset:yOffset];
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_delegationUser", nil)
                          value:[self getAgentString:_houseDetail.delegationAgent]
                      linkValue:[self getAgentLinkString:_houseDetail.delegationAgent]
                        yOffset:yOffset];
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_keyuser", nil)
                          value:[self getAgentString:_houseDetail.keyAgent]
                      linkValue:[self getAgentLinkString:_houseDetail.keyAgent]
                        yOffset:yOffset];
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_keystore", nil)
                          value:_houseDetail.keyStore
                      linkValue:nil
                        yOffset:yOffset];
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_closeuser", nil)
                          value:[self getAgentString:_houseDetail.closeAgent]
                      linkValue:[self getAgentLinkString:_houseDetail.closeAgent]
                        yOffset:yOffset];
    yOffset += yOffset == 15 ? 0 : 2;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (_houseDetail.entrustProp > 0)
    {
        [tempArray addObject:@{@"name":NSLocalizedString(@"house_delegation_type", nil), @"value":_houseDetail.entrustProp}];
    }
    if (_houseDetail.entrustNum.length > 0)
    {
        [tempArray addObject:@{@"name":NSLocalizedString(@"house_delegation_code", nil), @"value":_houseDetail.entrustNum}];
    }
    if (_houseDetail.visitCat.length > 0)
    {
        [tempArray addObject:@{@"name":NSLocalizedString(@"house_visit_cat", nil), @"value":_houseDetail.visitCat}];
    }
    if (_houseDetail.submitDate.length > 0)
    {
        [tempArray addObject:@{@"name":NSLocalizedString(@"house_submit_date", nil), @"value":_houseDetail.submitDate}];
    }
    
    if (tempArray.count > 0)
    {
        if(yOffset != 15)
        {
            [self parentView:_delegationView addLine:yOffset - 0.5];
            yOffset += 15;
        }
        NSInteger temp = 0;
        for (int i = 0; i < tempArray.count; i++)
        {
            NSDictionary *item = tempArray[i];
            NSString *value = item[@"value"];
            CGFloat width = [EBViewFactory textSize:value font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
            BOOL singleLine = NO;
            if (width > 80.0)
            {
                singleLine = YES;
            }
            if (singleLine)
            {
                if (temp % 2 == 1)
                {
                    yOffset += 27;
                }
                CGFloat height =[self parentView:_delegationView addKey:item[@"name"] value:value linkValue:nil xOffset:0.0 yOffset:yOffset limitWidth:[EBStyle screenWidth]];
                if (height > 0)
                {
                    yOffset += height;
                    temp = 0;
                }
            }
            else
            {
                CGFloat height = [self parentView:_delegationView addKey:item[@"name"] value:value linkValue:nil xOffset:temp % 2 == 0 ? 0 : 160 yOffset:yOffset limitWidth:160];
                if (height > 0)
                {
                    yOffset += temp % 2 == 0 ? 0 : height;
                    temp ++;
                }
                if (i == tempArray.count - 1 && temp % 2 == 1)
                {
                    yOffset += 27;
                }
            }
        }
    }
    if (yOffset > 15)
    {
        [self parentView:_delegationView addLine:0];
    }
    _delegationView.frame = CGRectMake(0, 0, [EBStyle screenWidth], yOffset == 15 ? 0 : yOffset + 2);
    [_delegationView setNeedsLayout];
}

- (UIView *)buildContentView
{
    if (_contentView == nil)
    {
        _contentView = [[UIView alloc] init];
    }
    else
    {
        for (UIView *subView in _contentView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    
    CGFloat labelOffset = 15.0;
    NSInteger temp = 0;
    if (_houseDetail.extraArray && _houseDetail.extraArray.count > 0)
    {
        for (int i = 0; i < _houseDetail.extraArray.count; i++)
        {
            NSDictionary *item = _houseDetail.extraArray[i];
            NSString *value = item[@"value"];
            CGFloat width = [EBViewFactory textSize:value font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
            BOOL singleLine = NO;
            if (width > 80.0)
            {
                singleLine = YES;
            }
            if (singleLine)
            {
                if (temp % 2 == 1)
                {
                    labelOffset += 27;
                }
                CGFloat height =[self parentView:_contentView addKey:item[@"name"] value:value linkValue:nil xOffset:0.0 yOffset:labelOffset limitWidth:[EBStyle screenWidth]];
                if (height > 0)
                {
                    labelOffset += height;
                    temp = 0;
                }
                else
                {
                    if (temp % 2 == 1)
                    {
                        labelOffset -= 27;
                    }
                }
            }
            else
            {
                CGFloat height = [self parentView:_contentView addKey:item[@"name"] value:value linkValue:nil xOffset:temp % 2 == 0 ? 0 : [EBStyle screenWidth]/2.0f yOffset:labelOffset limitWidth:[EBStyle screenWidth]/2.0f];
                if (height > 0)
                {
                    labelOffset += temp % 2 == 0 ? 0 : height;
                    temp ++;
                }
                if (i == _houseDetail.extraArray.count - 1 && temp % 2 == 1)
                {
                    labelOffset += 27;
                }
            }
        }
        if (labelOffset > 15)
        {
            labelOffset += 3;
            [self parentView:_contentView addLine:labelOffset - 0.5];
        }
    }
    
    if (_houseDetail.curInfo.length > 0 || _houseDetail.facility.length > 0 || _houseDetail.decoration.length > 0)
    {
        labelOffset += labelOffset > 15 ? 15 : 0;
        labelOffset += [self parentView:_contentView addKey:NSLocalizedString(@"decoration", nil)
                                  value:_houseDetail.decoration linkValue:nil yOffset:labelOffset];
        labelOffset += [self parentView:_contentView addKey:NSLocalizedString(@"current_situation", nil)
                                  value:_houseDetail.curInfo linkValue:nil yOffset:labelOffset];
        labelOffset += [self parentView:_contentView addKey:NSLocalizedString(@"facility", nil)
                                  value:_houseDetail.facility linkValue:nil yOffset:labelOffset];
        labelOffset += 2;
        [self parentView:_contentView addLine:labelOffset - 0.5];
    }
    _contentView.frame = CGRectMake(0, 0, [EBStyle screenWidth], labelOffset > 15 ? labelOffset : 0);
    [_contentView setNeedsLayout];
    return _contentView;
}

- (void)headerView:(UITableViewCell *)cell
{
    for (UIView *view in cell.contentView.subviews)
    {
        if (view.tag < 997)
        {
            [view removeFromSuperview];
        }
    }
    self.title = _houseDetail.contractCode;
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:997];
    UILabel *subLabel = (UILabel *)[cell.contentView viewWithTag:998];
    UILabel *sourceLabel = (UILabel *)[cell.contentView viewWithTag:999];
    if (titleLabel == nil)
    {
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, [EBStyle screenWidth]-20, 22)];
        titleLabel.textColor = [EBStyle blackTextColor];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.tag = 997;
        subLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, [EBStyle screenWidth]-20, 20)];
        subLabel.font = [UIFont systemFontOfSize:14.0];
        subLabel.textColor = [EBStyle blackTextColor];
        subLabel.tag = 998;
        
        sourceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        sourceLabel.font = [UIFont systemFontOfSize:14.0];
        sourceLabel.textColor = [UIColor whiteColor];
        sourceLabel.tag = 999;
        
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:subLabel];
    }
    
    
    NSString *format = @"%@\r\n%@";
    NSMutableString *text = [[NSMutableString alloc] initWithString:_houseDetail.title];
    
    if (_houseDetail.media.length > 0 && ![_houseDetail.media isEqualToString:@"0"])
    {
        NSString *source = [NSString stringWithFormat:NSLocalizedString(@"house_gather_source_fromat", nil), _houseDetail.media];
        text = [NSMutableString stringWithFormat:format, _houseDetail.title, source];
        
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:text];
        
        NSMutableDictionary *sourceAttr = [NSMutableDictionary dictionary];
        sourceAttr[NSForegroundColorAttributeName] = [EBStyle grayTextColor];
        sourceAttr[NSFontAttributeName] = [UIFont systemFontOfSize:14.0];
        [attributedStr addAttributes:sourceAttr range:[text rangeOfString:source]];
        titleLabel.attributedText = attributedStr;
    }
    else
    {
        titleLabel.text = text;
    }
    CGSize size= [EBViewFactory textSize:text font:[UIFont systemFontOfSize:18.0] bounding:CGSizeMake(300.0, MAXFLOAT)];
//    if(size.height > 22.0)
    {
        CGRect frame = titleLabel.frame;
        frame.size.height = size.height;
        titleLabel.frame = frame;
        frame = subLabel.frame;
        frame.origin.y =  30 + size.height - 22.0;
        subLabel.frame = frame;
    }
    NSString *rentalKey = [NSString stringWithFormat:@"rental_house_state_%ld", _houseDetail.rentalState];
    
    subLabel.text =  NSLocalizedString(rentalKey, nil);
    
    CGFloat tagWidth = 14.0;
    CGFloat titleWidth = [EBViewFactory textSize:_houseDetail.status font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    tagWidth += titleWidth == 0 ? 0 : titleWidth + 7;
    NSString *accessTag = [NSString stringWithFormat:@"tag_access_%ld",  _houseDetail.access];
    [EBViewFactory parentView:cell.contentView addRecommendTag:@[NSLocalizedString(accessTag, nil),_houseDetail.status == nil ? @"" : _houseDetail.status] xOffset:[EBStyle screenWidth] - tagWidth - 10.0 yOffset:30 + size.height - 22.0 limitWidth:[EBStyle screenWidth] tagColor:[UIColor colorWithRed:144./255.f green:191./255.f blue:0./255.f alpha:1.0]];
}

- (UIView *)picturesView
{
    if (!_imagePager) {
        _imagePager = [[KIImagePager alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 173)];
    }
    _imagePager.dataSource = self;
    _imagePager.delegate = self;
    _imagePager.backgroundColor = [UIColor colorWithRed:233 / 255.f green:231 / 255.f blue:224 / 255.f alpha:1.0];
    [_imagePager setImageCounterDisabled:YES];
    _imagePager.pageControlCenter = CGPointMake(CGRectGetWidth(_imagePager.frame) / 2, CGRectGetHeight(_imagePager.frame) - 12);
    _imagePager.slideshowTimeInterval = 2;
    
    if ([self arrayWithImages].count == 0)
    {
        UILabel *emptyView = [[UILabel alloc] initWithFrame:_imagePager.bounds];
        emptyView.backgroundColor = [UIColor clearColor];
        emptyView.textAlignment = NSTextAlignmentCenter;
        emptyView.textColor = [UIColor colorWithWhite:201/255.f alpha:1.0];
        emptyView.tag = 9999;
        [_imagePager addSubview:emptyView];
    }

    // upload image button
    UIImage *uploadImage = [UIImage imageNamed:@"house_upload_photo"];
#pragma mark -- 房源图片上传的button
    UIButton *uploadButton = [[UIButton alloc] initWithFrame:CGRectMake([EBStyle screenWidth] - 58, 173 - 58, 58, 58)];
//    uploadButton.backgroundColor = [UIColor blueColor];
    uploadButton.tag = 800;
    [uploadButton setImage:uploadImage forState:UIControlStateNormal];
    [uploadButton setImage:[uploadImage imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];

    [uploadButton addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];

    uploadButton.alpha = [_houseDetail.housePri[@"upload_photo"] integerValue];
    
//    UIView *picturesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 173)];
    _picturesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 173)];

//    _picturesView = picturesView;
//    [picturesView addSubview:imagePager];
//    [picturesView addSubview:uploadButton];
    [_picturesView addSubview:_imagePager];
    [_picturesView addSubview:uploadButton];
    
    return _picturesView;
}

- (UIView *)numbersView
{
    if (_numbersView)
    {
        for (UIView *subView in _numbersView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    else
    {
        _numbersView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 73)];
    }
    CGFloat headerHeight = 0;
    CGFloat footerHeight = 0;
    CGFloat totalWidth = 0;
    NSMutableArray *iconLabels = [[NSMutableArray alloc] init];
    
    if (_houseDetail.rentPrice != nil)
    {
        CGFloat diff = _houseDetail.rentPrice.diff;
        
        NSString *iconName = diff > 0 ? @"price_rent_up" : (diff < 0 ? @"price_rent_down" : @"price_rent_normal");
        UIImage *image = [UIImage imageNamed:iconName];
        NSString *price = [NSString stringWithFormat:@"%@%@ ", _houseDetail.rentPrice.amount, _houseDetail.rentPrice.unit];
        EBIconLabel *rentLabel = [EBViewFactory
                                  parentView:_numbersView
                                  iconTextWithImage:image
                                  text:price];
//        rentLabel.backgroundColor = [UIColor redColor];
        rentLabel.label.textColor = diff > 0 ? [EBStyle redTextColor] : (diff < 0 ? [EBStyle greenTextColor]  : [EBStyle blackTextColor]);
        CGRect labelFrame = rentLabel.currentFrame;
        if (diff != 0)
        {
            UIImageView *trendIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_houseDetail.rentPrice.diff > 0 ? @"trend_up" : @"trend_down"]];
            trendIcon.frame = CGRectOffset(trendIcon.frame, labelFrame.size.width - trendIcon.image.size.width + 2, 3);
            [rentLabel.label addSubview:trendIcon];
        }
        
        [iconLabels addObject:rentLabel];
        totalWidth += labelFrame.size.width;
        
        if (diff != 0)
        {
            [rentLabel addSubview:[self diffLabel:diff withUnit:_houseDetail.rentPrice.unit]];
        }
    }
    
    if (_houseDetail.sellPrice != nil)
    {
        CGFloat diff = _houseDetail.sellPrice.diff;
        NSString *iconName = diff > 0 ? @"price_sale_up" : (diff < 0 ? @"price_sale_down" : @"price_sale_normal");
        UIImage *image = [UIImage imageNamed:iconName];
        NSString *price = [NSString stringWithFormat:NSLocalizedString(@"sell_price_amount", nil), _houseDetail.sellPrice.amount];
        price = [price stringByAppendingString:@" "];
        EBIconLabel *sellLabel = [EBViewFactory
                                  parentView:_numbersView
                                  iconTextWithImage:image
                                  text:price];
        sellLabel.label.textColor = diff > 0 ? [EBStyle redTextColor] : (diff < 0 ? [EBStyle greenTextColor]  : [EBStyle blackTextColor]);
        CGRect labelFrame = sellLabel.currentFrame;
        if (diff != 0)
        {
            UIImageView *trendIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_houseDetail.sellPrice.diff > 0 ? @"trend_up" : @"trend_down"]];
            trendIcon.frame = CGRectOffset(trendIcon.frame, labelFrame.size.width - trendIcon.image.size.width + 2, 3);
            [sellLabel.label addSubview:trendIcon];
        }
        
        [iconLabels addObject:sellLabel];
        totalWidth += labelFrame.size.width;
        
        if (diff != 0)
        {
            [sellLabel addSubview:[self diffLabel:diff withUnit:NSLocalizedString(@"amount_unit", nil)]];
        }
        if (_houseDetail.sellPrice.unitCost != 0)
        {
            [sellLabel addSubview:[self unitCostLabel:_houseDetail.sellPrice.unitCost withUnit:_houseDetail.sellPrice.unit]];
        }
    }
    if (_houseDetail.purpose == EHousePurposeTypeLand
        || _houseDetail.purpose == EHousePurposeTypeCarport
        || _houseDetail.purpose == EHousePurposeTypeWorkshop)
    {
        EBIconLabel *label = [EBViewFactory parentView:_numbersView
                                     iconTextWithImage:[UIImage imageNamed:@"area_length"]
                                                  text:_houseDetail.length.length == 0 ? NSLocalizedString(@"zero_length", nil) : _houseDetail.length];
        totalWidth += label.currentFrame.size.width;
        [iconLabels addObject:label];
        label = [EBViewFactory parentView:_numbersView
                        iconTextWithImage:[UIImage imageNamed:@"area_width"]
                                     text:_houseDetail.width.length == 0 ? NSLocalizedString(@"zero_length", nil) : _houseDetail.width];
        totalWidth += label.currentFrame.size.width;
        [iconLabels addObject:label];
    }else{
        EBIconLabel *label = [EBViewFactory parentView:_numbersView iconTextWithImage:[UIImage imageNamed:@"icon_room_large"]
                                                  text:[NSString stringWithFormat:NSLocalizedString(@"format_unit_room_hall", nil), _houseDetail.room, _houseDetail.hall]];
        totalWidth += label.currentFrame.size.width;
        [iconLabels addObject:label];
        label = [EBViewFactory parentView:_numbersView
                        iconTextWithImage:[UIImage imageNamed:@"icon_area_large"]
                                     text:[NSString stringWithFormat:NSLocalizedString(@"format_area", nil), _houseDetail.area]];
        totalWidth += label.currentFrame.size.width;
        [iconLabels addObject:label];
    }
    CGFloat gap = ([EBStyle screenWidth]-20 - totalWidth) / (iconLabels.count - 1);
    CGFloat xOffset = 10.0;
    for (NSInteger i = 0; i < iconLabels.count; i++)
    {
        EBIconLabel *label = iconLabels[i];
        CGRect oldFrame = label.currentFrame;
        label.frame = CGRectOffset(oldFrame, xOffset, 15);
        UILabel *unitCostLabel = (UILabel *)[label viewWithTag:890];
        if (unitCostLabel)
        {
            headerHeight = 15 + 5;
            [self adjustAffiliateInfoLabelFrame:unitCostLabel accordingFrame:label.frame above:YES];
        }
        
        xOffset += oldFrame.size.width + gap;
        
        UILabel *extraLabel = (UILabel *)[label viewWithTag:889];
        if (extraLabel)
        {
            footerHeight = 12 + 5;
            extraLabel.frame = CGRectMake(-5, label.frame.size.height, label.frame.size.width + 12, 14);
        }
    }
    
    EBIconLabel *iconLabel4 = iconLabels.lastObject;
    EBIconLabel *iconLabel3 = iconLabels[iconLabels.count - 2];
    if (_houseDetail.purpose == EHousePurposeTypeVilla)
    {
        headerHeight = 15 + 5;
        UILabel *affiliateLabel = [self affiliateInfoLabel:[NSString stringWithFormat:NSLocalizedString(@"house_floor_area_format", nil),_houseDetail.usableArea.length == 0 ? NSLocalizedString(@"zero_area", nil) :  _houseDetail.usableArea]];
        [iconLabel4 addSubview:affiliateLabel];
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:iconLabel4.frame above:YES];
    }
    else if (_houseDetail.purpose == EHousePurposeTypeLand
             || _houseDetail.purpose == EHousePurposeTypeCarport)
    {
        headerHeight = 15 + 5;
        UILabel *affiliateLabel = [self affiliateInfoLabel:[NSString stringWithFormat:_houseDetail.purpose == EHousePurposeTypeLand ? NSLocalizedString(@"house_land_area_format", nil) : NSLocalizedString(@"house_area_format", nil) ,_houseDetail.area]];
        [iconLabel3 addSubview:affiliateLabel];
        
        CGRect frame3 = iconLabel3.frame;
        CGRect frame4 = iconLabel4.frame;
        CGRect frame = CGRectMake(frame3.origin.x, frame3.origin.y, frame4.origin.x - frame3.origin.x + frame3.size.width, frame3.size.height);
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:frame above:YES];
    }
    else if (_houseDetail.purpose == EHousePurposeTypeShop)
    {
        headerHeight = 15 + 5;
        footerHeight = 15 + 5;
        UILabel *affiliateLabel = [self affiliateInfoLabel:[NSString stringWithFormat:NSLocalizedString(@"house_usable_area_format", nil),_houseDetail.usableArea.length == 0 ? NSLocalizedString(@"zero_area", nil) :  _houseDetail.usableArea]];
        [iconLabel4 addSubview:affiliateLabel];
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:iconLabel4.frame above:YES];
        
        affiliateLabel = [self affiliateInfoLabel:[NSString stringWithFormat:NSLocalizedString(@"house_depth_format", nil), _houseDetail.depth.length == 0 ? NSLocalizedString(@"zero_length", nil) : _houseDetail.depth]];
        [iconLabel3 addSubview:affiliateLabel];
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:iconLabel3.frame above:NO];
        
        affiliateLabel = [self affiliateInfoLabel:[NSString stringWithFormat:NSLocalizedString(@"house_door_width_format", nil), _houseDetail.doorWidth.length == 0 ? NSLocalizedString(@"zero_length", nil) : _houseDetail.doorWidth]];
        [iconLabel4 addSubview:affiliateLabel];
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:iconLabel4.frame above:NO];
        
    }
    else if (_houseDetail.purpose == EHousePurposeTypeWorkshop)
    {
        headerHeight = 15 + 5;
        footerHeight = 15;
        UILabel *affiliateLabel = [self affiliateInfoLabel:[NSString stringWithFormat:NSLocalizedString(@"house_work_shop_area_format", nil),_houseDetail.area]];
        [iconLabel3 addSubview:affiliateLabel];
        
        CGRect frame3 = iconLabel3.frame;
        CGRect frame4 = iconLabel4.frame;
        CGRect frame = CGRectMake(frame3.origin.x, frame3.origin.y, frame4.origin.x - frame3.origin.x + frame3.size.width, frame3.size.height);
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:frame above:YES];
        
        affiliateLabel = [self affiliateInfoLabel:[NSString stringWithFormat:NSLocalizedString(@"house_height_format", nil),_houseDetail.height.length == 0 ? NSLocalizedString(@"zero_length", nil) : _houseDetail.height]];
        [iconLabel3 addSubview:affiliateLabel];
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:frame above:NO];
        
        if (_houseDetail.factoryExtra && _houseDetail.factoryExtra.count > 0)
        {
            CGFloat originalY = frame.origin.y + frame.size.height + affiliateLabel.frame.size.height + headerHeight + 5 + 10;
            CGFloat yOffset = originalY;
            NSInteger temp = 0;
            for (int i = 0; i < _houseDetail.factoryExtra.count; i++)
            {
                NSDictionary *item = _houseDetail.factoryExtra[i];
                if ([item[@"single_line"] boolValue])
                {
                    if (temp % 2 == 1)
                    {
                        yOffset += 20;
                    }
                    CGFloat height =[self parentView:_numbersView
                                         addAreaItem:item[@"name"]
                                               value:item[@"value"]
                                             xOffset:0.0
                                             yOffset:yOffset
                                          limitWidth:[EBStyle screenWidth]];
                    if (height > 0)
                    {
                        yOffset += height;
                        temp = 0;
                    }
                    else
                    {
                        if (temp % 2 == 1)
                        {
                            yOffset -= 20;
                        }
                    }
                }
                else
                {
                    CGFloat height = [self parentView:_numbersView
                                          addAreaItem:item[@"name"]
                                                value:item[@"value"]
                                              xOffset:temp % 2 == 0 ? 0 : 160.0
                                              yOffset:yOffset
                                           limitWidth:160.0];
                    if (height > 0)
                    {
                        yOffset += temp % 2 == 0 ? 0 : height;
                        temp ++;
                    }
                    if (i == _houseDetail.factoryExtra.count - 1 && temp % 2 == 1)
                    {
                        yOffset += 20;
                    }
                }
            }
            if (yOffset - originalY > 0)
            {
                footerHeight += yOffset - originalY + 10;
            }
        }
    }
    if (headerHeight > 0 )
    {
        for (EBIconLabel *label in iconLabels)
        {
            label.frame = CGRectOffset(label.frame, 0, headerHeight);
        }
    }
    
    CGFloat yOffset = 72.5;
    yOffset += headerHeight + footerHeight;
    [self parentView:_numbersView addLine:yOffset];
    CGRect frame = _numbersView.frame;
    frame.size.height = yOffset + 0.5;
    _numbersView.frame = frame;
    [_numbersView setNeedsLayout];
    return _numbersView;
}

- (void)buildTagsView
{
    if (_tagsView)
    {
        for (UIView *view in _tagsView.subviews)
        {
            if (view.tag != 83)
            {
                [view removeFromSuperview];
            }
        }
    }
    else
    {
        _tagsView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, [EBStyle screenWidth], 44.0)];
    }
    CGFloat yOffset = 15;
//    _houseDetail.recommendTags = @[@"全款",@"急切",@"新",@"租",@"售",@"满五唯一",@"公",@"有效"];
    if(_houseDetail.recommendTags.count > 0)
    {
        yOffset += [EBViewFactory parentView:_tagsView addRecommendTag:_houseDetail.recommendTags xOffset:15 yOffset:yOffset limitWidth:278.0 - 15.0 tagColor:[UIColor colorWithRed:122./255.f green:157./255.f blue:200./255.f alpha:1.0]];
    }
    if (yOffset < 44.0)
    {
        yOffset = 44.0;
    }
    else
    {
        yOffset += 15.0;
    }
    _tagsView.frame = CGRectMake(0.0, 0.0, [EBStyle screenWidth], yOffset);
    UIButton *calcBtn = (UIButton *)[_tagsView viewWithTag:83];
    if (calcBtn == nil)
    {
        UIButton *calcBtn = [EBViewFactory buttonWithImage:[UIImage imageNamed:@"icon_calc"]];
        [calcBtn addTarget:self action:@selector(calculate:) forControlEvents:UIControlEventTouchUpInside];
        calcBtn.frame = CGRectOffset(calcBtn.frame, [EBStyle screenWidth]-calcBtn.frame.size.width-10, (yOffset - calcBtn.frame.size.height) / 2);
        calcBtn.tag = 83;
        [_tagsView addSubview:calcBtn];
    }
    [self parentView:_tagsView addLine:yOffset - 0.5];
    [_tagsView setNeedsLayout];
}


#pragma mark -- 地图视图
- (void)buildAddressView
{
    if (_addressView == nil)
    {
        _addressView = [[UIView alloc] init];
    }
    else
    {
        for (UIView *subView in _addressView.subviews)
        {
            if (subView.tag != 86 ||subView.tag != 87 || subView.tag != 88 || subView.tag != 89)
            {
                [subView removeFromSuperview];
            }
        }
    }
    
    CGFloat yOffset = 15;
    UIButton *sameCommunityBtn = (UIButton *)[_addressView viewWithTag:86];
//    同小区房源 隐藏
    if (sameCommunityBtn == nil)
    {
        sameCommunityBtn = [EBViewFactory blueButtonWithFrame:CGRectMake(220, yOffset + 2, 86, 24)
                                                        title:@""
                                                       target:self
                                                       action:@selector(showList:)];
        #pragma mark -- lwl
        sameCommunityBtn.hidden = YES;
        EBIconLabel *label = [[EBIconLabel alloc] initWithFrame:CGRectZero];
        label.label.textColor = [EBStyle blueTextColor];
        label.label.font = [UIFont systemFontOfSize:12];
        label.label.text = NSLocalizedString(@"house_from_same_community", nil);
        label.gap = 5;
        label.imageView.image = [UIImage imageNamed:@"blue_accessory"];
        label.userInteractionEnabled = NO;
        CGRect oldFrame = label.currentFrame;
        label.frame = CGRectOffset(oldFrame, (86 - oldFrame.size.width) / 2, (24 - oldFrame.size.height) / 2);
        [sameCommunityBtn addSubview:label];
        sameCommunityBtn.tag = 86;
        [_addressView addSubview:sameCommunityBtn];
    }
    
    //添加查看门牌号
    UIButton *checkHouseNumberBtn = (UIButton *)[_addressView viewWithTag:89];
    if (checkHouseNumberBtn == nil) {
        checkHouseNumberBtn = [EBViewFactory blueButtonWithFrame:CGRectMake(kScreenW-86-10-36, yOffset + 2, 120, 24)
                                                        title:@""
                                                       target:self
                                                       action:@selector(checkHouseNumber:)];
        #pragma mark -- lwl
        if (_houseDetail.view_room_pri != YES) {//没有权限隐藏
            checkHouseNumberBtn.hidden = YES;
        }
//        checkHouseNumberBtn.hidden = YES;
        [checkHouseNumberBtn setTitle:@"查看门牌号" forState:UIControlStateNormal];
        checkHouseNumberBtn.titleLabel.numberOfLines = 0;
        checkHouseNumberBtn.titleLabel.textColor = [EBStyle blueTextColor];;
        checkHouseNumberBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        checkHouseNumberBtn.tag = 89;
        [_addressView addSubview:checkHouseNumberBtn];
    }
    
    
    CGFloat height1 = [self myParentView:_addressView addKey:NSLocalizedString(@"house_address", nil) value:[self getHouseLocation] linkValue:nil xOffset:0 yOffset:yOffset limitWidth:210];
    NSLog(@"height1=%f",height1);
    yOffset += height1;
    CGFloat height = [self parentView:_addressView addKey:NSLocalizedString(@"house_road", nil) value:_houseDetail.road linkValue:nil yOffset:yOffset];
    yOffset += yOffset == 15 ? 0 : height == 0 ? yOffset > 15 + 27 ? 0 : 10 : height;

    UIFont *font = [UIFont systemFontOfSize:14.0];
    RTLabel *mapLabel = (RTLabel *)[_addressView viewWithTag:87];
    if (mapLabel == nil)
    {
        RTLabel *mapLabel = [[RTLabel alloc] initWithFrame:CGRectMake(10.0, yOffset, 60, 25)];
        mapLabel.font = font;
        mapLabel.textColor = [EBStyle grayTextColor];
        mapLabel.text = NSLocalizedString(@"house_map", nil);
        mapLabel.textAlignment = RTTextAlignmentRight;
        mapLabel.tag = 87;
        [_addressView addSubview:mapLabel];
    }
    UIButton *mapButton = (UIButton *)[_addressView viewWithTag:88];
    if (mapButton == nil)
    {
        mapButton = [[UIButton alloc] initWithFrame:CGRectMake(75.0, yOffset + 1, 244, 74.0)];
        [mapButton setBackgroundImage:[UIImage imageNamed:@"house_map_icon"] forState:UIControlStateNormal];
        [mapButton addTarget:self action:@selector(showHouseLocation:) forControlEvents:UIControlEventTouchUpInside];
        mapButton.tag = 88;
        [_addressView addSubview:mapButton];
        
    }
    yOffset += 74 + 15 + 1;
    _addressView.frame = CGRectMake(0, 0, [EBStyle screenWidth], yOffset);
    [self parentView:_addressView addLine:yOffset - 0.5];
    
    [_addressView setNeedsLayout];
}

#pragma mark -- 获取电话的Number

- (UIView *)getPhoneNumberView
{
    if (_phoneNumberView)
    {
        for (UIView *view in _phoneNumberView.subviews)
        {
            [view removeFromSuperview];
        }
        //old
        [_phoneNumberView addSubview:[EBViewFactory accessPhoneNumberViewForHouse:self action:@selector(viewPhoneNumber:) house:_houseDetail view:self.view]];
        //new
//        [_phoneNumberView addSubview:[EBViewFactory accessNewPhoneNumberViewForHouse:self action:@selector(viewPhoneNumber:) house:_houseDetail view:self.view]];
    }
    else
    {
        _phoneNumberView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 87)];
       
        //old
        [_phoneNumberView addSubview:[EBViewFactory accessPhoneNumberViewForHouse:self action:@selector(viewPhoneNumber:) house:_houseDetail view:self.view]];
        //new
//        [_phoneNumberView addSubview:[EBViewFactory accessNewPhoneNumberViewForHouse:self action:@selector(viewPhoneNumber:) house:_houseDetail view:self.view]];
    }
    return _phoneNumberView;
}

- (UIView *)phoneNumberView
{
    UIView *view =  [EBViewFactory phoneButtonWithTarget:nil action:nil];
    view.tag = 99;
    return view;
}

- (void)refreshAccessView
{
    if (_accessView)
    {
        if(_houseDetail.marked)
        {
            UIButton *remarkedBtn = (UIButton*)[_accessView viewWithTag:2];
            UIImageView *imageView = (UIImageView*)[remarkedBtn viewWithTag:1000];
            if (imageView == nil)
            {
                CGRect btnFrame = remarkedBtn.frame;
                UIImage *image = [UIImage imageNamed:@"mark_recom_tag"];
                //            UIImage *newImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width / 1.5, image.size.height / 1.5)];
                imageView = [[UIImageView alloc] initWithImage:image];
                imageView.tag = 1000;
                imageView.frame = CGRectOffset(imageView.frame, btnFrame.size.width - imageView.frame.size.width - 4, 4);
                [remarkedBtn addSubview:imageView];
            }
            remarkedBtn.hidden = NO;
        }
        else
        {
            UIButton *remarkedBtn = (UIButton*)[_accessView viewWithTag:2];
            UIImageView *imageView = (UIImageView*)[remarkedBtn viewWithTag:1000];
            if (imageView)
            {
                imageView.hidden = YES;
            }
        }
        if(_houseDetail.recommended)
        {
            UIButton *recommendedBtn = (UIButton*)[_accessView viewWithTag:3];
            UIImageView *imageView = (UIImageView*)[recommendedBtn viewWithTag:1001];
            if (imageView == nil)
            {
                CGRect btnFrame = recommendedBtn.frame;
                UIImage *image = [UIImage imageNamed:@"mark_recom_tag"];
                //            UIImage *newImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width / 1.5, image.size.height / 1.5)];
                imageView = [[UIImageView alloc] initWithImage:image];
                imageView.tag = 1000;
                imageView.frame = CGRectOffset(imageView.frame, btnFrame.size.width - imageView.frame.size.width - 4, 4);
                [recommendedBtn addSubview:imageView];
            }
            imageView.hidden = NO;
        }
        else
        {
            UIButton *recommendedBtn = (UIButton*)[_accessView viewWithTag:3];
            UIImageView *imageView = (UIImageView*)[recommendedBtn viewWithTag:1000];
            if (imageView)
            {
                imageView.hidden = YES;
            }
        }
    }
}

#pragma mark - UIButton Action

#pragma mark -- 收藏

- (void)taggedCollect:(UIButton *)btn
{
//    //房源收藏关闭
//    [[EBHttpClient sharedInstance] houseRequest:@{@"house_id": _houseDetail.id} collectState:_houseDetail.collected toggleCollect:^(BOOL success, id result)
//     {
//         if (success)
//         {
//             _houseDetail.collected  = !_houseDetail.collected ;
//             btn.selected = !btn.selected;
//
//             [EBAlert alertSuccess:btn.selected ? NSLocalizedString(@"btn_collected", nil) : NSLocalizedString(@"btn_cancelcollected", nil)];
//         }
//     }];
//
//    return;
    
    //没有开启房源收藏
    if (_houseDetail.group == nil || ![_houseDetail.group isKindOfClass:[NSArray class]] || [_houseDetail.group isEqual:[NSNull null]]) {
        [[EBHttpClient sharedInstance] houseRequest:@{@"house_id": _houseDetail.id} collectState:_houseDetail.collected toggleCollect:^(BOOL success, id result)
        {
            if (success)
                {
                    _houseDetail.collected  = !_houseDetail.collected ;
                     btn.selected = !btn.selected;
        
                    [EBAlert alertSuccess:btn.selected ? NSLocalizedString(@"btn_collected", nil) : NSLocalizedString(@"btn_cancelcollected", nil)];
                }
        }];
        return;
    }

    //开启了房源收藏
    if (_houseDetail.collected == YES) {
        
        NSLog(@"请求接口");
        
        NSString *url = @"/house/deleteFavorite";
        NSDictionary *parm = nil;
 
        parm = @{
                    @"token" : [EBPreferences sharedInstance].token,
                    @"ids" :  _houseDetail.id,

                    };
        NSLog(@"parm = %@" , parm);
        
        [HttpTool post:url parameters:parm success:^(id responseObject) {
            NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"dict = %@",dict);
            if ([dict[@"code"] integerValue] == 0) {
                _houseDetail.collected  = !_houseDetail.collected ;
                btn.selected = !btn.selected;
                
                [EBAlert alertSuccess:btn.selected ? NSLocalizedString(@"btn_collected", nil) : NSLocalizedString(@"btn_cancelcollected", nil)];
            }else{
                [EBAlert alertError:@"删除失败"];
            }
            
        } failure:^(NSError *error) {
            [EBAlert alertSuccess:@"请求失败"];
        }];
        
//        [[EBHttpClient sharedInstance] houseRequest:@{@"house_id": _houseDetail.id} collectState:_houseDetail.collected toggleCollect:^(BOOL success, id result)
//         {
//             if (success)
//             {
//                 _houseDetail.collected  = !_houseDetail.collected ;
//                 btn.selected = !btn.selected;
//
//                 [EBAlert alertSuccess:btn.selected ? NSLocalizedString(@"btn_collected", nil) : NSLocalizedString(@"btn_cancelcollected", nil)];
//             }
//         }];
        return;
    }
    
    [[EBController sharedInstance] showPopOverListView:btn choices:@[@"选择收藏分组",@"新建收藏分组"] block:^(NSInteger selectedIndex) {
        
        NSLog(@"selectedIndex = %ld",selectedIndex);
        if (selectedIndex == 0) {   //选择收藏分组
            NSLog(@"group = %@",_houseDetail.group);
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请选择分组" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            if (_houseDetail.group != nil && [_houseDetail.group isKindOfClass:[NSArray class]]) {
                for (NSDictionary *dic in _houseDetail.group) {
                    [alertVC addAction:[UIAlertAction actionWithTitle:dic[@"text"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        NSLog(@"分组id = %@",dic[@"value"]);
                        if (dic[@"value"] == nil) {
                            [EBAlert alertError:@"无分组信息"];
                            return ;
                        }
                        //新增分组
                        NSString *url = @"/house/addFavoriteHouse";
                        NSDictionary *parm = @{
                                               @"token" : [EBPreferences sharedInstance].token,
                                               @"group_id" : dic[@"value"],
                                               @"fk_id" : _houseDetail.id
                                               };
                        NSLog(@"parm = %@",parm);
                        
                        [HttpTool post:url parameters:parm success:^(id responseObject) {
                            NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                            NSLog(@"dict = %@",dict);
                            if ([dict[@"code"] integerValue] == 0) {
                                [EBAlert alertSuccess:@"收藏成功"];
                                __weak typeof(self) weakSelf = self;
                                [weakSelf refreshHouseDetail:YES];
                            }else{
                                [EBAlert alertError:dict[@"desc"]];
                            }
                        } failure:^(NSError *error) {
                            [EBAlert alertSuccess:@"请求失败"];
                            [[HWPopTool sharedInstance]closeWithBlcok:^{
                                
                            }];
                        }];
                    }]];
                }
            }
            [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
               
            }]];
            [self presentViewController:alertVC animated:YES completion:nil];
            
        }else{  //新建收藏分组

            HouseCreateNewGroupView *createView = [[HouseCreateNewGroupView alloc]initWithFrame:CGRectMake(0, 0, kScreenW-80, 200)];
            
            createView.btnClick = ^(UIButton *btn ,UITextField *groupName) {
              
                if (btn.tag == 1) {
                    [[HWPopTool sharedInstance]closeWithBlcok:^{
                        NSLog(@"取消");//取消
                       
                    }];
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
                    
                [HttpTool post:url parameters:parm success:^(id responseObject) {
                    NSDictionary *dict =   [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                    NSLog(@"dict = %@",dict);
                    if ([dict[@"code"] integerValue] == 0) {
                        [[HWPopTool sharedInstance]closeWithBlcok:^{
                            
                        }];
                        __weak typeof(self) weakSelf = self;
                        if ([dict[@"data"][@"code"] integerValue] == 200) {
                            [EBAlert alertSuccess:@"新建成功"];
                            [weakSelf refreshHouseDetail:YES];;   //刷新详情
                        }else{
                            [EBAlert alertError:dict[@"data"][@"desc"]];
                        }
                    }else{
                        [EBAlert alertError:@"请求失败"];
                    }
                        
                } failure:^(NSError *error) {
                    [EBAlert alertSuccess:@"请求失败"];
                    [[HWPopTool sharedInstance]closeWithBlcok:^{

                    }];
                }];
            };
            MyViewController *vc = [[HWPopTool sharedInstance]showWithPresentView:createView animated:YES];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closePop)];
            vc.styleView.userInteractionEnabled = YES;
            [vc.styleView addGestureRecognizer:tap];
        }
        
    }];
    
    
    [EBTrack event:EVENT_CLICK_HOUSE_VIEW_FAVORITES];
    
   
    
}


- (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
    [image drawInRect:imageRect];
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return retImage;
}

#pragma mark -- 分享


- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType withShareConfig:(NSDictionary*)shareConfig
{
    NSLog(@"点击了分享按钮: %@",shareConfig);
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
//    NSString *title = shareConfig[@"title"];
    NSString *title = @"测试";
//    NSString *desc = shareConfig[@"text"];
    NSString *desc = @"我的";
//    NSString* thumbURL = [NSString stringWithFormat:@"%@",shareConfig[@"image"]];
//    
//    NSURL *url = [NSURL URLWithString:thumbURL];
//    NSData *data = [NSData dataWithContentsOfURL:url];
//    UIImage *img = [self resizeImage:[UIImage imageWithData:data scale:0.10] size:CGSizeMake(15, 15)];
    
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:desc thumImage:nil];
    
    //设置网页地址
//    shareObject.webpageUrl = [NSString stringWithFormat:@"%@",shareConfig[@"url"]];
    shareObject.webpageUrl =@"http://www.baidu.com";
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
//    NSLog(@"self = %@",shareConfig[@"viewController"]);
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        //        [self alertWithError:error];
    }];
}


//分享
- (void)share:(UIButton *)btn
{
    //filter 房源过滤
    [EBTrack event:EVENT_CLICK_HOUSE_SHARE];
  
    if (![_houseDetail.status isEqualToString:@"有效"]) {
        [EBAlert alertError:@"房源已售,不能分享" length:3.0];
        return;
    }
    
    if (_houseDetail.is_recommend == NO) {
        [EBAlert alertError:@"该房源录入时候未超过24小时或没有委托,暂时不能分享" length:2.0];
        //图片数大于0 有委托
        return;
    }
    //分享测试
//    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sms)]];
//    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
//        // 根据获取的platformType确定所选平台进行下一步操作
//        //在回调里面获得点击的
//        if (platformType == UMSocialPlatformType_WechatSession) { //微信聊天
//            [self shareWebPageToPlatformType:UMSocialPlatformType_WechatSession withShareConfig:nil];
//            
//        } else if (platformType == UMSocialPlatformType_WechatTimeLine){ //微信朋友圈
////            [self shareWebPageToPlatformType:UMSocialPlatformType_WechatTimeLine];
//            
//        } else if (platformType == UMSocialPlatformType_QQ){ //QQ聊天页面
////            [self shareWebPageToPlatformType:UMSocialPlatformType_QQ];
//            
//        } else if (platformType == UMSocialPlatformType_Qzone){ //QQ空间
////            [self shareWebPageToPlatformType:UMSocialPlatformType_Qzone];
//            
//        } else if (platformType == UMSocialPlatformType_Sms){ //短信
////            [self shareWebPageToPlatformType:UMSocialPlatformType_Sms];
//            
//        }
//    }];
    
    //分享
    SnsViewController *viewController = [[EBController sharedInstance] shareHouses:[NSArray arrayWithObjects:_houseDetail, nil] handler:^(BOOL success, NSDictionary *info){
        NSLog(@"info = %@",info);
        if (success)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^{
                [EBAlert alertSuccess:nil];
            });
        }
        else
        {
            if ([info[@"desc"] rangeOfString:@"canceled"].location == NSNotFound)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^{
                    [EBAlert alertError:NSLocalizedString(info[@"desc"], nil)];
                });
                
            }
        }
    }];
    
    EBFilter *filter = [[EBFilter alloc] init];
    [filter parseFromHouse:_houseDetail withDetail:YES];
    
    viewController.extraInfo = filter;
}

#pragma mark -- 显示更多

- (void)showMoreFunctionList:(id)sender
{
    NSMutableArray *choices = [[NSMutableArray alloc] initWithCapacity:_houseOperations.count];
    for (NSString *key in _houseOperations) {
        [choices addObject:[NSString stringWithFormat:NSLocalizedString(key, nil), NSLocalizedString(@"house", nil)]];
    }
    NSLog(@"choices=%@",choices);
    __weak typeof(self) weakSelf = self;
    [[EBController sharedInstance] showPopOverListView:sender choices:choices block:^(NSInteger selectedIndex)
     {
         NSString *action = _houseOperations[selectedIndex];
         if ([action isEqualToString:@"operation_modify"])
         {
             HouseEditViewController *editViewController = [[HouseEditViewController alloc] init];
             editViewController.houseDetail = _houseDetail;
             editViewController.hidesBottomBarWhenPushed = YES;
             [weakSelf.navigationController pushViewController:editViewController animated:YES];
             [EBTrack event:EVENT_CLICK_HOUSE_EDIT];
         }
         else if ([action isEqualToString:@"operation_modify_status"])
         {
             ChangeStatusViewController *desViewController = [[ChangeStatusViewController alloc] init];
             desViewController.house = _houseDetail;
             desViewController.isClient = NO;
             [weakSelf.navigationController pushViewController:desViewController animated:YES];
             [EBTrack event:EVENT_CLICK_HOUSE_CHANGE_STATUS];
         }
         else if ([action isEqualToString:@"operation_modify_recommend_tag"])
         {
             ChangeRecTagViewController *desViewController = [[ChangeRecTagViewController alloc] init];
             desViewController.house = _houseDetail;
             desViewController.isClient = NO;
             [weakSelf.navigationController pushViewController:desViewController animated:YES];
             [EBTrack event:EVENT_CLICK_HOUSE_CHANGE_TAGS];
         }
         else if ([action isEqualToString:@"operation_modify_report"])
         {
             EBBusinessConfig *config = [EBCache sharedInstance].businessConfig;
             NSArray *reportTypeArray = config.houseConfig.reportTypes;
             NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:reportTypeArray.count];
             for (int i = 0; i < reportTypeArray.count; i++)
             {
                 NSString *repostType = reportTypeArray[i];
                 [buttons addObject:[RIButtonItem itemWithLabel:repostType action:^
                                     {
                                         ReportViewController *desViewController = [[ReportViewController alloc] init];
                                         desViewController.house = _houseDetail;
                                         desViewController.reportType = repostType;
                                         [weakSelf.navigationController pushViewController:desViewController animated:YES];
                                     }]];
             }
             [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"action_sheet_report_title", nil) buttons:buttons] showInView:weakSelf.view];
             [EBTrack event:EVENT_CLICK_HOUSE_REPORT];
         }
     }];
}

#pragma mark -- 房源上传图片
- (void)uploadPhoto
{
    //判断有没有网络（没有封装）
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        NSString *temp = nil;
        if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
            if (temp == nil) {
                temp = @"";
            }
        }
        [[[UIAlertView alloc] initWithTitle:temp
                                    message:NSLocalizedString(@"network_error", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"confirm_ok", nil) otherButtonTitles:nil] show];
        return;
    }
    
    //是否正在上传
    if ( isUploadPhoto == NO) {
        [[[UIAlertView alloc] initWithTitle:@"提示"
                                    message:@"正在上传照片,上传完成后才可以继续上传"
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"confirm_ok", nil) otherButtonTitles:nil] show];
        return;
    }
    //有网的时候调用
    //housePri图片字典
    if ([_houseDetail.housePri[@"upload_photo"] integerValue]) {
        [self getPhoto:_houseDetail];
    }
//    if (_houseDetail.pictures.count >= 10)
//    {
//        NSString *temp = nil;
//        if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
//            if (temp == nil) {
//                temp = @"";
//            }
//        }
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:temp message:NSLocalizedString(@"photo_uploading_limit_warn", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"anonymous_call_end_confirm", nil) otherButtonTitles:nil];
//        [alertView show];
//    }
//    else
//    {
    
//    }
}
//
- (void)checkPhoneNumber:(UIButton *)btn{
    
    [EBTrack event:EVENT_CLICK_HOUSE_VIEW_NUMBER];
    NSDictionary *params = @{@"id":_houseDetail.id, @"type": [EBFilter typeString:_houseDetail.rentalState],@"contract_code":_houseDetail.contractCode};
    [EBCallEventHandler clickPhoneButton:btn withParams:params numStatus:_numStatus timesRemain:_houseDetail.timesRemain phoneNumbers:_houseDetail.phoneNumbers type:ECallEventTypeHouse phoneGotHandler:^(BOOL success, NSDictionary *result){
    if (success){
        NSDictionary *detail = result[@"detail"];
        _houseDetail.phoneNumbers = detail[@"phone_numbers"];
        _houseDetail.address = detail[@"address"];
        _houseDetail.coreMemo = detail[@"core_memo"];
        _houseDetail.name = detail[@"name"];
        _houseDetail.building = detail[@"building"];
        [self refreshDetail];
        [[EBCache sharedInstance] cacheHouseDetail:_houseDetail];
        BOOL isPush = !(self.houseDetail.ownbyme == YES||self.houseDetail.timesRemain <= 0);
        if (isPush && [_houseDetail.if_dhgj isEqualToString:@"yes"]){
            //将请求出来的数组传到下一个界面
            HouseNewForceFollowUpViewController *house = [[HouseNewForceFollowUpViewController alloc]init];
            house.followUptype = ZHForceFollowUpTypeNO;
            house.hidesBottomBarWhenPushed = YES;
            house.house_id = _houseDetail.id;//房源id
            house.house_code = _houseDetail.contractCode;//房源编号
            house.name = _houseDetail.name;//业主名字
            house.phoneNum = detail[@"phone"];
            house.returnBlock = ^(BOOL succeed){
                if (succeed == YES) {//成功
                    NSLog(@"跟进提交成功");
                }else{
                    [EBAlert alertError:@"跟进提交失败,暂无法查看电话"];
                }
            };
            
            [self.navigationController pushViewController:house animated:YES];
        }
    }
        [EBAlert hideLoading];
    } inView:self.view];
}

//lwl 查看电话（强制写跟进的时候在界面回调之后block回调这些代码）
- (void)viewPhoneNumber:(UIButton *)btn
{
    NSLog(@"if_dhgj=%@",_houseDetail.if_dhgj);
    NSLog(@"force_follow=%@",_houseDetail.force_follow);
    BOOL isPush = !(self.houseDetail.ownbyme == YES||self.houseDetail.timesRemain <= 0);
//     [self checkPhoneNumber:btn];
    NSLog(@"ispush=%d",isPush);
    if ([_houseDetail.if_dhgj isEqualToString:@"yes"]) {//开启了查看电话强制写跟进
        if (self.houseDetail.ownbyme == YES || self.houseDetail.timesRemain <= 0) {
            [self checkPhoneNumber:btn];//自己的电话查看不需要
        }else{
            if (_houseDetail.force_follow != nil) {//有上一次查看的电话,
                NSString *str = [NSString  stringWithFormat:@"请您先补充上次查看房源的跟进,房源编号为%@,再点击\"查看电话\"查看",_houseDetail.force_follow[@"view_phone_code"]];
                __weak typeof(self) weakSelf = self;
                [EBAlert confirmWithTitle:@"提示" message:str
                yes:@"补充跟进" action:^{
                    HouseNewForceFollowUpViewController *house = [[HouseNewForceFollowUpViewController alloc]init];
                    house.isForceFollow = YES;//这里进去的是强制跟进
                    house.hidesBottomBarWhenPushed = YES;
                    //            house.params = params;
                    NSLog(@"fk_id = %@",_houseDetail.force_follow[@"fk_id"]);
                    NSLog(@"view_phone_code = %@",_houseDetail.force_follow[@"view_phone_code"]);
                    house.followUptype = ZHForceFollowUpTypeYES;
                    house.house_id = _houseDetail.force_follow[@"fk_id"];//房源id
                    house.house_code = _houseDetail.force_follow[@"view_phone_code"];//房源编号
                    house.returnBlock = ^(BOOL succeed){
                        if (succeed == YES) {//成功
                            NSLog(@"跟进提交成功");
                        }else{
                            [EBAlert alertError:@"跟进提交失败,暂无法查看电话"];
                        }
                    };
                    [weakSelf.navigationController pushViewController:house animated:YES];
                }];
        
            }else{//没有需要强制写跟进的房源
                [self checkPhoneNumber:btn];
            }
        }
    }else{
        [self checkPhoneNumber:btn];//查看电话不用强制写跟进
    }
}


#pragma mark -- checkHouseNumber
- (void)checkHouseNumber:(UIButton *)btn{
    NSLog(@"查看门牌号");
    //接口
    
    NSString *urlStr = @"house/viewRoomCode";
    NSString *typeid = nil;
    
    if (_houseDetail.rentalState == EHouseRentalTypeRent){
        typeid = @"rent";
    }else if (_houseDetail.rentalState == EHouseRentalTypeSale){
        typeid = @"sale";
    }else{
        typeid = @"both";
    }
    
    if (_houseDetail.id == nil || [_houseDetail.id isEqual:[NSNull null]]) {
        [EBAlert alertError:@"资源id为空"];
        return;
    }
    
    NSDictionary *param = @{
                            @"token":[EBPreferences sharedInstance].token,
                            @"type":typeid,
                            @"id":_houseDetail.id,
                            };
    [EBAlert showLoading:@"加载中" allowUserInteraction:NO];
    [HttpTool get:urlStr parameters:param success:^(id responseObject) {
        [EBAlert hideLoading];
        NSLog(@"responseObject = %@",responseObject);
        if ([responseObject[@"code"] integerValue] == 0) {
            if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = responseObject[@"data"];
                if ([data.allKeys containsObject:@"building"]) {
                     CGFloat textLineHeight = [EBViewFactory textSize:responseObject[@"data"][@"building"] font:btn.titleLabel.font bounding:CGSizeMake(120, MAXFLOAT)].height;
                     NSLog(@"textLineHeight=%f",textLineHeight);
                     btn.height = textLineHeight + 5;
                     [btn setTitle:responseObject[@"data"][@"building"] forState:UIControlStateNormal];
                }else{
                    [EBAlert alertError:@"请求失败"];
                }
            }else{
                [EBAlert alertError:@"请求失败"];
            }
           
        }else{
            [EBAlert alertError:@"请求失败"];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"请求失败"];
    }];
    
}

- (void)showList:(UIButton *)btn
{
    NSInteger tag = btn.tag;
    //! wyl
    if (tag < 4)
    {
        EBFilter *filter = [[EBFilter alloc] init];
        [filter parseFromHouse:_houseDetail withDetail:tag == 1];
        //    filter.houseId = _houseDetail.id;
        //    filter.houseType = [EBFilter typeString:_houseDetail.rentalState];
        
        EBIconLabel *iconLabel = (EBIconLabel *)[btn viewWithTag:88];
        [[EBController sharedInstance] showClientListWithType:EClientListTypeMatchClientsForHouse + tag - 1
                                                       filter:filter title:iconLabel.label.text house:_houseDetail];
    }
    else if (tag == 4)
    {
        HouseVisitLogViewController *viewController = [[HouseVisitLogViewController alloc] init];
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.houseDetail = _houseDetail;
        [self.navigationController pushViewController:viewController animated:YES];
        [EBTrack event:EVENT_CLICK_HOUSE_TAKE_LOOK];
    }
    else if (tag == 5)
    {
        [EBTrack event:EVENT_CLICK_HOUSE_MARKED_GJ_LIST];
//        HouseFollowLogViewController *viewControler = [[HouseFollowLogViewController alloc] init];
//        viewControler.hidesBottomBarWhenPushed = YES;
//        viewControler.houseDetail = _houseDetail;
//        [self.navigationController pushViewController:viewControler animated:YES];
        
        //新的跟进记录
        HouseNewFollowLogViewController *viewControler = [[HouseNewFollowLogViewController alloc] init];
        viewControler.hidesBottomBarWhenPushed = YES;
        viewControler.houseDetail = _houseDetail;
        [self.navigationController pushViewController:viewControler animated:YES];
        
    }
    else if (tag == 86)
    {
        EBFilter *filter = [[EBFilter alloc] init];
        filter.requireOrRentalType = _houseDetail.rentalState;
        filter.keywordType = @"community";
        filter.keyword = [_houseDetail.community copy];
        
        [[EBController sharedInstance] showHouseListWithType:EHouseListTypeSearch
                                                      filter:filter title:_houseDetail.community client:nil];
    }else if (tag == 6){
        //通话录音
        HouseCallRecordViewController *callRecord = [[HouseCallRecordViewController alloc]init];
        callRecord.hidesBottomBarWhenPushed = YES;
        callRecord.houseDetail = self.houseDetail;
        [self.navigationController pushViewController:callRecord animated:YES];
    }
    
    switch (tag)
    {
        case 1:
            [EBTrack event:EVENT_CLICK_HOUSE_MATCH_CLIENTS];
            break;
        case 2:
            [EBTrack event:EVENT_CLICK_HOUSE_MARKED_CLIENTS];
            break;
        case 3:
            break;
        default:
            
            break;
    }
}

- (void)calculate:(UIButton *)btn
{
    CGFloat amount = [_houseDetail.sellPrice.amount floatValue];
    CGFloat mortgage = amount * 0.6;
    NSDictionary *info = @{@"amount":_houseDetail.sellPrice.amount, @"mortgage":@(mortgage)};
    [[EBController sharedInstance] showCalculator:info];
}

- (void)showHouseLocation:(id)sender
{
    NSMutableDictionary *poiInfo = [[NSMutableDictionary alloc] init];
    [poiInfo setObject:_houseDetail.title forKey:@"name"];
    [poiInfo setObject:[NSString stringWithFormat:@"%f",0.0] forKey:@"lat"];
    [poiInfo setObject:[NSString stringWithFormat:@"%f",0.0] forKey:@"lon"];
    [poiInfo setObject:[self getHouseMapSearchAddress] forKey:@"address"];
    [[EBController sharedInstance] showLocationInMap:poiInfo showKeywordLocation:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self refreshHouseDetail:YES];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return NO; // should return if data source model is reloading
}

#pragma mark - KIImagePagerDataSource

- (NSArray *)arrayWithImages
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *item in _houseDetail.pictures)
    {
        [array addObject:item[@"image"]];
    }
    
    return array;
}

- (BOOL)isVideoAtIndex:(NSUInteger)index
{
    return _houseDetail.pictures[index][@"video"] && [_houseDetail.pictures[index][@"video"] boolValue];
}

- (UIImage *)placeHolderImageForImagePager
{
    return nil;
}

- (UIViewContentMode)contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleAspectFill;
}

- (NSString *)captionForImageAtIndex:(NSUInteger)index
{
    if (_houseDetail.pictures.count > 0)
    {
        return _houseDetail.pictures[index][@"description"];
    }
    else
    {
        return @"";
    }
}

#pragma mark - KIImagePagerDelegate

- (void)imagePager:(KIImagePager *)imagePager didScrollToIndex:(NSUInteger)index
{
    
}
- (void)imagePager:(KIImagePager *)imagePager didSelectImageAtIndex:(NSUInteger)index
{
    
    if (_houseDetail.pictures[index][@"video"] && [_houseDetail.pictures[index][@"video"] boolValue]) {
        [EBVideoUtil playWithURL:self remoteURL:[NSURL URLWithString:_houseDetail.pictures[index][@"original"]]];
        return;
    }
    
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    for (NSDictionary *photoInfo  in _houseDetail.pictures)
    {
        if (!photoInfo[@"video"] || ![photoInfo[@"video"] boolValue]) {
            [photos addObject:[[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:photoInfo[@"original"]] name:photoInfo[@"description"]]];
        }
    }
    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:photos];
    FSImageViewerViewController *controller = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:index];
    controller.fixTitle = _houseDetail.contractCode;
    
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - View Factory

- (UILabel *)diffLabel:(CGFloat)diff withUnit:(NSString *)unit
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 12)];
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"%.0f%@", diff, unit];
    if (diff > 0)
    {
        label.text = [NSString stringWithFormat:@"+%@", label.text];
    }
    label.backgroundColor = diff > 0 ? [EBStyle redTextColor] : [EBStyle greenTextColor];
    label.font = [UIFont systemFontOfSize:12.0];
    label.tag = 889;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (UILabel *)unitCostLabel:(CGFloat)unitCost withUnit:(NSString *)unit
{
    UILabel *label = [self affiliateInfoLabel:[NSString stringWithFormat:NSLocalizedString(@"format_unit_cost_0", nil),unitCost]];
    label.tag = 890;
    return label;
}

- (UILabel *)affiliateInfoLabel:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [EBStyle grayTextColor];
    CGSize size = [EBViewFactory textSize:text font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    label.frame = CGRectMake(0, 0, size.width, size.height);
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12.0];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

//- (EBIconLabel *)parentView:(UIView *)parent iconTextWithImage:(UIImage *)image text:(NSString *)text
//{
//    EBIconLabel *iconLabel = [[EBIconLabel alloc] initWithFrame:CGRectZero];
//    iconLabel.backgroundColor = [UIColor clearColor];
//    iconLabel.iconPosition = EIconPositionTop;
//    iconLabel.imageView.image = image;
//    iconLabel.label.textColor = [EBStyle blackTextColor];
//    iconLabel.label.font = [UIFont systemFontOfSize:14.0];
//    iconLabel.label.text = text;
//    iconLabel.gap = 2;
//    [parent addSubview:iconLabel];
//    
//    return iconLabel;
//}

- (void)parentView:(UIView *)parent addLine:(CGFloat)yOffset
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, [EBStyle screenWidth], 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    [parent addSubview:line];
}

- (CGFloat)parentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue yOffset:(CGFloat)yOffset
{
    return [self parentView:parent addKey:key value:value linkValue:linkValue yOffset:yOffset limitWidth:[EBStyle screenWidth]];
}

- (CGFloat)parentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth
{
    return [self parentView:parent addKey:key value:value linkValue:linkValue xOffset:0 yOffset:yOffset limitWidth:limitWidth];
}

- (CGFloat)parentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth
{
    return [EBViewFactory parentView:parent addKey:key value:value linkValue:linkValue xOffset:xOffset yOffset:yOffset limitWidth:limitWidth delegate:self];
}

- (CGFloat)myParentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth
{
    return [EBViewFactory myParentView:parent addKey:key value:value linkValue:linkValue xOffset:xOffset yOffset:yOffset limitWidth:limitWidth delegate:self];
}

- (CGFloat)parentView:(UIView *)parent addAreaItem:(NSString *)key value:(NSString *)value xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth
{
    if (value == nil || value.length == 0)
    {
        return 0;
    }
    UIFont *font = [UIFont systemFontOfSize:12.0];
    UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0 + xOffset, yOffset, 54, 20)];
    keyLabel.font = font;
    keyLabel.textColor = [EBStyle grayTextColor];
    keyLabel.text = key;
    keyLabel.textAlignment = NSTextAlignmentRight;
    [parent addSubview:keyLabel];
    
    CGSize contentSize = [EBViewFactory textSize:value font:font bounding:CGSizeMake(limitWidth - 10 - 70, MAXFLOAT)];
    if (contentSize.height < 20)
    {
        contentSize.height = 20;
    }
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(70 + xOffset, yOffset, contentSize.width, contentSize.height)];
    contentLabel.font = font;
    contentLabel.textColor = [EBStyle blackTextColor];
    contentLabel.text = value;
    [parent addSubview:contentLabel];
    
    return contentSize.height;
}

- (EBIconLabel *)labelWithYOffset:(CGFloat)yOffset imageName:(NSString *)name text:(NSString *)text parent:(UIView *)parent
{
    EBIconLabel *label = [[EBIconLabel alloc] initWithFrame:CGRectMake(10, yOffset, 0, 0)];
    label.gap = 10.0;
    label.maxWidth = 300.0;
    label.iconPosition = EIconPositionLeft;
    label.label.font = [UIFont systemFontOfSize:14.0];
    label.label.textColor = [EBStyle blackTextColor];
    
    label.imageView.image = [UIImage imageNamed:name];
    label.label.text = text;
    
    [parent addSubview:label];
    
    return label;
}

#pragma mark - RTLabelDelegate

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url
{
    NSArray *components = [[url absoluteString] componentsSeparatedByString:@"#"];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    if (components.count > 1)
    {
        NSString *phone = components[1];
        
        if (phone.length)
        {
            [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"call_contact", nil) action:^
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]]];
            }]];
            
            [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"sms_contact", nil) action:^
            {
                [[ShareManager sharedInstance] shareContent:@{@"to" : phone} withType:EShareTypeMessage
                                                                        handler:^(BOOL success, NSDictionary *info)
                {
                }];
            }]];
        }
    }
    
    EBContact *contact = [[EBContactManager sharedInstance] contactById:_houseDetail.delegationAgent.userId];
    if (contact)
    {
        [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"profile_btn_send_im", nil) action:^
        {
            if (contact.notFound)
            {
                [EBAlert alertWithTitle:nil message:NSLocalizedString(@"alert_contact_not_fount", nil) yes:NSLocalizedString(@"btn_yes", nil) confirm:^{
                    
                }];
            }
            else
            {
                [[EBController sharedInstance] startChattingWith:@[contact] popToConversation:NO];
            }
        }]];
    }
    
    [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.view];
}

#pragma mark - Tool

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)refreshHouseDetail:(BOOL)force
{
    [[EBHttpClient sharedInstance] houseRequest:@{@"id":_houseDetail.id, @"force_refresh":@(force),
                                                  @"type":[EBFilter typeString:_houseDetail.rentalState]}
                                         detail:^(BOOL success, id result)
     {
         [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
         if (success)
         {
             NSLog(@"_houseDetail=%@",_houseDetail);
             _houseDetail = result; //判断
//             _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
//             _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//             _tableView.delegate = self;
//             _tableView.dataSource = self;
             [self.view addSubview:self.tableView];
             
             
             _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.frame.size.height,
                                                                                              _tableView.frame.size.width, _tableView.frame.size.height)];
             _refreshHeaderView.delegate = self;
             [_tableView addSubview:_refreshHeaderView];
             
             [self refreshDetail];
             [[EBCache sharedInstance] updateCacheByViewHouseDetail:_houseDetail];
             
#pragma mark -- 隐号呼叫
             //隐号呼叫
             [self hiddenFollowup];
             
         }
     }];
}

- (BOOL)diffInPrice
{
    return (_houseDetail.rentPrice && _houseDetail.rentPrice.diff != 0) || (_houseDetail.sellPrice && _houseDetail.sellPrice.diff != 0);
}

- (void)adjustAffiliateInfoLabelFrame:(UILabel *)affiliateLabel accordingFrame:(CGRect)accordingFrame above:(BOOL)isAbove
{
    CGRect frame = affiliateLabel.frame;
    if (isAbove)
    {
        frame.origin.y = -frame.size.height - 5;
    }
    else
    {
        frame.origin.y = accordingFrame.size.height + 5;
    }
    
    if (frame.size.width > accordingFrame.size.width)
    {
        CGPoint origin = CGPointMake(-(frame.size.width - accordingFrame.size.width) / 2, frame.origin.y);
        if ([affiliateLabel convertPoint:origin toView:_numbersView].x + frame.size.width > [EBStyle screenWidth])
        {
            frame.origin.x = origin.x - ([affiliateLabel convertPoint:origin toView:_numbersView].x + frame.size.width - [EBStyle screenWidth]) - 5;
        }
        else if ([affiliateLabel convertPoint:origin toView:_numbersView].x < 0)
        {
            frame.origin.x = - accordingFrame.origin.x + 5;
        }
        else
        {
            frame.origin = origin;
        }
    }
    else
    {
        frame.origin.x = (accordingFrame.size.width - frame.size.width) / 2;
    }
    affiliateLabel.frame = frame;
}

- (void)getHouseOperations
{
    if (_houseOperations == nil)
    {
        _houseOperations = [[NSMutableArray alloc] init];
    }
    else
    {
        [_houseOperations removeAllObjects];
    }
    NSArray *keys = @[@"modify", @"modify_status", @"modify_recommend_tag", @"modify_report"];
    for (NSString *key in keys)
    {
        if ([[_houseDetail.housePri objectForKey:key] boolValue])
        {
            if ([key isEqualToString:keys.lastObject])
            {
                if (!_houseDetail.ownbyme)
                {
                    [_houseOperations addObject:[NSString stringWithFormat:@"operation_%@", key]];
                }
            }
            else
            {
                [_houseOperations addObject:[NSString stringWithFormat:@"operation_%@", key]];
            }
        }
    }
}

- (NSString *)getHouseLocation
{
    NSMutableArray *addressArray = [[NSMutableArray alloc] init];
    if (_houseDetail.district.length > 0)
    {
        [addressArray addObject:_houseDetail.district];
    }
    if (_houseDetail.region.length > 0)
    {
        [addressArray addObject:_houseDetail.region];
    }
    if (_houseDetail.address.length > 0)
    {
        [addressArray addObject:_houseDetail.address];
    }
    else if (_houseDetail.community.length > 0)
    {
        [addressArray addObject:_houseDetail.community];
    }
    return [addressArray componentsJoinedByString:@"-"];
}

- (NSString *)getHouseMapSearchAddress
{
    NSMutableArray *addressArray = [[NSMutableArray alloc] init];
    if (_houseDetail.district.length > 0)
    {
        [addressArray addObject:_houseDetail.district];
    }
    if (_houseDetail.region.length > 0)
    {
        [addressArray addObject:_houseDetail.region];
    }
    if (_houseDetail.community.length > 0)
    {
        [addressArray addObject:_houseDetail.community];
    }
    return [addressArray componentsJoinedByString:@" "];
}

#pragma mark - 上传图片

- (void)getPhoto:(EBHouse*)house
{
    __weak HouseDetailViewController *weakSelf = self;
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    NSString *format = nil;
    NSInteger count = _houseDetail.priUploadVideo ? 4 : 2;
    for (int i = 0; i < count; i++)
    {
        format = [NSString stringWithFormat:@"upload_select_%d", i];
        [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(format, nil) action:^{
            
            HouseDetailViewController *strongSelf = weakSelf;
            
            NSString * imageCount = [EBPreferences sharedInstance].image_num_limit;
            
            NSLog(@"%ld",_houseDetail.image_num);
            
            //改好改动 _houseDetail.current_image_count 替换 _houseDetail.pictures.count
            
            if ((i == 0 || i == 1) && _houseDetail.image_num >= [imageCount integerValue])
            {
                NSString *temp = nil;
                if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                    if (temp == nil) {
                        temp = @"";
                    }
                }
//                "photo_uploading_limit_warn"     = "本房源下图片已达到十张，无法继续添加";
//                "anonymous_call_end_confirm" = "好的";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:temp message:NSLocalizedString(@"photo_uploading_limit_warn", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"anonymous_call_end_confirm", nil) otherButtonTitles:nil];
                [alertView show];
                return;
            }
            if (i == 0)
            {
                //跳转到图片选择控制器
                [strongSelf performSelector:@selector(showImagePicker:) withObject:house afterDelay:0.3];
            } else if (i == 1) {
                [SKImageController showMutlSelectPhotoFrom:strongSelf maxSelect:[imageCount integerValue] - strongSelf->_houseDetail.image_num select:^(NSArray *info) {
                    NSMutableArray *photos = [NSMutableArray arrayWithArray:info];
//                    EBVideoUpload *video = nil;
//                    for (ALAsset *asset in photos) {
//                        if ([EBVideoUtil isVideoWithAsset:asset]) {
//                            video = [[EBVideoUpload alloc] init];
//                            video.houseUid = _houseDetail.id;
//                            video.assetURL = [asset.defaultRepresentation url];
//                            video.status = VideoStatusUploading;
//                            [photos removeObject:asset];
//                        }
//                    }
                    //上传图片控制器
                    HousePhotoPreUploadViewController *preUploadViewController = [[HousePhotoPreUploadViewController alloc] init];
                    [preUploadViewController uploadPhotos:photos forHouse:house getUpLoadPhotoBlock:^(NSArray *array) {
                        
                        if (array && array.count > 0)
                        {
                            [[EBHousePhotoUploader sharedInstance] addHousePhotos:array];
                        }
                    }];
                    [strongSelf.navigationController pushViewController:preUploadViewController animated:YES];
                    
//                    if (video) {
//                        [EBVideoUtil upload:video];
//                    }
                }];
            } else if (i == 2) {
                [strongSelf performSelector:@selector(showVideoPicker:) withObject:house afterDelay:0.3];
            }
            else
            {
                VideoListViewController *vc = [[VideoListViewController alloc] init];
                vc.houseUid = _houseDetail.id;
                EBNavigationController *nav = [[EBNavigationController alloc] initWithRootViewController:vc];
                [strongSelf presentViewController:nav animated:YES completion:nil];
            }
        }]];
    }
    //弹出选择的视图
    [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.view];
}

- (NSString *)getAgentString:(EBContact *)agent
{
    if (agent == nil) {
        return @"";
    }
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    if (agent.name.length == 0)
    {
        return @"";
    }
    else
    {
        [temp addObject:agent.name];
    }
    if (agent.happenDate.length > 0)
    {
        [temp addObject:agent.happenDate];
    }
    return [temp componentsJoinedByString:@" "];
}

- (NSString *)getAgentLinkString:(EBContact *)agent
{
    if (agent == nil) {
        return @"";
    }
    return [NSString stringWithFormat:NSLocalizedString(@"deleagtion_contact_format", nil), agent.phone == nil ? @"" : agent.phone, agent.name == nil ? @"" : agent.name, agent.happenDate == nil ? @"" : agent.happenDate];
}

- (void)showImagePicker:(EBHouse *)house
{
    __weak HouseDetailViewController *weakSelf = self;
    
    [[EBController sharedInstance] pickImageWithUrlSourceTypeEx:UIImagePickerControllerSourceTypeCamera curentViewController:self handler:^(UIImage *image, NSURL *url){
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        HousePhotoPreUploadViewController *preUploadViewController = [[HousePhotoPreUploadViewController alloc] init];
        [preUploadViewController uploadCameraPhotos:image url:url forHouse:house getUpLoadPhotoBlock:^(NSArray *array) {
            if (array && array.count > 0)
            {
                [[EBHousePhotoUploader sharedInstance] addHousePhotos:array];
            }
        }];
        [weakSelf.navigationController pushViewController:preUploadViewController animated:YES];
    }];
}

- (void)showVideoPicker:(EBHouse *)house
{
    __weak HouseDetailViewController *weakSelf = self;
    [[EBController sharedInstance] pickVideoWithUrlSourceTypeEx:UIImagePickerControllerSourceTypeCamera curentViewController:self handler:^(NSURL *sourceUrl){
//        [weakSelf dismissViewControllerAnimated:YES completion:nil];
        HouseVideoPreUploadViewController *vc = [[HouseVideoPreUploadViewController alloc] init];
//        vc.assetURL = sourceUrl;
        vc.tmpURL = sourceUrl;
        vc.houseUid = _houseDetail.id;
        
//        HousePhotoPreUploadViewController *preUploadViewController = [[HousePhotoPreUploadViewController alloc] init];
//        [preUploadViewController uploadCameraPhotos:image url:url forHouse:house getUpLoadPhotoBlock:^(NSArray *array) {
//            if (array && array.count > 0)
//            {
//                [[EBHousePhotoUploader sharedInstance] addHousePhotos:array];
//            }
//        }];
        EBNavigationController *nav = [[EBNavigationController alloc] initWithRootViewController:vc];
        [weakSelf presentViewController:nav animated:YES completion:nil];
//        [weakSelf.navigationController pushViewController:vc animated:YES];
        
        
    }];
}
-(void)setAppParam:(NSDictionary *)appParam
{
    if (!_houseDetail) {
        _houseDetail = [[EBHouse alloc]init];
        _houseDetail.id = appParam[@"id"];
        if ([appParam[@"type"] isEqualToString:@"sale"]) {
            _houseDetail.rentalState = 2;
        }else if ([appParam[@"type"] isEqualToString:@"rent"]){
            _houseDetail.rentalState = 1;
        }else{
            _houseDetail.rentalState = 3;
        }
    }
}

@end
