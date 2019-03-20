//
//  QRScannerViewController.h
//  beaver
//
//  Created by 何 义 on 14-2-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "ShareConfig.h"

@interface SendShareViewController : BaseViewController

@property (nonatomic, strong) NSMutableDictionary *content;
@property (nonatomic, assign) EShareType shareType;
@property (nonatomic, assign) BOOL CheckLabelHidden;

@property (nonatomic, copy) void(^shareHandler)(BOOL success, NSDictionary *info);

@end
