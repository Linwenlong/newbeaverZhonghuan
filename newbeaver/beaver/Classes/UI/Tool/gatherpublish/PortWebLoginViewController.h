//
//  PortWebLoginViewController.h
//  beaver
//
//  Created by wangyuliang on 14-12-22.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBWebViewController.h"

@interface PortWebLoginViewController : BaseViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic) BOOL isEdit;
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, copy) NSDictionary *port;

@end
