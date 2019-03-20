//
//  PublishHouseWebViewController.h
//  beaver
//
//  Created by wangyuliang on 14-9-11.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBWebViewController.h"

@interface PublishHouseWebViewController : BaseViewController <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, copy) NSURLRequest *request;

@property (nonatomic, strong) NSString *recordId;

@end
