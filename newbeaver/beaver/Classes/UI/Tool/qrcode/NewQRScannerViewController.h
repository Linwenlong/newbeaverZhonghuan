//
//  NewQRScannerViewController.h
//  beaver
//
//  Created by eall_linger on 16/3/29.
//  Copyright © 2016年 eall. All rights reserved.
//

#import "LBXScanViewController.h"
#import "EBController.h"

@class QRScannerView;
@interface NewQRScannerViewController : LBXScanViewController

@property (nonatomic, assign) BOOL is_JuhePay;

@property (nonatomic, copy) BOOL(^shouldFetchInfo)(NSArray *codeInfo);
@property (nonatomic, copy) void(^infoFetched)(id info);
@end
