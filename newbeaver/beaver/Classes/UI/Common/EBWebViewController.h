//
//  ViewController.h
//  WebViewDemo
//
//  Created by Satoshi Asano on 4/20/13.
//  Copyright (c) 2013 Satoshi Asano. All rights reserved.
//

#import "NJKWebViewProgress.h"
#import "BaseViewController.h"

@interface EBWebViewController : BaseViewController<UIWebViewDelegate, NJKWebViewProgressDelegate>
{
    UIWebView *_webView;
}
@property (nonatomic, copy) NSURLRequest *request;

@end
