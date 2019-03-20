//
//  EBFollowLogAddView.m
//  beaver
//
//  Created by wangyuliang on 14-7-23.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBFollowLogAddView.h"
#import "CustomIOS7AlertView.h"
#import "EBStyle.h"
#import "EBHttpClient.h"
#import "EBAlert.h"

@interface EBFollowLogAddView () <UITextViewDelegate>
{
    UITextView *_note;
    NSMutableDictionary *_noteDic;
    UILabel *_placeholder;
    CustomIOS7AlertView *_alertView;
}

@end

@implementation EBFollowLogAddView

//- (EBFollowLogAddView*)initCustom:(CGRect)frame setType:(EBSetFollowLogType)setType normal
//{
//    EBFollowLogAddView *alert = [[EBFollowLogAddView alloc] init];
//    
//    return alert;
//}

+ ( EBFollowLogAddView*)sharedInstance
{
    static EBFollowLogAddView  *_sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[self alloc] init];
        isShow = NO;
    });
    return _sharedInstance;
}

+ (BOOL)getShowState
{
    return isShow;
}

- (void)close
{
    if (isShow && _alertView) {
        [_alertView close];
        isShow = NO;
    }
}

- (void)showSetFollowLogView:(BOOL)normal
{
    if (!_noteDic)
    {
        _noteDic = [[NSMutableDictionary alloc] init];
    }
    if (!isShow || !_alertView)
    {
        [self createAlertView:normal];
    }
    if(_processType == EBProcessTypeBegin)
    {
        [_alertView.containerView viewWithTag:101].hidden = NO;
        [_alertView.containerView viewWithTag:102].hidden = YES;
        [_alertView.containerView viewWithTag:103].hidden = YES;
    }
    if(_processType == EBProcessTypeWait)
    {
        [_alertView.containerView viewWithTag:101].hidden = YES;
        [_alertView.containerView viewWithTag:102].hidden = NO;
        [_alertView.containerView viewWithTag:103].hidden = YES;
    }
    if(_processType == EBProcessTypeEnd)
    {
        [_alertView.containerView viewWithTag:101].hidden = YES;
        [_alertView.containerView viewWithTag:102].hidden = YES;
        [_alertView.containerView viewWithTag:103].hidden = NO;
    }
    if (!isShow)
    {
        isShow = YES;
        [_alertView show];
    }
}

- (void)createAlertView:(BOOL)normal
{
    _alertView = [[CustomIOS7AlertView alloc] init];
    [_alertView setButtonTitles:nil];
    UIView *begin = [self setBeginView:normal];
    UIView *wait = [self setWaitView];
    UIView *end = [self setEndView];
    UIView *container = [[UIView alloc] initWithFrame:_curFrame];
    [container addSubview:begin];
    [container addSubview:wait];
    [container addSubview:end];
    [_alertView setContainerView:container];
}

