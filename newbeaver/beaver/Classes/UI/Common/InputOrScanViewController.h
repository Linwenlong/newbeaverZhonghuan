//
//  InputOrScanViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-17.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"

@interface InputOrScanViewController : BaseViewController

@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, copy) void(^outputBlock)(NSDictionary *result) ;

@end
