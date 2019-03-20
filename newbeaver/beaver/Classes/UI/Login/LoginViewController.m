//
//  LoginViewController.m
//  beaver
//
//  Created by 何 义 on 14-2-18.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "LoginViewController.h"
#import "MHTextField.h"
#import "CodeVerifyViewController.h"
#import "RTLabel.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "SvUDIDTools.h"
#import "EBPreferences.h"
#import "EBController.h"
#import "EBCompatibility.h"
#import "AgentGuideView.h"
#import "JSONKit.h"
#import "UIImageView+WebCache.h"
#import "JLCityListViewController.h"

@interface LoginViewController () <RTLabelDelegate, UITextFieldDelegate, UIScrollViewDelegate>
{
    MHTextField *_companyNo;
    MHTextField *_account;
    MHTextField *_pwd;
    UIScrollView *_scrollView;
    UIImageView *_logoView;
    BOOL _animationPlayed;
    UIButton *_btn_city;
    
    NSString *company_name;
    NSString *company_code;
}

@end

@implementation LoginViewController

- (void)loadView
{
    [super loadView];
	// Do any additional setup after loading the view.
    self.view.backgroundColor =  AppMainColor(1);
    [self setupLoginView];
    //引导图
    [self setupGuideView];
    self.wantsFullScreenLayout = YES;
    [self.navigationController setNavigationBarHidden:YES];
//    //不透明
    _scrollView.layer.opacity = 0;
    _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_login"]];
    NSLog(@"_logoView.frame.size.width=%f",_logoView.frame.size.width);
    _logoView.frame = CGRectOffset(_logoView.frame, ([EBStyle screenWidth] - _logoView.frame.size.width) / 2, [EBStyle loginLogoOffsetY]);
    [self.view addSubview:_logoView];

}

- (void)setupGuideView
{
    AgentGuideView *guideView = [[AgentGuideView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    CGPoint centerPt = guideView.center;
    centerPt.x = -[EBStyle screenWidth]/2.0f;
    guideView.center = centerPt;

    __weak LoginViewController *weakSelf = self;
    
    //回调后完成引导功能
    guideView.finishGuide = ^(){
        //第一次使用弱引用
      [UIView animateWithDuration:1.0 animations:^
      {
          __strong LoginViewController *strongSelf = weakSelf;
          [strongSelf showLoginView];
      }];
    };

    [self.view addSubview:guideView];

    guideView.tag = 9999;
    
    //加手势支持从登录返回引导页
    UISwipeGestureRecognizer *gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showGuideViewBySwip)];
    gestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [_scrollView addGestureRecognizer:gestureRecognizer];
}

#define LOGIN_Y_START 55.0
#define LOGIN_X_MARGIN 15.0
#define LOGIN_FIELD_HEIGHT 44.0
#define LOGIN_LABEL_HEIGHT 20.0
#define LOGIN_FIELD_GAP 1.0
#define LOGIN_LOGO_HEIGHT 72.0
#define LOGIN_DESC_HEIGHT 100.0
#define LOGIN_BTN_HEIGHT 36
#define LOGIN_GAP_BOTTOM 0.0
#define LOGIN_BTN_GAP 30.0

- (void)setupLoginView
{
    CGFloat yOffset = LOGIN_Y_START;
    //    if ([EBStyle isUnder_iPhone5])
    //    {
    //        yOffset -= 10;
    //    }
    
    CGFloat scrollHeight = self.view.frame.size.height;
    if (![EBCompatibility isIOS7Higher])
    {
        scrollHeight += 20;
    }
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0,
                                                                 self.view.frame.size.width, scrollHeight)];
    //保持垂直方向有弹簧效果
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    // logo
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, yOffset, self.view.frame.size.width,LOGIN_LOGO_HEIGHT)];
    
    logoView.contentMode = UIViewContentModeCenter;
    logoView.image = [UIImage imageNamed:@"logo_login"];
    [_scrollView addSubview:logoView];
    
    // title
    yOffset += LOGIN_LOGO_HEIGHT + 15;
    [_scrollView addSubview:[self centerAlignedLabelWithOffsetY:yOffset fontSize:18.0
                                                          title:NSLocalizedString(@"app_title", nil) color:[UIColor whiteColor]]];
    
    // company number (城市编号)
    yOffset += LOGIN_FIELD_HEIGHT + LOGIN_FIELD_GAP;
