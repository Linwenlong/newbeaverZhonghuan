//
// Created by 何 义 on 14-3-5.
// Copyright (c) 2014 eall. All rights reserved.
//

#import "AFNetworking.h"
#import "AFHTTPRequestOperationManager.h"

//同步数据
#define BEAVER_DATA_FILTER @"data/filter"
#define BEAVER_DATA_CONTACTS @"data/contacts"
#define BEAVER_DATA_PREFETCH @"data/prefetch"

//上传图片跟语音
#define BEAVER_DATA_UPLOAD_IMAGE @"upload/image"
#define BEAVER_DATA_UPLOAD_AUDIO @"upload/audio"
#define BEAVER_DATA_GET_AUDIO_URI @"upload/audioUri"
#define BEAVER_DATA_GET_IMAGE_URI @"upload/imageUri"

#define BEAVER_CODE_ACTION @"code/action"

#define BEAVER_HOUSE_SPECIAL_CATEGORY @"house/specialCategory"
#define BEAVER_HOUSE_RECENT_VIEWED @"house/recentViewed"
#define BEAVER_HOUSE_FILTER @"house/filter"
#define BEAVER_HOUSE_DETAIL @"house/detail"
#define BEAVER_HOUSE_MATCH @"house/matchClients"
#define BEAVER_HOUSE_MARKED @"house/markedClients"
#define BEAVER_HOUSE_RECOMMENDED @"house/recommendedClients"
#define BEAVER_HOUSE_UPDATE_SPECIAL_CONDITION @"house/updateSpecial"
#define BEAVER_HOUSE_DELETE_SPECIAL_CONDITION @"house/deleteSpecial"
#define BEAVER_HOUSE_VIEW_PHONE_NUMBER @"house/viewPhoneNumber"
#define BEAVER_HOUSE_SET_SHARE_DATA @"house/setShareData"
#define BEAVER_HOUSE_SHARE_TO_WEIBO @"house/shareToWeibo"
#define BEAVER_HOUSE_VISIT_LOG @"house/visitlogs"
#define BEAVER_HOUSE_COLLECT @"house/filter"
#define BEAVER_HOUSE_ADD_COLLECT @"house/collect"
#define BEAVER_HOUSE_DELETE_COLLECT @"house/discard"
#define BEAVER_HOUSE_FOLLOW @"house/follow"
#define BEAVER_HOUSE_ANONYMOUSCALL @"house/anonymousCall"
#define BEAVER_HOUSE_APPONITMENT @"house/appointmentHouse"
#define BEAVER_HOUSE_ADD_FOLLOWLOG @"follow/addHouse"
#define BEAVER_HOUSE_ADD_VALIDATE @"house/validate"
#define BEAVER_HOUSE_ADD_PARAMETER @"house/parameter"
#define BEAVER_HOUSE_ADD_SAVE @"house/save"
#define BEAVER_HOUSE_EDIT @"house/editParameter"
#define BEAVER_HOUSE_UPDATE @"house/update"
#define BEAVER_HOUSE_CHANGE_STATUS @"house/status"
#define BEAVER_HOUSE_CHANGE_RECOMMEND_TAG @"house/recommendTag"
#define BEAVER_HOUSE_REPORT @"house/report"
#define BEAVER_HOUSE_ADD_PHOTO @"upload/finish"
#define BEAVER_HOUSE_VALID_STATUS @"house/validStatus"
#define BEAVER_HOUSE_COMMUNITY_ASSOCIATE @"community/suggest"
#define BEAVER_HOUSE_ADD_FILING @"house/nhApplyFollow"
#define BEAVER_HOUSE_NH_FOLLOW_LIST @"house/nhFollowList"