- (UIView*)createContainerView:(NSInteger)tag
{
    UIView *containerView = [[UIView alloc] initWithFrame:_curFrame];
    containerView.tag = tag;
    UIButton *backBtn = [[UIButton alloc] initWithFrame:containerView.bounds];
    [backBtn addTarget:self action:@selector(textFieldEndEdit:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn.layer setCornerRadius:10.0];
    backBtn.backgroundColor = [UIColor whiteColor];
    [containerView addSubview:backBtn];
    return containerView;
}

- (UILabel*)createLabel:(CGRect)frame title:(NSString*)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [EBStyle blackTextColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = title;
    label.numberOfLines = 0;
    return label;
}

- (UIButton*)createCheckBtn:(CGRect)frame title:(NSString*)title target:(id)target action:(SEL)action
{
    UIImage *bgN = [[UIImage imageNamed:@"btn_blue_normal"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIImage *bgP = [[UIImage imageNamed:@"btn_blue_pressed"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
    UIButton *checkIn = [[UIButton alloc] initWithFrame:frame];
    
    [checkIn setBackgroundImage:bgN forState:UIControlStateNormal];
    [checkIn setBackgroundImage:bgP forState:UIControlStateHighlighted];
    checkIn.adjustsImageWhenHighlighted = NO;
    [checkIn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
    [checkIn setTitle:title forState:UIControlStateNormal];
    checkIn.titleLabel.font = [UIFont systemFontOfSize:16];
    [checkIn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return checkIn;
}

- (void)addNoteView:(UIView*)containerView frame:(CGRect)frame default:(NSString*)text placeholder:(NSString*)placeText type:(EBProcessType)process
{
    if (process == EBProcessTypeBegin)
    {
        NSInteger gap = 3;
        UIView *noteBackView = [[UIView alloc] initWithFrame:frame];
        noteBackView.backgroundColor = [UIColor colorWithRed:252/255.f green:242/255.f blue:176/255.f alpha:1.0];
        
        _note = [[UITextView alloc] initWithFrame:CGRectMake(gap, 0, frame.size.width - 2 * gap, frame.size.height)];
        _note.tag = 100 + process;
        [_noteDic setObject:_note forKey:[NSString stringWithFormat:@"%ld",process]];
        _note.font = [UIFont systemFontOfSize:14.0];
        _note.keyboardType = UIKeyboardTypeDefault;
        _note.returnKeyType = UIReturnKeyDone;
        if (text)
        {
            _note.text = text;
        }
        _note.delegate = self;
        _note.backgroundColor = [UIColor colorWithRed:252/255.f green:242/255.f blue:176/255.f alpha:1.0];
        
        _note.hidden = NO;
        _note.textColor = [EBStyle blackTextColor];
        _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(_note.frame.origin.x + 4, _note.frame.origin.y + 5, _note.frame.size.width, 20)];
        _placeholder.font = [UIFont systemFontOfSize:14.0];
        _placeholder.textAlignment = NSTextAlignmentLeft;
        _placeholder.textColor = [EBStyle grayTextColor];
        if (placeText)
        {
            _placeholder.text = placeText;
        }
        [noteBackView addSubview:_note];
        [noteBackView addSubview:_placeholder];
        [containerView addSubview:noteBackView];
    }
    else
    {
        NSInteger gap = 4;
        UIView *noteBackView = [[UIView alloc] initWithFrame:frame];
        noteBackView.backgroundColor = [UIColor colorWithRed:252/255.f green:242/255.f blue:176/255.f alpha:1.0];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(gap, 0, frame.size.width - 2 * gap, frame.size.height)];
        [_noteDic setObject:label forKey:[NSString stringWithFormat:@"%ld",process]];
        label.backgroundColor = [UIColor colorWithRed:252/255.f green:242/255.f blue:176/255.f alpha:1.0];
        label.numberOfLines = 0;
        label.textColor = [EBStyle grayTextColor];
        label.font = [UIFont systemFontOfSize:14.0];
        [noteBackView addSubview:label];
        [containerView addSubview:noteBackView];
    }
}

- (UIView*)setBeginView:(BOOL)normal
{
    UIView *containerView;
    if (_setFollowType == EBSetFollowLogForHouse)
    {
        NSInteger narrow = 0;
        if ([_follow[@"community"] isKindOfClass:[NSNull class]]) {
            narrow = 20;
        }
        containerView = [self createContainerView:101 - narrow];
        
        [containerView addSubview:[self createLabel:CGRectMake(0, 20, 270, 20) title:NSLocalizedString(@"followlog_add_text_1", nil)]];
        if (![_follow[@"community"] isKindOfClass:[NSNull class]])
        {
            if ([_follow[@"building_num"] isKindOfClass:[NSNull class]])
            {
                [containerView addSubview:[self createLabel:CGRectMake(0, 40, 270, 20) title:[NSString stringWithFormat:@"%@",_follow[@"community"]]]];
            }
            else
            {
                [containerView addSubview:[self createLabel:CGRectMake(0, 40, 270, 20) title:[NSString stringWithFormat:@"%@ %@",_follow[@"community"] , _follow[@"building_num"]]]];
            }
        }
        
        [containerView addSubview:[self createLabel:CGRectMake(0, 60 - narrow, 270, 20) title:[NSString stringWithFormat:NSLocalizedString(@"followlog_add_text_2", nil),_follow[@"owner"]]]];
        [containerView addSubview:[self createLabel:CGRectMake(14, 85 - narrow, 242, 60) title:NSLocalizedString(@"followlog_add_text_3", nil)]];
        [self addNoteView:containerView frame:CGRectMake(14, 160 - narrow, 242, 44) default:nil placeholder:NSLocalizedString(@"followlog_add_placeholder", nil) type:EBProcessTypeBegin];
        
        UIButton *checkIn = [self createCheckBtn:CGRectMake(14, 225 - narrow, 242, 36) title:NSLocalizedString(@"followlog_add_commit", nil) target:self action:@selector(submitNote:)];
        [containerView addSubview:checkIn];
        
        UILabel *warn = [[UILabel alloc] initWithFrame:CGRectMake(0, 265 - narrow, 270, 20)];
        warn.textAlignment = NSTextAlignmentCenter;
        warn.textColor = [EBStyle redTextColor];
        warn.font = [UIFont systemFontOfSize:12.0];
        warn.text = NSLocalizedString(@"followlog_add_warn", nil);
        [containerView addSubview:warn];
    }
    else
    {
        containerView = [self createContainerView:101];//CGRectMake(0, 0, 270, 280)
        
        [containerView addSubview:[self createLabel:CGRectMake(0, 20, 270, 20) title:NSLocalizedString(@"followlog_add_text_1", nil)]];
        NSString *format;
        if ([_follow[@"type"] compare:@"sale" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            format = NSLocalizedString(@"followlog_add_client_name_format_sale", nil);
        }
        else if ([_follow[@"type"] compare:@"rent" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            format = NSLocalizedString(@"followlog_add_client_name_format_rent", nil);
        }
        else
        {
            format = NSLocalizedString(@"followlog_add_client_name_format_both", nil);
        }
        [containerView addSubview:[self createLabel:CGRectMake(0, 40, 270, 20) title:[NSString stringWithFormat:format, _follow[@"name"]]]];
        [containerView addSubview:[self createLabel:CGRectMake(14, 65, 242, 60) title:NSLocalizedString(@"followlog_add_text_3", nil)]];
        
        [self addNoteView:containerView frame:CGRectMake(14, 140, 242, 44) default:nil placeholder:NSLocalizedString(@"followlog_add_placeholder", nil) type:EBProcessTypeBegin];
        
        UIButton *checkIn = [self createCheckBtn:CGRectMake(14, 205, 242, 36) title:NSLocalizedString(@"followlog_add_commit", nil) target:self action:@selector(submitNote:)];
        [containerView addSubview:checkIn];
        
        UILabel *warn = [[UILabel alloc] initWithFrame:CGRectMake(0, 245, 270, 20)];
        warn.textAlignment = NSTextAlignmentCenter;
        warn.textColor = [EBStyle redTextColor];
        warn.font = [UIFont systemFontOfSize:12.0];
        warn.text = NSLocalizedString(@"followlog_add_warn", nil);
        [containerView addSubview:warn];
    }
    if (!normal)
    {
        UIImage *image = [UIImage imageNamed:@"icon_note_close"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectOffset(imageView.frame, 250 - imageView.frame.size.width, 15);
        [containerView addSubview:imageView];
    }
    return containerView;
}

- (UIView*)setWaitView
{
    UIView *containerView;
    if (_setFollowType == EBSetFollowLogForHouse)
    {
        containerView = [self createContainerView:102];
        
        UIActivityIndicatorView *activeView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activeView.center = CGPointMake(containerView.bounds.size.width/2.0f, 60);
        activeView.color = [UIColor grayColor];
        [activeView startAnimating];
        [containerView addSubview:activeView];
        
        UILabel *label = [self createLabel:CGRectMake(0, 90, 270, 20) title:NSLocalizedString(@"followlog_add_commiting", nil)];
        [containerView addSubview:label];
        
        [self addNoteView:containerView frame:CGRectMake(14, 160, 242, 44) default:nil placeholder:NSLocalizedString(@"followlog_add_placeholder", nil) type:EBProcessTypeWait];
    }
    else
    {
        containerView = [self createContainerView:102];
        
        UIActivityIndicatorView *activeView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activeView.center = CGPointMake(containerView.bounds.size.width/2.0f, 60);
        activeView.color = [UIColor grayColor];
        [activeView startAnimating];
        [containerView addSubview:activeView];
        
        [containerView addSubview:[self createLabel:CGRectMake(0, 90, 270, 20) title:NSLocalizedString(@"followlog_add_commiting", nil)]];
        
        [self addNoteView:containerView frame:CGRectMake(14, 160, 242, 44) default:nil placeholder:NSLocalizedString(@"followlog_add_placeholder", nil) type:EBProcessTypeWait];
    }
    return containerView;
}

- (UIView*)setEndView
{
    UIView *containerView;
    if (_setFollowType == EBSetFollowLogForHouse)
    {
        containerView = [self createContainerView:103];//CGRectMake(0, 0, 270, 300)
        
        UIImage *image = [UIImage imageNamed:@"icon_note_sucess"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectOffset(imageView.frame, ( 270 - imageView.frame.size.width) / 2, 40);
        [containerView addSubview:imageView];
        
        UILabel *label = [self createLabel:CGRectMake(0, 110, 270, 20) title:NSLocalizedString(@"followlog_add_committed", nil)];
        [containerView addSubview:label];
        
        [self addNoteView:containerView frame:CGRectMake(14, 160, 242, 44) default:nil placeholder:NSLocalizedString(@"followlog_add_placeholder", nil) type:EBProcessTypeEnd];
        
        UIButton *checkIn = [self createCheckBtn:CGRectMake(14, 225, 242, 36) title:@"好的" target:self action:@selector(endSetNote:)];
        [containerView addSubview:checkIn];
    }
    else
    {
        containerView = [self createContainerView:103];//CGRectMake(0, 0, 270, 280)
        
        UIImage *image = [UIImage imageNamed:@"icon_note_sucess"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectOffset(imageView.frame, ( 270 - imageView.frame.size.width) / 2, 40);
        [containerView addSubview:imageView];
        
        [containerView addSubview:[self createLabel:CGRectMake(0, 110, 270, 20) title:NSLocalizedString(@"followlog_add_committed", nil)]];
        
        [self addNoteView:containerView frame:CGRectMake(14, 160, 242, 44) default:nil placeholder:NSLocalizedString(@"followlog_add_placeholder", nil) type:EBProcessTypeEnd];
        
        UIButton *checkIn = [self createCheckBtn:CGRectMake(14, 225, 242, 36) title:@"好的" target:self action:@selector(endSetNote:)];
        [containerView addSubview:checkIn];
    }
    return containerView;
}

#pragma btnaction

- (void)textFieldEndEdit:(UIButton*)btn
{
    UITextView *text = nil;
    text = (UITextView*)_noteDic[[NSString stringWithFormat:@"%d", 0]];
    [text resignFirstResponder];
}

- (void)submitNote:(UIButton*)btn
{
    [self addFollowLogNote];
    UITextView *text = nil;
    if (_noteDic && _noteDic.count > 0)
    {
        for (int i = 0; i < _noteDic.count; i ++)
        {
            text = (UITextView*)_noteDic[[NSString stringWithFormat:@"%d", i]];
            if (text)
            {
                [text resignFirstResponder];
                text = nil;
            }
        }
    }
}

- (void)endSetNote:(UIButton*)btn
{
    isShow = NO;
    [_alertView close];
}

- (void)addFollowLogNote
{
    UITextView *textView = _noteDic[[NSString stringWithFormat:@"%ld", EBProcessTypeBegin]];
    NSString *content = textView.text;
//    "followlog_way_add_content_warn" = "请输入备注";
    if ([content length] < 1)
    {
        [EBAlert alertError:NSLocalizedString(@"followlog_way_add_content_warn", nil) length:2.0];
        return;
    }
    UILabel *textLabel = (UILabel*)_noteDic[[NSString stringWithFormat:@"%ld", EBProcessTypeWait]];
    textLabel.text = content;
    textLabel = _noteDic[[NSString stringWithFormat:@"%ld", EBProcessTypeEnd]];
    textLabel.text = content;
    _processType = EBProcessTypeWait;
    [self showSetFollowLogView:YES];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (_setFollowType == EBSetFollowLogForHouse)
    {
        if (_follow)
        {
            parameters[@"house_id"] = _follow[@"id"];
            parameters[@"fid"] = _follow[@"fid"];
            parameters[@"way"] = NSLocalizedString(@"followlog_add_way", nil);
            parameters[@"type"] = _follow[@"type"];
            parameters[@"content"] = content;
            [[EBHttpClient sharedInstance] houseRequest:parameters addFollow:^(BOOL success, id result){
                if (success)
                {
                    _processType = EBProcessTypeEnd;
                    [self showSetFollowLogView:YES];
                }else{
                    _processType = EBProcessTypeBegin;
                    [self showSetFollowLogView:YES];
                }
            }];
        }
    }
    else
    {
        if (_follow)
        {
            parameters[@"client_id"] = _follow[@"id"];
            parameters[@"fid"] = _follow[@"fid"];
            parameters[@"way"] = NSLocalizedString(@"followlog_add_way", nil);
            parameters[@"type"] = _follow[@"type"];
            parameters[@"content"] = content;
            [[EBHttpClient sharedInstance] clientRequest:parameters addFollow:^(BOOL success, id result){
                if (success)
                {
                    _processType = EBProcessTypeEnd;
                    [self showSetFollowLogView:YES];
                }else{
                    _processType = EBProcessTypeBegin;
                    [self showSetFollowLogView:YES];
                }
            }];
        }
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (_placeholder)
    {
        if (textView.text.length == 0)
        {
            _placeholder.hidden = NO;
        }
        else
        {
            _placeholder.hidden = YES;
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (textView.tag == 100 + EBProcessTypeBegin)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.tag == 100 + EBProcessTypeBegin)
    {
        if ([@"\n" isEqualToString:text] == YES)
        {
            [textView resignFirstResponder];
//            [self addFollowLogNote];
            return NO;
        }
    }
    return YES;
}

@end