//    _companyNo = [self addTextFieldWithOffsetY:yOffset
//                                   placeholder:NSLocalizedString(@"placeholder_company", nil) superView:_scrollView withOffx:LOGIN_X_MARGIN];
    _companyNo = [self addTextFieldWithOffsetY:yOffset
                                   placeholder:@"" superView:_scrollView withOffx:LOGIN_X_MARGIN];
//    _companyNo.userInteractionEnabled = NO;
    _companyNo.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _companyNo.returnKeyType = UIReturnKeyNext;
    
    //add city select
    
    UIImageView *iamgeView = [[UIImageView alloc]initWithFrame:CGRectMake(_companyNo.width-10, (_companyNo.height-12)/2.0f, 7, 12)];
    iamgeView.image = [UIImage imageNamed:@"jiantou"];
    [_companyNo addSubview:iamgeView];
    
    _btn_city = [[UIButton alloc]initWithFrame:CGRectMake(0, 0,_companyNo.width, _companyNo.height-2)];
//    _btn_city.hidden = YES;//修改新的登录关闭
    [_btn_city setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [_btn_city setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    _btn_city.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_btn_city addTarget:self action:@selector(selectCity:) forControlEvents:UIControlEventTouchUpInside];
    _btn_city.titleLabel.font = [UIFont systemFontOfSize:18.0f];
    
    [_companyNo addSubview:_btn_city];
    
    yOffset += LOGIN_FIELD_HEIGHT + LOGIN_FIELD_GAP;
    
    _account = [self addTextFieldWithOffsetY:yOffset
                placeholder:NSLocalizedString(@"placeholder_account", nil) superView:_scrollView withOffx:LOGIN_X_MARGIN];
    _account.returnKeyType = UIReturnKeyNext;
    
    // member login password
    yOffset += LOGIN_FIELD_GAP + LOGIN_FIELD_HEIGHT;
    _pwd = [self addTextFieldWithOffsetY:yOffset
                             placeholder:NSLocalizedString(@"placeholder_pwd", nil) superView:_scrollView withOffx:LOGIN_X_MARGIN];
    [_pwd setSecureTextEntry:YES];
    _pwd.returnKeyType = UIReturnKeyGo;
    
    // to adjust the keyboard tool bar.（适应键盘工具条）
    [_companyNo markTextFieldsWithTagInView:_scrollView];
    [_account markTextFieldsWithTagInView:_scrollView];
    [_pwd markTextFieldsWithTagInView:_scrollView];
    
    //获取保存了的设置(如果有则直接获取)
    EBPreferences *pref = [EBPreferences sharedInstance];
    _account.text = pref.userAccount;
    
    
    NSLog(@"city=%@",pref.city);
    
    if ([pref.city isEqualToString:@""] || pref.city == nil) {
        [_btn_city setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.5] forState:UIControlStateNormal];
        [_btn_city setTitle:@"城市" forState:UIControlStateNormal];
    }else{
        [_btn_city setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_btn_city setTitle:pref.city forState:UIControlStateNormal];
        company_code = pref.companyCode;//编号
    }
    
    // login button
    yOffset += LOGIN_BTN_GAP + LOGIN_FIELD_HEIGHT;
    //    if ([EBStyle isUnder_iPhone5])
    //    {
    //        yOffset -= 10;
    //    }
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(LOGIN_X_MARGIN, yOffset,
                                                               self.view.frame.size.width - 2 * LOGIN_X_MARGIN, LOGIN_BTN_HEIGHT)];
    UIImage *bgN = [[UIImage imageNamed:@"btn_login_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
    UIImage *bgP = [[UIImage imageNamed:@"btn_login_pressed"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
    [btn setBackgroundImage:bgN forState:UIControlStateNormal];
    [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
    btn.adjustsImageWhenHighlighted = NO;
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btn setTitle:NSLocalizedString(@"btn_login", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:btn];
    
    // describe
    yOffset = self.view.frame.size.height - LOGIN_GAP_BOTTOM - LOGIN_DESC_HEIGHT;
    
    if (![EBCompatibility isIOS7Higher]){
        yOffset += 20;
    }
    //下面的版权
    RTLabel *desc = [[RTLabel alloc]
                     initWithFrame:CGRectMake(0.0, yOffset, self.view.frame.size.width, LOGIN_DESC_HEIGHT)];
    desc.linkAttributes = @{@"underline":@"0"};
    desc.selectedLinkAttributes = @{@"color":@"#FFFFFF"};
    desc.text = NSLocalizedString(@"app_description", nil);
    desc.font = [UIFont systemFontOfSize:12.0];
    desc.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    desc.textAlignment = RTTextAlignmentCenter;
    desc.delegate = self;
    [_scrollView addSubview:desc];
}

- (void)selectCity:(UIButton *)btn{
    //跳转页面选择城市
    NSLog(@"选择城市");
    JLCityListViewController *JLCity = [[JLCityListViewController alloc]init];
    JLCity.hidesBottomBarWhenPushed = YES;
    JLCity.current_city = _btn_city.titleLabel.text;
    JLCity.returnBlock = ^(NSString *name, NSString *code){
        NSLog(@"company_name = %@",name);
        NSLog(@"company_code = %@",code);
        company_name = name;
        [_btn_city setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btn_city setTitle:name forState:UIControlStateNormal];
        company_code = code;
    };
    [self.navigationController pushViewController:JLCity animated:YES];
}

//显示loginview
- (void)showLoginView
{
    //没有动画的时候 走动画效果
    if (!_animationPlayed)
    {
        [UIView animateWithDuration:1.0 delay:0.1 options:0 animations:^
        {
             CGRect frame = _logoView.frame;
             frame.origin.y = 55;
             _logoView.frame = frame;
         } completion:^(BOOL finished)
         {
             [self.view bringSubviewToFront:_scrollView];
             [UIView animateWithDuration:0.5 animations:^
              {
                  _scrollView.layer.opacity = 1.0;
                  _logoView.layer.opacity = 0.0;
              } completion:^(BOOL finishedB){
//                [self showGuideView];
              }];
         }];
        _animationPlayed = YES;
    }
    UIView *guideView = [self.view viewWithTag:9999];
    CGPoint centerPt = guideView.center;
    centerPt.x = -[EBStyle screenWidth]/2.0f;
    [UIView animateWithDuration:1.0 animations:^
    {
        guideView.center = centerPt;
    } completion:^(BOOL finished){
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
}

- (void)showGuideView:(BOOL)animated
{
    [_companyNo resignFirstResponder];
    [_account resignFirstResponder];
    [_pwd resignFirstResponder];
    
    AgentGuideView *guideView  = (AgentGuideView *)[self.view viewWithTag:9999];
    CGPoint centerPt = guideView.center;
    centerPt.x = [EBStyle screenWidth]/2.0f;
    [self.view bringSubviewToFront:guideView];
    guideView.page = 0;
    if (animated)
    {
        [UIView animateWithDuration:1.0 animations:^
         {
             guideView.center = centerPt;
         } completion:^(BOOL finished){
             [[UIApplication sharedApplication] setStatusBarHidden:YES];
         }];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        guideView.center = centerPt;
    }
    
}

- (void)showGuideViewBySwip
{
    [self showGuideView:YES];
}


- (void)viewDidLoad
{
    [self showGuideView:NO];
    
    
    //监测登录的通知
    [EBController observeNotification:@"refreshAnimation" from:self selector:@selector(animationAction:)];
}

- (void)animationAction:(NSNotification *)nofi{

    CATransition * anim = [CATransition animation];
    anim.type = @"pageCurl";
    anim.duration = 0.5;
    [self.view.layer addAnimation:anim forKey:@"animation"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self showGuideView];
//    if (!_animationPlayed)
//    {
//        [UIView animateWithDuration:1.0 delay:0.1 options:0 animations:^
//        {
//            CGRect frame = _logoView.frame;
//            frame.origin.y = 55;
//            _logoView.frame = frame;
//        } completion:^(BOOL finished)
//        {
//            [self.view bringSubviewToFront:_scrollView];
//            [UIView animateWithDuration:0.5 animations:^
//            {
//                _scrollView.layer.opacity = 1.0;
//                _logoView.layer.opacity = 0.0;
//            } completion:^(BOOL finishedB){
//               [self showGuideView];
//            }];
//        }];
//        _animationPlayed = YES;
//    }
    
    

}

- (void)loginClicked:(UIButton *)btn
{
    [_companyNo resignFirstResponder];
    [_account resignFirstResponder];
    [_pwd resignFirstResponder];
    [_scrollView setContentOffset:CGPointMake(0, 0)];
//判断[_companyNo validate]
    if ((_btn_city.titleLabel.text.length
        != 0 && ![_btn_city.titleLabel.text isEqualToString:@"城市"]) && [_account validate] && [_pwd validate])
    {
        
//        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)([[NSDate date] timeIntervalSince1970]*1000)];
//        NSString *jsonUrl = [NSString stringWithFormat:BEAVER_AUTHORIZE_JSON_URL,(long)arc4random()/1000000];
//        
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:jsonUrl]];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//        NSString *baseUrl = dict[@"url"];
////        NSString *baseUrl = [[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//        if ([baseUrl hasPrefix:@"http"]) {
//            [EBPreferences sharedInstance].baseUrl = baseUrl;
//            [[EBPreferences sharedInstance] writePreferences];
//        }else{
//            [EBAlert alertError:@"未获取到服务器地址"];
//            return;
//        }

        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
//        parameters[@"company_code"] = _companyNo.text;
        parameters[@"company_code"] = company_code;
        parameters[@"passwd"] = _pwd.text;
        parameters[@"account"] = _account.text;
        parameters[@"udid"] = [SvUDIDTools UDID];
        parameters[@"phonetype"] = [UIDevice currentDevice].model;
//        parameters[@"udid"] = @"8898dd76";

//        [EBAlert showLoading:NSLocalizedString(@"loading_login", nil)];
        [EBAlert showLoading:NSLocalizedString(@"loading_login", nil) allowUserInteraction:NO];
        [[EBHttpClient sharedInstance] accountRequest:parameters login:^(BOOL success, id result)
        {
            [EBAlert hideLoading];
            if (success)
            {
                NSDictionary *loginInfo = ((NSDictionary *)result)[@"login"];
                NSLog(@"loginInfo=%@",loginInfo);
                EBPreferences *pref     = [EBPreferences sharedInstance];
                
                //后台图片为0或者后台没有这个字段的时 自动设置为10
                if ([loginInfo[@"image_num_limit"] integerValue] == 0 || ![loginInfo.allKeys containsObject:@"image_num_limit"]) {
                    pref.image_num_limit = @"10";
                }else{
                    pref.image_num_limit = [NSString stringWithFormat:@"%@",loginInfo[@"image_num_limit"]];
                }
                
                pref.photo = loginInfo[@"photo"];
                pref.userAccount        = _account.text;
                pref.userPassword       = _pwd.text;
                pref.companyCode        = company_code;
                pref.city_name          = company_name;//城市名字
                pref.companyName        = loginInfo[@"company_name"];
                pref.userName           = loginInfo[@"user_name"];
                pref.storeName          = loginInfo[@"dept_name"];
                pref.city               = loginInfo[@"city"];
                pref.wapUrl             = loginInfo[@"wap_url"];
                pref.wapToken           = loginInfo[@"wap_token"];
                pref.wapMainUrl         = loginInfo[@"wap_main_url"];
                pref.xmppDomainUrl      = loginInfo[@"xmpp_domain"];
                pref.xmppDomainPort     = loginInfo[@"xmpp_domain_port"];
                pref.shareUrl           = loginInfo[@"share_url"];
                pref.cal_url            = loginInfo[@"cal_url"];
                pref.dept_id      =  loginInfo[@"dept_id"];
                pref.dept_name      =  loginInfo[@"dept_name"];
//                pref.anonymouCallNumber = loginInfo[@"anonymous_call_number"];
                if (![pref.userId isEqualToString:loginInfo[@"user_id"]])
                {
                    pref.userId = loginInfo[@"user_id"];
                    pref.deviceToken = @"";
                }
                NSDictionary *tokenInfo = loginInfo[@"token"];
                if (tokenInfo != nil)
                {
                    pref.token = tokenInfo[@"token"];
                    pref.tokenLife = [tokenInfo[@"expire"] integerValue] - [tokenInfo[@"time"] integerValue];
                    pref.loginTime = [NSDate date].timeIntervalSince1970;
                    //写入
                    [pref writePreferences];
//                    [EBController accountLoggedIn];
                    [EBController accountLoggedIn:self];
                    NSLog(@"login = %@",self);
                    
                }
                else
                {
                   [self verifyCode:loginInfo];
                }
            }
        }];
    }
    else
    {
        NSMutableArray *needFields = [[NSMutableArray alloc] init];
         //修改新的界面打开
        if ([_btn_city.titleLabel.text isEqualToString:@"城市"]||[_btn_city.titleLabel.text isEqualToString:@""])
        {
            [needFields addObject:_btn_city.titleLabel.text];
        }
       
//        if (!_companyNo.validate)
//        {
//            [needFields addObject:_companyNo.placeholder];
//        }
        if (!_account.validate)
        {
            [needFields addObject:_account.placeholder];
        }
        if (!_pwd.validate)
        {
            [needFields addObject:_pwd.placeholder];
        }
#pragma mark -- 重点
        
        [EBAlert alertWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"login_input", nil),
                        [needFields componentsJoinedByString:@"、"]]confirm:^{

        }];
    }
}
#pragma mark -- 验证码验证
-(void) verifyCode:(NSDictionary *)loginInfo
{
    EBPreferences *pref = [EBPreferences sharedInstance];
    CodeVerifyViewController *controller = [[CodeVerifyViewController alloc] init];
    controller.userName = pref.userName;
    controller.phoneNumber = loginInfo[@"phone"];

    if (loginInfo[@"ticket"] != nil)
    {
        pref.ticket = loginInfo[@"ticket"];
        controller.verifyCode = loginInfo[@"verify_code"];
        [pref writePreferences];
    }
    else
    {
        controller.badPhoneNumber = YES;
//      pref.ticket = @"3456";
//      controller.verifyCode = @"1234";
    }
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark -- UILable And UItextField
- (UILabel *)centerAlignedLabelWithOffsetY:(CGFloat)yOffset fontSize:(CGFloat)size title:(NSString *)title
                                     color:(UIColor *) color
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, yOffset, self.view.frame.size.width,
            LOGIN_LABEL_HEIGHT)];
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:color];
    [label setText:title];
    [label setFont:[UIFont systemFontOfSize:size]];

    return label;
}