#define BEAVER_CLIENT_RECENT_VIEWED @"client/recentViewed"
#define BEAVER_CLIENT_FILTER @"client/filter"
#define BEAVER_CLIENT_DETAIL @"client/detail"
#define BEAVER_CLIENT_MATCH @"client/matchHouses"
#define BEAVER_CLIENT_MARKED @"client/markedHouses"
#define BEAVER_CLIENT_RECOMMENDED @"client/recommendedHouses"
#define BEAVER_CLIENT_ADD_MARK @"client/addMark"
#define BEAVER_CLIENT_DELETE_MARK @"client/deleteMark"
#define BEAVER_CLIENT_ADD_COLLECT @"client/collect"
#define BEAVER_CLIENT_DELETE_COLLECT @"client/discard"
#define BEAVER_CLIENT_VIEW_PHONE_NUMBER @"client/viewPhoneNumber"
#define BEAVER_CLIENT_RECOMMEND_HOUSE @"client/recommend"
#define BEAVER_CLIENT_NEW_APPOINTMENT @"client/newAppointment"
#define BEAVER_CLIENT_TEL_LIST @"client/telByIds"
#define BEAVER_CLIENT_VISIT_LOG @"client/visitlogs"
#define BEAVER_CLIENT_COLLECT @"client/filter"
#define BEAVER_CLIENT_LIST_APPOINTMENT @"client/listAppointment"
#define BEAVER_CLIENT_FOLLOW @"client/follow"
#define BEAVER_CLIENT_APPOINTMENTHISTORY @"client/appointmentHistory"
#define BEAVER_CLIENT_ANONYMOUSCALL @"client/anonymousCall"
#define BEAVER_CLIENT_ADD_VISIT_LOG @"visit/new"
#define BEAVER_CLIENT_ADD_FOLLOWLOG @"follow/addClient"
#define BEAVER_CLIENT_CHANGE_STATUS @"client/status"
#define BEAVER_CLIENT_CHANGE_RECOMMEND_TAG @"client/recommendTag"
#define BEAVER_CLIENT_VALID_STATUS @"client/validStatus"
#define BEAVER_CLIENT_ADD_VALIDATE @"client/validate"
#define BEAVER_CLIENT_ADD_PARAMETER @"client/parameter"
#define BEAVER_CLIENT_ADD_SAVE @"client/save"
#define BEAVER_CLIENT_EIDT @"client/editParameter"
#define BEAVER_CLIENT_UPDATE @"client/update"
#define BEAVER_CLIENT_CHOWDETAIL @"client/chowDetail"

#define GATHER_PUBLISH_TRANSCEIVER_PORTAUTHLIST @"transceiver/portAuthList"
#define GATHER_PUBLISH_TRANSCEIVER_PORTAVAILABLELIST @"transceiver/portAvailableList"
#define GATHER_PUBLISH_TRANSCEIVER_PORTEDITAUTH @"transceiver/portEditAuth"
#define BEAVER_TRANSCEIVER_HOUSE_LIST @"transceiver/houseList"
#define BEAVER_TRANSCEIVER_VIEW_HOUSE @"transceiver/viewHouse"
#define BEAVER_TRANSCEIVER_SUBSCRIPTION_LIST @"transceiver/subscriptionList"
#define BEAVER_TRANSCEIVER_SUBSCRIPTION_EDIT @"transceiver/subscriptionEdit"
#define BEAVER_TRANSCEIVER_SUBSCRIPTION_DELETE @"transceiver/subscriptionDelete"
#define BEAVER_TRANSCEIVER_SUBSCRIPTION_HOUSE_LIST @"transceiver/houseSList"
#define BEAVER_TRANSCEIVER_BOOKMARK_LIST @"transceiver/bookmarkList"
#define BEAVER_TRANSCEIVER_TOGGLE_BOOKMARK @"transceiver/toggleBookmark"
#define BEAVER_TRANSCEIVER_REPORT_HOUSE @"transceiver/reportHouse"
#define BEAVER_TRANSCEIVER_TOGGLE_VOTE @"transceiver/portToggleVote"
#define BEAVER_TRANSCEIVER_GET_SETTING @"transceiver/getSetting"
#define BEAVER_TRANSCEIVER_UPDATE_SETTING @"transceiver/updateSetting"
#define BEAVER_TRANSCEIVER_UNREAD_COUNT @"transceiver/getUnreadCount"
#define BEAVER_TRANSCEIVER_PORT_ADD_PROPOSAL @"transceiver/portAddProposal"
#define BEAVER_TRANSCEIVER_PORT_PROPOSAL_LIST @"transceiver/portProposalList"
#define BEAVER_TRANSCEIVER_PUBLISHHOUSEEDITOR @"transceiver/publishHouseEditor"
#define BEAVER_TRANSCEIVER_PORTAUTHSTATUS @"transceiver/portAuthStatus"
#define BEAVER_TRANSCEIVER_PORTREFRESHCAPTCHA @"transceiver/portAuthRefreshCaptcha"
#define BEAVER_REANSCEIVER_PUBLISHTASKLIST @"transceiver/publishTaskList"
#define BEAVER_TRANSCEIVER_PUBLISHHOUSE @"transceiver/publishHouse"
#define BEAVER_TRANSCEIVER_PORTCHECKAUTHSTATUS @"transceiver/portCheckAuthStatus"
#define BEAVER_TRANSCEIVER_PORTAUTHSTATUSLIST @"transceiver/portAuthStatusList"
#define BEAVER_TRANSCEIVER_PORTDELETEAUTH @"transceiver/portDeleteAuth"
#define BEAVER_TRANSCEIVER_REPUBLISHHOUSE @"transceiver/republishHouse"
#define BEAVER_TRANSCEIVER_REFRESHPUBLISHHOUSE @"transceiver/refreshPublishHouse"
#define BEAVER_TRANSCEIVER_DELETEPUBLISHEDHOUSE @"transceiver/deletePublishedHouse"
#define BEAVER_TRANSCEIVER_ADDPUBLISHPHOTO @"transceiver/addPublishPhoto"
//登录的路径
#define BEAVER_ACCOUNT_LOGIN @"account/login"
#define BEAVER_ACCOUNT_LOGOUT @"account/logout"
#define BEAVER_ACCOUNT_VERIFY_CODE @"account/verifyCode"
#define BEAVER_ACCOUNT_RESEND_CODE @"account/resendCode"
#define BEAVER_ACCOUNT_CHANGE_PASSWORD @"account/changePassword"
#define BEAVER_ACCOUNT_REGISTER_PUSH_TOKEN @"account/registerPushToken"
#define BEAVER_ACCOUNT_CHANGE_CALLNUMBER @"account/callNumber"
#define BEAVER_ACCOUNT_GET_CALLNUMBER @"account/callNumber"
#define BEAVER_ACCOUNT_GET_NUMBERSTATUS @"/account/numberStatus"
#define BEAVER_ACCOUNT_SET_CALLNUMBER @"/account/callNumber"

