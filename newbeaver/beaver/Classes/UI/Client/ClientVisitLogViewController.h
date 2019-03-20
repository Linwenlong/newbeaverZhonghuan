//
//  ClientVisitLogViewController.h
//  beaver
//
//  Created by wangyuliang on 14-5-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"

@interface ClientVisitLogViewController : BaseViewController
@property (nonatomic, strong) EBClient *clientDetail;

@property (nonatomic, strong) NSDictionary *openDict;
@property (nonatomic, assign)BOOL isOpenpage;

@end
