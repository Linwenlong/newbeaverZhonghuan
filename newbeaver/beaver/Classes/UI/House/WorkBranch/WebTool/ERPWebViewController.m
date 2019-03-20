//
//  ERPWebViewController.m
//  chowRentAgent
//
//  Created by 凯文马 on 15/11/13.
//  Copyright © 2015年 eallcn. All rights reserved.
//

#import "ERPWebViewController.h"
#import "KWWebAnalyzer.h"
#import <MessageUI/MessageUI.h>
#import "EBController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "EBUtil.h"
#import "JSONKit.h"
#import "ERPSignViewController.h"
#import "EBMapService.h"
#import "ERPUploadPhotoController.h"
#import "EBMapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import "EBHousePhoto.h"
#import "EBPreferences.h"
#import "SKImageController.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "EBAppAnalyzer.h"
#import "JSONKit.h"
#import "FSBasicImageSource.h"
#import "FSImageViewerViewController.h"
#import "FSBasicImage.h"
#import "CCMD5.h"

/**********************    协议信息      ************************/
/*
 -方法名-           -说明-
 back             返回
 geo              定位
 sign             签名
 telList          通讯录
 phoneCall        拨号
 message          发信息
 map              地图
 uploadImg        上传图片
 changeTitle      换标题
 getTitle         获取APP当前标题
 removeCache      清空缓存
 setRightTopBtn   设置右上角按钮文字
 hideRightTopBtn  设置右上角按钮隐藏
 showRightTopBtn  设置右上角按钮显示
 appTakePhoto     点击获取相机拍照
 appSelectAlbum   点击获取本地照片
 setHouseCode     获取房间号
 ImagePager    点击 发现图片 显示
 uploadPort      加密
 pushAppViewController  通过web 推出 app界面
*/
/***************************************************************/

@interface ERPWebViewController () <UIWebViewDelegate,MFMessageComposeViewControllerDelegate,ABPeoplePickerNavigationControllerDelegate,UINavigationControllerDelegate>
{
    NSMutableArray * _imagesUrlMutableArray;//上传images数组时候保存返回的url
}

@property (nonatomic, strong) KWWebAnalyzer *webAnalyzer;

@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UILabel *titleLable;

@property (nonatomic, strong) UILabel *timeLable;

@end

static ERPWebViewController *_sharedInstance = nil;

@implementation ERPWebViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [ERPWebViewController sharedInstance].isHiddenRightBarItem = NO;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[ERPWebViewController alloc] init];
        [_sharedInstance view];
    });
    return _sharedInstance;
}

- (UIWebView *)webView
{
    return _webView;
}

- (void)setToken:(NSString *)token
{
    
    if (_token) return;
   
    _token = [token copy];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970]*1000)];
    NSString *AppendParam = [NSString stringWithFormat:@"eagle_time=%@&eagle_key=%@",timeSp,[[EBController sharedInstance] getEagleKeyWithDate:timeSp]];
    //lwl
    NSString *url = [NSString stringWithFormat:@"%@%@?%@",BEAVER_WAP_URL,[EBPreferences sharedInstance].wapMainUrl,AppendParam];
//    NSString *url = [NSString stringWithFormat:@"%@%@?%@",NewHttpBaseUrl,[EBPreferences sharedInstance].wapMainUrl,AppendParam];
    NSLog(@"=============%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:_token forHTTPHeaderField:@"token"];
    [request addValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"version"];

    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    self.request = [request copy];
    self.view.backgroundColor = [UIColor whiteColor];
    [_webView loadRequest:self.request];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
    [self.rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
//    self.rightButton.hidden = YES;
    self.rightButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
    
    [self beaverStatistics:@"CheckNotice"];
}

- (UILabel *)titleLable{
    if (!_titleLable) {
        _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, kScreenW, 40)];
        _titleLable.font = [UIFont systemFontOfSize:15.0f];
        _titleLable.textAlignment = NSTextAlignmentCenter;
        _titleLable.textColor  =UIColorFromRGB(0x404040);
    }
    return _titleLable;
}

- (UILabel *)timeLable{
    if (!_timeLable) {
        _timeLable = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLable.frame), kScreenW-20, 40)];
        _timeLable.font = [UIFont systemFontOfSize:12.0f];
        _timeLable.textAlignment = NSTextAlignmentRight;
        _timeLable.textColor = UIColorFromRGB(0x808080);
    }
    return _timeLable;
}

