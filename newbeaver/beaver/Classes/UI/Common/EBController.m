//
// Created by 何 义 on 14-3-16.
// Copyright (c) 2014 eall. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "EBController.h"
#import "MainTabViewController.h"
#import "SingleChoiceViewController.h"
#import "EBSingleChoiceView.h"
#import "EBFilter.h"
#import "HouseListViewController.h"
#import "ClientListViewController.h"
#import "EBClient.h"
#import "EBHouse.h"
#import "HouseDetailViewController.h"
#import "ClientDetailViewController.h"
#import "EBCondition.h"
#import "CustomConditionViewController.h"
#import "CalculatorViewController.h"
#import "QRScannerViewController.h"
#import "InputOrScanViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "RecommendViewController.h"
#import "SnsViewController.h"
#import "SendShareViewController.h"
#import "EBPreferences.h"
#import "EBXMPP.h"
#import "EBIMConversation.h"
#import "ChatViewController.h"
#import "EBIMManager.h"
#import "EBContact.h"
#import "EBIMGroup.h"
#import "EBAlert.h"
#import "EBInputViewController.h"
#import "ProfileViewController.h"
#import "EBHttpClient.h"
#import "FSBasicImage.h"
#import "FSBasicImageSource.h"
#import "CustomIOS7AlertView.h"
#import "EBNoneImageModeAlertView.h"
#import "EBWebViewController.h"
#import "ShareManager.h"
#import "RIButtonItem.h"
#import "EBContactManager.h"
#import "UIActionSheet+Blocks.h"
#import "EBLocationPickerViewController.h"
#import "EBNavigationController.h"
#import "EBMapViewController.h"
#import "EBCache.h"
#import "EBAnonymousCallAlertView.h"
#import "AnonymousCallViewController.h"
#import "AnonymousNumSetViewController.h"
#import "FPPopoverController.h"
#import "CommonTableViewController.h"
#import "ALAsset+AGIPC.h"
#import "FilingDetailViewController.h"
#import "HouseEditFirstStepViewController.h"
#import "HouseAddSecondStepViewController.h"
#import "HouseAddViewController.h"
#import "ClientEditFirstStepViewController.h"
#import "ClientAddViewController.h"
#import "EBGatherHouse.h"
#import "GatherHouseDetailViewController.h"
#import "GatherHouseListViewController.h"
#import "GatherViewController.h"
#import "PublishHouseRecordViewController.h"
#import "ERPWebViewController.h"
#import "CCMD5.h"
typedef void(^TPickImageBlock)(UIImage *);

typedef void(^TPickImageWithUrlBlock)(UIImage *, NSURL *);

typedef void(^TPickVideoWithUrlBlock)(NSURL *);

@interface EBController()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, copy) TPickImageBlock pickImageBlock;

@property (nonatomic, copy) TPickImageWithUrlBlock pickImageWithUrlBlock;

@property (nonatomic, copy) TPickVideoWithUrlBlock pickVideoWithUrlBlock;

@end

@implementation EBController

