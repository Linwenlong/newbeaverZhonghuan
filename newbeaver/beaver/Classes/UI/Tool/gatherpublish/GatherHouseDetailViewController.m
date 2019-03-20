//
//  GatherHouseDetailViewController.m
//  beaver
//
//  Created by wangyuliang on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseDetailViewController.h"
#import "EBViewFactory.h"
#import "NSDate+TimeAgo.h"
#import "EBController.h"
#import "EBHttpClient.h"
#import "UIImage+Alpha.h"
#import "HouseEquGatherTelViewController.h"
#import "EBCache.h"
#import "EBBusinessConfig.h"
#import "FSImageViewer.h"
#import "GatherHouseAddViewController.h"
#import "EBAlert.h"
#import "RIButtonItem.h"
#import "UIActionSheet+Blocks.h"
#import "PublishHouseViewController.h"
#import "GatherHouseWebViewController.h"

@interface GatherHouseDetailViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    UIView *_sourceView;
    UIView *_houseInfoView;
    UIView *_otherInfoView;
    NSInteger _sameTelExist;
    BOOL _showRightAdd;
    UIImage *_phoneImage;
    UITextField *_phoneTextField;
    UIView *_customViewForKeybord;
    UIButton *_callBtn;
    UIView *_shadeView;
    UIWindow *_window;
    UIView *_parentView;
}

@end

@implementation GatherHouseDetailViewController

- (void)loadView
{
    [super loadView];
    [self initVar];
    self.navigationItem.title = @"房源详情";
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"btn_menu"] target:self action:@selector(showMoreFunctionList:)];
    
    _shadeView = [[UIView alloc] initWithFrame:self.view.frame];
    _shadeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    UITapGestureRecognizer *backTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResin:)];
    [_shadeView addGestureRecognizer:backTapGes];
    
    _phoneTextField = [[UITextField alloc] init];
    _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keywordTextFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:_phoneTextField];
    [self.view addSubview:_phoneTextField];
    
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [self setPhoneButton];
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] init];
    parameter[@"house_id"] = _house.id;
    if (_house.tel_type == 1)
    {
        parameter[@"type"] = _house.type == EGatherHouseRentalTypeSale ? @"sale" : @"rent";
        parameter[@"tel"] = _house.owner_tel;
    }
    [[EBHttpClient sharedInstance] gatherPublishRequest:parameter viewHouse:^(BOOL success, id result) {
        if (success)
        {
            if (_house.viewed == 0)
            {
                _house.viewed = 1;
                _house.view_count ++;
                [_tableView reloadData];
            }
            id value = result[@"same_tel_exist"];
            _sameTelExist = [(NSNumber *)value integerValue];
//            _sameTelExist = 1;
            if (_sameTelExist > 0)
            {
                _tableView.tableHeaderView  = [self buildHeadView];
            }
        }
    }];
    if (_house.tel_type == 3 && _house.owner_tel_img && _house.owner_tel_img.length > 0)
    {
        __weak GatherHouseDetailViewController *weakSelf = self;
        [[FSImageLoader sharedInstance] loadImageForURL:[NSURL URLWithString:_house.owner_tel_img] image:^(UIImage *image, NSError *error) {
            if (!error) {
                _phoneImage = image;
                [weakSelf setPhoneButton];
                [weakSelf initCustomViewForKeybord];
                //                    weakSelf.image.image = image;
//                [weakSelf setupImageViewWithImage:image];
                image = nil;
            }
            else {
//                [weakSelf handleFailedImage];
            }
        }];
    }
    NSArray *windows = [UIApplication sharedApplication].windows;
    if(windows.count > 0)
    {
        _parentView=nil;
        _window = [windows objectAtIndex:0];
        if(_window.subviews.count > 0)
        {
            _parentView = [_window.subviews objectAtIndex:0];
        }
    }
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_openPhoneSet)
    {
        _openPhoneSet = NO;
        [_phoneTextField becomeFirstResponder];
        [_parentView addSubview:_shadeView];
    }
    [_tableView reloadData];
}

