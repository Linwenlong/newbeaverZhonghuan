//
//  AnonymousCallViewController.m
//  beaver
//
//  Created by wangyuliang on 14-6-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "AnonymousCallViewController.h"
#import "EBController.h"
#import "EBPreferences.h"
#import "EBHttpClient.h"
#import "EBFilter.h"
#import "EBAlert.h"
#import "RIButtonItem.h"
#import "UIActionSheet+Blocks.h"
#import "EBViewFactory.h"
#import "CodeVerifyViewController.h"
#import "AnonymousNumSetViewController.h"
#import "SettingViewController.h"

@interface AnonymousCallViewController ()<UITableViewDataSource , UITableViewDelegate>
{
    UITableView *_tableView;
    UILabel *_phone;
    UIView *_headerView;
}

@end

@implementation AnonymousCallViewController

- (void)loadView
{
    [super loadView];
    if (_pageType == EAnonymousUnstart)
    {
        self.title = NSLocalizedString(@"anonymous_phone_unstart", nil);
    }
    else
    {
        self.title = NSLocalizedString(@"anonymous_phone_start", nil);
    }

    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [self buildTableHeaderView];
    [self.view addSubview:_tableView];
}

- (UIView *)buildTableHeaderView
{
    if (_pageType != EAnonymousWait)
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 450)];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, 296, 54)];
        title.font = [UIFont systemFontOfSize:14.0];
        title.textColor = [EBStyle blackTextColor];
        title.numberOfLines = 0;
        title.textAlignment = NSTextAlignmentLeft;
        title.text = NSLocalizedString(@"anonymous_title", nil);
        [_headerView addSubview:title];
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(14, 58, 296, 120)];
        text.font = [UIFont boldSystemFontOfSize:14.0];
        text.textColor = [EBStyle blackTextColor];
        text.numberOfLines = 0;
        text.text = NSLocalizedString(@"anonymous_text_1", nil);
        [_headerView addSubview:text];
        
        text = [[UILabel alloc] initWithFrame:CGRectMake(14, 180, 296, 18)];
        text.font = [UIFont systemFontOfSize:14.0];
        text.textColor = [EBStyle blackTextColor];
        text.numberOfLines = 0;
        text.text = NSLocalizedString(@"anonymous_text_2", nil);
        [_headerView addSubview:text];
        
        UIView *line = [self addLine:213 left:14 right:14];
        [_headerView addSubview:line];
        
        if (_pageType == EAnonymousUnstart)
        {
            text = [[UILabel alloc] initWithFrame:CGRectMake(14, 228, 296, 18)];
            text.numberOfLines = 0;
            text.font = [UIFont systemFontOfSize:14];
            text.textColor = [EBStyle blackTextColor];
            text.text = NSLocalizedString(@"anonymous_text_3", nil);
            [_headerView addSubview:text];
            
            text = [[UILabel alloc] initWithFrame:CGRectMake(18, 250, 284, 36)];
            text.numberOfLines = 0;
            text.font = [UIFont systemFontOfSize:14.0];
            text.textColor = [EBStyle blackTextColor];
            text.text = NSLocalizedString(@"anonymous_text_4", nil);
            [_headerView addSubview:text];
            
            _phone = [[UILabel alloc] initWithFrame:CGRectMake(20, 288, 200, 40)];
            _phone.font = [UIFont boldSystemFontOfSize:18.0];
            _phone.textColor = [EBStyle blackTextColor];
            _phone.textAlignment = NSTextAlignmentLeft;
            NSString *showText;
            NSRange range = [_anonymousNum rangeOfString:@"-"];
            NSInteger location = range.location;
            if (location >= 0)
            {
                NSArray *array = [_anonymousNum componentsSeparatedByString:@"-"];
                if ([array count] > 1)
                {
                    showText = [NSString stringWithFormat:@"%@%@%@",array[0], NSLocalizedString(@"anonymous_phone_set_fix_show_4", nil), array[1]];
                }
                else
                    showText = _anonymousNum;
            }
            else
                showText = _anonymousNum;
            _phone.text = showText;
            [_headerView addSubview:_phone];
            
            UIButton *change = [[UIButton alloc] initWithFrame:CGRectMake(260, 288, 46, 36)];
            UIImage *bgN = [[UIImage imageNamed:@"btn_blue_normal"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
            UIImage *bgP = [[UIImage imageNamed:@"btn_blue_pressed"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
            [change setBackgroundImage:bgN forState:UIControlStateNormal];
            [change setBackgroundImage:bgP forState:UIControlStateHighlighted];
            
            change.adjustsImageWhenHighlighted = NO;
            
            [change setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
            [change setTitle:NSLocalizedString(@"anonymous_modyfy", nil) forState:UIControlStateNormal];
            [change addTarget:self action:@selector(promptChangeNumber:) forControlEvents:UIControlEventTouchUpInside];
            change.titleLabel.font = [UIFont systemFontOfSize:14];
            [_headerView addSubview:change];
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(14, 350, 290, 36)];
            [btn setBackgroundImage:bgN forState:UIControlStateNormal];
            [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
            btn.adjustsImageWhenHighlighted = NO;
            [btn setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
            [btn setTitle:NSLocalizedString(@"anonymous_contiue", nil) forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn addTarget:self action:@selector(enableNumber:) forControlEvents:UIControlEventTouchUpInside];
            [_headerView addSubview:btn];
        }
        if (_pageType == EAnonymousStart)
        {
            text = [[UILabel alloc] initWithFrame:CGRectMake(14, 228, 296, 36)];
            text.numberOfLines = 0;
            text.font = [UIFont systemFontOfSize:14];
            text.textColor = [EBStyle blackTextColor];
            text.text = NSLocalizedString(@"anonymous_start_text_3", nil);
            [_headerView addSubview:text];
            
            _phone = [[UILabel alloc] initWithFrame:CGRectMake(20, 268, 200, 40)];
            _phone.font = [UIFont boldSystemFontOfSize:18.0];
            _phone.textColor = [EBStyle blackTextColor];
            _phone.textAlignment = NSTextAlignmentLeft;
            NSString *showText;
            NSRange range = [_anonymousNum rangeOfString:@"-"];
            NSInteger location = range.location;
            if (location >= 0)
            {
                NSArray *array = [_anonymousNum componentsSeparatedByString:@"-"];
                if ([array count] > 1)
                {
                    showText = [NSString stringWithFormat:@"%@%@%@",array[0], NSLocalizedString(@"anonymous_phone_set_fix_show_4", nil), array[1]];
                }
                else
                    showText = _anonymousNum;
            }
            else
                showText = _anonymousNum;
            _phone.text = showText;
            [_headerView addSubview:_phone];
            
            UIButton *change = [[UIButton alloc] initWithFrame:CGRectMake(260, 268, 46, 36)];
            UIImage *bgN = [[UIImage imageNamed:@"btn_blue_normal"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
            UIImage *bgP = [[UIImage imageNamed:@"btn_blue_pressed"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
            [change setBackgroundImage:bgN forState:UIControlStateNormal];
            [change setBackgroundImage:bgP forState:UIControlStateHighlighted];
            
            change.adjustsImageWhenHighlighted = NO;
            
            [change setTitleColor:[EBStyle blueTextColor] forState:UIControlStateNormal];
            [change setTitle:NSLocalizedString(@"anonymous_modyfy", nil) forState:UIControlStateNormal];
            [change addTarget:self action:@selector(promptChangeNumber:) forControlEvents:UIControlEventTouchUpInside];
            change.titleLabel.font = [UIFont systemFontOfSize:14];
            [_headerView addSubview:change];
            _headerView.frame = CGRectMake(0, 0, 318, 400);
        }
        return _headerView;
    }
    else
    {
        return [self buildHeadViewForWait];
    }
}

- (UIView *)buildHeadViewForWait
{
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 450)];
    UIImageView *firstIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"face"]];
    firstIcon.frame = CGRectMake(25.0, 55.0, 32.0, 32.0);
    
    NSString *showText;
    NSRange range = [_anonymousNum rangeOfString:@"-"];
    NSInteger location = range.location;
    if (location >= 0)
    {
        NSArray *array = [_anonymousNum componentsSeparatedByString:@"-"];
        if ([array count] > 1)
        {
            showText = [NSString stringWithFormat:@"%@%@%@",array[0], NSLocalizedString(@"anonymous_phone_set_fix_show_4", nil), array[1]];
        }
        else
            showText = _anonymousNum;
    }
    else
        showText = _anonymousNum;
    NSString *labelText = [NSString stringWithFormat:NSLocalizedString(@"anonymous_call_setting_wait_label1", nil), showText];
    
    CGFloat labelHeight = [EBViewFactory textSize:labelText font:[UIFont systemFontOfSize:16.0] bounding:CGSizeMake(228.0, MAXFLOAT)].height;
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0, 50.0, 228.0, labelHeight)];
    firstLabel.font = [UIFont systemFontOfSize:16.0];
    firstLabel.textColor = [EBStyle blackTextColor];
    firstLabel.numberOfLines = 0;
    firstLabel.text = labelText;
    
    [_headerView addSubview:firstIcon];
    [_headerView addSubview:firstLabel];
    
    UIImageView *secondIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hourglass"]];
    secondIcon.frame = CGRectMake(25.0, labelHeight > 37.0 ? firstLabel.frame.origin.y + labelHeight + 45 : 32.0, 32.0, 32.0);
    
    labelText = NSLocalizedString(@"anonymous_call_setting_wait_label2", nil);
    
    labelHeight = [EBViewFactory textSize:labelText font:[UIFont systemFontOfSize:16.0] bounding:CGSizeMake(228.0, MAXFLOAT)].height;
    UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(72.0, secondIcon.frame.origin.y - 5, 228.0, labelHeight)];
    secondLabel.font = [UIFont systemFontOfSize:16.0];
    secondLabel.textColor = [EBStyle blackTextColor];
    secondLabel.numberOfLines = 0;
    secondLabel.text = labelText;
    
    [_headerView addSubview:secondIcon];
    [_headerView addSubview:secondLabel];
    
    return _headerView;
}

- (void)refreshView
{
    _tableView.tableHeaderView = [self buildTableHeaderView];
}

- (void)enableNumber:(UIButton *)btn
{
    NSDictionary *params = @{@"number":_phone.text};
    [[EBHttpClient sharedInstance] accountRequest:params setNumber:^(BOOL success, id result){
        BOOL verifield = [result[@"need_verified"] intValue];
        NSString *verifyType = result[@"verify_type"];
        if (verifield)
        {
            CodeVerifyViewController *codeVerifyViewController =[[CodeVerifyViewController alloc] init];
            codeVerifyViewController.viewType = ECodeVerifyViewTypeAnonymousTel;
            codeVerifyViewController.phoneNumber = _phone.text;
            codeVerifyViewController.verifyType = verifyType;
            codeVerifyViewController.verifySuccess = ^(){
//                self.pageType = EAnonymousStart;
//                [self refreshView];
                id viewController = [self.navigationController.viewControllers objectAtIndex: ([self.navigationController.viewControllers count] -3)];
                if ([viewController isKindOfClass:[SettingViewController class]])
                {
                    SettingViewController *temp = (SettingViewController*)viewController;
                    dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
                    {
                        [self.navigationController popToViewController:temp animated:YES];
                    });
                    
                }
                [self.navigationController popViewControllerAnimated:YES];
            };
            [self.navigationController pushViewController:codeVerifyViewController animated:YES];
//            self.pageType = EAnonymousWait;
//            [self refreshView];
        }
        else
        {
//            self.pageType = EAnonymousStart;
//            [self refreshView];
            [EBAlert alertSuccess:nil];
            dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^
            {
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    }];
}

- (void)promptChangeNumber:(UIButton *)btn
{
    [EBTrack event:EVENT_CLICK_SETTINGS_CHANGE_ANONYMOUSE_PHONE];
    [[EBController sharedInstance] promptChangeNumberInView:self.view withVerifySuccess:nil];
}

- (UIView *)addLine:(CGFloat) height left:(CGFloat)left right:(CGFloat)right
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(left, height, self.view.width - left - right, 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    return line;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:84.0 leftMargin:5.0]];
        
        cell.shouldIndentWhileEditing = NO;
    }
    else
    {
//        itemView = (HouseItemView *)[cell.contentView viewWithTag:88];
    }
    
    
    return  cell;
}

@end