+ (EBController *)sharedInstance
{
    static EBController *_sharedInstance = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (UINavigationController *)currentNavigationController
{
    if (_mainTabViewController)
    {
        if (_mainTabViewController.presentedViewController)
        {
            return (UINavigationController *)_mainTabViewController.presentedViewController;
        }
        else
        {
            return (UINavigationController *)_mainTabViewController.selectedViewController;
        }
    }
    else
    {
       return (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    }
}

- (void)promptChoices:(NSArray *)items
      withRightChoice:(NSInteger)rightChoice
           leftChoice:(NSInteger)leftChoice
                title:(NSString *)title
           completion:(void (^)(NSInteger, NSInteger))completion
{
    SingleChoiceViewController *controller = [[SingleChoiceViewController alloc] init];
    controller.title = title;
    controller.singleChoiceView.rightIndex = rightChoice;
    controller.singleChoiceView.leftIndex = leftChoice;
    controller.singleChoiceView.title = title;
    controller.singleChoiceView.choices = items;
    controller.singleChoiceView.makeChoice = ^(NSInteger rChoice, NSInteger lChoice){
        completion(rChoice, lChoice);
        [[self currentNavigationController] popViewControllerAnimated:YES];
    };
    controller.hidesBottomBarWhenPushed = YES;
    [[self currentNavigationController] pushViewController:controller animated:YES];
}

- (void)promptChoices:(NSArray *)items
      withRightChoice:(NSInteger)rightChoice
           leftChoice:(NSInteger)leftChoice
                title:(NSString *)title
            houseType:(NSInteger)houseType
           completion:(void (^)(NSInteger, NSInteger))completion
{
    SingleChoiceViewController *controller = [[SingleChoiceViewController alloc] init];
    controller.title = title;
    controller.singleChoiceView.rightIndex = rightChoice;
    controller.singleChoiceView.leftIndex = leftChoice;
    controller.singleChoiceView.houseType = houseType;
    controller.singleChoiceView.title = title;
    controller.singleChoiceView.choices = items;
    controller.singleChoiceView.makeChoice = ^(NSInteger rChoice, NSInteger lChoice){
        completion(rChoice, lChoice);
        [[self currentNavigationController] popViewControllerAnimated:YES];
    };
    controller.hidesBottomBarWhenPushed = YES;
    [[self currentNavigationController] pushViewController:controller animated:YES];
}

- (void)promptChoices:(NSArray *)items
      withRightChoice:(NSInteger)rightChoice
           leftChoice:(NSInteger)leftChoice
                title:(NSString *)title
            houseType:(NSInteger)houseType
             hidezero:(BOOL)hidezero
           completion:(void (^)(NSInteger, NSInteger))completion
{
    SingleChoiceViewController *controller = [[SingleChoiceViewController alloc] init];
    controller.title = title;
    controller.singleChoiceView.hideRowZero = hidezero;
    controller.singleChoiceView.rightIndex = rightChoice;
    controller.singleChoiceView.leftIndex = leftChoice;
    controller.singleChoiceView.houseType = houseType;
    controller.singleChoiceView.title = title;
    controller.singleChoiceView.choices = items;
    controller.singleChoiceView.makeChoice = ^(NSInteger rChoice, NSInteger lChoice){
        completion(rChoice, lChoice);
        [[self currentNavigationController] popViewControllerAnimated:YES];
    };
    controller.hidesBottomBarWhenPushed = YES;
    [[self currentNavigationController] pushViewController:controller animated:YES];
}

- (void)promptChoices:(NSArray *)items withChoice:(NSInteger)choice
                title:(NSString *)title footer:(NSString *)footerStr completion:(void (^)(NSInteger))completion
{
    [self promptChoices:items withChoice:choice title:title header:nil footer:footerStr completion:completion];
}

- (void)promptChoices:(NSArray *)items withChoice:(NSInteger)choice
                title:(NSString *)title header:(NSString *)headerStr footer:(NSString *)footerStr completion:(void (^)(NSInteger))completion
{
    SingleChoiceViewController *controller = [[SingleChoiceViewController alloc] init];
    controller.title = title;
    controller.singleChoiceView.rightIndex = choice;
    controller.singleChoiceView.choices = items;
    controller.singleChoiceView.footerText = footerStr;
    controller.singleChoiceView.headerText = headerStr;
    controller.singleChoiceView.makeChoice = ^(NSInteger rChoice, NSInteger lChoice){
        completion(rChoice);
        [[self currentNavigationController] popViewControllerAnimated:YES];
    };

    controller.hidesBottomBarWhenPushed = YES;
    [[self currentNavigationController] pushViewController:controller animated:YES];
}

- (HouseListViewController *)showHouseListWithType:(EHouseListType)listType filter:(EBFilter *)filter title:(NSString *)title client:(EBClient*)client
{
    HouseListViewController *controller = [[HouseListViewController alloc] init];
    controller.listType = listType;
    controller.filter = filter;
    controller.title = title;
    controller.hidesBottomBarWhenPushed = YES;
    controller.client = client;

    [[self currentNavigationController] pushViewController:controller animated:YES];

    return controller;
}

- (GatherHouseListViewController *)showGatherHouseListWithType:(EGatherHouseListType)listType filter:(EBFilter *)filter title:(NSString *)title
{
    GatherHouseListViewController *controller = [[GatherHouseListViewController alloc] init];
    controller.listType = listType;
    controller.filter = filter;
    controller.title = title;
    controller.hidesBottomBarWhenPushed = YES;
    
    [[self currentNavigationController] pushViewController:controller animated:YES];
    
    return controller;
}

- (ClientListViewController *)showClientListWithType:(EClientListType)listType filter:(EBFilter *)filter title:(NSString *)title house:(EBHouse*)house
{
    ClientListViewController *controller = [[ClientListViewController alloc] init];
    controller.listType = listType;
    controller.filter = filter;
    controller.title = title;
    controller.hidesBottomBarWhenPushed = YES;
    if (house)
    {
        controller.houses = @[house];
    }

    [[self currentNavigationController] pushViewController:controller animated:YES];

    return controller;
}

- (void)hideTabBar
{
   _mainTabViewController.tabBar.hidden = YES;
}

- (void)showTabBar
{
    _mainTabViewController.tabBar.hidden = NO;
}

- (void)showClientDetail:(EBClient *)client
{
    ClientDetailViewController *viewController = [[ClientDetailViewController alloc] init];
    viewController.clientDetail = client;
    viewController.pageOpenType = EClientDetailOpenTypeCommon;
    viewController.hidesBottomBarWhenPushed = YES;

    [[self currentNavigationController] pushViewController:viewController animated:YES];
}

//lwl
- (void)showJuHePay:(NSDictionary *)dic{
    
}

- (void)showClientDetailBackRoot:(EBClient *)client
{
    ClientDetailViewController *viewController = [[ClientDetailViewController alloc] init];
    viewController.clientDetail = client;
    viewController.pageOpenType = EClientDetailOpenTypeAdd;
    viewController.hidesBottomBarWhenPushed = YES;
    
    [[self currentNavigationController] pushViewController:viewController animated:YES];
}

//房源接口
- (void)showHouseDetail:(EBHouse *)house{
    HouseDetailViewController *viewController = [[HouseDetailViewController alloc] init];
    viewController.houseDetail = house;
    viewController.pageOpenType = EHouseDetailOpenTypeCommon;
    viewController.hidesBottomBarWhenPushed = YES;
    [[self currentNavigationController] pushViewController:viewController animated:YES];
}

- (GatherHouseDetailViewController *)showGatherHouseDetail:(EBGatherHouse *)house
{
    GatherHouseDetailViewController *viewController = [[GatherHouseDetailViewController alloc] init];
    viewController.house = house;
    viewController.hidesBottomBarWhenPushed = YES;
    [[self currentNavigationController] pushViewController:viewController animated:YES];
    return viewController;
}


- (void)showHouseDetailBackRoot:(EBHouse *)house uploadTag:(BOOL)isUplaodForNewHouse openType:(EHouseDetailOpenType)openType
{
    HouseDetailViewController *viewController = [[HouseDetailViewController alloc] init];
    viewController.houseDetail = house;
    viewController.isUplaodForNewHouse = isUplaodForNewHouse;
    viewController.pageOpenType = openType;
    viewController.hidesBottomBarWhenPushed = YES;
    
    [[self currentNavigationController] pushViewController:viewController animated:YES];
}

- (void)showCustomCondition:(EBCondition *)condition customType:(ECustomConditionViewType)customType
{
    CustomConditionViewController *viewController = [[CustomConditionViewController alloc] init];
    viewController.condition = condition;
    viewController.customType = customType;
    viewController.hidesBottomBarWhenPushed = YES;

    [[self currentNavigationController] pushViewController:viewController animated:YES];
}

- (void)showCalculator:(NSDictionary *)info
{
    [self openURL:[NSURL URLWithString:BEAVER_Calculator]];
//    CalculatorViewController *viewController = [[CalculatorViewController alloc] init];
//    viewController.userInfo = info;
//    viewController.isOpenByTool = NO;
//
//    viewController.hidesBottomBarWhenPushed = YES;
//    [[self currentNavigationController] pushViewController:viewController animated:YES];
}

- (void)showQRCodeScannerWithType:(EQRCodeType)type completion:(void(^)(NSString *result))completion
{
    QRScannerViewController *viewController = [[QRScannerViewController alloc] init];
//    viewController.codeType = type;
//    viewController.finishScan = completion;

    viewController.hidesBottomBarWhenPushed = YES;
    [[self currentNavigationController] pushViewController:viewController animated:YES];
}

- (InputOrScanViewController *)showInputWithFilter:(NSArray *)filter completion:(void(^)(NSDictionary *result))completion
{
    InputOrScanViewController *viewController = [[InputOrScanViewController alloc] init];
    viewController.outputBlock = completion;
    viewController.filters = filter;

    viewController.hidesBottomBarWhenPushed = YES;

    return viewController;
}

- (void)showPopUpView
{
//    UIActivity *activity =[[UIActivity alloc] init];
//    [activity ]
//
//    UIView *popView = [[UIView alloc] initWithFrame:_mainTabViewController.view.bounds];
//    popView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
//
//    [_mainTabViewController.view addSubview:popView];
}

- (void)shareItemWith:(NSString *)url image:(UIImage *)image text:(NSString *)text
{
//     [self dismissPopUpView];
//    NSArray *activityItems = @[text, image, [[NSURL alloc] initWithString:url]];
//
//    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems
//                                                                            applicationActivities:nil];
//
//    activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
//            UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList];
//
//    [_mainTabViewController presentViewController:activityVC animated:TRUE completion:nil];

//    SendShareViewController *viewController = [[SendShareViewController alloc] init];
//    viewController.text = text;
//    viewController.url = url;
//    viewController.image = image;
//    viewController.hidesBottomBarWhenPushed = YES;

//    [[self currentNavigationController] pushViewController:viewController animated:YES];
}

//分享房源
- (SnsViewController *)shareHouses:(NSArray *)houses handler:(void(^)(BOOL success, NSDictionary *info))handler
{

//    [self shareItemWith:@"http://baidu.com" image:[UIImage imageNamed:@"nav_btn_add"] text:@"hahaha"];
    static SnsViewController *viewController = nil;
    if (viewController == nil)
    {
        viewController = [[SnsViewController alloc] init];
    }
    viewController.shareItems = houses;
    viewController.shareType = EBShareTypeHouse;
    viewController.shareHandler = handler;
    [_mainTabViewController presentPopupViewController:viewController animationType:MJPopupViewAnimationSlideBottomBottom
                                       destinationType:MJPopupViewDestinationBottom];

    return viewController;
}


//分享客户
- (void)shareClients:(NSArray *)clients
{
//    [self shareItemWith:@"http://baidu.com" image:[UIImage imageNamed:@"nav_btn_add"] text:@"hahaha"];
    static SnsViewController *viewController = nil;
    if (viewController == nil)
    {
        viewController = [[SnsViewController alloc] init];
    }

    viewController.shareItems = clients;
    viewController.shareType = EBShareTypeClient;
    [_mainTabViewController presentPopupViewController:viewController animationType:MJPopupViewAnimationSlideBottomBottom
                                       destinationType:MJPopupViewDestinationBottom];
}

- (SnsViewController *)shareNewHouses:(NSArray *)houses handler:(void(^)(BOOL success, NSDictionary *info))handler
{
    static SnsViewController *viewController = nil;
    if (viewController == nil)
    {
        viewController = [[SnsViewController alloc] init];
    }
    viewController.shareType = EBShareTypeNewHouse;
    viewController.shareItems = houses;
    viewController.shareHandler = handler;
    [_mainTabViewController presentPopupViewController:viewController animationType:MJPopupViewAnimationSlideBottomBottom
                                       destinationType:MJPopupViewDestinationBottom];
    return viewController;
}

- (void)recommendHouses:(NSArray *)houses toClient:(EBClient *)client completion:(void(^)(BOOL success, NSDictionary *info))handler
{
    static RecommendViewController *viewController = nil;
    if (viewController == nil)
    {
        viewController = [[RecommendViewController alloc] init];
    }
    viewController.tagHouseOrVisit = 0;
    viewController.client = client;
    viewController.sendDataArray = houses;
    viewController.completionHandler = handler;
    [_mainTabViewController presentPopupViewController:viewController animationType:MJPopupViewAnimationSlideBottomBottom
                                       destinationType:MJPopupViewDestinationBottom];
}

- (void)recommendVisit:(NSArray *)visitLogs toClient:(EBClient *)client completion:(void(^)(BOOL success, NSDictionary *info))handler
{
    static RecommendViewController *viewController = nil;
    if (viewController == nil)
    {
        viewController = [[RecommendViewController alloc] init];
    }
    viewController.tagHouseOrVisit = 1;
    viewController.client = client;
    viewController.sendDataArray = visitLogs;
    viewController.completionHandler = handler;
    [_mainTabViewController presentPopupViewController:viewController animationType:MJPopupViewAnimationSlideBottomBottom
                                       destinationType:MJPopupViewDestinationBottom];
}

- (void)pickImageWithSourceType:(UIImagePickerControllerSourceType)type handler:(void(^)(UIImage *image))handler
{
    dispatch_block_t imagePickBlock = ^(){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.view.tag = EPickImageForIM;
        picker.delegate = self;
        self.pickImageBlock = handler;
        picker.sourceType = type;
        [_mainTabViewController presentViewController:picker animated:YES completion:^(){
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    };
    if (type == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"user_setavatar_camera_restrict_tip", nil) yes:NSLocalizedString(@"confirm", nil) confirm:nil];
            return;
        }
        else if (authStatus == AVAuthorizationStatusNotDetermined)
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        imagePickBlock();
                    }
                });
            }];
            return;
        }
        imagePickBlock();
    }
    else
    {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"user_setavatar_album_restrict_tip", nil) yes:NSLocalizedString(@"confirm", nil) confirm:nil];
            return;
        }
        imagePickBlock();
    }
}