#pragma mark - private method
- (void)initCustomViewForKeybord
{
    _customViewForKeybord = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 130)];
    _customViewForKeybord.backgroundColor = [UIColor colorWithRed:252/255.f green:252/255.f blue:252/255.f alpha:1.0];
    UIImage *closeImage = [UIImage imageNamed:@"icon_close"];
    UIImageView *iconClose = [[UIImageView alloc] initWithImage:closeImage];
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 4, iconClose.frame.size.width + 10, iconClose.frame.size.height + 10)];
    [closeBtn addTarget:self action:@selector(closePhoneNumInput:) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setImage:closeImage forState:UIControlStateNormal];
    [closeBtn setImage:[closeImage imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
    [_customViewForKeybord addSubview:closeBtn];
    
    UIImageView *phoneImageView = [[UIImageView alloc] initWithImage:_phoneImage];
    phoneImageView.frame = CGRectOffset(phoneImageView.frame, (self.view.width - phoneImageView.frame.size.width) / 2.0, 18);
    [_customViewForKeybord addSubview:phoneImageView];
    
    UILabel *tipLabel = [self createLabel:CGRectMake(0, 45, [EBStyle screenWidth], 20) text:NSLocalizedString(@"gather_house_phone_call_input", nil) textColor:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:14.0]];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [_customViewForKeybord addSubview:tipLabel];
    
    _callBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 80, [EBStyle screenWidth], 50)];
    _callBtn.backgroundColor = [UIColor colorWithRed:61/255.f green:193/255.f blue:84/255.f alpha:1.0];
    [self btnAddIconText:_callBtn image:[UIImage imageNamed:@"icon_phone_call_white"] text:_phoneTextField.text font:[UIFont systemFontOfSize:16.0] color:[UIColor whiteColor]];
    [_callBtn addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
    [_customViewForKeybord addSubview:_callBtn];
    [_phoneTextField setInputAccessoryView:_customViewForKeybord];
}

- (void)btnAddIconText:(UIButton*)btn image:(UIImage*)image text:(NSString*)text font:(UIFont*)font color:(UIColor*)color
{
    CGFloat horizon = 5;
    UIImageView *iconView = [[UIImageView alloc] initWithImage:image];
    CGSize textSize = [EBViewFactory textSize:text font:font bounding:CGSizeMake(150, 30)];
    iconView.frame = CGRectOffset(iconView.frame, (btn.frame.size.width - iconView.frame.size.width - horizon - textSize.width) / 2.0, (btn.frame.size.height - iconView.frame.size.height) / 2.0);
    [btn addSubview:iconView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(iconView.frame.origin.x + iconView.frame.size.width + horizon, (btn.frame.size.height - textSize.height) / 2.0, textSize.width, textSize.height)];
    label.tag = 800;
    label.font = font;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = color;
    label.text = text;
    [btn addSubview:label];
}



- (void)initVar
{
    _sameTelExist = 0;
    _showRightAdd = NO;
}

- (UIView*)buildHeadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 44)];
    view.backgroundColor = [UIColor colorWithRed:255/255.0 green:169/255.0 blue:34/255.0 alpha:1];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gather_house_icon_warn"]];
    imageView.frame = CGRectOffset(imageView.frame, 7, 22 - imageView.frame.size.height / 2.0);
    [view addSubview:imageView];
    
    CGSize tipSize = [EBViewFactory textSize:NSLocalizedString(@"gather_house_tel_repeat", nil) font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(300, 30)];
    UILabel *tipLabel = [self createLabel:CGRectMake(30, 22 - tipSize.height / 2.0, tipSize.width, tipSize.height) text:NSLocalizedString(@"gather_house_tel_repeat", nil) textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:14.0]];
    tipLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:tipLabel];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(268, 11, 40, 22)];
    [btn addTarget:self action:@selector(viewHouseSameTel:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [[UIImage imageNamed:@"gather_house_button_bord"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 10, 15, 10)];
//    UIImage *imageLighted = [image imageByApplyingAlpha:0.4];
    [btn setBackgroundImage:image forState:UIControlStateNormal];
//    [btn setImage:imageLighted forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
    [btn setTitle:NSLocalizedString(@"gather_house_tel_view", nil) forState:UIControlStateNormal];
    [view addSubview:btn];
    
    return view;
}

- (void)setPhoneButton
{
    CGRect frame = [EBStyle fullScrTableFrame:NO];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-54.0, frame.size.width, 55.0)];
    [self.view addSubview:view];
    UIButton *phoneButton = [EBViewFactory blueButtonWithFrame:CGRectMake(15.0, 10, view.width-30, 35) title:nil target:self action:@selector(phoneClick:)];
    CGFloat iconGap = 5;
    if (_house.tel_type == 2)
    {
        phoneButton.enabled = NO;
    }
    else
    {
        phoneButton.enabled = YES;
    }
    if (_house.tel_type != 3 && _house.owner_tel.length > 0)
    {
        NSString *showText;
        if (!_house.owner_name)
        {
            showText = [NSString stringWithFormat:@"%@", _house.owner_tel];
        }
        else
        {
            if (_house.owner_name.length < 1)
            {
                showText = [NSString stringWithFormat:@"%@", _house.owner_tel];
            }
            else
            {
                showText = [NSString stringWithFormat:@"%@ %@",_house.owner_name, _house.owner_tel];
            }
        }
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_phone"]];
        if (_house.tel_type == 2)
        {
            iconView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"btn_phone"] imageByApplyingAlpha:0.4]];
        }
        else
        {
            iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_phone"]];
        }
        
        CGSize textSize = [EBViewFactory textSize:showText font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(200, 25)];
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
        numLabel.font = [UIFont systemFontOfSize:14.0];
        if (_house.tel_type == 2)
        {
            numLabel.textColor = [[EBStyle blueTextColor] colorWithAlphaComponent:0.4];
        }
        else
        {
            numLabel.textColor = [EBStyle blueTextColor];
        }
        
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.text = showText;
        
        iconView.frame = CGRectOffset(iconView.frame, (phoneButton.frame.size.width - iconView.frame.size.width - 5 - numLabel.frame.size.width) / 2.0, (phoneButton.frame.size.height - iconView.frame.size.height) / 2.0);
        numLabel.frame = CGRectOffset(numLabel.frame, iconView.frame.origin.x + iconView.frame.size.width + iconGap, (phoneButton.frame.size.height - numLabel.frame.size.height) / 2.0);
        [phoneButton addSubview:iconView];
        [phoneButton addSubview:numLabel];
        
