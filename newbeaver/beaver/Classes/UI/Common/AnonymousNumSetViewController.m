//
//  AnonymousNumSetViewController.m
//  beaver
//
//  Created by wangyuliang on 14-7-9.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "AnonymousNumSetViewController.h"
#import "EBHttpClient.h"
#import "CodeVerifyViewController.h"
#import "AnonymousCallViewController.h"
#import "EBAlert.h"
#import "SettingViewController.h"
#import "ClientDetailViewController.h"
#import "HouseDetailViewController.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"

@interface AnonymousNumSetViewController ()
{
    UITextField *_hiddenInput;
    UIBarButtonItem *_saveStep;
    UITextField *_mobileField;
    UITextField *_areaField;
    UITextField *_fixNumField;
    UITextField *_extensionField;
    NSArray *_areaCode;
    NSArray *_areaCodeForEight;
}

@end

@implementation AnonymousNumSetViewController

- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"anonymous_phone_set_title", nil);
    _saveStep = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil)
                                              target:self action:@selector(saveStep)];
    _saveStep.enabled = YES;
    if (_hiddenInput == nil)
    {
        _hiddenInput = [[UITextField alloc] initWithFrame:CGRectZero];
        _hiddenInput.keyboardType = UIKeyboardTypePhonePad;
        [self.view addSubview:_hiddenInput];
    }
