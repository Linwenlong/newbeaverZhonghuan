//
// Created by 何 义 on 14-3-16.
// Copyright (c) 2014 eall. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#define NOTIFICATION_LOGIN @"beaver_login"
#define NOTIFICATION_LOGOUT @"beaver_logout"
#define NOTIFICATION_MESSAGE_RECEIVE @"beaver_msg_receive"
#define NOTIFICATION_SYSTEM_MESSAGE_RECEIVE @"beaver_system_msg_receive"
#define NOTIFICATION_MESSAGE_DELETE @"beaver_msg_delete"
#define NOTIFICATION_MESSAGE_FAILURE_HANDLE @"beaver_handle_failure_msg"
#define NOTIFICATION_MESSAGE_READ @"beaver_msg_read"
#define NOTIFICATION_CONDITION_DELETE @"beaver_condition_delete"
#define NOTIFICATION_CONDITION_UPDATE @"beaver_condition_update"
#define NOTIFICATION_NETWORK_STATUS_CHANGED @"network_status_changed"
#define NOTIFICATION_IM_BUBBLE_SIZE_CHANGED @"im_bubble_size_changed"
#define NOTIFICATION_RECEIVE_REMINDER @"beaver_receive_reminder"
#define NOTIFICATION_INVITE_ADDED @"beaver_invite_added"
#define NOTIFICATION_SHOW_INVITE @"beaver_show_invite"
#define NOTIFICATION_UPLOADING_PHOTO @"beaver_uploading_photo"
#define NOTIFICATION_UPLOADING_PHOTO_PROGRESS @"beaver_uploading_photo_progress_change"
#define NOTIFICATION_UPLOADING_PHOTO_FINISHED @"beaver_uploading_photo_finished"
#define NOTIFICATION_UPLOADING_VIDEO @"beaver_uploading_video"
#define NOTIFICATION_UPLOADING_VIDEO_PROGRESS @"beaver_uploading_video_progress_change"
#define NOTIFICATION_UPLOADING_VIDEO_FINISHED @"beaver_uploading_video_finished"

#define NOTIFICATION_VERSION_FORCE_UPDATE @"beaver_version_force_update"
#define NOTIFICATION_VERSION_UPDATE @"beaver_version_update"
#define NOTIFICATION_VERSION_NO_UPDATE @"beaver_version_no_update"

#define NOTIFICATION_BUSINESS_CONFIG @"beaver_business_config"

#define NOTIFICATION_SUBSCRIPTION_DELETE @"beaver_subscription_delete"
#define NOTIFICATION_SUBSCRIPTION_UPDATE @"beaver_subscription_update"

#define NOTIFICATION_PUBLISH_HOUSE @"beaver_publish_house"

#define NOTIFICATION_GATHER_UNREADCOUNT_CHANGED @"beaver_gather_unreadcount_changed"
#define NOTIFICATION_GATHER_READ @"beaver_gather_read"
#define NOTIFICATION_GATHER_FIND @"beaver_gather_find"
@class MainTabViewController;
@class EBFilter;
@class EBClient;
@class EBHouse;
@class EBCondition;
@class HouseListViewController;
@class ClientListViewController;
@class EBIMConversation;
@class ChatViewController;
@class InputOrScanViewController;
@class SnsViewController;
@class EBContact;
@class ProfileViewController;
@class EBWebViewController;
@class EBIMGroup;
@class EBGatherHouse;
@class GatherHouseListViewController;
@class GatherHouseDetailViewController;
@class GatherViewController;
@class PublishHouseRecordViewController;

typedef NS_ENUM(NSInteger , EHouseDetailOpenType)
{
    EHouseDetailOpenTypeCommon = 1,
    EHouseDetailOpenTypeAdd = 2,
    EHouseDetailOpenTypeGatherToErp = 3
};

typedef NS_ENUM(NSInteger , EHouseListType)
{
    EHouseListTypeSpecial = 1,
    EHouseListTypeSpecialCustom,
    EHouseListTypeMatchHousesForClient,//客户匹配新房
    EHouseListTypeMarkedHousesForClient,
    EHouseListTypeRecommendedHousesForClient,
    EHouseListTypeSearch,
    EHouseListTypeFilter,       //过滤器
    EHouseListTypeRecent, //最新的
    EHouseListTypeInvited   //邀请
};