//pickImageWithUrlBlock
- (void)pickImageWithUrlSourceType:(UIImagePickerControllerSourceType)type handler:(void(^)(UIImage *image, NSURL *url))handler
{
    dispatch_block_t imagePickBlock = ^(){
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.view.tag = EPickImageForHouse;
            self.pickImageWithUrlBlock = handler;
            picker.sourceType = type;
            picker.allowsEditing = YES;
            //    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
            //    picker.allowsEditing = YES;
            [_mainTabViewController presentViewController:picker animated:YES completion:^(){
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
        }
    };
    if (type == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"user_setavatar_camera_restrict_tip", nil) yes:NSLocalizedString(@"confirm", nil) confirm:nil];
            return;
        }
        else if (authStatus == AVAuthorizationStatusNotDetermined)
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        imagePickBlock();
                    }
                });
            }];
            return;
        }
        imagePickBlock();
    }
    else
    {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"user_setavatar_album_restrict_tip", nil) yes:NSLocalizedString(@"confirm", nil) confirm:nil];
            return;
        }
        imagePickBlock();
    }
}

- (void)pickImageWithUrlSourceTypeEx:(UIImagePickerControllerSourceType)type curentViewController:(id)curentViewController handler:(void(^)(UIImage *image, NSURL *url))handler
{
    dispatch_block_t imagePickBlock = ^(){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.view.tag = EPickImageForHouse;
        self.pickImageWithUrlBlock = handler;
        picker.sourceType = type;
        picker.allowsEditing = YES;
        //    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil];
        //    picker.allowsEditing = YES;
        if (curentViewController)
        {
            [curentViewController presentViewController:picker animated:YES completion:^(){
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
        }
    };
    if (type == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"user_setavatar_camera_restrict_tip", nil) yes:NSLocalizedString(@"confirm", nil) confirm:nil];
            return;
        }
        else if (authStatus == AVAuthorizationStatusNotDetermined)
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        imagePickBlock();
                    }
                });
            }];
            return;
        }
        imagePickBlock();
    }
    else
    {
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied) {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"user_setavatar_album_restrict_tip", nil) yes:NSLocalizedString(@"confirm", nil) confirm:nil];
            return;
        }
        imagePickBlock();
    }
}