//    [_hiddenInput becomeFirstResponder];
    
    if (_setType == ESetTypeFix)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, 200, 18)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = NSLocalizedString(@"anonymous_phone_set_fix", nil);
        [self.view addSubview:label];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(14, 40, 54, 40)];
        view.backgroundColor = [UIColor whiteColor];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(4, 39.5, 46, 0.5)];
        [view addSubview:line];
        line.backgroundColor = [EBStyle grayUnClickLineColor];

        _areaField = [[UITextField alloc] initWithFrame:CGRectMake(4, 0, 46, 40)];
        _areaField.font = [UIFont systemFontOfSize:14.0];
        _areaField.keyboardType = UIKeyboardTypePhonePad;
        _areaField.placeholder = NSLocalizedString(@"anonymous_fix_area_show", nil);
        [view addSubview:_areaField];
        [_areaField becomeFirstResponder];
        [self.view addSubview:view];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(68, 40, 20, 40)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = @"-";
        [self.view addSubview:label];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(88, 40, 100, 40)];
        view.backgroundColor = [UIColor whiteColor];

        line = [[UIView alloc] initWithFrame:CGRectMake(4, 39.5, 92, 0.5)];
        [view addSubview:line];
        line.backgroundColor = [EBStyle grayUnClickLineColor];

        _fixNumField = [[UITextField alloc] initWithFrame:CGRectMake(4, 0, 92, 40)];
        _fixNumField.font = [UIFont systemFontOfSize:14.0];
        _fixNumField.keyboardType = UIKeyboardTypePhonePad;
        _fixNumField.placeholder = NSLocalizedString(@"anonymous_fix_num_show", nil);
        [view addSubview:_fixNumField];
        [self.view addSubview:view];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(190, 40, 20, 40)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = NSLocalizedString(@"anonymous_phone_set_fix_show_4", nil);
        [self.view addSubview:label];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(210, 40, 100, 40)];
        view.backgroundColor = [UIColor whiteColor];

        line = [[UIView alloc] initWithFrame:CGRectMake(4, 39.5, 92, 0.5)];
        [view addSubview:line];
        line.backgroundColor = [EBStyle grayUnClickLineColor];

        _extensionField = [[UITextField alloc] initWithFrame:CGRectMake(4, 0, 92, 40)];
        _extensionField.font = [UIFont systemFontOfSize:14.0];
        _extensionField.keyboardType = UIKeyboardTypePhonePad;
        _extensionField.placeholder = NSLocalizedString(@"anonymous_fix_extension_show", nil);
        [view addSubview:_extensionField];
        [self.view addSubview:view];
    }
    else if (_setType == ESetTypeFixSingle)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, 200, 18)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = NSLocalizedString(@"anonymous_phone_set_fix", nil);
        [self.view addSubview:label];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(14, 40, 54, 40)];
        view.backgroundColor = [UIColor whiteColor];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(4, 39.5, 46, 0.5)];
        [view addSubview:line];
        line.backgroundColor = [EBStyle grayUnClickLineColor];

        _areaField = [[UITextField alloc] initWithFrame:CGRectMake(4, 0, 46, 40)];
        _areaField.font = [UIFont systemFontOfSize:14.0];
        _areaField.keyboardType = UIKeyboardTypePhonePad;
        _areaField.placeholder = NSLocalizedString(@"anonymous_fix_area_show", nil);
        [_areaField becomeFirstResponder];
        [view addSubview:_areaField];
        [self.view addSubview:view];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(68, 40, 20, 40)];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = @"-";
        [self.view addSubview:label];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(88, 40, 210, 40)];
        view.backgroundColor = [UIColor whiteColor];

        line = [[UIView alloc] initWithFrame:CGRectMake(4, 39.5, 202, 0.5)];
        [view addSubview:line];
        line.backgroundColor = [EBStyle grayUnClickLineColor];

        _fixNumField = [[UITextField alloc] initWithFrame:CGRectMake(4, 0, 202, 40)];
        _fixNumField.font = [UIFont systemFontOfSize:14.0];
        _fixNumField.keyboardType = UIKeyboardTypePhonePad;
        _fixNumField.placeholder = NSLocalizedString(@"anonymous_fix_num_show", nil);
        [view addSubview:_fixNumField];
        [self.view addSubview:view];

        UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 90, 292, 50)];
        alertLabel.numberOfLines = 0;
        alertLabel.textColor = [EBStyle redTextColor];
        alertLabel.text = NSLocalizedString(@"anonymous_fix_number_alert", nil);
        alertLabel.font = [UIFont systemFontOfSize:12.0];
        [self.view addSubview:alertLabel];
    }
    else if (_setType == ESetTypeMobile)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, 200, 18)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = [EBStyle blackTextColor];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = NSLocalizedString(@"anonymous_phone_set_mobile_title", nil);
        [self.view addSubview:label];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(14, 40, 292, 40)];
        view.backgroundColor = [UIColor whiteColor];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(4, 39.5, 284, 0.5)];
        [view addSubview:line];
        line.backgroundColor = [EBStyle grayUnClickLineColor];

        _mobileField = [[UITextField alloc] initWithFrame:CGRectMake(4, 0, 284, 40)];
        _mobileField.font = [UIFont systemFontOfSize:16.0];
        _mobileField.keyboardType = UIKeyboardTypePhonePad;
        _mobileField.placeholder = NSLocalizedString(@"anonymous_mobile_default_show", nil);
        [view addSubview:_mobileField];
        [_mobileField becomeFirstResponder];
        [self.view addSubview:view];
    }
    _areaCode = [[NSArray alloc] initWithObjects:@"010",@"021",@"022", @"023",@"0310",@"0311", @"0312", @"0313", @"0314", @"0315", @"0316", @"0317", @"0318", @"0319", @"0335", @"0349", @"0350", @"0351", @"0352", @"0353", @"0354", @"0355", @"0356", @"0357", @"0358", @"0359", @"0470", @"0471", @"0472", @"0473", @"0474", @"0475", @"0476", @"0477", @"0478", @"0479", @"0482", @"0483", @"024", @"0410", @"0411", @"0412", @"0413", @"0414", @"0415", @"0416", @"0417", @"0418", @"0419", @"0421", @"0427", @"0429", @"0431", @"0432", @"0433", @"0434", @"0435", @"0436", @"0437", @"0438", @"0439", @"0440", @"0448", @"0451", @"0452", @"0453", @"0454", @"0455", @"0456", @"0457", @"0458", @"0459", @"0464", @"0467", @"0468", @"0469", @"025", @"0510", @"0511", @"0512", @"0513", @"0514", @"0515", @"0516", @"0517", @"0518", @"0519", @"0523", @"0527", @"0570", @"0571", @"0572", @"0573", @"0574", @"0575", @"0576", @"0577", @"0578", @"0579", @"0580", @"0550", @"0551", @"0552", @"0553", @"0554", @"0555", @"0556", @"0557", @"0558", @"0559", @"0561", @"0562", @"0563", @"0564", @"0565", @"0566", @"0591", @"0592", @"0593", @"0594", @"0595", @"0596", @"0597", @"0598", @"0599", @"0790", @"0791", @"0792", @"0793", @"0794", @"0795", @"0796", @"0797", @"0798", @"0799", @"0701", @"0530", @"0531", @"0532", @"0533", @"0534", @"0535", @"0536", @"0537", @"0538", @"0539", @"0543", @"0546", @"0631", @"0632", @"0633", @"0634", @"0635", @"0370", @"0371", @"0372", @"0373", @"0374", @"0375", @"0376", @"0377", @"0378", @"0379", @"0391", @"0392", @"0393", @"0394", @"0395", @"0396", @"0398", @"027", @"0710", @"0711", @"0712", @"0713", @"0714", @"0715", @"0716", @"0717", @"0718", @"0719", @"0722", @"0724", @"0728", @"0730", @"0731", @"0732", @"0733", @"0734", @"0735", @"0736", @"0737", @"0738", @"0739", @"0743", @"0744", @"0745", @"0746", @"020", @"0660", @"0662", @"0663", @"0668", @"0750", @"0751", @"0752", @"0753", @"0754", @"0755", @"0756", @"0757", @"0758", @"0759", @"0760", @"0762", @"0763", @"0766", @"0768", @"0769", @"0770", @"0771", @"0772", @"0773", @"0774", @"0775", @"0776", @"0777", @"0778", @"0779", @"0898", @"028", @"0812", @"0813", @"0816", @"0817", @"0818", @"0825", @"0826", @"0827", @"0830", @"0831", @"0832", @"0833", @"0834", @"0835", @"0836", @"0837", @"0838", @"0839", @"0851", @"0852", @"0853", @"0854", @"0855", @"0856", @"0857", @"0858", @"0859", @"0691", @"0692", @"0870", @"0871", @"0872", @"0873", @"0874", @"0875", @"0876", @"0877", @"0878", @"0879", @"0883", @"0886", @"0887", @"0888", @"0891", @"0892", @"0893", @"0894", @"0895", @"0896", @"0897", @"029", @"0910", @"0911", @"0912", @"0913", @"0914", @"0915", @"0916", @"0917", @"0919", @"0930", @"0931", @"0932", @"0933", @"0934", @"0935", @"0936", @"0937", @"0938", @"0939", @"0941", @"0943", @"0951", @"0952", @"0953", @"0954", @"0955", @"0970", @"0971", @"0972", @"0973", @"0974", @"0975", @"0976", @"0977", @"0979", @"0901", @"0902", @"0903", @"0906", @"0908", @"0909", @"0990", @"0991", @"0992", @"0993", @"0994", @"0996", @"0997", @"0998", @"0999", nil];
    _areaCodeForEight = [[NSArray alloc] initWithObjects:@"010", @"021", @"022", @"023", @"024", @"025", @"027", @"028", @"029", @"020", @"0311", @"0371", @"0377", @"0379", @"0411", @"0451", @"0512", @"0513", @"0516", @"0510", @"0531", @"0532", @"0571", @"0574", @"0577", @"0591", @"0595", @"0755", @"0757", @"0769", nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveStep
{
    NSInteger back = -1;
    if (_setType == ESetTypeFix)
    {
        back = [self checkInputFix:_areaField.text fixNum:_fixNumField.text extension:_extensionField.text];
        if (back == 0)
        {
            [_areaField resignFirstResponder];
            [_fixNumField resignFirstResponder];
            [_extensionField resignFirstResponder];
            NSString *num = [NSString stringWithFormat:@"%@%@-%@",_areaField.text, _fixNumField.text, _extensionField.text];
            [self setNumber:num];
        }
    }
    else if (_setType == ESetTypeFixSingle)
    {
        [_areaField resignFirstResponder];
        [_fixNumField resignFirstResponder];
        [_extensionField resignFirstResponder];
        back = [self checkInputFixSingle:_areaField.text fixNum:_fixNumField.text];
        if (back == 0)
        {
            NSString *num = [NSString stringWithFormat:@"%@%@",_areaField.text, _fixNumField.text];
            [self setNumber:num];
        }
    }
    else if (_setType == ESetTypeMobile)
    {
        [_mobileField resignFirstResponder];
        back = [self checkInputMobile:_mobileField.text];
        if (back == 0)
        {
            [self setNumber:_mobileField.text];
        }
    }
}

- (NSInteger)checkInputMobile:(NSString*)input
{
    if ([input length] == 0)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_mobile_error_1", nil)];
        return -1;//!为空 请输入正确的手机号码
    }
    if ([input hasPrefix:@"+"] == 1)
    {
        if ([input hasPrefix:@"+86"] != 1)
        {
            [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_mobile_error_2", nil)];
            return -1;//!请输入中国大陆地区手机号码
        }
    }
    if ([input hasPrefix:@"00"] == 1)
    {
        if ([input hasPrefix:@"0086"] != 1)
        {
            [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_mobile_error_2", nil)];
            return -1;//!请输入手机号，请输入中国大陆地区手机号码
        }
    }
    if ([input hasPrefix:@"+"] == 1)
    {
        if (([input length] < 12) || ([input length] > 16))
        {
            [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_mobile_error_1", nil)];
            return -1;//!请输入正确的手机号码
        }
    }
    else
    {
        if (([input length] > 15) || ([input length] < 11))
        {
            [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_mobile_error_1", nil)];
            return -1;//!请输入正确的电手机号码
        }
    }
    NSString *compare = @"+0123456789";
    NSString *temp;
    for (int i = 0; i < [input length]; i ++)
    {
        temp = [input substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [compare rangeOfString:temp];
        NSInteger location = range.location;
        if (location < 0)
        {
            [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_mobile_error_1", nil)];
            return -1;//!请输入正确的手机号码
        }
    }
    return 0;//!正确
}

- (NSInteger)checkInputFix:(NSString*)areaCode fixNum:(NSString*)fixNum extension:(NSString*)exNum
{
    NSString *compare = @"0123456789";
    NSString *temp;
    if ([areaCode length] == 0)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_areacode_error_1", nil)];
        return -1;//!为空 请输入区号
    }
    if ([areaCode hasPrefix:@"0"] != 1 || [areaCode length] < 3 || [areaCode length] > 4)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_areacode_error_2", nil)];
        return -1;//!请输入正确的区号
    }
    else
    {
        for (int i = 0; i < [areaCode length]; i ++)
        {
            temp = [areaCode substringWithRange:NSMakeRange(i, 1)];
            NSRange range = [compare rangeOfString:temp];
            NSInteger location = range.location;
            if (location < 0)
            {
                [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_areacode_error_2", nil)];
                return -1;//!请输入正确的区号
            }
        }
        NSInteger codeCount = [_areaCode count];
        int i = 0;
        for (; i < codeCount; i ++)
        {
            if ([areaCode hasPrefix:_areaCode[i]] == 1)
            {
                break;
            }
        }
        if (i >= codeCount)
        {
            [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_areacode_error_2", nil)];
            return -1;//!非区号
        }
    }
    if ([fixNum length] == 0)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_fixnum_error_1", nil)];
        return -1;//!为空 请输入座机号码
    }
    if (([fixNum hasPrefix:@"0"] == 1) || [fixNum length] > 8 || [fixNum length] < 7)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_fixnum_error_2", nil)];
        return -1;//!请输入正确的座机号
    }
    else
    {
        for (int i = 0; i < [fixNum length]; i ++)
        {
            temp = [fixNum substringWithRange:NSMakeRange(i, 1)];
            NSRange range = [compare rangeOfString:temp];
            NSInteger location = range.location;
            if (location < 0)
            {
                [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_fixnum_error_2", nil)];
                return -1;//!请输入正确的座机号
            }
        }
    }
    if ([exNum length] == 0)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_extension_error_1", nil)];
        return -1;//!为空 请输入分机号
    }
    if ([exNum length] > 7)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_extension_error_2", nil)];
        return -1;//!请输入正确的分机号
    }
    else
    {
        for (int i = 0; i < [exNum length]; i ++)
        {
            temp = [exNum substringWithRange:NSMakeRange(i, 1)];
            NSRange range = [compare rangeOfString:temp];
            NSInteger location = range.location;
            if (location < 0)
            {
                [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_extension_error_2", nil)];
                return -1;//!请输入正确的分机号
            }
        }
    }
    
    return 0;//!正确
}

- (NSInteger)checkInputFixSingle:(NSString*)areaCode fixNum:(NSString*)fixNum
{
    NSString *compare = @"0123456789";
    NSString *temp;
    if ([areaCode length] == 0)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_areacode_error_1", nil)];
        return -1;//!为空 请输入区号
    }
    if ([areaCode hasPrefix:@"0"] != 1 || [areaCode length] < 3 || [areaCode length] > 4)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_areacode_error_2", nil)];
        return -1;//!请输入正确的区号
    }
    else
    {
        for (int i = 0; i < [areaCode length]; i ++)
        {
            temp = [areaCode substringWithRange:NSMakeRange(i, 1)];
            NSRange range = [compare rangeOfString:temp];
            NSInteger location = range.location;
            if (location == NSNotFound)
            {
                [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_areacode_error_2", nil)];
                return -1;//!请输入正确的区号
            }
        }
        NSInteger codeCount = [_areaCode count];
        int i = 0;
        for (; i < codeCount; i ++)
        {
            if ([areaCode compare:_areaCode[i]] == NSOrderedSame)
            {
                break;
            }
        }
        if (i >= codeCount)
        {
            [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_areacode_error_2", nil)];
            return -1;//!非区号
        }
    }
    if ([fixNum length] == 0)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_fixnum_error_1", nil)];
        return -1;//!为空 请输入座机号码
    }
    
    int i = 0;
    NSInteger codeEightCount = [_areaCodeForEight count];
    for (; i < codeEightCount ; i ++)
    {
        if ([areaCode compare:_areaCodeForEight[i]] == NSOrderedSame)
        {
            break;
        }
    }
    if (i >= codeEightCount)
    {
        if ([fixNum length] != 7)
        {
            [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_fixnum_error_2", nil)];
            return -1;//!请输入正确的座机号
        }
    }
    else
    {
        if ([fixNum length] != 8)
        {
            [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_fixnum_error_2", nil)];
            return -1;//!请输入正确的座机号
        }
    }
    
    if ([fixNum hasPrefix:@"0"] == 1)
    {
        [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_fixnum_error_2", nil)];
        return -1;//!请输入正确的座机号
    }
    else
    {
        for (int i = 0; i < [fixNum length]; i ++)
        {
            temp = [fixNum substringWithRange:NSMakeRange(i, 1)];
            NSRange range = [compare rangeOfString:temp];
            NSInteger location = range.location;
            if (location == NSNotFound)
            {
                [self inputErrorShow:NSLocalizedString(@"anonymous_phone_set_fixnum_error_2", nil)];
                return -1;//!请输入正确的座机号
            }
        }
    }
    
    return 0;//!正确
}

- (void)setNumber:(NSString *)phoneNumber
{
    [EBAlert showLoading:nil];
    NSDictionary *params = @{@"number": phoneNumber};
    [[EBHttpClient sharedInstance] accountRequest:params setNumber:^(BOOL success, id result)
    {
        [EBAlert hideLoading];
        if (success)
        {
            NSInteger doNotSupport = [result[@"do_not_support"] intValue];
            if (doNotSupport)
            {
                NSString *title = nil;
                if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                    if (title == nil) {
                        title = @"";
                    }
                }
                [[[UIAlertView alloc] initWithTitle:title
                                            message:result[@"err_desc"]
                                   cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"yes_got_it", nil) action:^
                                   {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }]
                                   otherButtonItems:nil] show];
            }
            else
            {
                NSInteger needVerify = [result[@"need_verified"] intValue];
                NSString *verifyType = result[@"verify_type"];
                if (needVerify)
                {
                    CodeVerifyViewController *codeVerifyViewController =[[CodeVerifyViewController alloc] init];
                    codeVerifyViewController.viewType = ECodeVerifyViewTypeAnonymousTel;
                    codeVerifyViewController.phoneNumber = phoneNumber;
                    codeVerifyViewController.verifyType = verifyType;
                    codeVerifyViewController.verifySuccess = ^(){
                        [EBAlert alertSuccess:nil];
                       [self goBack];
                    };
                    [self.navigationController pushViewController:codeVerifyViewController animated:YES];
                }
                else
                {

                    [EBAlert alertSuccess:nil];
                    [self goBack];
                    if (self.phoneVerifySuccess)
                    {
                        self.phoneVerifySuccess();
                    }
                }
            }
        }
    }];
}

- (void)goBack
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *popToViewController = nil;
    for (UIViewController *viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[SettingViewController class]] ||
                [viewController isKindOfClass:[HouseDetailViewController class]] ||
                [viewController isKindOfClass:[ClientDetailViewController class]])
        {
            popToViewController = viewController;
           break;
        }
    }

    if (popToViewController)
    {
        dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
        {
            [self.navigationController popToViewController:popToViewController animated:YES];
        });
    }
}

- (void)inputErrorShow:(NSString*)message
{
    NSString *title = nil;
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
        if (title == nil) {
            title = @"";
        }
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"anonymous_call_end_confirm", nil) otherButtonTitles:nil];
    [alertView show];
}

@end