typedef NS_ENUM(NSInteger , EGatherHouseListType)
{
    EGatherHouseListTypeSpecial = 1,
};

typedef NS_ENUM(NSInteger , EClientListType)
{
    EClientListTypeMatchClientsForHouse,
    EClientListTypeMarkedClientsForHouse,
    EClientListTypeRecommendClientsForHouse,
    EClientListTypeSearch,
    EClientListTypeFilter,
    EClientListTypeForShare,
    EClientListTypeRecent,
    EClientListTypeCollected,
};

typedef NS_ENUM(NSInteger , EQRCodeType)
{
    EQRCodeTypeAll = 0,
    EQRCodeTypeHouse,
    EQRCodeTypeClient,
    EQRCodeTypeLogin
};

typedef NS_ENUM(NSInteger , EPickImageType)
{
    EPickImageForHouse = 101,
    EPickImageForIM = 102,
    EPickVideoForHouse = 103,
};

typedef NS_ENUM(NSInteger , ECustomConditionViewType){
    ECustomConditionViewTypeHouse = 0,
    ECustomConditionViewTypeGatherHouse = 1,
};

typedef NS_ENUM(NSInteger , EGatherViewType)
{
    EGatherViewTypeGather = 0,
    EGatherViewTypeSubscription = 1,
    EGatherViewTypeBookmark = 2
};

@interface EBController : NSObject

@property (nonatomic, assign) MainTabViewController *mainTabViewController;

+ (EBController *)sharedInstance;

- (UINavigationController *)currentNavigationController;
- (void)promptChoices:(NSArray *)items
      withRightChoice:(NSInteger)rightChoice
           leftChoice:(NSInteger)leftChoice
                title:(NSString *)title
           completion:(void (^)(NSInteger, NSInteger))completion;

- (void)promptChoices:(NSArray *)items
      withRightChoice:(NSInteger)rightChoice
           leftChoice:(NSInteger)leftChoice
                title:(NSString *)title
            houseType:(NSInteger)houseType
           completion:(void (^)(NSInteger, NSInteger))completion;

- (void)promptChoices:(NSArray *)items
      withRightChoice:(NSInteger)rightChoice
           leftChoice:(NSInteger)leftChoice
                title:(NSString *)title
            houseType:(NSInteger)houseType
             hidezero:(BOOL)hidezero
           completion:(void (^)(NSInteger, NSInteger))completion;

- (void)promptChoices:(NSArray *)items
           withChoice:(NSInteger)choice
                title:(NSString *)title
               footer:(NSString *)footerStr
           completion:(void (^)(NSInteger))completion;

- (void)promptChoices:(NSArray *)items
           withChoice:(NSInteger)choice
                title:(NSString *)title
               header:(NSString *)headerStr
               footer:(NSString *)footerStr
           completion:(void (^)(NSInteger))completion;

- (HouseListViewController *)showHouseListWithType:(EHouseListType)listType filter:(EBFilter *)filter title:(NSString *)title client:(EBClient*)client;
- (GatherHouseListViewController *)showGatherHouseListWithType:(EGatherHouseListType)listType filter:(EBFilter *)filter title:(NSString *)title;
- (ClientListViewController *)showClientListWithType:(EClientListType)listType filter:(EBFilter *)filter title:(NSString *)title house:(EBHouse*)house;

- (void)hideTabBar;
- (void)showTabBar;
- (void)showClientDetail:(EBClient *)client;
- (void)showClientDetailBackRoot:(EBClient *)client;
- (void)showHouseDetail:(EBHouse *)house;
- (void)showHouseDetailBackRoot:(EBHouse *)house uploadTag:(BOOL)isUplaodForNewHouse openType:(EHouseDetailOpenType)openType;
- (GatherHouseDetailViewController *)showGatherHouseDetail:(EBGatherHouse *)house;
- (void)showCustomCondition:(EBCondition *)condition customType:(ECustomConditionViewType)customType;

- (void)showCalculator:(NSDictionary *)info;
- (void)showQRCodeScannerWithType:(EQRCodeType)type completion:(void(^)(NSString *result))completion;

- (InputOrScanViewController *)showInputWithFilter:(NSArray *)filter completion:(void(^)(NSDictionary *result))completion;

- (void)dismissPopUpView:(void(^)())completion;

