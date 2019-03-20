//
//  GatherHouseWebViewController.h
//  beaver
//
//  Created by wangyuliang on 14-9-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBWebViewController.h"

@interface GatherHouseWebViewController : BaseViewController <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, copy) NSURLRequest *request;

@end