- (void)pickVideoWithUrlSourceTypeEx:(UIImagePickerControllerSourceType)type curentViewController:(id)curentViewController handler:(void(^)(NSURL *sourceUrl))handler
{
    dispatch_block_t imagePickBlock = ^(){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.view.tag = EPickVideoForHouse;
        self.pickVideoWithUrlBlock = handler;
        picker.sourceType = type;
        NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        picker.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];
        picker.allowsEditing = YES;
        picker.videoMaximumDuration = 60.0;
        if (curentViewController)
        {
            [curentViewController presentViewController:picker animated:YES completion:^(){
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
        }
    };
    if (type == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"user_setavatar_camera_restrict_tip", nil) yes:NSLocalizedString(@"confirm", nil) confirm:nil];
            return;
        }
        else if (authStatus == AVAuthorizationStatusNotDetermined)
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (granted) {
                        imagePickBlock();
                    }
                });
            }];
            return;
        }
        imagePickBlock();
    }
}

- (void)pickLocationWithBlock:(void(^)(NSDictionary *))block  pickBySend:(BOOL)bySend
{
    EBLocationPickerViewController *locationPicker = [[EBLocationPickerViewController alloc] init];
    locationPicker.selectBlock = block;
    locationPicker.withSend = bySend;
    locationPicker.hidesBottomBarWhenPushed = YES;

    EBNavigationController *nav = [[EBNavigationController alloc] initWithRootViewController:locationPicker];
    [self.currentNavigationController.topViewController presentViewController:nav animated:YES completion:^
    {

    }];
}

//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//
////    viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
////            initWithTitle:@" "
////                    style:UIBarButtonItemStyleBordered
////                   target:nil
////                   action:nil];
//}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIImage *selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (picker.view.tag == EPickImageForIM)
    {
        [picker dismissViewControllerAnimated:YES completion:^{
            if (self.pickImageBlock)
            {
                self.pickImageBlock(selectedImage);
            }
        }];
    }
    else if (picker.view.tag == EPickImageForHouse)
    {
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
            [library writeImageToSavedPhotosAlbum:[selectedImage CGImage] orientation:(ALAssetOrientation)[selectedImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
                //        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
                NSURL *url = assetURL;
                [picker dismissViewControllerAnimated:YES completion:^{
                    if (self.pickImageWithUrlBlock)
                    {
                        self.pickImageWithUrlBlock(selectedImage, url);
                    }
                }];
            }];
        }
    } else if (picker.view.tag == EPickVideoForHouse) {
        [picker dismissViewControllerAnimated:YES completion:^{
            NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
            self.pickVideoWithUrlBlock(sourceURL);
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc]init];
//            [library writeVideoAtPathToSavedPhotosAlbum:sourceURL completionBlock:^(NSURL *assetURL, NSError *error) {
//                            self.pickVideoWithUrlBlock(assetURL);
//            }];
        }];
        
    }
}


#pragma mark -

- (void)dismissPopUpView:(void(^)())completion
{
    [_mainTabViewController dismissPopupViewControllerWithAnimationType:MJPopupViewAnimationSlideBottomBottom completion:completion];
}


- (ChatViewController *)startChattingWith:(NSArray *)contacts popToConversation:(BOOL)pop
{
    EBIMConversation *cvsn = [[EBIMConversation alloc] init];
    if (contacts.count == 1)
    {
        EBContact *contact = contacts[0];
        cvsn.objId = contact.userId;
        cvsn.chatContact = contact;
        cvsn.type = [EBIMConversation typeByObjectId:cvsn.objId];
        cvsn.id = [[EBIMManager sharedInstance] getConversationId:contact.userId type:cvsn.type];

        return [[EBController sharedInstance] openConversation:cvsn popToConversation:pop];
    }
    else
    {
        [EBAlert showLoading:NSLocalizedString(@"loading", nil)];
        NSMutableArray *groupContacts = [[NSMutableArray alloc] initWithArray:contacts];
        if (![groupContacts containsObject:[[EBContactManager sharedInstance] myContact]])
        {
            [groupContacts insertObject:[[EBContactManager sharedInstance] myContact] atIndex:0];
        }
        [[EBIMManager sharedInstance] createGroupWithMembers:groupContacts handler:^(BOOL success, NSDictionary *info)
        {
            if (success)
            {
                EBIMGroup *group = info[@"group"];
                cvsn.objId = group.globalId;
                cvsn.chatGroup = group;
                cvsn.type = EConversationTypeGroup;
                cvsn.id = [[EBIMManager sharedInstance] getConversationId:group.globalId type:cvsn.type];
                [[EBController sharedInstance] openConversation:cvsn popToConversation:pop];
            }
            else
            {

            }
            [EBAlert hideLoading];
        }];

        return nil;
    }
}

- (ChatViewController *)openGroupChat:(EBIMGroup *)group popToConversation:(BOOL)pop
{
    EBIMConversation *cvsn = [[EBIMConversation alloc] init];
    cvsn.objId = group.globalId;
    cvsn.chatGroup = group;
    cvsn.type = EConversationTypeGroup;
    cvsn.receiveNotify = [[EBIMManager sharedInstance] notifyState:cvsn.objId];
    cvsn.id = [[EBIMManager sharedInstance] ensureConversationExist:cvsn.objId converstaionType:EConversationTypeGroup];
    return [[EBController sharedInstance] openConversation:cvsn popToConversation:pop];
}