- (MHTextField *)addTextFieldWithOffsetY:(CGFloat)yOffset placeholder:(NSString *)placeholder superView:(UIView *)superView withOffx:(CGFloat)offx
{
    CGFloat textFieldHeight = 44;

    if (![EBCompatibility isIOS7Higher])
    {
        textFieldHeight = 34;
        yOffset += 10;
    }

    CGFloat fieldWidth = self.view.frame.size.width - 2 * LOGIN_X_MARGIN;
    MHTextField *textField = [[MHTextField alloc] initWithFrame:CGRectMake(offx, yOffset,
            fieldWidth, textFieldHeight)];
 
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.hideToolBar = YES;
    textField.placeholder = placeholder;
    textField.textColor = [UIColor whiteColor];
    textField.font = [UIFont systemFontOfSize:18.0f];
    textField.backgroundColor = self.view.backgroundColor;
//    textField.tintColor = [UIColor whiteColor];
    textField.placeholderColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    textField.delegate = self;
    [textField setRequired:YES];

    [superView addSubview:textField];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(LOGIN_X_MARGIN, yOffset + textFieldHeight, fieldWidth, 0.5f)];
    line.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [superView addSubview:line];

    return textField;
}

#pragma mark -- Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_companyNo resignFirstResponder];
    [_account resignFirstResponder];
    [_pwd resignFirstResponder];
    [_scrollView setContentOffset:CGPointMake(0, 0)];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    MHTextField *mhTextField = (MHTextField *)textField;
    if (mhTextField == _pwd)
    {
        [self loginClicked:nil];
    }
    else
    {
        [mhTextField nextButtonIsClicked:nil];
    }
    return NO;
}


- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    [[EBController sharedInstance] openURL:url];
}

@end
