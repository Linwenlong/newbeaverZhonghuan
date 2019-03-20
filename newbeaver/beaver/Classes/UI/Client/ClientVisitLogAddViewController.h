//
//  ClientVisitLogAddViewController.h
//  beaver
//
//  Created by ChenYing on 14-7-21.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"

@class EBClient;
@protocol ClientVisitLogAddViewControllerDelegate <NSObject>

- (void)openPage:(NSDictionary *)paramer;

@end

@interface ClientVisitLogAddViewController : BaseViewController <UIScrollViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) EBClient *clientDetail;
@property (nonatomic, copy) void(^addVisitLogcompletion)();
@property (nonatomic,assign)id <ClientVisitLogAddViewControllerDelegate>delegate;
@end
