//
//  QRScannerViewController.h
//  beaver
//
//  Created by 何 义 on 14-2-25.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"

@class QRScannerView;

@interface QRScannerViewController : BaseViewController


@property (nonatomic, assign) BOOL is_JuhePay;

@property (nonatomic, copy) BOOL(^shouldFetchInfo)(NSArray *codeInfo);
@property (nonatomic, copy) void(^infoFetched)(id info);
@property (nonatomic, readonly) QRScannerView *scannerView;

@end