- (ChatViewController *)openConversation:(EBIMConversation *)cvsn  popToConversation:(BOOL)pop
{
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.conversation = cvsn;
    chatViewController.hidesBottomBarWhenPushed = YES;

//    if (pop)
//    {
//        [self.currentNavigationController popToRootViewControllerAnimated:NO];
//        _mainTabViewController.selectedIndex = 2;
//    }
    NSUInteger messageIndex=2;
    
    UINavigationController *oldNavCtrl = nil;
    if (_mainTabViewController.selectedIndex != messageIndex) {
        oldNavCtrl = self.currentNavigationController;
    }
    _mainTabViewController.selectedIndex = messageIndex;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (oldNavCtrl) {
            NSMutableArray *tempAry = [[NSMutableArray alloc] init];
            [tempAry addObject:oldNavCtrl.viewControllers[0]];
            [oldNavCtrl setViewControllers:tempAry];
        }
        NSMutableArray *controllerArr = [[NSMutableArray alloc] init];
        [controllerArr addObject:self.currentNavigationController.viewControllers[0]];
        [self.currentNavigationController setViewControllers:controllerArr];
        [self.currentNavigationController pushViewController:chatViewController animated:YES];
    });

//    [self.currentNavigationController pushViewController:chatViewController animated:YES];
//    
//    NSMutableArray *controllerArr = [[NSMutableArray alloc] initWithArray:chatViewController.navigationController.viewControllers];
//    if (controllerArr.count > 2) {
//        NSMutableArray *newControllerArr = [[NSMutableArray alloc] init];
//        [newControllerArr addObject:controllerArr.firstObject];
//        [newControllerArr addObject:controllerArr.lastObject];
//        [chatViewController.navigationController setViewControllers:newControllerArr];
//    }
    
    
//
//    if (cvsn.id > 0)
//    {
//       [[EBIMManager sharedInstance] clearUnread:cvsn.id];
//    }

    return chatViewController;
}

- (EBWebViewController *)openWebViewWithUrl:(NSURL *)url
{
    return [self openWebViewWithRequest:[[NSURLRequest alloc] initWithURL:url]];
}

- (void)showLocationInMap:(NSDictionary *)poiInfo showKeywordLocation:(BOOL)showKeywordLocation
{
    EBMapViewController *viewController = [[EBMapViewController alloc] init];
    viewController.poiInfo = poiInfo;

    viewController.mapType = showKeywordLocation ? EMMapViewTypeByKeyword : EMMapViewTypeByCoordinate;
    [self.currentNavigationController pushViewController:viewController animated:YES];
}

- (void)openURL:(NSURL*)url
{
    NSString *scheme = url.scheme;

    if ([scheme isEqualToString:@"mailto"])
    {
        NSString *mailTo = url.absoluteString;
        NSString *mailAddress = mailTo;
        if ([mailAddress rangeOfString:@"mailto:"].length > 0)
        {
            mailAddress = [mailAddress substringFromIndex:7];
        }

        [[ShareManager sharedInstance] shareContent:@{@"to":mailAddress}
                                           withType:EShareTypeMail handler:^(BOOL success, NSDictionary *info)
        {

        }];
    }
    else if ([scheme isEqualToString:@"tel"] || [scheme isEqualToString:@"sms"])
    {
        NSString *phone = [url.absoluteString substringFromIndex:scheme.length + 1];
        NSMutableArray *buttons = [[NSMutableArray alloc] init];

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

        [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.mainTabViewController.view];
    }
    else if ([scheme rangeOfString:@"http"].length > 0)
    {
        [self openWebViewWithUrl:url];
    }
}

- (EBWebViewController *)openWebViewWithRequest:(NSURLRequest *)request
{
    EBWebViewController *webViewController = [[EBWebViewController alloc] init];
    webViewController.hidesBottomBarWhenPushed = YES;
    webViewController.request = request;

    [[self currentNavigationController] pushViewController:webViewController animated:YES];

    return webViewController;
}

- (GatherViewController *)openGatherView:(EGatherViewType)viewType
{
    GatherViewController *viewController = [[GatherViewController alloc] init];
    viewController.viewType = viewType;
    EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:viewController];
    [self.mainTabViewController presentViewController:naviController animated:YES completion:nil];
    return viewController;
}

- (PublishHouseRecordViewController *)openPublishRecordView
{
    PublishHouseRecordViewController *viewController = [[PublishHouseRecordViewController alloc] init];
    [[self currentNavigationController] pushViewController:viewController animated:YES];
    return viewController;
}

- (void)viewImagesFromMsg:(NSInteger)msgId inConversation:(NSInteger)cvsnId
{
   NSArray *messages = [[EBIMManager sharedInstance] messagesByType:EMessageContentTypeImage inConversation:cvsnId];
   NSInteger currentIdx = 0;
   NSMutableArray *imageArray = [[NSMutableArray alloc] init];
   for (NSInteger i = 0; i < messages.count; i++)
   {
      EBIMMessage *msg = messages[i];
      if (msg.id == msgId)
      {
          currentIdx = i;
      }
      NSString *url = msg.content[@"url"];
      if (!url)
      {
          url = msg.content[@"local"];
      }
      [imageArray addObject:[[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:url]]];
   }

    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:imageArray];
    FSImageViewerViewController *controller = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:currentIdx];

    [self.currentNavigationController pushViewController:controller animated:YES];
}
//发送通知
+ (void)broadcastNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
//对于某个通知增加一个观察者
+ (void)observeNotification:(NSString *)notificationName from:(id)observer  selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:notificationName object:nil];
}
//账号登陆(通知)
+ (void)accountLoggedIn
{
    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_LOGIN object:nil]];
}

+ (void)accountLoggedIn:(UIViewController *)view{
     [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_LOGIN object:view]];
}

//验证码验证
+ (void)accountVerifyCodeLoggedOut
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    if ([pref isTokenValid])
    {
        [[EBHttpClient sharedInstance] accountRequest:nil logout:^(BOOL success, id result)
         {
             [EBAlert hideLoading];
             if (success)
             {
                 [[EBCache sharedInstance] clearDataWhenLogOut];
                 [[ERPWebViewController sharedInstance] cleanCache];
                 [self accountDataReset];
             }
         }];
    }
    else
    {
        [self accountDataReset];
    }
    
}
//账号登出
+ (void)accountLoggedOut
{
    [EBAlert showLoading:nil];
    EBPreferences *pref = [EBPreferences sharedInstance];
    if ([pref isTokenValid])
    {
        [[EBHttpClient sharedInstance] accountRequest:nil logout:^(BOOL success, id result)
        {
            [EBAlert hideLoading];
            if (success)
            {
                [[EBCache sharedInstance] clearDataWhenLogOut];
                [[ERPWebViewController sharedInstance] cleanCache];
                [self accountDataReset];
            }
        }];
    }
    else
    {
        [self accountDataReset];
    }

}