- (void)openWebPage:(NSDictionary *)param
{
    
    if (_isHiddenRightBarItem == YES) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc]init]];
    }else{
        self.rightButton.hidden = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    }
//    [self.view addSubview:self.titleLable];
//    [self.view addSubview:self.timeLable];
    
    if ([[param allKeys] containsObject:@"type"]) {
        _webView.frame = CGRectMake(0, 0, kScreenW, kScreenH-64);
        self.titleLable.hidden = NO;
        self.timeLable.hidden = NO;
        if ([[param allKeys] containsObject:@"title"]) {
            _titleLable.text = param[@"title"];
            _timeLable.text = _titleDate;
        }else{
            _titleLable.text =    @"暂无标题";
        }
    }else{
        _webView.frame = CGRectMake(0, 0, kScreenW, kScreenH);
        self.titleLable.hidden = YES;
        self.timeLable.hidden = YES;
    }
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970]*1000)];
//    NSString *AppendParam = [NSString stringWithFormat:@"eagle_time=%@&eagle_key=%@",timeSp,[[EBController sharedInstance] getEagleKeyWithDate:timeSp]];
     NSString *AppendParam = [NSString stringWithFormat:@"eagle_time=%@&eagle_key=%@&open=%d",timeSp,[[EBController sharedInstance] getEagleKeyWithDate:timeSp],1];
    
    if (param) {
        NSString *url = param[@"url"];
        NSLog(@"webUrl1 = %@",url);
        NSRange range = [url rangeOfString:@"?"];
        if (range.length) {
            url = [NSString stringWithFormat:@"%@&%@",url,AppendParam];
        }else{
            url = [NSString stringWithFormat:@"%@?%@",url,AppendParam];
        }
        NSLog(@"webUrl2 = %@",url);
        NSString *funtion = [NSString stringWithFormat:@"openPage('%@','%@','%@','%@','%@');", url, param[@"title"],@"", @"0", @"1"];
        NSLog(@"fun = %@",funtion);
        
        [_webView stringByEvaluatingJavaScriptFromString:funtion];
        
    }
}

- (void)rightClick
{
    NSString *funtion = @"clickRightTopBtn();";
    NSLog(@"fun = %@",funtion);
    [_webView stringByEvaluatingJavaScriptFromString:funtion];
}

# pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    self.webAnalyzer.requestURL = request.URL;


    NSLog(@"url= %@",request.URL);
    if (self.webAnalyzer.enableAnalyze) {
        NSLog(@"%@",self.webAnalyzer);
        [self action:self.webAnalyzer.actionName param:self.webAnalyzer.params];
        return NO;
    }
    NSLog(@"%@ -- ✈️✈️✈️✈️",request.URL.absoluteString);
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    CGFloat height1 = [[_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"] floatValue];
  NSLog(@"self.first_webview = %f",height1);
    _webView.scrollView.contentSize = CGSizeMake(kScreenW, kScreenH*2);
}

- (void)action:(NSString *)action param:(NSDictionary *)param
{
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@Act:",action]);
    if ([self respondsToSelector:sel]) {
        IMP imp = [self methodForSelector:sel];
        void (*func)(id,SEL,NSDictionary *) = (void *)imp;
        func(self,sel,param);
    }
}

# pragma mark - gettter
- (KWWebAnalyzer *)webAnalyzer
{
    if (!_webAnalyzer) {
        _webAnalyzer = [[KWWebAnalyzer alloc] initWithAnalyzeHeader:self.protocal];
    }
    return _webAnalyzer;
}

- (NSString *)protocal
{
    if (!_protocal) {
        _protocal = @"eallios";
    }
    return _protocal;
}

# pragma mark - actions
- (void)rightButtonClick:(id)sender
{
    NSString *funtion = @"clickRightTopBtn();";
    [_webView stringByEvaluatingJavaScriptFromString:funtion];
}

- (void)backAction:(id)sender
{
    NSString *funtion = @"doBack();";
    [_webView stringByEvaluatingJavaScriptFromString:funtion];
}

- (void)backAct:(NSDictionary *)param
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)phoneCallAct:(NSDictionary *)param
{
    NSString *url = [NSString stringWithFormat:@"tel://%@",param[@"tel"]];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)messageAct:(NSDictionary *)param
{
    MFMessageComposeViewController *vc = [[MFMessageComposeViewController alloc] init];
    vc.body = param[@"message"];
    vc.recipients = @[param[@"tel"]];
    vc.messageComposeDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)mapAct:(NSDictionary *)param
{
    NSMutableDictionary *poiInfo = [[NSMutableDictionary alloc] init];
    BOOL showKeywordLocation = YES;
    [poiInfo setObject:param[@"lat"] forKey:@"lat"];
    [poiInfo setObject:param[@"lng"] forKey:@"lon"];
    showKeywordLocation = NO;
    [poiInfo setObject:@"君隆" forKey:@"address"];
    [poiInfo setObject:@"北京" forKey:@"name"];

    EBMapViewController *mapVc = [[EBMapViewController alloc] init];
    mapVc.poiInfo = poiInfo;
    mapVc.mapType = EMMapViewTypeByCoordinate;
    [self presentViewController:mapVc animated:YES completion:^{
    
    }];

    
//    [[ECController sharedInstance] showLocationInMap:poiInfo city:nil showKeywordLocation:showKeywordLocation showSurrounding:YES];
}
-(void)mapActWithLine:(NSArray*)acts
{
    NSDictionary*poiInfo=acts[0];
    EBMapViewController *mapVc = [[EBMapViewController alloc] init];
    mapVc.poiInfo = poiInfo;
    mapVc.mapType = EMMapViewTypeByCoordinate;
    mapVc.AnnotationType=EBAnnotationTypeByIcon;
    [self presentViewController:mapVc animated:YES completion:^{
        [mapVc addAnnotationsWithArray:acts];
    }];
}
- (void)telListAct:(NSDictionary *)param
{
    ABPeoplePickerNavigationController *pNC = [[ABPeoplePickerNavigationController alloc] init];
    pNC.peoplePickerDelegate = self;
    if([[UIDevice currentDevice].systemVersion floatValue] >= 8.0){
        pNC.predicateForSelectionOfPerson = [NSPredicate predicateWithValue:false];
    }
    [self presentViewController:pNC animated:YES completion:nil];
}

- (void)geoAct:(NSDictionary *)param
{
    [[EBMapService sharedInstance] requestUserLocation:^(id location) {
        if ([location isKindOfClass:[MAUserLocation class]]) {
            MAUserLocation*locationM =(MAUserLocation*)location;
            CLLocationCoordinate2D point = locationM.location.coordinate;
            point = [EBUtil bd_encrypt:point];
            NSMutableDictionary *temp = [@{} mutableCopy];
            temp[@"lat"] = @(point.latitude);
            temp[@"lng"] = @(point.longitude);
            [_webAnalyzer callbackActionWithParam:temp.JSONString withWebView:_webView];
        }else{
            [EBAlert alertError:@"定位失败!"];
        }
        
    } superview:_webView];    
}

- (void)signAct:(NSDictionary *)param
{
    ERPSignViewController *signVc = [[ERPSignViewController alloc] init];
    signVc.commitAction = ^(NSString *url){
        [_webAnalyzer callbackActionWithParam:url withWebView:_webView];
    };
    EBNavigationController *navVc= [[EBNavigationController alloc] initWithRootViewController:signVc];
    [self presentViewController:navVc animated:YES completion:nil];
}

