//
//  ShareManager.h
//  ShareManagerExample
//
//

#import "WXApi.h"
#import "ShareConfig.h"

@interface ShareManager : NSObject
{
    //TcWeibo
//    WeiboApi          *_qqWeibo;
//    SinaWeibo           *_sinaWeibo;
}

+ (ShareManager *) sharedInstance;

- (BOOL)handleOpenURL:(NSURL *)url;
- (BOOL)isLogin:(EShareType)shareType;
- (void)loginWithType:(EShareType)shareType handler:(void(^)(BOOL success, NSDictionary *info))handler;
- (void)logOutWithType:(EShareType)shareType;

- (void)shareContent:(NSDictionary *)content withType:(EShareType)shareType handler:(void(^)(BOOL success, NSDictionary *info))handler;

- (void)shareContentWithReccmmond:(NSDictionary *)content withType:(EShareType)shareType;


@end
