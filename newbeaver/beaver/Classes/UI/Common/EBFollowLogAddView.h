//
//  EBFollowLogAddView.h
//  beaver
//
//  Created by wangyuliang on 14-7-23.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger , EBSetFollowLogType)
{
    EBSetFollowLogForHouse = 0,
    EBSetFollowLogForClient = 1,
};

typedef NS_ENUM(NSInteger , EBProcessType)
{
    EBProcessTypeBegin = 0,
    EBProcessTypeWait = 1,
    EBProcessTypeEnd = 2,
};

typedef void(^commitNote)();
typedef void(^endCommitNote)(BOOL);

static BOOL isShow;

@interface EBFollowLogAddView : NSObject

@property (nonatomic, assign) EBSetFollowLogType setFollowType;
@property (nonatomic, assign) EBProcessType processType;
@property (nonatomic, assign) BOOL isNormal;
@property (nonatomic, assign) CGRect curFrame;

@property (nonatomic, copy) commitNote commitNoteBlock;
@property (nonatomic, copy) endCommitNote endCommitNoteBlock;
@property (nonatomic, strong) NSDictionary *follow;

+ ( EBFollowLogAddView*)sharedInstance;

+ (BOOL)getShowState;

- (void)showSetFollowLogView:(BOOL)normal;

- (void)close;

@end
