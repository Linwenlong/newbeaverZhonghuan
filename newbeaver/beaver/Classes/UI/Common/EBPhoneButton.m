//
// Created by 何 义 on 14-3-18.
// Copyright (c) 2014 eall. All rights reserved.
//


#import "EBPhoneButton.h"
#import "EBStyle.h"
#import "EBAlert.h"
#import "ShareManager.h"
#import "RIButtonItem.h"
#import "EBController.h"
#import "UIActionSheet+Blocks.h"


@interface EBPhoneButton ()


@end

@implementation EBPhoneButton
{
   UILabel *_phoneLabel;
   UILabel *_nameLabel;
}

- (id)initWithFrameHidden:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 215, 57)];
        UIImage *bgN = [[UIImage imageNamed:@"btn_b_l_n"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        UIImage *bgP = [[UIImage imageNamed:@"btn_b_l_p"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
        btn.adjustsImageWhenHighlighted = NO;
        //        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *callIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hidden_call"]];
        callIcon.frame = CGRectOffset(callIcon.frame, 18, (57 - callIcon.frame.size.height) / 2);
        [btn addSubview:callIcon];
        
        
        
//        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 200, 20)];
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 20, 200, 20)];
        _nameLabel.textColor = [EBStyle blueTextColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.backgroundColor = [UIColor clearColor];
        [btn addSubview:_nameLabel];
        
        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 200, 20)];
        
        _phoneLabel.hidden = YES;
        
        _phoneLabel.textColor = [EBStyle blueTextColor];
        _phoneLabel.font = [UIFont systemFontOfSize:14];
        _phoneLabel.backgroundColor = [UIColor clearColor];
        [btn addSubview:_phoneLabel];
        
        [self addSubview:btn];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(230, 10, 75, 57)];
        bgN = [[UIImage imageNamed:@"btn_b_r_n"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        bgP = [[UIImage imageNamed:@"btn_b_r_p"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
        [btn setImage:[UIImage imageNamed:@"hidden_sms"] forState:UIControlStateNormal];
        btn.adjustsImageWhenHighlighted = NO;
        [btn addTarget:self action:@selector(sms:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
    }
    return self;

    
}

- (id)initWithFrame:(CGRect)frame
{
//    self = [super initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 72)];
    self = [super initWithFrame:frame];
    if (self)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 215, 57)];
        UIImage *bgN = [[UIImage imageNamed:@"btn_b_l_n"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        UIImage *bgP = [[UIImage imageNamed:@"btn_b_l_p"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
        btn.adjustsImageWhenHighlighted = NO;
//        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];

        UIImageView *callIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone_nomal"]];
        callIcon.frame = CGRectOffset(callIcon.frame, 18, (57 - callIcon.frame.size.height) / 2);
        [btn addSubview:callIcon];
        
        

        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 200, 20)];
        _nameLabel.textColor = [EBStyle blueTextColor];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.backgroundColor = [UIColor clearColor];
        [btn addSubview:_nameLabel];

        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 200, 20)];
        _phoneLabel.textColor = [EBStyle blueTextColor];
        _phoneLabel.font = [UIFont systemFontOfSize:14];
        _phoneLabel.backgroundColor = [UIColor clearColor];
        [btn addSubview:_phoneLabel];

        [self addSubview:btn];

        btn = [[UIButton alloc] initWithFrame:CGRectMake(230, 10, 75, 57)];
        bgN = [[UIImage imageNamed:@"btn_b_r_n"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        bgP = [[UIImage imageNamed:@"btn_b_r_p"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
        [btn setImage:[UIImage imageNamed:@"icon_sms"] forState:UIControlStateNormal];
        btn.adjustsImageWhenHighlighted = NO;
        [btn addTarget:self action:@selector(sms:) forControlEvents:UIControlEventTouchUpInside];

        if (_isorNotHidden) {
            callIcon.image = [UIImage imageNamed:@"hidden_call"];
            [btn setImage:[UIImage imageNamed:@"hidden_sms"] forState:UIControlStateNormal];
        }
        
        [self addSubview:btn];
    }
    return self;
}

- (id)initWithFrameCustom:(CGRect)frame
{
    self = [super initWithFrame:frame];
//    if (self)
//    {
////        CGRectMake(15, 15.5, 215, 57)
//        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15 + 148.5, 15, 110, 57)];
//        UIImage *bgN = [[UIImage imageNamed:@"btn_b_l_n"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
//        UIImage *bgP = [[UIImage imageNamed:@"btn_b_l_p"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
//        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
//        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
//        btn.adjustsImageWhenHighlighted = NO;
//        //        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIImageView *callIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_call"]];
//        callIcon.frame = CGRectOffset(callIcon.frame, 0, (57 - callIcon.frame.size.height) / 2);
//        [btn addSubview:callIcon];
//        
//        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 20)];
//        _nameLabel.textColor = [EBStyle blueTextColor];
//        _nameLabel.font = [UIFont systemFontOfSize:14];
//        _nameLabel.backgroundColor = [UIColor clearColor];
//        [btn addSubview:_nameLabel];
//        
//        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 100, 20)];
//        _phoneLabel.textColor = [EBStyle blueTextColor];
//        _phoneLabel.font = [UIFont systemFontOfSize:14];
//        _phoneLabel.backgroundColor = [UIColor clearColor];
//        [btn addSubview:_phoneLabel];
//        
//        [self addSubview:btn];
//        
//        btn = [[UIButton alloc] initWithFrame:CGRectMake(125 + 148.5, 15, 31.5, 57)];
//        bgN = [[UIImage imageNamed:@"btn_b_r_n"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
//        bgP = [[UIImage imageNamed:@"btn_b_r_p"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
//        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
//        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
//        [btn setImage:[UIImage imageNamed:@"icon_sms"] forState:UIControlStateNormal];
//        btn.adjustsImageWhenHighlighted = NO;
//        [btn addTarget:self action:@selector(sms:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self addSubview:btn];
//    }
    if (self)
    {
        //        CGRectMake(15, 15.5, 215, 57)
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width - 41.5, 57)];
        UIImage *bgN = [[UIImage imageNamed:@"btn_b_l_n"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        UIImage *bgP = [[UIImage imageNamed:@"btn_b_l_p"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
        btn.adjustsImageWhenHighlighted = NO;
        //        [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *callIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_phone_nomal"]];
        callIcon.frame = CGRectOffset(callIcon.frame, 14, (57 - callIcon.frame.size.height) / 2);
        [btn addSubview:callIcon];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(42, 10, frame.size.width - 51.5, 20)];
        _nameLabel.textColor = [EBStyle blueTextColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.backgroundColor = [UIColor clearColor];
        [btn addSubview:_nameLabel];
        
        _phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(42, 30, frame.size.width - 51.5, 20)];
        _phoneLabel.textColor = [EBStyle blueTextColor];
        _phoneLabel.font = [UIFont systemFontOfSize:14];
        _phoneLabel.backgroundColor = [UIColor clearColor];
        [btn addSubview:_phoneLabel];
        
        [self addSubview:btn];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 41.5, 0, 41.5, 57)];
        bgN = [[UIImage imageNamed:@"btn_b_r_n"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        bgP = [[UIImage imageNamed:@"btn_b_r_p"] stretchableImageWithLeftCapWidth:10 topCapHeight:3];
        [btn setBackgroundImage:bgN forState:UIControlStateNormal];
        [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
        [btn setImage:[UIImage imageNamed:@"icon_sms"] forState:UIControlStateNormal];
        btn.adjustsImageWhenHighlighted = NO;
        [btn addTarget:self action:@selector(sms:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btn];
    }
    return self;
}

- (void)call:(UIButton *)btn
{

    
    if(_phoneNumbers.count == 0 && [_phoneNumber isEqualToString:@"没有电话号码"]){
        [EBAlert alertError:@"暂无业主电话" length:2.0f];
        return;
    }
    
    if (!_isMutliPhone)
    {
        if (_isorNotHidden == YES) {//隐号通话
            self.HiddenClickCall([NSString stringWithFormat:@"%@",_phoneNumberDic[@"document_id"]],_phoneNumberDic[@"name"]);
        }else{
            UIDevice *device = [UIDevice currentDevice];
            if ([[device model] isEqualToString:@"iPhone"] ) {
            
                [EBAlert confirmWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"dial_confirm_format", nil), _phoneNumber]
                                  yes:NSLocalizedString(@"confirm_ok", nil) action:^
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _phoneNumber]]];
                }];
            }
            else
            {
                [EBAlert alertError:NSLocalizedString(@"dial_not_supported", nil)];
            }
        }
    }
    else
    {
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSInteger count = [_phoneNumbers count];
        for (int i = 0; i < count; i ++)
        {
            NSString *num = [_phoneNumbers objectAtIndex:i];
            NSString *code;
            if (_isorNotHidden == YES) {
                NSDictionary *dic = [_phoneNumbers objectAtIndex:i];
                NSLog(@"dic=%@",dic);
                NSString *document = [NSString stringWithFormat:@"%@",dic[@"document_id"]];
                code = [NSString stringWithFormat:@"%@    %@",dic[@"name"],document];
            }else{
                if ([num hasPrefix:@"0"] == 1)
                {
                    code = [NSString stringWithFormat:NSLocalizedString(@"mutli_phone_fix", nil),[_phoneNumbers     objectAtIndex:i]];
                }
                else
                {
                    code = [NSString stringWithFormat:NSLocalizedString(@"mutli_phone_mobile", nil),[_phoneNumbers objectAtIndex:i]];
                }
            }
            
            [buttons addObject:[RIButtonItem itemWithLabel:code
                                 action:^
                                {
                                    //                                    [[EBController sharedInstance] startChattingWith:@[contact] popToConversation:NO];
                                    if (_isorNotHidden == YES) {//隐号通话
                                        NSDictionary *dic = [_phoneNumbers objectAtIndex:i];
                                        NSLog(@"dic=%@",dic);
                                        NSString *document = [NSString stringWithFormat:@"%@",dic[@"document_id"]];
                                        self.HiddenClickCall(document,dic[@"name"]);
                                    }else{
                                        UIDevice *device = [UIDevice currentDevice];
                                        if ([[device model] isEqualToString:@"iPhone"] ) {
                                        
                                            [EBAlert confirmWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"dial_confirm_format", nil), [_phoneNumbers     objectAtIndex:i]]
                                                              yes:NSLocalizedString(@"confirm_ok", nil) action:^
                                            {
                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", [_phoneNumbers objectAtIndex:i]]]];
                                            }];
                                        }
                                        else
                                        {
                                            [EBAlert alertError:NSLocalizedString(@"dial_not_supported", nil)];
                                        }
                                    }
                                }]];
        }
        NSString *title;
        if (_isHouse)
        {
            title = NSLocalizedString(@"mutli_phone_title", nil);
        }
        else
        {
            title = NSLocalizedString(@"mutli_phone_title_client", nil);
        }
        [[[UIActionSheet alloc] initWithTitle:title buttons:buttons] showInView:self.view];
    }
}