//        UIView *icon = [self iconLabel:@"btn_phone" text:showText font:[UIFont systemFontOfSize:14] textColor:[EBStyle blueTextColor] portait:NO gap:5];
//        icon.frame = CGRectOffset(icon.frame, (phoneButton.frame.size.width - icon.frame.size.width) / 2.0, (phoneButton.frame.size.height - icon.frame.size.height) / 2);
//        [phoneButton addSubview:icon];
    }
    else
    {
        CGFloat gapLabelImage = 2.0;
        NSString *showText = nil;
        if (!_house.owner_name)
        {
            showText = @"";
        }
        else if (_house.owner_name.length < 1)
        {
            showText = @"";
        }
        else
        {
            showText = [NSString stringWithFormat:@"%@",_house.owner_name];
        }
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_phone"]];
        
        CGSize textSize = [EBViewFactory textSize:showText font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(200, 25)];
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
        numLabel.font = [UIFont systemFontOfSize:14.0];
        numLabel.textColor = [EBStyle blueTextColor];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.text = showText;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:_phoneImage];
        iconView.frame = CGRectOffset(iconView.frame, (phoneButton.frame.size.width - iconView.frame.size.width - numLabel.frame.size.width - imageView.frame.size.width - gapLabelImage - iconGap) / 2.0, (phoneButton.frame.size.height - iconView.frame.size.height) / 2.0);
        numLabel.frame = CGRectOffset(numLabel.frame, iconView.frame.origin.x + iconView.frame.size.width + iconGap, (phoneButton.frame.size.height - numLabel.frame.size.height) / 2.0);
        imageView.frame = CGRectOffset(imageView.frame, numLabel.frame.origin.x + numLabel.frame.size.width + gapLabelImage, (phoneButton.frame.size.height - imageView.frame.size.height) / 2.0);
        [phoneButton addSubview:iconView];
        [phoneButton addSubview:numLabel];
        [phoneButton addSubview:imageView];
        
//        iconView.frame = CGRectOffset(iconView.frame, (phoneButton.frame.size.width - iconView.frame.size.width - 5 - numLabel.frame.size.width) / 2.0, (phoneButton.frame.size.height - iconView.frame.size.height) / 2.0);
//        numLabel.frame = CGRectOffset(numLabel.frame, iconView.frame.origin.x + iconView.frame.size.width + iconGap, (phoneButton.frame.size.height - numLabel.frame.size.height) / 2.0);
//        
//        UIView *icon = [self iconLabel:@"btn_phone" text:_house.owner_name font:[UIFont systemFontOfSize:14.0] textColor:[EBStyle blueTextColor] portait:NO gap:5];
//        UIImageView *imageView = [[UIImageView alloc] initWithImage:_phoneImage];
//        icon.frame = CGRectOffset(icon.frame, (phoneButton.frame.size.width - icon.frame.size.width - imageView.frame.size.width - 3) / 2.0, (phoneButton.frame.size.height - icon.frame.size.height) / 2);
//        imageView.frame = CGRectOffset(imageView.frame, icon.frame.origin.x + icon.frame.size.width + 3, (phoneButton.frame.size.height - imageView.frame.size.height) / 2.0);
//        
//        [phoneButton addSubview:icon];
//        [phoneButton addSubview:imageView];
    }
    [view addSubview:phoneButton];
}