#define BEAVER_VERSION_UPDATE_CHECK @"account/checkUpdate"
#define BEAVER_ACCOUNT_VERIFY_ANONYMOUSTEL @"account/verifyTel"

#define BEAVER_CUSTOMER_GET_SIGNATURE @"customer/getSignature"
#define BEAVER_CUSTOMER_MAPROOMAUDIOURI @"customer/mapRoomAudioUri"

# pragma mark - wap 
#define WAP_INDEX_FOUNDLIST @"index/foundList"
#define WAP_INDEX_DESKTOP @"index/desktop"
//检查更新
#define WAP_INDEX_CHECK_UPDATE @"index/checkUpdate"
#define WAP_INDEX_UPLOADIMAGE  @"index/upLoadImage"
#define WAP_INDEX_NEARBYLIST @"index/nearbyList"
#define WAP_INDEX_QRCODE  @"/index/qrcode"
#define WAP_INDEX_SHARETOFOUND @"/index/shareToFound"
typedef void(^THandlerBlock)(BOOL success, id result);
typedef void(^THandlerProgress)(id, CGFloat);

@interface EBHttpClient : AFHTTPRequestOperationManager
+ (EBHttpClient *)sharedInstance;

+ (EBHttpClient *)wapInstance;



- (void)gatherPublishRequest:(NSDictionary *)parameters portAuthList:(THandlerBlock)handler;//已授权端口列表
- (void)gatherPublishRequest:(NSDictionary *)parameters portAvailableList:(THandlerBlock)handler;//可选端口列表
- (void)gatherPublishRequest:(NSDictionary *)parameters portEditAuth:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters houseList:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters viewHouse:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters subscriptionList:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters subscriptionEdit:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters subscriptionDelete:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters subscriptionHouseList:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters bookmarkList:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters toggleBookmark:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters reportHouse:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters portToggleVote:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters getSetting:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters updateSetting:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters getUnreadCount:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters portProposalList:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters portAddProposal:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters publishTaskList:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters portAuthStatus:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters portRefreshCaptcha:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters publishHouse:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters portCheckAuthStatus:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters portAuthStatusList:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters publishHouseEditor:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters portDeleteAuth:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters republishHouse:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters deletePublishedHouse:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters refreshPublishHouse:(THandlerBlock)handler;
- (void)gatherPublishRequest:(NSDictionary *)parameters addPublishPhoto:(THandlerBlock)handler;

#pragma mark -- 登录接口跟登出接口
- (void)accountRequest:(NSDictionary *)parameters login:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters logout:(THandlerBlock)handler;
#pragma mark -- 验证码验证
- (void)accountRequest:(NSDictionary *)parameters verifyCode:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters resendCode:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters changePassword:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters verifyAnonymousTel:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters registerPushToken:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters checkUpdate:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters changeCallNumber:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters getCallNum:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters getNumberStatus:(THandlerBlock)handler;
- (void)accountRequest:(NSDictionary *)parameters setNumber:(THandlerBlock)handler;