//待处理
- (void)sms:(UIButton *)btn
{
    if(_phoneNumbers.count == 0 && [_phoneNumber isEqualToString:@"没有电话号码"]){
        [EBAlert alertError:@"暂无业主电话" length:2.0f];
        return;
    }
    
    if (!_isMutliPhone)
    {
        
        if (_isorNotHidden == YES) {//隐号通话
            self.HiddenClickSms([NSString stringWithFormat:@"%@",_phoneNumberDic[@"document_id"]]);
        }else{
            [[ShareManager sharedInstance] shareContent:@{@"to":_phoneNumber} withType:EShareTypeMessage handler:^(BOOL success, NSDictionary *info)
             {
             
             }];
        }
    }
    else
    {
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSInteger count = [_phoneNumbers count];
        for (int i = 0; i < count; i ++)
        {
            NSString *num = [_phoneNumbers objectAtIndex:i];
            NSString *code;
            if (_isorNotHidden == YES) {
                NSDictionary *dic = [_phoneNumbers objectAtIndex:i];
                NSLog(@"dic=%@",dic);
                NSString *document = [NSString stringWithFormat:@"%@",dic[@"document_id"]];
                code = [NSString stringWithFormat:@"%@    %@",dic[@"name"],document];
            }else{
            
                if ([num hasPrefix:@"0"] == 1)
                    {
                    code = [NSString stringWithFormat:NSLocalizedString(@"mutli_phone_fix", nil),[_phoneNumbers objectAtIndex:i]];
                    }
                else
                    {
                    code = [NSString stringWithFormat:NSLocalizedString(@"mutli_phone_mobile", nil),[_phoneNumbers objectAtIndex:i]];
                    }
            }
            [buttons addObject:[RIButtonItem itemWithLabel:code action:^
                                {
                                    
                                    if (_isorNotHidden == YES) {//隐号通话
                                        NSDictionary *dic = [_phoneNumbers objectAtIndex:i];
                                        NSLog(@"dic=%@",dic);
                                        NSString *document = [NSString stringWithFormat:@"%@",dic[@"document_id"]];
                                        self.HiddenClickSms(document);
                                    }else{
//                                    [[EBController sharedInstance] startChattingWith:@[contact] popToConversation:NO];
                                        [[ShareManager sharedInstance] shareContent:@{@"to":[_phoneNumbers objectAtIndex:i]} withType:EShareTypeMessage handler:^(BOOL success, NSDictionary *info)
                                         {
                                         
                                         }];
                                    }
                                }]];
        }
        NSString *title;
        if (_isHouse)
        {
            title = NSLocalizedString(@"mutli_phone_title", nil);
        }
        else
        {
            title = NSLocalizedString(@"mutli_phone_title_client", nil);
        }
        [[[UIActionSheet alloc] initWithTitle:title buttons:buttons] showInView:self.view];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_isorNotHidden) {
        _nameLabel.text = _contactName;
        _phoneLabel.text = _phoneNumber;
    }else{
        _nameLabel.text = _contactName;
        _phoneLabel.text = _phoneNumber;
    }
}

@end