+(void)accountDataReset
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    [pref resetPref];
    [[EBXMPP sharedInstance] logout];
    [[EBIMManager sharedInstance] closeDB];
    [EBController broadcastNotification:[NSNotification notificationWithName:NOTIFICATION_LOGOUT object:nil]];
}

- (void)promptNoneImageMode:(void(^)())completion
{
    EBNoneImageModeAlertView *alertView = [[EBNoneImageModeAlertView alloc] init];

    alertView.completion = completion;

    [alertView show];
}

- (void)showAnonymousCallAlert:(void(^)())completion type:(BOOL)isHouse detail:(id)detail page:(NSInteger)pageType
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    if (!pref.rememberAnonymousNavChoice)
    {
        AnonymousCallViewController *viewController = [[AnonymousCallViewController alloc] init];
        viewController.pageType = pageType;
        viewController.isHouse = isHouse;
        if (isHouse)
        {
            viewController.house = (EBHouse *)detail;
        }
        else
        {
            viewController.client = (EBClient *)detail;
        }
        [[self currentNavigationController] pushViewController:viewController animated:YES];
    }
    else
    {
        [EBAlert showLoading:NSLocalizedString(@"", nil)];
        if (isHouse)
        {
            EBHouse *house = (EBHouse *) detail;
            NSDictionary *params = @{@"id":house.id, @"type": [EBFilter typeString:house.rentalState],@"contract_code":house.contractCode};
            [[EBHttpClient sharedInstance] houseAnonymousCallRequest:params handler:^(BOOL success, id result)
            {
                [EBAlert hideLoading];
                //                 success = true;
                if (success)
                {
                    NSString *title = nil;
                    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                        if (title == nil) {
                            title = @"";
                        }
                    }
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"anonymous_call_end_title", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"anonymous_call_end_confirm", nil) otherButtonTitles:nil];
                    [alertView show];
                }
            }];
        }
        else
        {
            EBClient *client = (EBClient *) detail;
            NSDictionary *params = @{@"id":client.id, @"type": [EBFilter typeString:client.rentalState],@"contract_code":client.contractCode};
            [[EBHttpClient sharedInstance] clientAnonymousCallRequest:params handler:^(BOOL success, id result)
            {
                [EBAlert hideLoading];
                //                 success = true;
                if (success)
                {
                    NSString *title = nil;
                    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                        if (title == nil) {
                            title = @"";
                        }
                    }
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"anonymous_call_end_title", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"anonymous_call_end_confirm", nil) otherButtonTitles:nil];
                    [alertView show];
                }
            }];
        }
    }
}

- (void)showAnonymousCallWnd:(void(^)())completion type:(NSInteger)type num:(NSString*)num
{
    AnonymousCallViewController *viewController = [[AnonymousCallViewController alloc] init];
    viewController.pageType = type;
    viewController.anonymousNum = num;
    [self.currentNavigationController pushViewController:viewController animated:YES];
}

- (void)promptChangeNumberInView:(UIView *)view withVerifySuccess:(void(^)())handler
{
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"anonymous_phone_set_mobile", nil)
                action:^
                {
                    AnonymousNumSetViewController *viewController = [[AnonymousNumSetViewController alloc] init];
                    viewController.setType = ESetTypeMobile;
                    viewController.phoneVerifySuccess = handler;
                    [self.currentNavigationController pushViewController:viewController animated:YES];
                }]];

    if ([EBPreferences sharedInstance].enableExtensionNumber)
    {
        [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"anonymous_phone_set_fix_1", nil)
                    action:^
                    {
                        AnonymousNumSetViewController *viewController = [[AnonymousNumSetViewController alloc] init];
                        viewController.setType = ESetTypeFix;
                        viewController.phoneVerifySuccess = handler;
                        [self.currentNavigationController pushViewController:viewController animated:YES];
                    }]];
    }

    [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"anonymous_phone_set_fix_2", nil)
                action:^
                {
                    AnonymousNumSetViewController *viewController = [[AnonymousNumSetViewController alloc] init];
                    viewController.setType = ESetTypeFixSingle;
                    viewController.phoneVerifySuccess = handler;
                    [self.currentNavigationController pushViewController:viewController animated:YES];
                }]];
    [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"anonymous_phone_choose_title", nil) buttons:buttons] showInView:view];
}

- (void)showProfile:(EBContact *)contact
{
    ProfileViewController *viewController = [[ProfileViewController alloc] init];
    viewController.contact = contact;
    viewController.hidesBottomBarWhenPushed = YES;

    [self.currentNavigationController pushViewController:viewController animated:YES];
}

- (void)promptInputWithText:(NSString *)text title:(NSString *)title block:(void(^)(NSString *inputString))inputBlock
{
    EBInputViewController *viewController = [[EBInputViewController alloc] init];

    viewController.value = text;
    viewController.placeholder = NSLocalizedString(@"im_group_name_pl", nil);
    viewController.confirmInputBlock = inputBlock;
    viewController.title = title;

    [self.currentNavigationController pushViewController:viewController animated:YES];
//    [self.currentNavigationController pushViewController:viewController animated:YES completion:nil];
}

- (void)showPopOverListView:(id)sender choices:(NSArray *)choices block:(void(^)(NSInteger selectedIndex)) selectedBlock
{
    CommonTableViewController *tableViewController = [[CommonTableViewController alloc] init];
    tableViewController.dataSourceArray = choices;
    
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:tableViewController];
    popover.tint = FPPopoverWhiteTint;
    popover.border = NO;
    popover.arrowDirection = FPPopoverNoArrow;
    popover.contentSize = CGSizeMake(200, choices.count * 44 + 20);
    [popover setShadowsHidden:YES];
    tableViewController.selectedTableRow =^(NSInteger selectedIndex){
        [popover dismissPopoverAnimated:YES];
        if (selectedBlock)
        {
            selectedBlock(selectedIndex);
        }
    };
    [popover presentPopoverFromNavigationBtn:sender];
}

- (void)showPopOverListView:(id)sender choices:(NSArray *)choices delegate:(id)delegate
{
    CommonTableViewController *tableViewController = [[CommonTableViewController alloc] init];
    tableViewController.dataSourceArray = choices;
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:tableViewController];
    popover.tint = FPPopoverWhiteTint;
    popover.border = NO;
    popover.arrowDirection = FPPopoverNoArrow;
    popover.contentSize = CGSizeMake(200, choices.count * 44 + 20);
    [popover setShadowsHidden:YES];
    popover.delegate = delegate;
    [popover presentPopoverFromNavigationBtn:sender];
}