- (CGFloat)heightForRow:(NSInteger)row
{
    if (row == 0) {
        if (_house.bookmarked)
            return 62.0;
        else
            return 48;
    }
    else if (row == 1)
    {
        CGFloat height = 66;
        height = height + [EBViewFactory textSize:_house.title font:[UIFont systemFontOfSize:16.0] bounding:CGSizeMake(292, 300)].height;
        if (_house.community && _house.community.length > 0)
        {
            NSString *showText = [NSString stringWithFormat:NSLocalizedString(@"gather_house_info_format", nil), _house.community];
            CGSize communitySize = [EBViewFactory textSize:showText font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(292, 40)];
            height = height + communitySize.height;
        }
        if (_house.house_type && _house.house_type.length > 0)
        {
            height = height + 20;
        }
        return height;
    }
    else if(row == 2)
    {
        if (_house.des && _house.des.length > 0)
        {
            return 77 + 2 * 9 + [EBViewFactory textSize:_house.des font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(176, 4000)].height;
        }
        else
            return 77;
        return 170;//temp
    }
    return 0;
}

- (UIView *)addLine:(CGFloat) height left:(CGFloat)left right:(CGFloat)right
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(left, height, [EBStyle screenWidth] - left - right, 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    return line;
}

- (void)setViewForCell:(UITableViewCell*)cell row:(NSInteger)row
{
    if (cell)
    {
        if (row == 0)
        {
            [self buildViewSourceView];
            [cell.contentView addSubview:_sourceView];
        }
        else if (row == 1)
        {
            [self buildViewHouseInfoView];
            [cell.contentView addSubview:_houseInfoView];
        }
        else
        {
            [self buildViewOtherInfoView];
            [cell.contentView addSubview:_otherInfoView];
        }
    }
}

- (void)buildViewSourceView
{
    if (_sourceView == nil)
    {
        _sourceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], [self heightForRow:0])];
    }
    else
    {
        [_sourceView removeFromSuperview];
    }
    for (UIView *subView in _sourceView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    CGFloat portInfoHeight= 14;
    if (_house.bookmarked)
    {
        UIView *markView = [self iconLabel:@"bookmark" text:NSLocalizedString(@"gather_house_bookmarked", nil) font:[UIFont systemFontOfSize:14.0] textColor:[EBStyle grayTextColor] portait:NO gap:-1];
        markView.frame = CGRectOffset(markView.frame, 14, 14);
        [_sourceView addSubview:markView];
        portInfoHeight = portInfoHeight + 18;
    }
    NSString *portInfo = [NSString stringWithFormat:NSLocalizedString(@"gather_house_port_tip_1", nil), _house.port_name];
    UILabel *labelOne = [self createLabel:CGRectMake(14, portInfoHeight, [EBViewFactory textSize:portInfo font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(150, 20)].width, 17) text:portInfo textColor:[EBStyle grayTextColor] font:[UIFont systemFontOfSize:14.0]];
    CGFloat xBtnExprand = 20;
    CGFloat yBtnExprand = 10;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(14 + [EBViewFactory textSize:portInfo font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(150, 20)].width - xBtnExprand / 2.0, portInfoHeight - yBtnExprand / 2.0, [EBViewFactory textSize:NSLocalizedString(@"gather_house_port_tip_2", nil) font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(150, 20)].width + xBtnExprand, 17 + yBtnExprand)];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button setTitleColor:[EBStyle darkBlueTextColor] forState:UIControlStateNormal];
    [button setTitleColor:[EBStyle darkBlueHighlightTextColor] forState:UIControlStateHighlighted];
    [button setTitle:NSLocalizedString(@"gather_house_port_tip_2", nil) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(openURL:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *text;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_house.create_time];
    text = [date dateTimeAgo];
    UILabel *lableTwo = [self createLabel:CGRectMake(14 + labelOne.frame.size.width + [EBViewFactory textSize:NSLocalizedString(@"gather_house_port_tip_2", nil) font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(150, 20)].width, portInfoHeight, [EBViewFactory textSize:[NSString stringWithFormat:NSLocalizedString(@"gather_house_port_tip_3", nil), [date dateTimeAgo]] font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(150, 18)].width, 17) text:[NSString stringWithFormat:NSLocalizedString(@"gather_house_port_tip_3", nil), [date dateTimeAgo]] textColor:[EBStyle grayTextColor] font:[UIFont systemFontOfSize:14.0]];
    [_sourceView addSubview:labelOne];
    [_sourceView addSubview:button];
    [_sourceView addSubview:lableTwo];
    [_sourceView addSubview:[self addLine:[self heightForRow:0] - 0.5 left:0 right:0]];
}

