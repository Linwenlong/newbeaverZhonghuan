//
// Created by 何 义 on 14-3-30.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBIMBaseModel.h"
#import "EBIMConversation.h"

typedef NS_ENUM(NSInteger , EMessageStatus)
{
    EMessageStatusGenerating = -5,
    EMessageStatusUploading = -4,
    EMessageStatusUploadingError = -3,
    EMessageStatusSending = -2,
    EMessageStatusSendError = -1,
    EMessageStatusOK = 0,
    EMessageStatusPlaying = 1,
};

typedef NS_ENUM(NSInteger , EMessageContentType)
{
    EMessageContentTypeHint = -1,
    EMessageContentTypeText = 0,
    EMessageContentTypeHouse = 1,
    EMessageContentTypeClient = 2,
    EMessageContentTypeImage = 3,
    EMessageContentTypeAudio = 4,
    EMessageContentTypeShareLocation = 5,
    EMessageContentTypeReportLocation = 6,
    EMessageContentTypeLink = 7,
    EMessageContentTypePublishFailureReminder = 95,
    EMessageContentTypeSubscriptionReminder = 96,
    EMessageContentTypeReserved = 97,
    EMessageContentTypeSystemBound = 98,
    EMessageContentTypeInvitationReminder = 99,
    EMessageContentTypeNewHouse = 1000,//useless
};

typedef NS_ENUM(NSInteger, EMessageSourceType)
{
    EMessageSourceTypeEall = 0,
    EMessageSourceTypeFang = 1
};

@class EBContact;
@class XMPPMessage;
@class EBHouse;
@class EBClient;

@interface EBIMMessage : EBIMBaseModel

-(id)initWithXmppMessage:(XMPPMessage *)xmppMessage;

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger cvsnId;
@property (nonatomic, assign) EMessageStatus status;
@property (nonatomic, assign) EMessageContentType type;
@property (nonatomic, assign) EConversationType conversationType;
@property (nonatomic, assign) EMessageSourceType sourcePlatType;//信息来源
@property (nonatomic, assign) BOOL isIncoming;
@property (nonatomic, copy) NSString *from;
@property (nonatomic, copy) NSString *to;
@property (nonatomic, strong) NSDictionary *content;
@property (nonatomic, assign) BOOL isRead;
@property (nonatomic, strong) EBContact *sender;

@property (nonatomic, strong) NSString *convertedString;
@property (nonatomic, strong) NSMutableArray *emojiImagesArray;

#pragma mark forDisplay
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic) CGFloat contentHeight;
@property (nonatomic, readonly) CGFloat timestampHeight;
@property (nonatomic) CGSize bubbleSize;
@property (nonatomic) BOOL displayTimestamp;

- (NSString *)subString;

+(NSDictionary *)buildTextContent:(NSString *)text;
+(NSDictionary *)buildImageContent:(NSString *)url localUrl:(NSString *)localUrl size:(CGSize)size;
+(NSDictionary *)buildAudioContent:(NSString *)url localUrl:(NSString *)localUrl length:(NSInteger)length  listened:(BOOL)listened;
+(NSDictionary *)buildHouseContent:(EBHouse *)house;
+(NSDictionary *)buildNewHouseContent:(EBHouse *)house;
+(NSDictionary *)buildClientContent:(EBClient *)client;

@end