- (void)showFilingDetailView
{
    FilingDetailViewController *viewController = [[FilingDetailViewController alloc] init];
    [[self currentNavigationController] pushViewController:viewController animated:YES];
}

- (EBHouse*)refreshHouseDetailWhenEdited:(id)target
{
    __block EBHouse *house = nil;
    if ([target isKindOfClass:[HouseEditFirstStepViewController class]]) {
        HouseEditFirstStepViewController *temp = (HouseEditFirstStepViewController*)target;
        house = temp.house;
    }
    else if ([target isKindOfClass:[HouseAddSecondStepViewController class]])
    {
        HouseAddSecondStepViewController *temp = (HouseAddSecondStepViewController*)target;
        house = temp.house;
    }
    else if ([target isKindOfClass:[HouseAddViewController class]])
    {
        HouseAddViewController *temp = (HouseAddViewController*)target;
        house = temp.house;
    }
    [[EBHttpClient sharedInstance] houseRequest:@{@"id":house.id, @"force_refresh":@(YES),
                                                  @"type":[EBFilter typeString:house.rentalState]}
                                         detail:^(BOOL success, id result){
                                             [EBAlert hideLoading];
                                             if (success)
                                             {
                                                 house = result;
                                                 [[EBCache sharedInstance] updateCacheByViewHouseDetail:house];
                                                 id viewController = [[self currentNavigationController].viewControllers objectAtIndex:[[self currentNavigationController].viewControllers count] - 3];
                                                 if ([viewController isKindOfClass:[HouseDetailViewController class]])
                                                 {
                                                     HouseDetailViewController *temp = (HouseDetailViewController*)viewController;
                                                     temp.houseDetail = result;
//                                                     dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
//                                                                    {
//                                                                        [[self currentNavigationController] popToViewController:temp animated:YES];
//                                                                    });
                                                     
                                                 }
                                             }
                                             [EBAlert alertSuccess:NSLocalizedString(@"house_edit_alert_text_success", nil)];
                                             [[self currentNavigationController] popViewControllerAnimated:YES];
                                         }];
    return house;
}

- (EBClient*)refreshClientDetailWhenEdited:(id)target
{
    __block EBClient *client = nil;
    if ([target isKindOfClass:[ClientEditFirstStepViewController class]]) {
        ClientEditFirstStepViewController *temp = (ClientEditFirstStepViewController*)target;
        client = temp.clientDetail;
    }
    else if ([target isKindOfClass:[ClientAddViewController class]])
    {
        ClientAddViewController *temp = (ClientAddViewController*)target;
        client = temp.client;
    }
    [[EBHttpClient sharedInstance] clientRequest:@{@"id":client.id, @"force_refresh":@(YES),
                                                   @"type":[EBFilter typeString:client.rentalState]}
                                          detail:^(BOOL success, id result)
     {
         [EBAlert hideLoading];
         if (success)
         {
             client = result;
             [[EBCache sharedInstance] updateCacheByViewClientDetail:client];
             id viewController = [[self currentNavigationController].viewControllers objectAtIndex:[[self currentNavigationController].viewControllers count] - 3];
             if ([viewController isKindOfClass:[ClientDetailViewController class]])
             {
                 ClientDetailViewController *temp = (ClientDetailViewController*)viewController;
                 temp.clientDetail = result;
                 //                                                     dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
                 //                                                                    {
                 //                                                                        [[self currentNavigationController] popToViewController:temp animated:YES];
                 //                                                                    });
                 
             }
             [EBAlert alertSuccess:NSLocalizedString(@"client_edit_alert_text_success", nil)];
             [[self currentNavigationController] popViewControllerAnimated:YES];
         }
     }];
    return client;
}