- (void)buildViewHouseInfoView
{
    if (_houseInfoView == nil)
    {
        _houseInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], [self heightForRow:1])];
    }
    else
    {
        [_houseInfoView removeFromSuperview];
    }
    for (UIView *subView in _houseInfoView.subviews)
    {
        [subView removeFromSuperview];
    }
    
    CGFloat viewHeight = 13;
    CGFloat gap = 3;
    CGSize titleSize = [EBViewFactory textSize:_house.title font:[UIFont systemFontOfSize:16.0] bounding:CGSizeMake(292, 300)];
    UILabel *titleLabel = [self createLabel:CGRectMake(14, viewHeight, titleSize.width, titleSize.height) text:_house.title textColor:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:16.0]];
    [_houseInfoView addSubview:titleLabel];
    viewHeight = viewHeight + titleSize.height + gap;
    
    UILabel *contentLabel;
    NSString *showText = nil;
    if (_house.community && _house.community.length > 0) {
        showText = [NSString stringWithFormat:NSLocalizedString(@"gather_house_info_format", nil), _house.community];
        CGSize communitySize = [EBViewFactory textSize:showText font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(292, 40)];
        contentLabel = [self createLabel:CGRectMake(14, viewHeight, 292, communitySize.height) text:showText textColor:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:14.0]];
        viewHeight = viewHeight + communitySize.height + gap;
        [_houseInfoView addSubview:contentLabel];
    }
    if (_house.house_type && _house.house_type.length > 0) {
        showText = [NSString stringWithFormat:NSLocalizedString(@"gather_house_info_format", nil), _house.house_type];
        contentLabel = [self createLabel:CGRectMake(14, viewHeight, 292, 17) text:showText textColor:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:14.0]];
        viewHeight = viewHeight + 17 + gap;
        [_houseInfoView addSubview:contentLabel];
    }
    if (_house.type == EGatherHouseRentalTypeSale) {
        showText = [NSString stringWithFormat:NSLocalizedString(@"gather_house_info_format", nil), @"出售"];
    }
    else
    {
        showText = [NSString stringWithFormat:NSLocalizedString(@"gather_house_info_format", nil), @"出租"];
    }
    contentLabel = [self createLabel:CGRectMake(14, viewHeight, 292, 17) text:showText textColor:[EBStyle blackTextColor] font:[UIFont systemFontOfSize:14.0]];
    viewHeight = viewHeight + 17 + gap;
    [_houseInfoView addSubview:contentLabel];
    
    viewHeight = viewHeight + 5;
    UIView *viewIcon = [self iconLabel:@"icon_click" text:[NSString stringWithFormat:NSLocalizedString(@"gp_click_number_format", nil), _house.view_count] font:[UIFont systemFontOfSize:12.0] textColor:[UIColor colorWithRed:150 / 255.f green:168 / 255.f blue:195 / 255.f alpha:1.0] portait:NO gap:-1];
    viewIcon.frame = CGRectOffset(viewIcon.frame, 16, viewHeight);
    [_houseInfoView addSubview:viewIcon];
    
    UIView *reportIcon = [self iconLabel:@"icon_report" text:[NSString stringWithFormat:NSLocalizedString(@"gp_report_number_format", nil), _house.report_count] font:[UIFont systemFontOfSize:12.0] textColor:[UIColor colorWithRed:150 / 255.f green:168 / 255.f blue:195 / 255.f alpha:1.0] portait:NO gap:-1];
    reportIcon.frame = CGRectOffset(reportIcon.frame, 16 + viewIcon.frame.size.width + 30, viewHeight);
    [_houseInfoView addSubview:reportIcon];
    
    UIView *gatherIcon = [self iconLabel:@"icon_gather" text:[NSString stringWithFormat:NSLocalizedString(@"gp_gather_number_format", nil), _house.to_erp_count] font:[UIFont systemFontOfSize:12.0] textColor:[UIColor colorWithRed:150 / 255.f green:168 / 255.f blue:195 / 255.f alpha:1.0] portait:NO gap:-1];
    gatherIcon.frame = CGRectOffset(gatherIcon.frame, reportIcon.frame.origin.x + reportIcon.frame.size.width + 30, viewHeight);
    [_houseInfoView addSubview:gatherIcon];
    [_houseInfoView addSubview:[self addLine:[self heightForRow:1] - 0.5 left:0 right:0]];
    
}

