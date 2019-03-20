//
//  NewQRScannerViewController.m
//  beaver
//
//  Created by eall_linger on 16/3/29.
//  Copyright © 2016年 eall. All rights reserved.
//

#import "NewQRScannerViewController.h"
#import "EBHttpClient.h"
#import "ERPWebViewController.h"
#import "QRScannerView.h"
#import "EBCrypt.h"
#import "EBAlert.h"
#import "ConfirmLoginViewController.h"
#import "EBController.h"
#import "ZHDCWebViewController.h"


@interface NewQRScannerViewController ()
@property(nonatomic, copy) UIView *errorHint;

@end

@implementation NewQRScannerViewController
{
    NSMutableArray *errorStrArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self addRightNavigationBtnWithTitle:@"跳过扫码" target:self action:@selector(juhePayItem:)];
    // Do any additional setup after loading the view.
}

- (UIBarButtonItem *)addRightNavigationBtnWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                                             style:UIBarButtonItemStylePlain target:target action:action];
    [item setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.rightBarButtonItem = item;
    
    return item;
}

-(void)showHint:(NSString *)hint duration:(NSTimeInterval)duration
{
    
    [UIView animateWithDuration:duration animations:^{
        [EBAlert alertError:hint length:duration];
    } completion:^(BOOL finished) {
        [self.parentViewController.navigationController popViewControllerAnimated:YES];
    }];
    
//    [EBAlert alertError:hint length:duration];
   
    
//  [self.parentViewController.navigationController popViewControllerAnimated:YES];
    
//    _errorHint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
//    _errorHint.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 10, 10)];
//    label.font =[ UIFont systemFontOfSize:14];
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.numberOfLines = 0;
//    label.text = hint;
//    [_errorHint addSubview:label];
//    
//    CGSize size = [label sizeThatFits:CGSizeMake(250, MAXFLOAT)];
//    label.frame = CGRectMake(5, 5, size.width, size.height);
//    _errorHint.frame = CGRectMake(0, 0, size.width+10, size.height +10);
//    [self.view addSubview:_errorHint];
//    _errorHint.center = self.view.center;
//    
//    [UIView animateWithDuration:duration animations:^{
//        _errorHint .alpha = 0;
//    } completion:^(BOOL finished) {
//        [_errorHint removeFromSuperview];
//        _errorHint = nil;
//    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)popAlertMsgWithScanResult:(NSString*)strResult
{
    if (!strResult) {
        
        strResult = @"识别失败";
        [self showHint:strResult duration:3];
    }
    [self reStartDevice];
    
}
- (void)scanResultWithArray:(NSArray<LBXScanResult*>*)array
{
    if (array.count < 1)
    {
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    
    //经测试，可以同时识别2个二维码，不能同时识别二维码和条形码
    for (LBXScanResult *result in array) {
        
        NSLog(@"scanResult:%@",result.strScanned);
    }
    
    LBXScanResult *scanResult = array[0];
    
    NSString*strResult = scanResult.strScanned;
    
    self.scanImage = scanResult.imgScanned;
    
    if (!strResult) {
        
        [self popAlertMsgWithScanResult:nil];
        
        return;
    }
    [self showNextVCWithScanResult:scanResult];

}
- (void)showNextVCWithScanResult:(LBXScanResult*)strResult
{
    
    [self resultArrived:strResult.strScanned];
}
- (void)resultArrived:(NSString *)rs
{
    //    wrong   openPage:/wap/house:20456844f2f695402f658eab01588bd1e
    //     right openPage:/wap/house:20456844f2f695402f658eab01588bd1
    
 
    
        if ([rs hasPrefix:@"mse:"]) {
            NSString *Mstr = [rs substringFromIndex:4];
            
            [[EBHttpClient wapInstance] wapRequest:@{@"qrcode":Mstr} qrcode:^(BOOL success, id result) {
                if (success) {
                    NSLog(@"%@",result);
                    
                    if ([result[@"type"] isEqualToString:@"openPage"]) {
                        ERPWebViewController *webVc = [ERPWebViewController sharedInstance];
                        [webVc openWebPage:@{@"title":@"",@"url":result[@"url"]}];
                        
                        
                        [self.navigationController pushViewController:webVc animated:YES];
                    }else if ([result[@"type"] isEqualToString:@"alert"]){
                          [self showHint:result[@"url"] duration:3];
                    }
                    NSLog(@"2");
                }else{
                      [self showHint:result duration:3];
                    NSLog(@"1");
                 }
            }];
            
            return;
        }
        
        
        NSArray *info = [EBCrypt decrypt:rs];
        
        if (info)
        {
            
            if (self.shouldFetchInfo && !self.shouldFetchInfo(info))
            {
                  [self showHint:@"二维码非法" duration:3];
                  return;
            }
            
            NSString *key = info[0];
            if ([key isEqualToString:@"erp"] && [info[1] isEqualToString:@"login"])
            {
                [EBAlert showLoading:NSLocalizedString(@"status_processing", nil)];
                [[EBHttpClient sharedInstance] codeRequest:@{@"what":@1, @"code":info[2]} what:^(BOOL success, id result)
                 {
                     [EBAlert hideLoading];
                     if (success)
                     {
                         [self loginToERP:info[2]];
                     }
                     else
                     {
                         [self showHint:@"二维码非法" duration:3];
                     }
                 }];
            }
            else if ([key isEqualToString:@"house"])
            {
                [EBAlert showLoading:NSLocalizedString(@"status_processing", nil)];
                [[EBHttpClient sharedInstance] houseRequest:@{
                                                              @"id":info[2],
                                                              @"type":info[1]
                                                              } detail:^(BOOL success, id result)
                 {
                     [EBAlert hideLoading];
                     if (success)
                     {
                         if (self.infoFetched)
                         {
                             self.infoFetched(result);
                         }
                         else
                         {
                             [self.navigationController popViewControllerAnimated:NO];
                             [[EBController sharedInstance] showHouseDetail:result];
                         }
                     }
                     else
                     {
                         [self showHint:@"二维码非法" duration:3];
                     }
                 }];
                
            }
            else if ([key isEqualToString:@"client"])
            {
                // get client detail
                [EBAlert showLoading:NSLocalizedString(@"status_processing", nil)];
                [[EBHttpClient sharedInstance] clientRequest:@{
                                                               @"id":info[2],
                                                               @"type":info[1]
                                                               } detail:^(BOOL success, id result)
                 {
                     [EBAlert hideLoading];
                     if (success)
                     {
                         if (self.infoFetched)
                         {
                             self.infoFetched(result);
                         }
                         else
                         {
                             [self.navigationController popViewControllerAnimated:NO];
                             [[EBController sharedInstance] showClientDetail:result];
                         }
                     }
                     else
                     {
                         [self showHint:@"二维码非法" duration:3];
                     }
                 }];
            }
            else
            {
           
                [self showHint:@"二维码非法" duration:3];
            }
        }
        else
        {
            if (_is_JuhePay) {
                if (rs!= nil && rs.length > 0) {
                    
                    //                [self juhePay:rs];
                    NSString *url = [NSString stringWithFormat:@"%@/Housedeal/verifyContract",NewHttpBaseUrl];
                    NSDictionary *parm = @{
                                           @"token" : [EBPreferences sharedInstance].token,
                                           @"servercode" : [EBPreferences sharedInstance].companyCode,
                                           @"contract_code" : rs
                                           };
                    NSLog(@"parm=%@",parm);
                    [EBAlert showLoading:@"加载中..."];
                    [HttpTool post:url parameters:parm success:^(id responseObject) {
                        [EBAlert hideLoading];
                        //                    NSLog(@"responseObject=%@",responseObject);
                        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                        NSLog(@"result=%@",result);
                        if ([result[@"code"] integerValue] == 0){
                            if ([result[@"data"] boolValue] == YES) {
                                [self juhePay:rs];
                            }else{
                                
                                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"无效二维码" preferredStyle:UIAlertControllerStyleAlert];
                                
                                [alertVC addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    [self.parentViewController.navigationController popViewControllerAnimated:YES];
                                }]];
                                
                                [alertVC addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    [self reStartDevice];
                                }]];
                                
                                [self presentViewController:alertVC animated:YES completion:^{
                                    
                                }];
//                                [EBAlert alertError:@"无效合同" length:2.0f];
//                                [self showHint:@"无效合同" duration:3];
//                                [self reStartDevice];
                            }
                        }else{
                            [EBAlert alertError:@"数据加载失败" length:2.0f];
                        }
                            
                       
                    } failure:^(NSError *error) {
                        [EBAlert hideLoading];
                        [EBAlert alertError:@"数据加载失败" length:2.0f];
                    }];
                    
                }else{
                    
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"无效二维码" preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alertVC addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                         [self.parentViewController.navigationController popViewControllerAnimated:YES];
                    }]];
                    
                    [alertVC addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self reStartDevice];
                    }]];
                    
                    [self presentViewController:alertVC animated:YES completion:^{
                        
                    }];
                    