- (void)dataRequest:(NSDictionary *)parameters prefetch:(THandlerBlock)handler;
- (void)dataRequest:(NSDictionary *)parameters filter:(THandlerBlock)handler;
- (void)dataRequest:(NSDictionary *)parameters contacts:(THandlerBlock)handler;
- (void)dataRequest:(NSDictionary *)parameters uploadImage:(UIImage *)image withHandler:(THandlerBlock)handler;
- (AFHTTPRequestOperation *)dataRequest:(NSDictionary *)parameters uploadImage:(UIImage *)image
    withCompression:(CGFloat)compression progress:(THandlerProgress)progressHandler handler:(THandlerBlock)handler;
- (void)dataRequest:(NSDictionary *)parameters uploadAudio:(NSURL *)fileUrl withHandler:(THandlerBlock)handler;

- (void)codeRequest:(NSDictionary *)parameters what:(THandlerBlock)handler;

- (void)houseRequest:(NSDictionary *)parameters specialCategory:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters recentViewed:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters visitLogs:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters collect:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters follow:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters filter:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters detail:(THandlerBlock)handler;
- (void)houseRequestWithOutWarn:(NSDictionary *)parameters detail:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters matchClients:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters markedClients:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters recommendedClients:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters updateCondition:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters deleteCondition:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters viewPhoneNumber:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters setShareData:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters shareToWeibo:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters collectState:(BOOL)state toggleCollect:(THandlerBlock)handler;
- (void)houseAnonymousCallRequest:(NSDictionary *)parameters handler:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters appointmentHouse:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters addFollow:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters houseValidate:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters houseParameter:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters houseSave:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters houseEdit:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters houseUpdate:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters changeStatus:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters changeRecommendTag:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters report:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters addPhoto:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters validStatus:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters communityAssociate:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters addFiling:(THandlerBlock)handler;
- (void)houseRequest:(NSDictionary *)parameters nhFollowList:(THandlerBlock)handler;

- (void)clientRequest:(NSDictionary *)parameters recentViewed:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters visitLogs:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters collect:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters follow:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters filter:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters detail:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters matchHouses:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters markedHouses:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters recommendedHouses:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters recommend:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters newAppointment:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters viewPhoneNumber:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters markState:(BOOL)state toggleMark:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters collectState:(BOOL)state toggleCollect:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters telList:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters listAppointment:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters appointHistory:(THandlerBlock)handler;
- (void)clientAnonymousCallRequest:(NSDictionary *)parameters handler:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters newVisitLog:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters addFollow:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters changeStatus:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters changeRecommendTag:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters validStatus:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters clientValidate:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters clientParameter:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters clientSave:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters clientEdit:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters clientUpdate:(THandlerBlock)handler;
- (void)clientRequest:(NSDictionary *)parameters chowDetail:(THandlerBlock)handler;

- (void)customerRequest:(NSDictionary *)parameters getSignature:(THandlerBlock)handler;
- (void)customerRequest:(NSDictionary *)parameters mapRoomAudioUri:(THandlerBlock)handler;

# pragma mark - wap

- (void)wapRequest:(NSDictionary *)paramters foundList:(THandlerBlock)handler;
- (void)wapRequest:(NSDictionary *)paramters desktop:(THandlerBlock)handler;
- (void)wapRequest:(NSDictionary *)paramters checkUpdate:(THandlerBlock)handler;
- (void)wapRequest:(NSDictionary *)paramters nearbyList:(THandlerBlock)handler;
- (void)wapRequest:(NSDictionary *)paramters qrcode:(THandlerBlock)handler;
- (void)wapRequest:(NSDictionary *)paramters shareToFound:(THandlerBlock)handler;

- (void)wapRequest:(NSDictionary *)parameters uploadImage:(UIImage *)image withHandler:(THandlerBlock)handler;



- (AFHTTPRequestOperation *)ebPost:(NSString *)url parameters:(NSDictionary *)parameters handler:(void(^)(BOOL successful, NSDictionary *response))handler;
- (AFHTTPRequestOperation *)ebGet:(NSString *)url parameters:(NSDictionary *)parameters handler:(void(^)(BOOL successful, NSDictionary *response))handler;

//无底层错误提示
- (AFHTTPRequestOperation *)ebGetWithOutWarn:(NSString *)url parameters:(NSDictionary *)parameters handler:(void(^)(BOOL successful, NSDictionary *response))handler;

- (void)downloadFile:(NSString *)url to:(NSString *)filePath withHandler:(THandlerBlock)handler;
- (void)downloadFile:(NSString *)url to:(NSString *)filePath withProgress:(THandlerProgress)progressHandler handler:(THandlerBlock)handler;
@end