- (void)uploadImgAct:(NSDictionary *)param
{
    ERPUploadPhotoController *vc = [[ERPUploadPhotoController alloc] init];
    NSArray *types = [[param[@"type"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] componentsSeparatedByString:@"#"];
    vc.localations = types;
    vc.memoEnable = [param[@"showMemo"] boolValue];
    vc.maxWidth = [param[@"maxWidth"] floatValue];
    vc.selectCount = [param[@"multiple"] boolValue] ? 20 : 1;
    __weak __typeof(self) weakSelf = self;
    [vc uploadPhotos:nil forHouse:nil getUpLoadPhotoBlock:^(NSArray *photoInfos)
     {
         NSMutableArray *temp = [@[] mutableCopy];
         for (EBHousePhoto *photo in photoInfos) {
             NSDictionary *dict = @{@"type":photo.locationDesc,@"url":photo.remoteUrl,@"memo":photo.note ? photo.note : @""};
             [temp addObject:dict];
         }
         NSString *info = [temp JSONString];
         [weakSelf.webAnalyzer callbackActionWithParam:info withWebView:weakSelf.webView];
     }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)changeTitleAct:(NSDictionary *)param
{
    NSString *title = param[@"title"];
    self.title = [title stringByRemovingPercentEncoding];
    
    
    if (!param[@"text"] || ![param[@"text"] length]) {
        self.rightButton.hidden = YES;
        return;
    }
    self.rightButton.hidden = NO;
    [self.rightButton setTitle:param[@"text"] forState:UIControlStateNormal];
}

- (void)getTitleAct:(NSDictionary *)param
{
    [self.webAnalyzer callbackActionWithParam:self.title withWebView:_webView];
}

- (void)removeCacheAct:(NSDictionary *)param
{
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:_webView.request];
    _token = nil;
    [self backAction:nil];
    [_webView loadHTMLString:@"" baseURL:nil];
}

- (void)setRightTopBtnAct:(NSDictionary *)param
{
    if (!param[@"text"] || ![param[@"text"] length]) {
        self.rightButton.hidden = YES;
        return;
    }
    self.rightButton.hidden = NO;
    [self.rightButton setTitle:param[@"text"] forState:UIControlStateNormal];

}

- (void)hideRightTopBtnAct:(NSDictionary *)param
{
    self.rightButton.hidden = YES;
}

- (void)showRightTopBtnAct:(NSDictionary *)param
{
    self.rightButton.hidden = NO;
}

- (void)appTakePhotoAct:(NSDictionary *)param
{
    [[EBController sharedInstance] pickImageWithUrlSourceTypeEx:UIImagePickerControllerSourceTypeCamera curentViewController:self handler:^(UIImage *image, NSURL *url)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             UIImage *thumimage=[self thumbnailWithImageWithoutScale:image size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)];
             [EBAlert showLoading:nil];
             
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[EBHttpClient wapInstance] wapRequest:nil uploadImage:thumimage withHandler:^(BOOL success, id result) {
                     if (success) {
                         NSLog(@"%@",result);
                         NSString *imageUrl=result[@"url"];
                         if(imageUrl){
                            [_webAnalyzer callbackActionWithParam:imageUrl withWebView:_webView];
                         }
                     }
                 }];
             });

             
             
             
             
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 [[EBHttpClient sharedInstance] dataRequest:nil uploadImage:thumimage withHandler:^(BOOL success, id result) {
//                     NSLog(@"%@  ",result);
//                     if (success) {
//                         NSString *imageUrl=result[@"url"];
//                         if(imageUrl){
//                             [_webAnalyzer callbackActionWithParam:imageUrl withWebView:_webView];
//                         }
//                     }
//                     [EBAlert hideLoading];
//                 }];
//             });
         });
     }];
}
- (void)ImagePagerAct:(NSDictionary *)params
{
    NSLog(@"%@",params);
    NSData *data = [params[@"url"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *Mparam = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        NSArray *pics = Mparam[@"param"][@"pics"];
        for (NSDictionary *photoInfo  in pics)
        {
            [photos addObject:[[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:photoInfo[@"image"]] name:@""]];
        }
    
        FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:photos];
        FSImageViewerViewController *controller = [[FSImageViewerViewController alloc] initWithImageSource:photoSource imageIndex:[Mparam[@"param"][@"position"] integerValue]];
        controller.fixTitle = Mparam[@"title"];
    
        [self.navigationController pushViewController:controller animated:YES];
}
- (void)appSelectAlbumAct:(NSDictionary *)params
{
    if (params[@"left"]) {
        [SKImageController showMutlSelectPhotoFrom:self maxSelect:[params[@"left"] integerValue] select:^(NSArray *info) {
            NSMutableArray *images=[[NSMutableArray alloc]init];
            for (ALAsset *set in info) {
                CGImageRef ref = [[set  defaultRepresentation]fullResolutionImage];
                
                UIImage *image = [[UIImage alloc]initWithCGImage:ref];
                [images addObject:image];
            }
            [self uploadImagesAtLast:images];
            
        }];
    }
    

}
- (void)uploadPortAct:(NSDictionary *)params
{
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970]*1000)];
    NSString *AppendParam = [NSString stringWithFormat:@"eagle_time=%@&eagle_key=%@",timeSp,[[EBController sharedInstance] getEagleKeyWithDate:timeSp]];
    [_webAnalyzer callbackActionWithParam:AppendParam withWebView:_webView];
}
- (void)setHouseCodeAct:(NSDictionary *)params
{
    NSData *data = [params[@"param"] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *Mparam = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    self.houseCode(Mparam);
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setHouse:(getHouseCode)getHouseCode
{
    self.houseCode = getHouseCode;
}

- (void)pushAppViewControllerAct:(NSDictionary *)params
{
    NSDictionary*dict= [params[@"url"] objectFromJSONString];
    if (dict) {
        // 打开的是本地的控制器,根据 url 判断
        EBAppAnalyzer *analyzer = [[EBAppAnalyzer alloc] initWithDict:dict];
        if ([analyzer.viewControllerKey isEqualToString:@"ImagePager"]) {
            [self ImagePagerAct:params];
        }else{
            UIViewController *vc = [analyzer toViewController];
            if (vc) {
                vc.title = dict[@"title"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        
    }

    
}
# pragma mark - 短信代理方法
//代理方法，当短信界面关闭的时候调用，发完后会自动回到原应用
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // 关闭短信界面
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled) {
        NSLog(@"取消发送");
    } else if (result == MessageComposeResultSent) {
        NSLog(@"已经发出");
    } else {
        NSLog(@"发送失败");
    }
}

# pragma mark - 联系人代理
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    //读取姓名
    NSString *personFirstName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *personLastName = (__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *name = @"";
    if (personLastName && personFirstName) {
        name = [NSString stringWithFormat:@"%@%@",personLastName,personFirstName];
    } else if (personFirstName) {
        name = personFirstName;
    } else if (personLastName) {
        name = personLastName;
    }
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    long index = ABMultiValueGetIndexForIdentifier(phone,identifier);
    NSString *phoneNO = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, index);
    phoneNO = [phoneNO stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary *temp = [@{} mutableCopy];
    temp[@"name"] = name;
    temp[@"tel"] = phoneNO;
    [_webAnalyzer callbackActionWithParam:temp.JSONString withWebView:_webView];
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person NS_AVAILABLE_IOS(8_0)
{
    ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
    personViewController.displayedPerson = person;
    [peoplePicker pushViewController:personViewController animated:YES];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person NS_DEPRECATED_IOS(2_0, 8_0)
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier NS_DEPRECATED_IOS(2_0, 8_0)
{
    return [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
}

- (void)cleanCache
{
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:_webView.request];
    _token= nil;
}

#pragma mark - 上传图片
// 保持原始图片的长宽比，生成需要尺寸的图片 width
- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }
    else{
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.width * image.size.height /image.size.width;
        
        
        CGRect rect = CGRectMake(0, 0, width, height);
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, width,height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

- (void)uploadImagesAtLast:(NSArray *)images
{
    if (!_imagesUrlMutableArray) {
        _imagesUrlMutableArray=[[NSMutableArray alloc]init];
    }
    
    if (images.count) {
        [EBAlert showLoading:nil];
        
        NSMutableArray *tmpImages = [[NSMutableArray alloc]init];
        tmpImages = [images mutableCopy];
        
        UIImage*image = [self thumbnailWithImageWithoutScale:tmpImages.firstObject size:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)];

        [tmpImages removeObjectAtIndex:0];
        __weak __typeof(self) weakSelf = self;
        [[EBHttpClient sharedInstance] dataRequest:nil uploadImage:image withHandler:^(BOOL success, id result){
            __strong __typeof(self) safeSelf = weakSelf;
            if (success) {
                [EBAlert hideLoading];
                NSLog(@"%@",result);
                if(result[@"url"]){
                   [_imagesUrlMutableArray addObject:result[@"url"]];
                }
            }
            [safeSelf uploadImagesAtLast:tmpImages];
        }];
        
    }else{
        
        [_webAnalyzer callbackActionWithParam:_imagesUrlMutableArray.JSONString withWebView:_webView];
        [_imagesUrlMutableArray removeAllObjects];
        
        [EBAlert hideLoading];
    }
}

@end
