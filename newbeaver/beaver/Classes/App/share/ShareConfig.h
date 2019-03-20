
#ifndef SHARE_CONFIG_H_
#define SHARE_CONFIG_H_

typedef NS_ENUM(NSInteger , EShareType)
{
    EShareTypeWeChat = 0,
    EShareTypeWeChatFriend = 1,
    EShareTypeQQ = 2,
    EShareTypeQQZone = 3,
    EShareTypeSinaWeibo = 4,
    EShareTypeMessage = 5,
    EShareTypeMail = 6,
    EShareTypeworkmate = 7,
    EShareTypePublishToPort = 9,
};



#define AccessTokenKey          @"WeiBoAccessToken"
#define ExpirationDateKey       @"WeiBoExpirationDate"
#define ExpireTimeKey           @"WeiBoExpireTime"
#define UserIDKey               @"WeiBoUserID"
#define OpenIdKey               @"WeiBoOpenId"
#define OpenKeyKey              @"WeiBoOpenKey"
#define RefreshTokenKey         @"WeiBoRefreshToken"
#define NameKey                 @"WeiBoName"
#define SSOAuthKey              @"WeiBoIsSSOAuth"

#endif