//                    [self showHint:@"无效合同" duration:3];
                    
                }
            }else{
                [self showHint:@"二维码非法" duration:3];
            }
        }
    
}



- (void)juhePayItem:(UIBarButtonItem *)item{
    [self juhePay:@""];
}

//聚合支付
- (void)juhePay:(NSString *)contact{
    
    NSString *url = @"http://218.65.86.80:8112/pay/getCityQuery";
    [EBAlert showLoading:@"加载中..."];
    [HttpTool post:url parameters:nil success:^(id responseObject) {
        [EBAlert hideLoading];
        
        NSDictionary *tmpdic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString *tmpStr = tmpdic[@"data"];
        NSArray *tmpArr = [NSJSONSerialization JSONObjectWithData:[tmpStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if ([tmpdic[@"code"] integerValue] == 200) {
            for (NSDictionary * dic in tmpArr) {
                NSLog(@"city = %@", dic[@"cityName"]);
                
                if ([dic[@"cityName"] isEqualToString:[EBPreferences sharedInstance].city] || [[EBPreferences sharedInstance].city containsString:dic[@"cityName"]]) {
                    NSString *mercId = dic[@"mercId"];
                    ZHDCWebViewController *webVC = [[ZHDCWebViewController alloc] init];
                    webVC.hidesBottomBarWhenPushed = YES;
                    NSString *tittleString = @"中环地产聚合支付";
                    if (contact.length > 0) {
                        webVC.homeUrl =[NSURL URLWithString:[NSString stringWithFormat:@"http://218.65.86.80:8114/index.html#/?mercId=%@&contract=%@",mercId,contact]];
                    }else{
                        webVC.homeUrl =[NSURL URLWithString:[NSString stringWithFormat:@"http://218.65.86.80:8114/index.html#/?mercId=%@",mercId]];
                    }
                    NSLog(@"homeUrl = %@",webVC.homeUrl);
                    webVC.title = tittleString;
                    NSLog(@"nav1 = %@",self.navigationController);
                    [self.navigationController pushViewController:webVC animated:YES];
                    return ;
                }
            }
            [EBAlert alertError:@"该城市暂未开通" length:2.0f];
        }else{
            [EBAlert alertError:@"数据加载失败" length:2.0f];
        }
    } failure:^(NSError *error) {
        [EBAlert hideLoading];
        [EBAlert alertError:@"数据加载失败" length:2.0f];
    }];
}

- (void)loginToERP:(NSString *)token
{
    UINavigationController *nav = self.navigationController;
    ConfirmLoginViewController *viewController = [[ConfirmLoginViewController alloc] init];
    viewController.loginToken = token;
    viewController.hidesBottomBarWhenPushed = YES;
    [nav popViewControllerAnimated:NO];
    [nav pushViewController:viewController animated:YES];
}

@end