- (BOOL)checkInputNum:(NSString*)num
{
    NSArray *_areaCode = [[NSArray alloc] initWithObjects:@"010",@"021",@"022", @"023",@"0310",@"0311", @"0312", @"0313", @"0314", @"0315", @"0316", @"0317", @"0318", @"0319", @"0335", @"0349", @"0350", @"0351", @"0352", @"0353", @"0354", @"0355", @"0356", @"0357", @"0358", @"0359", @"0470", @"0471", @"0472", @"0473", @"0474", @"0475", @"0476", @"0477", @"0478", @"0479", @"0482", @"0483", @"024", @"0410", @"0411", @"0412", @"0413", @"0414", @"0415", @"0416", @"0417", @"0418", @"0419", @"0421", @"0427", @"0429", @"0431", @"0432", @"0433", @"0434", @"0435", @"0436", @"0437", @"0438", @"0439", @"0440", @"0448", @"0451", @"0452", @"0453", @"0454", @"0455", @"0456", @"0457", @"0458", @"0459", @"0464", @"0467", @"0468", @"0469", @"025", @"0510", @"0511", @"0512", @"0513", @"0514", @"0515", @"0516", @"0517", @"0518", @"0519", @"0523", @"0527", @"0570", @"0571", @"0572", @"0573", @"0574", @"0575", @"0576", @"0577", @"0578", @"0579", @"0580", @"0550", @"0551", @"0552", @"0553", @"0554", @"0555", @"0556", @"0557", @"0558", @"0559", @"0561", @"0562", @"0563", @"0564", @"0565", @"0566", @"0591", @"0592", @"0593", @"0594", @"0595", @"0596", @"0597", @"0598", @"0599", @"0790", @"0791", @"0792", @"0793", @"0794", @"0795", @"0796", @"0797", @"0798", @"0799", @"0701", @"0530", @"0531", @"0532", @"0533", @"0534", @"0535", @"0536", @"0537", @"0538", @"0539", @"0543", @"0546", @"0631", @"0632", @"0633", @"0634", @"0635", @"0370", @"0371", @"0372", @"0373", @"0374", @"0375", @"0376", @"0377", @"0378", @"0379", @"0391", @"0392", @"0393", @"0394", @"0395", @"0396", @"0398", @"027", @"0710", @"0711", @"0712", @"0713", @"0714", @"0715", @"0716", @"0717", @"0718", @"0719", @"0722", @"0724", @"0728", @"0730", @"0731", @"0732", @"0733", @"0734", @"0735", @"0736", @"0737", @"0738", @"0739", @"0743", @"0744", @"0745", @"0746", @"020", @"0660", @"0662", @"0663", @"0668", @"0750", @"0751", @"0752", @"0753", @"0754", @"0755", @"0756", @"0757", @"0758", @"0759", @"0760", @"0762", @"0763", @"0766", @"0768", @"0769", @"0770", @"0771", @"0772", @"0773", @"0774", @"0775", @"0776", @"0777", @"0778", @"0779", @"0898", @"028", @"0812", @"0813", @"0816", @"0817", @"0818", @"0825", @"0826", @"0827", @"0830", @"0831", @"0832", @"0833", @"0834", @"0835", @"0836", @"0837", @"0838", @"0839", @"0851", @"0852", @"0853", @"0854", @"0855", @"0856", @"0857", @"0858", @"0859", @"0691", @"0692", @"0870", @"0871", @"0872", @"0873", @"0874", @"0875", @"0876", @"0877", @"0878", @"0879", @"0883", @"0886", @"0887", @"0888", @"0891", @"0892", @"0893", @"0894", @"0895", @"0896", @"0897", @"029", @"0910", @"0911", @"0912", @"0913", @"0914", @"0915", @"0916", @"0917", @"0919", @"0930", @"0931", @"0932", @"0933", @"0934", @"0935", @"0936", @"0937", @"0938", @"0939", @"0941", @"0943", @"0951", @"0952", @"0953", @"0954", @"0955", @"0970", @"0971", @"0972", @"0973", @"0974", @"0975", @"0976", @"0977", @"0979", @"0901", @"0902", @"0903", @"0906", @"0908", @"0909", @"0990", @"0991", @"0992", @"0993", @"0994", @"0996", @"0997", @"0998", @"0999", nil];
    NSArray *_areaCodeForEight = [[NSArray alloc] initWithObjects:@"010", @"021", @"022", @"023", @"024", @"025", @"027", @"028", @"029", @"020", @"0311", @"0371", @"0377", @"0379", @"0411", @"0451", @"0512", @"0513", @"0516", @"0510", @"0531", @"0532", @"0571", @"0574", @"0577", @"0591", @"0595", @"0755", @"0757", @"0769", nil];
    NSString *compare = @"0123456789";
    NSString *temp;
    for (int i = 0; i < [num length]; i ++)
    {
        temp = [num substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [compare rangeOfString:temp];
        NSInteger location = range.location;
        if (location < 0)
        {
            [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
            return -1;//!请输入正确的号码
        }
    }
    
    if ([num hasPrefix:@"1"] == 1)
    {
        //!mobile
        if (num.length != 11)
        {
            [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
            return NO;//!请输入正确的手机号码
        }
    }
    else
    {
        //!phone
        if (num.length == 10)
        {
            NSString *areaCode =[num substringWithRange:NSMakeRange(0, 3)];
            if (![self isExistInArray:areaCode array:_areaCode])
            {
                //!请输入正确的区号
                [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
                return NO;
            }
            else
            {
                if ([self isExistInArray:areaCode array:_areaCodeForEight])
                {
                    //!请输入正确的座机号
                    [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
                    return NO;
                }
            }
        }
        else if (num.length == 11)
        {
            if ([self isExistInArray:[num substringWithRange:NSMakeRange(0, 3)] array:_areaCode])
            {
                if (![self isExistInArray:[num substringWithRange:NSMakeRange(0, 3)] array:_areaCodeForEight]) {
                    //!请输入正确的座机号
                    [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
                    return NO;
                }
            }
            else if ([self isExistInArray:[num substringWithRange:NSMakeRange(0, 4)] array:_areaCode])
            {
                if ([self isExistInArray:[num substringWithRange:NSMakeRange(0, 4)] array:_areaCodeForEight]) {
                    //!请输入正确的座机号
                    [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
                    return NO;
                }
            }
            else
            {
                //!请输入正确的区号
                [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
                return NO;
            }
        }
        else if (num.length == 12)
        {
            NSString *areaCode =[num substringWithRange:NSMakeRange(0, 4)];
            if (![self isExistInArray:areaCode array:_areaCodeForEight])
            {
                //!请输入正确的电话号码
                [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
                return NO;
            }
        }
        else
        {
            [EBAlert alertError:NSLocalizedString(@"house_add_alert_text_1", nil)];
            return NO;
        }
    }
    
    return YES;
}

- (void)inputErrorShow:(NSString*)message
{
    NSString *title = nil;
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        if (title == nil) {
            title = @"";
        }
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"anonymous_call_end_confirm", nil) otherButtonTitles:nil];
    [alertView show];
}

- (BOOL)isExistInArray:(NSString*)code array:(NSArray*)array
{
    NSInteger arrayCount = [array count];
    int i = 0;
    for (; i < arrayCount; i ++)
    {
        if ([code isEqualToString:array[i]])
        {
            break;
        }
    }
    if (i >= arrayCount)
    {
        return NO;
    }
    return YES;
}
/// 百度坐标转高德坐标
- (CLLocationCoordinate2D)GCJ02FromBD09:(CLLocationCoordinate2D)coor
{
    CLLocationDegrees x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    CLLocationDegrees x = coor.longitude - 0.0065, y = coor.latitude - 0.006;
    CLLocationDegrees z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    CLLocationDegrees theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    CLLocationDegrees gg_lon = z * cos(theta);
    CLLocationDegrees gg_lat = z * sin(theta);
    return CLLocationCoordinate2DMake(gg_lat, gg_lon);
}
// 高德坐标转百度坐标
- (CLLocationCoordinate2D)BD09FromGCJ02:(CLLocationCoordinate2D)coor
{
    CLLocationDegrees x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    CLLocationDegrees x = coor.longitude, y = coor.latitude;
    CLLocationDegrees z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    CLLocationDegrees theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    CLLocationDegrees bd_lon = z * cos(theta) + 0.0065;
    CLLocationDegrees bd_lat = z * sin(theta) + 0.006;
    return CLLocationCoordinate2DMake(bd_lat, bd_lon);
}
//获取加密key
- (NSString *)getEagleKeyWithDate:(NSString *)date
{
    NSString *key  =  @"FLFke8zKb3Q";
    NSString *key1 =  [[CCMD5 md5:[NSString stringWithFormat:@"%@%@",date,key]] substringWithRange:NSMakeRange(3, 8)];
    NSString *key2 =  [[CCMD5 md5:[NSString stringWithFormat:@"%@%@%@",date,key1,key]] substringWithRange:NSMakeRange(4, 5)];
    return key2;
}
@end