- (void)buildViewOtherInfoView
{
    if (_otherInfoView == nil)
    {
        _otherInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], [self heightForRow:2])];
    }
    else
    {
        [_otherInfoView removeFromSuperview];
    }
    for (UIView *subView in _otherInfoView.subviews)
    {
        [subView removeFromSuperview];
    }
    CGFloat viewYDistance = 20;
    CGFloat viewXDistance = 14;
    NSString *price;
    if (_house.type == EGatherHouseRentalTypeSale) {
        price = [NSString stringWithFormat:NSLocalizedString(@"gather_house_sale_price", nil), _house.total_price];
    }
    else
    {
        price = [NSString stringWithFormat:NSLocalizedString(@"gather_house_rent_price", nil), _house.total_price];
    }
    UIView *priceIcon = [self iconLabel:@"price_sale_down" text:price font:[UIFont systemFontOfSize:14.0] textColor:[EBStyle greenTextColor] portait:YES gap:-1];
    
    NSString *houseText = [NSString stringWithFormat:NSLocalizedString(@"format_unit_room_hall", nil), _house.room, _house.hall];
    UIView *houseIcon = [self iconLabel:@"icon_room" text:houseText font:[UIFont systemFontOfSize:14.0] textColor:[EBStyle blackTextColor] portait:YES gap:-1];
    
    NSString *areaText = [NSString stringWithFormat:NSLocalizedString(@"format_unit_area", nil), _house.area];
    UIView *areaIcon = [self iconLabel:@"icon_area" text:areaText font:[UIFont systemFontOfSize:14.0] textColor:[EBStyle blackTextColor] portait:YES gap:-1];
    
    NSString *floorText = [NSString stringWithFormat:NSLocalizedString(@"gather_house_floor", nil), _house.floor, _house.total_floor];
    UIView *floorIcon = [self iconLabel:@"gather_house_floor" text:floorText font:[UIFont systemFontOfSize:14.0] textColor:[EBStyle blackTextColor] portait:YES gap:-1];
    
    CGFloat distance = (292 - priceIcon.frame.size.width - houseIcon.frame.size.width - areaIcon.frame.size.width - floorIcon.frame.size.width) / 3;
    priceIcon.frame = CGRectOffset(priceIcon.frame, viewXDistance, viewYDistance - 4);
    [_otherInfoView addSubview:priceIcon];
    viewXDistance = viewXDistance + priceIcon.frame.size.width + distance;
    
    houseIcon.frame = CGRectOffset(houseIcon.frame, viewXDistance, viewYDistance);
    [_otherInfoView addSubview:houseIcon];
    viewXDistance = viewXDistance + houseIcon.frame.size.width + distance;
    
    areaIcon.frame = CGRectOffset(areaIcon.frame, viewXDistance, viewYDistance);
    [_otherInfoView addSubview:areaIcon];
    viewXDistance = viewXDistance + areaIcon.frame.size.width + distance;
    
    floorIcon.frame = CGRectOffset(floorIcon.frame, viewXDistance, viewYDistance);
    [_otherInfoView addSubview:floorIcon];
    
    
    if (_house.des && _house.des.length > 0)
    {
        viewYDistance = 77;
        viewXDistance = 14;
        CGFloat xLable = 8;
        CGFloat yLabel = 9;
        CGSize textSize = [EBViewFactory textSize:_house.des font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(176, 400)];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(viewXDistance, viewYDistance, 292, textSize.height + 2 * yLabel)];
        view.backgroundColor = [UIColor colorWithRed:252/255.f green:242/255.f blue:176/255.f alpha:1.0];
        [_otherInfoView addSubview:view];
        
        UILabel *descriptionLabel = [self createLabel:CGRectMake(viewXDistance + xLable, viewYDistance + yLabel, textSize.width, textSize.height) text:_house.des textColor:[EBStyle grayTextColor] font:[UIFont systemFontOfSize:14.0]];
        [_otherInfoView addSubview:descriptionLabel];
    }
}

- (UILabel*)createLabel:(CGRect)frame text:(NSString*)text textColor:(UIColor*)color font:(UIFont*)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 0;
    label.textColor = color;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = font;
    label.text = text;
    return label;
}