- (void)shareItemWith:(NSString *)url image:(UIImage *)image text:(NSString *)text;

- (SnsViewController *)shareHouses:(NSArray *)houses handler:(void(^)(BOOL success, NSDictionary *info))handler;
- (SnsViewController *)shareNewHouses:(NSArray *)houses handler:(void(^)(BOOL success, NSDictionary *info))handler;
- (void)shareClients:(NSArray *)clients;
- (void)recommendHouses:(NSArray *)houses toClient:(EBClient *)client  completion:(void(^)(BOOL success, NSDictionary *info))handler;
- (void)recommendVisit:(NSArray *)visitLogs toClient:(EBClient *)client completion:(void(^)(BOOL success, NSDictionary *info))handler;

+ (void)broadcastNotification:(NSNotification *)notification;
+ (void)observeNotification:(NSString *)notificationName from:(id)observer selector:(SEL)selector;

+ (void)accountLoggedIn;

//新增
+ (void)accountLoggedIn:(UIViewController *)view;

+ (void)accountVerifyCodeLoggedOut;
+ (void)accountLoggedOut;
+ (void)accountDataReset;

- (void)showProfile:(EBContact *)contact;
//无图模式
- (void)promptNoneImageMode:(void(^)())completion;

- (void)showAnonymousCallAlert:(void(^)())completion type:(BOOL)isHouse detail:(id)detail page:(NSInteger)pageType;
- (void)showAnonymousCallWnd:(void(^)())completion type:(NSInteger)type num:(NSString*)num;
- (void)promptChangeNumberInView:(UIView *)view withVerifySuccess:(void(^)())handler;

- (void)promptInputWithText:(NSString *)text title:(NSString *)title block:(void(^)(NSString *inputString))inputBlock;

- (void)pickImageWithSourceType:(UIImagePickerControllerSourceType)type handler:(void(^)(UIImage *image))handler;
- (void)pickImageWithUrlSourceType:(UIImagePickerControllerSourceType)type handler:(void(^)(UIImage *image, NSURL *url))handler;
- (void)pickImageWithUrlSourceTypeEx:(UIImagePickerControllerSourceType)type curentViewController:(id)curentViewController handler:(void(^)(UIImage *image, NSURL *url))handler;
- (void)pickVideoWithUrlSourceTypeEx:(UIImagePickerControllerSourceType)type curentViewController:(id)curentViewController handler:(void(^)(NSURL *sourceUrl))handler;

- (void)pickLocationWithBlock:(void(^)(NSDictionary *))block pickBySend:(BOOL)bySend;

- (ChatViewController *)startChattingWith:(NSArray *)contacts popToConversation:(BOOL)pop;
- (ChatViewController *)openGroupChat:(EBIMGroup *)group popToConversation:(BOOL)pop;
- (ChatViewController *)openConversation:(EBIMConversation *)cvsn  popToConversation:(BOOL)pop;
- (EBWebViewController *)openWebViewWithRequest:(NSURLRequest *)request;
- (EBWebViewController *)openWebViewWithUrl:(NSURL *)url;
- (GatherViewController *)openGatherView:(EGatherViewType)viewType;
- (PublishHouseRecordViewController *)openPublishRecordView;
- (void)showLocationInMap:(NSDictionary *)poiInfo showKeywordLocation:(BOOL)showKeywordLocation;

- (void)openURL:(NSURL*)url;
- (CLLocationCoordinate2D)GCJ02FromBD09:(CLLocationCoordinate2D)coor;
- (CLLocationCoordinate2D)BD09FromGCJ02:(CLLocationCoordinate2D)coor;
- (void)viewImagesFromMsg:(NSInteger)msgId inConversation:(NSInteger)cvsnId;

- (void)showPopOverListView:(id)sender choices:(NSArray *)choices block:(void(^)(NSInteger selectedIndex))selectedBlock;
- (void)showPopOverListView:(id)sender choices:(NSArray *)choices delegate:(id)delegate;

- (void)showFilingDetailView;

- (EBHouse*)refreshHouseDetailWhenEdited:(id)target;

- (EBClient*)refreshClientDetailWhenEdited:(id)target;

- (BOOL)checkInputNum:(NSString*)num;
- (NSString *)getEagleKeyWithDate:(NSString *)date;

//lwl
- (void)showJuHePay:(NSDictionary *)dic;

@end