- (UIView *)iconLabel:(NSString*)imageName text:(NSString*)text font:(UIFont*)font textColor:(UIColor*)color portait:(BOOL)portaitTag gap:(CGFloat)gapTextImage
{
    UIView *view;
    CGFloat portait = 6;//纵向距离
    CGFloat horizon = 4;//横向距离
    if (gapTextImage > 0 )
    {
        if (portaitTag)
        {
            portait = gapTextImage;
        }
        else
        {
            horizon = gapTextImage;
        }
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    CGSize textSize = [EBViewFactory textSize:text font:font bounding:CGSizeMake(150, 25)];
    CGFloat viewHeight = 0;
    CGFloat viewWidth = 0;
    if (portaitTag)//纵向
    {
        if (imageView.frame.size.width > textSize.width)
        {
            viewWidth = imageView.frame.size.width;
        }
        else
        {
            viewWidth = textSize.width;
        }
        viewHeight = imageView.frame.size.height + portait + textSize.height;
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        imageView.frame = CGRectOffset(imageView.frame, (viewWidth - imageView.frame.size.width) / 2.0, 0);
        [view addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((viewWidth - textSize.width) / 2, imageView.frame.size.height + portait, textSize.width, textSize.height)];
        label.font = font;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = color;
        label.text = text;
        [view addSubview:label];
    }
    else
    {
        if (imageView.frame.size.height > textSize.height)
        {
            viewHeight = imageView.frame.size.height;
        }
        else
        {
            viewHeight = textSize.height;
        }
        viewWidth = imageView.frame.size.width + horizon + textSize.width;
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
        imageView.frame = CGRectOffset(imageView.frame, 0, (viewHeight - imageView.frame.size.height) / 2);
        [view addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.size.width + horizon, (viewHeight - textSize.height) / 2, textSize.width, textSize.height)];
        label.font = font;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = color;
        label.text = text;
        [view addSubview:label];
    }
    return view;
}

#pragma mark - action
- (void)openURL:(UIButton*)btn
{
    if (_house.url && _house.url.length > 0)
    {
//        [[EBController sharedInstance] openWebViewWithUrl:[[NSURL alloc] initWithString:_house.url]];
        
        GatherHouseWebViewController *webViewController = [[GatherHouseWebViewController alloc] init];
        webViewController.hidesBottomBarWhenPushed = YES;
        webViewController.request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:_house.url]];
        
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)textFieldResin:(UITapGestureRecognizer*)sender
{
    [_phoneTextField resignFirstResponder];
    [_shadeView removeFromSuperview];
}

- (void)phoneClick:(UIButton*)btn
{
    [EBTrack event:EVENT_CLICK_COLLECT_POST_COLLECT_HOUSE_CALL];
    if (_house.tel_type == 1)
    {
        UIDevice *device = [UIDevice currentDevice];
        if ([[device model] isEqualToString:@"iPhone"] ) {
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",_house.owner_tel];
            UIWebView * callWebview = [[UIWebView alloc] init];
            [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
            [self.view addSubview:callWebview];
            
//            [EBAlert confirmWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"dial_confirm_format", nil), _house.owner_tel]
//                                  yes:NSLocalizedString(@"confirm_ok", nil) action:^
//             {
//                 [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _house.owner_tel]]];
//             }];
        }
        else
        {
            [_phoneTextField resignFirstResponder];
            [_shadeView removeFromSuperview];
            [EBAlert alertError:NSLocalizedString(@"dial_not_supported", nil)];
        }
    }
    else if (_house.tel_type == 3)
    {
        [_phoneTextField becomeFirstResponder];
        [_parentView addSubview:_shadeView];
    }
}

- (void)call:(UIButton*)btn
{
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",_phoneTextField.text];
        UIWebView * callWebview = [[UIWebView alloc] init];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
        [self.view addSubview:callWebview];
        
//        [EBAlert confirmWithTitle:nil message:[NSString stringWithFormat:NSLocalizedString(@"dial_confirm_format", nil), _phoneTextField.text]
//                              yes:NSLocalizedString(@"confirm_ok", nil) action:^
//         {
//             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", _phoneTextField.text]]];
//         }];
    }
    else
    {
        [_phoneTextField resignFirstResponder];
        [_shadeView removeFromSuperview];
        [EBAlert alertError:NSLocalizedString(@"dial_not_supported", nil)];
    }
}

- (void)closePhoneNumInput:(UIButton*)btn
{
    [_phoneTextField resignFirstResponder];
    [_shadeView removeFromSuperview];
}

- (void)viewHouseSameTel:(UIButton*)btn
{
    HouseEquGatherTelViewController *controller = [[HouseEquGatherTelViewController alloc] init];
    controller.house = _house;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)showMoreFunctionList:(id)sender
{
    __weak GatherHouseDetailViewController *weakSelf = self;
    NSArray *choice = nil;
    if (!_showRightAdd && [EBCache sharedInstance].businessConfig.houseConfig.allowAdd)
    {
        choice = [[NSArray alloc] initWithObjects:
         NSLocalizedString(@"gather_house_add_erp_title", nil),
         NSLocalizedString(@"gather_house_publish_port", nil),
         _house.bookmarked ? NSLocalizedString(@"gather_house_remove_bookmark", nil) : NSLocalizedString(@"gather_house_add_bookmark", nil),
         NSLocalizedString(@"gather_house_report", nil), nil];
    }
    else
    {
        choice = [[NSArray alloc] initWithObjects:
                  NSLocalizedString(@"gather_house_publish_port", nil),
                  _house.bookmarked ? NSLocalizedString(@"gather_house_remove_bookmark", nil) : NSLocalizedString(@"gather_house_add_bookmark", nil),
                  NSLocalizedString(@"gather_house_report", nil), nil];
    }
    
    [[EBController sharedInstance] showPopOverListView:sender choices:choice block:^(NSInteger selectedIndex) {
        if (!(!_showRightAdd && [EBCache sharedInstance].businessConfig.houseConfig.allowAdd))
        {
            selectedIndex ++;
        }
        if (selectedIndex == 0)
        {
            [EBTrack event:EVENT_CLICK_COLLECT_POST_COLLECT_HOUSE_ADD];
            GatherHouseAddViewController *controller = [[GatherHouseAddViewController alloc] init];
            controller.actionType = EBEditTypeAdd;
            if (weakSelf.house.house_type && weakSelf.house.house_type.length > 0)
            {
                controller.purpose = weakSelf.house.house_type;
            }
            else
            {
                controller.purpose = @"住宅";
            }
            controller.gatherHouse = weakSelf.house;
            controller.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else if (selectedIndex == 1)
        {
            [EBTrack event:EVENT_CLICK_COLLECT_POST_COLLECT_HOUSE_POST];
            [self publishHouseAction];
        }
        else if (selectedIndex == 2)
        {
            [EBTrack event:EVENT_CLICK_COLLECT_POST_COLLECT_HOUSE_BOOKMARK];
            [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"house_id":_house.id} toggleBookmark:^(BOOL success, id result)
            {
                if (success)
                {
                    _house.bookmarked = !_house.bookmarked;
                    [_tableView reloadData];
                    [EBAlert alertSuccess:_house.bookmarked ? NSLocalizedString(@"alert_add_bookmark", nil) : NSLocalizedString(@"alert_remove_bookmark", nil)];
                }
            }];
        }
        else if (selectedIndex == 3)
        {
            [EBTrack event:EVENT_CLICK_COLLECT_POST_COLLECT_HOUSE_REPORT];
            if (_house.reported)
            {
                [EBAlert alertWithTitle:nil message:NSLocalizedString(@"alert_already_report", nil) yes:NSLocalizedString(@"yes_known", nil) confirm:nil];
            }
            else
            {
                [EBAlert confirmWithTitle:NSLocalizedString(@"alert_report_title", nil) message:NSLocalizedString(@"alert_report_msg", nil) yes:NSLocalizedString(@"confirm", nil) action:^{
                    [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"house_id":_house.id} reportHouse:^(BOOL success, id result) {
                        if (success)
                        {
                            _house.reported = YES;
                            _house.report_count ++;
                            [EBAlert alertSuccess:nil];
                            [_tableView reloadData];
                        }
                    }];
                }];
            }
        }
    }];
}

- (void)keywordTextFieldTextChanged:(id)sender
{
    for (UIView *view in _callBtn.subviews)
    {
        [view removeFromSuperview];
    }
    [self btnAddIconText:_callBtn image:[UIImage imageNamed:@"icon_phone_call_white"] text:_phoneTextField.text font:[UIFont systemFontOfSize:16.0] color:[UIColor whiteColor]];
}

- (void)publishHouseAction
{
    PublishHouseViewController *controller =[PublishHouseViewController new];
//    NSString *type = _house.type == EGatherHouseRentalTypeSale ? @"sale" : @"rent";
    controller.params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_house.id, @"relate_house_id", nil];
    controller.showActionSheet = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForRow:indexPath.row];
}

#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier;
    if (indexPath.row == 0) {
        cellIdentifier = @"cellGatherHouseMark";
    }
    else if (indexPath.row == 1)
    {
        cellIdentifier = @"cellGatherHouseInfo";
    }
    else if (indexPath.row == 2)
    {
        cellIdentifier = @"cellGatherHouseOther";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    [self setViewForCell:cell row:indexPath.row];
    return cell;
}



@end
