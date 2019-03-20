//
//  HouseDetailViewController.m
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientDetailViewController.h"
#import "EBClient.h"
#import "EBPreferences.h"
#import "EBViewFactory.h"
#import "EBIconLabel.h"
#import "EBContact.h"
#import "EBController.h"
#import "EBFilter.h"
#import "EBPhoneButton.h"
#import "EBHttpClient.h"
#import "EBCrypt.h"
#import "ConversationViewController.h"
#import "EBIMConversation.h"
#import "EBIMMessage.h"
#import "EBIMManager.h"
#import "EBAlert.h"
#import "RIButtonItem.h"
#import "UIActionSheet+Blocks.h"
#import "ShareManager.h"
#import "EBContactManager.h"
#import "EGORefreshTableHeaderView.h"
#import "EBCache.h"
#import "ClientInviteViewController.h"
#import "ClientVisitLogViewController.h"
#import "ClientFollowLogViewController.h"
#import "ClientHisInviteViewController.h"
#import "AnonymousCallViewController.h"
#import "EBCallEventHandler.h"
#import "ChangeStatusViewController.h"
#import "ChangeRecTagViewController.h"
#import "ClientEditViewController.h"


@interface ClientDetailViewController () <RTLabelDelegate, UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    UIView *_requireContentView;
    UITableView *_tableView;
    UIView *_headerView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    UIView *_phoneNumberView;
    UIView *_accessView;
    UIView *_numbersView;
    UIView *_noteView;
    UIView *_delegationView;
    NSMutableArray *_clientOperations;
}
@end

@implementation ClientDetailViewController

-(void)loadView
{
    [super loadView];

    self.title = _clientDetail.contractCode;

    [self requireContentView];
    [self numbersView];

    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.frame.size.height,
            _tableView.frame.size.width, _tableView.frame.size.height)];
    _refreshHeaderView.delegate = self;
    [_tableView addSubview:_refreshHeaderView];

    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"btn_menu"] target:self action:@selector(showMoreFunctionList:)];
    [self addRightNavigationBtnWithImage:[UIImage imageNamed:@"nav_btn_share"] target:self action:@selector(share:)];
    [self setRightButton:0 hidden:YES];
    UIButton *collectBtn = [self addRightNavigationBtnWithDynamicImage:[UIImage imageNamed:@"nav_btn_collect_n"] checkedImage:[UIImage imageNamed:@"nav_btn_collect_p"] target:self action:@selector(taggedCollect:) badge:nil];
    if(self.clientDetail.collected)
    {
        collectBtn.selected = YES;
    }
    else
    {
        collectBtn.selected = NO;
    }
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshClientDetail:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //无法修改权限在这显示
    [self refreshClientDetail:YES];
    [[EBHttpClient sharedInstance] accountRequest:nil getNumberStatus:^(BOOL success, id result)
     {
         if (success)
         {
             _numStatus = result;
             [self refreshDetail];
         }
     }];
    [self refreshAppoint];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPopOnBack
{
    if (_pageOpenType == EClientDetailOpenTypeCommon)
    {
        return YES;
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
}

#pragma mark - UIScroolViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self refreshClientDetail:YES];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return NO; // should return if data source model is reloading
}

#pragma mark - UIButton Action收藏成功
-(void)taggedCollect:(UIButton *)btn
{
    [[EBHttpClient sharedInstance] clientRequest:@{@"client_id":_clientDetail.id} collectState:_clientDetail.collected toggleCollect:^(BOOL success, id result)
     {
         if (success)
         {
             _clientDetail.collected = !_clientDetail.collected;
             btn.selected = !btn.selected;
             
             [EBAlert alertSuccess:btn.selected ? NSLocalizedString(@"btn_collected", nil) : NSLocalizedString(@"btn_cancelcollected", nil)];
         }
     }];
}

#pragma mark -- 分享
- (void)share:(UIButton *)btn
{
    [EBTrack event:EVENT_CLICK_CLIENT_SHARE];
    ConversationViewController *viewController = [[ConversationViewController alloc] init];
    viewController.selectBlock = ^(EBIMConversation *conversation)
    {
        EBIMMessage *message = [[EBIMMessage alloc] init];
        message.status = EMessageStatusSending;
        message.type = EMessageContentTypeClient;
        message.content = [EBIMMessage buildClientContent:_clientDetail];
        message.to = conversation.objId;
        message.conversationType = conversation.type;

        [EBAlert showLoading:NSLocalizedString(@"loading_sending", nil)];
        [[EBIMManager sharedInstance] sendMessage:message inConversation:conversation handler:^(BOOL success, NSDictionary *result)
        {
            [EBAlert hideLoading];
            if (success)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5), dispatch_get_main_queue(), ^{
                    [EBAlert alertSuccess:nil];
                });
            }
        }];
        [self.navigationController popViewControllerAnimated:YES];
        [EBTrack event:EVENT_CLICK_IM_SEND_CLIENT];
    };
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -- 编辑客源
- (void)showMoreFunctionList:(id)sender{
    NSMutableArray *choices = [[NSMutableArray alloc] initWithCapacity:_clientOperations.count];
     EBPreferences *pref     = [EBPreferences sharedInstance];
     #pragma mark -- 林文龙
    if (![pref.userName isEqualToString:[_clientDetail.name substringToIndex:_clientDetail.name.length - 2]]) {
       [EBAlert alertWithTitle:nil message:NSLocalizedString(@"client_changestatus_allow", nil)];
        return;
    }
    for (NSString *key in _clientOperations) {
        [choices addObject:[NSString stringWithFormat:NSLocalizedString(key, nil), NSLocalizedString(@"client", nil)]];
    }
    [[EBController sharedInstance] showPopOverListView:sender choices:choices block:^(NSInteger selectedIndex)
     {
         NSString *action = _clientOperations[selectedIndex];
         if ([action isEqualToString:@"operation_modify"])
         {
             ClientEditViewController *editViewController = [[ClientEditViewController alloc] init];
             editViewController.clientDetail = _clientDetail;
             editViewController.hidesBottomBarWhenPushed = YES;
             [self.navigationController pushViewController:editViewController animated:YES];
             [EBTrack event:EVENT_CLICK_CLIENT_EDIT];
         }
         else if ([action isEqualToString:@"operation_modify_status"])
         {
             ChangeStatusViewController *desViewController = [[ChangeStatusViewController alloc] init];
             desViewController.client = _clientDetail;
             desViewController.isClient = YES;
             [self.navigationController pushViewController:desViewController animated:YES];
             [EBTrack event:EVENT_CLICK_CLIENT_CHANGE_STATUS];
         }
         else if ([action isEqualToString:@"operation_modify_recommend_tag"])
         {
             ChangeRecTagViewController *desViewController = [[ChangeRecTagViewController alloc] init];
             desViewController.client = _clientDetail;
             desViewController.isClient = YES;
             [self.navigationController pushViewController:desViewController animated:YES];
             [EBTrack event:EVENT_CLICK_CLIENT_CHANGE_TAGS];
         }
     }];
}

#pragma mark -- phoneNumber 手机号码
- (void)viewPhoneNumber:(UIButton *)btn
{
    NSDictionary *params = @{@"id":_clientDetail.id, @"type": [EBFilter typeString:_clientDetail.rentalState],@"contract_code":_clientDetail.contractCode};
    [EBCallEventHandler clickPhoneButton:btn withParams:params numStatus:_numStatus timesRemain:_clientDetail.timesRemain
                            phoneNumbers:_clientDetail.phoneNumbers type:ECallEventTypeClient phoneGotHandler:^(BOOL success, NSDictionary *result){
         if (success){
             [EBAlert hideLoading];
             NSDictionary *detail = result[@"detail"];
             _clientDetail.phoneNumbers = detail[@"phone_numbers"];
             _clientDetail.coreMemo = detail[@"core_memo"];
             [self refreshDetail];
             [[EBCache sharedInstance] cacheClientDetail:_clientDetail];
         }
         
     } inView:self.view];
    
    [EBTrack event:EVENT_CLICK_CLIENT_VIEW_NUMBER];
}

- (void)showList:(UIButton *)btn
{
    NSInteger tag = btn.tag;
    if ((tag != 4) && (tag != 5) &&(tag != 6))
    {
        EBFilter *filter = [[EBFilter alloc] init];
        [filter parseFromClient:_clientDetail withDetail:tag == 1];
        
        EBIconLabel *iconLabel = (EBIconLabel *)[btn viewWithTag:88];
        [[EBController sharedInstance] showHouseListWithType:EHouseListTypeMatchHousesForClient + tag - 1
                                                      filter:filter title:iconLabel.label.text client:_clientDetail];
    }
    else
    {
        if (tag == 4)
        {
            [EBTrack event:EVENT_CLICK_CLIENT_INVITE];
            if (_appointArray.count > 0) {
                ClientHisInviteViewController *viewController = [[ClientHisInviteViewController alloc] init];
                viewController.appointArray = _appointArray;
                viewController.clientDetail = _clientDetail;
                viewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else
            {
                ClientInviteViewController *viewController = [[ClientInviteViewController alloc] init];
                viewController.clientDetail = _clientDetail;
                viewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:viewController animated:YES];
            }
        }
        else if (tag == 5)
        {
            ClientVisitLogViewController *viewController = [[ClientVisitLogViewController alloc] init];
            viewController.hidesBottomBarWhenPushed = YES;
            viewController.clientDetail = _clientDetail;
            [self.navigationController pushViewController:viewController animated:YES];
            [EBTrack event:EVENT_CLICK_CLIENT_TAKE_LOOK];
        }
        else if (tag == 6)
        {
            [EBTrack event:EVENT_CLICK_CLIENT_VIEW_GJ_LIST];
            ClientFollowLogViewController *viewControler = [[ClientFollowLogViewController alloc] init];
            viewControler.hidesBottomBarWhenPushed = YES;
            viewControler.clientDetail = _clientDetail;
            [self.navigationController pushViewController:viewControler animated:YES];
        }
    }
    
    
    if (tag == 1)
    {
        [EBTrack event:EVENT_CLICK_CLIENT_MATCH_HOUSES];
    }
    else if (tag == 3)
    {
        [EBTrack event:EVENT_CLICK_CLIENT_MARKED_CLIENTS];
    }
}

- (void)refreshDetail
{
    self.title = _clientDetail.contractCode;
    [self getClientOperations];
    if (_clientOperations && _clientOperations.count > 0)
    {
        [self setRightButton:0 hidden:NO];
    }
    else
    {
        [self setRightButton:0 hidden:YES];
    }
    [self headerView];
    [self numbersView];
    [self requireContentView];
    [self noteView];
    [self getPhoneNumberView];
    [self refreshAccessView];
    [self delegationView];
    [_tableView reloadData];
}

//刷新客户数据
- (void)refreshClientDetail:(BOOL)force
{
    [[EBHttpClient sharedInstance] clientRequest:@{@"id":_clientDetail.id, @"force_refresh":@(force),
            @"type":[EBFilter typeString:_clientDetail.rentalState]}
                                          detail:^(BOOL success, id result)
                                          {
                                              [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
                                              if (success)
                                              {
                                                  _clientDetail = result;
                                                  [self refreshDetail];
                                                  [[EBCache sharedInstance] updateCacheByViewClientDetail:_clientDetail];
                                              }
                                          }];
//    [self refreshAppoint];
}

- (void)refreshAppoint
{
    [[EBHttpClient sharedInstance] clientRequest:@{@"client_id":_clientDetail.id, @"force_refresh":@(YES)} appointHistory:^(BOOL success, id result)
     {
         if (success)
         {
             _appointArray = result;
         }
     }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger total = [self tableView:tableView numberOfRowsInSection:0];
    if (row == 0)
    {
        return 76.0;
    }
    else if (row == 1)
    {
        return _numbersView.frame.size.height;//numbersView
    }
    else if (row == 2)
    {
        return 44.0;
    }
    else if (row == 3)
    {
       return _requireContentView.frame.size.height;
    }
    else if (row == total - 5)
    {
        return _noteView.frame.size.height;
    }
    else if (row == total - 3)
    {
        return 117.0; //65--100 wyl
    }
    else if (row == total - 2)
    {
         return _delegationView.frame.size.height;
    }
    else if (row == total - 1)
    {
         return 360.0;
    }
    else
    {
        return 72.0;
    }
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger total = [self tableView:tableView numberOfRowsInSection:0];
    NSString *identifier;
    if (row < 5)
    {
        identifier = [NSString stringWithFormat:@"cell_%ld", row];
    }
    else if (row >= total - 5)
    {
        identifier = [NSString stringWithFormat:@"cell_last_%ld", total - row];
    }
    else if (_clientDetail.phoneNumbers.count == 0 && row == 5)
    {
        identifier = @"cell_get_phone";
    }
    else
    {
        identifier = @"cell_phone";
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        [EBDebug showFrame:cell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (row == 0)
        {
            [cell.contentView addSubview:[self headerView]];
            return cell;
        }
        else if (row == 1)
        {
            [cell.contentView addSubview:[self numbersView]];
            return cell;
        }
        else if (row == 2)
        {
            [self tagsView:cell];
            return cell;
        }
        else if (row == 3)
        {
            [cell.contentView addSubview:_requireContentView];
            return cell;
        }
        else if (row == total - 5)
        {
            [cell.contentView addSubview:_noteView];
            return cell;
        }
        else if (row == total - 3)
        {
            _accessView = [EBViewFactory accessoryView:self action:@selector(showList:) forHouse:NO];
            [self refreshAccessView];
            [cell.contentView addSubview:_accessView];
            return cell;
        }
        else if (row == total - 2)
        {
            [cell.contentView addSubview:_delegationView];
            return cell;
        }
        else if (row == total - 1)
        {
            UIView *qrCodeView = [EBViewFactory qrCodeNumberView:[EBCrypt encryptClient:_clientDetail]];
            UILabel *label = (UILabel *)[qrCodeView viewWithTag:88];
            label.text = NSLocalizedString(@"pr_scan_client", nil);
            [cell.contentView addSubview:qrCodeView];
            return cell;
        }
        else if (row == 5)
        {
            for (UIView *view in cell.contentView .subviews)
            {
                [view removeFromSuperview];
            }
            [[cell.contentView viewWithTag:88] removeFromSuperview];
            [cell.contentView addSubview:[self getPhoneNumberView]];
            return cell;
        }
    }
    else
    {
        if (row == total - 2)
        {
            [cell.contentView addSubview:_delegationView];
        }
        else if (row == total - 5)
        {
            [cell.contentView addSubview:_noteView];
        }
    }
    return  cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

#pragma mark - Cell View

- (void)refreshAccessView
{
    if (_accessView)
    {
        if(_clientDetail.marked)
        {
            UIButton *remarkedBtn = (UIButton*)[_accessView viewWithTag:2];
            UIImageView *imageView = (UIImageView*)[remarkedBtn viewWithTag:1000];
            if (imageView == nil)
            {
                CGRect btnFrame = remarkedBtn.frame;
                UIImage *image = [UIImage imageNamed:@"mark_recom_tag"];
                //                UIImage *newImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width / 1.5, image.size.height / 1.5)];
                imageView = [[UIImageView alloc] initWithImage:image];
                imageView.tag = 1000;
                imageView.frame = CGRectOffset(imageView.frame, btnFrame.size.width - imageView.frame.size.width - 4, 4);
                [remarkedBtn addSubview:imageView];
            }
            imageView.hidden = NO;
            
        }
        else
        {
            UIButton *remarkedBtn = (UIButton*)[_accessView viewWithTag:2];
            UIImageView *imageView = (UIImageView*)[remarkedBtn viewWithTag:1000];
            if (imageView)
            {
                imageView.hidden = YES;
            }
        }
        if(_clientDetail.recommended)
        {
            UIButton *recommendedBtn = (UIButton*)[_accessView viewWithTag:3];
            UIImageView *imageView = (UIImageView*)[recommendedBtn viewWithTag:1000];
            if (imageView == nil)
            {
                CGRect btnFrame = recommendedBtn.frame;
                UIImage *image = [UIImage imageNamed:@"mark_recom_tag"];
                //                UIImage *newImage = [self imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width / 1.5, image.size.height / 1.5)];
                imageView = [[UIImageView alloc] initWithImage:image];
                imageView.tag = 1000;
                imageView.frame = CGRectOffset(imageView.frame, btnFrame.size.width - imageView.frame.size.width - 4, 4);
                [recommendedBtn addSubview:imageView];
            }
            imageView.hidden = NO;
        }
        else
        {
            UIButton *recommendedBtn = (UIButton*)[_accessView viewWithTag:3];
            UIImageView *imageView = (UIImageView*)[recommendedBtn viewWithTag:1000];
            if (imageView)
            {
                imageView.hidden = YES;
            }
        }
    }
}

- (UIView *)headerView
{
    if (_headerView)
    {
        for (UIView *view in _headerView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    else
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 76.0)];
    }

    UILabel *lastName = [EBViewFactory lastNameLabel];
    lastName.text = [_clientDetail.name substringToIndex:1];
    lastName.frame = CGRectOffset(lastName.frame, 15, 15);
    [_headerView addSubview:lastName];

    UILabel *nameView = [[UILabel alloc] initWithFrame:CGRectMake(72, 17, 140, 18)];
    nameView.textColor = [EBStyle blackTextColor];
    nameView.font = [UIFont boldSystemFontOfSize:16.0];
//    NSString *genderFormat = [NSString stringWithFormat:@"gender_format_%@", _clientDetail.gender];
//    nameView.text = [NSString stringWithFormat:NSLocalizedString(genderFormat, nil), _clientDetail.name];
    nameView.text = _clientDetail.name;
    [_headerView addSubview:nameView];

    UILabel *followLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 17, 130, 16)];
    followLabel.font = [UIFont systemFontOfSize:12.0];
    followLabel.textColor = [UIColor colorWithRed:138/255.0 green:151/255.0 blue:181.0/255 alpha:1.0];
    followLabel.textAlignment = NSTextAlignmentRight;
    followLabel.text = _clientDetail.status;
    [_headerView addSubview:followLabel];

    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(72, 43, 270, 16)];
    subLabel.font = [UIFont systemFontOfSize:14.0];
    subLabel.textColor = [EBStyle blackTextColor];
    NSString *rentalKey = [NSString stringWithFormat:@"rental_client_state_%ld", _clientDetail.rentalState];
    NSString *purposeKey = [NSString stringWithFormat:@"house_purpose_%ld", _clientDetail.purpose];
    subLabel.text = [NSString stringWithFormat:@"%@  %@",NSLocalizedString(rentalKey, nil), NSLocalizedString(purposeKey, nil)];
    [_headerView addSubview:subLabel];
    
    //!wyl
//    UIImage *stateImage;
//    if(_clientDetail.rentalState == EClientRequireTypeRent)
//    {
//        stateImage = [UIImage imageNamed:@"tag_rental_1"];
//    }
//    else if (_clientDetail.rentalState == EClientRequireTypeBuy)
//    {
//        stateImage = [UIImage imageNamed:@"tag_rental_02"];
//    }
//    else
//    {
//        stateImage = [UIImage imageNamed:@"tag_rental_03"];
//    }
//    UIImageView *tagState = [[UIImageView alloc] initWithImage:stateImage];
//    tagState.frame = CGRectOffset(tagState.frame, 72, 43);
//    [_headerView addSubview:tagState];
    

//    UIImageView *tagAccess = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"tag_access_%d",
//                    _clientDetail.access]]];
//    tagAccess.frame = CGRectOffset(tagAccess.frame, 265, 43);
//    [_headerView addSubview:tagAccess];
//
//    UIImageView *tagValid = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"tag_valid",
//                                                                                                  _clientDetail.valid ? @"valid" : @"invalid"]]];
//    tagValid.frame = CGRectOffset(tagValid.frame, 283, 43);
//    [_headerView addSubview:tagValid];
    
    CGFloat tagWidth = 14.0;
    CGFloat titleWidth = [EBViewFactory textSize:_clientDetail.changeStatus font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)].width;
    tagWidth += titleWidth == 0 ? 0 : titleWidth + 7;
    NSString *accessTag = [NSString stringWithFormat:@"tag_access_%ld",  _clientDetail.access];
    [EBViewFactory parentView:_headerView addRecommendTag:@[NSLocalizedString(accessTag, nil),_clientDetail.changeStatus == nil ? @"" : _clientDetail.changeStatus] xOffset:[EBStyle screenWidth] - tagWidth - 10.0 yOffset:43.0 limitWidth:[EBStyle screenWidth] tagColor:[UIColor colorWithRed:144./255.f green:191./255.f blue:0./255.f alpha:1.0]];

    [self parentView:_headerView addLine:75.5];

    return _headerView;
}

- (UIView *)numbersView
{
    if (_numbersView)
    {
        for (UIView *view in _numbersView.subviews)
        {
            [view removeFromSuperview];
        }
    }
    else
    {
        _numbersView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 73.0)];
    }
    CGFloat headerHeight = 0;
    CGFloat footerHeight = 0;
    CGFloat totalWidth = 0;
    NSMutableArray *iconLabels = [[NSMutableArray alloc] init];
    NSString *iconName =  _clientDetail.rentalState == EClientRequireTypeRent ? @"price_rent_normal" : @"price_sale_normal";
    UIImage *image = [UIImage imageNamed:iconName];
    NSString *priceFormat = _clientDetail.rentalState == EClientRequireTypeRent ?
    NSLocalizedString(@"rent_price_amount", nil) : NSLocalizedString(@"buy_price_amount", nil);
    NSString *price = [NSString stringWithFormat:priceFormat, [_clientDetail.priceRange[0] floatValue],
                       [_clientDetail.priceRange[1] floatValue]];
    if ([_clientDetail.priceRange[0] floatValue] == [_clientDetail.priceRange[1] floatValue])
    {
        priceFormat = _clientDetail.rentalState == EClientRequireTypeRent ?
        NSLocalizedString(@"rent_price_amount2", nil) : NSLocalizedString(@"buy_price_amount2", nil);
        price = [NSString stringWithFormat:priceFormat, [_clientDetail.priceRange[0] floatValue]];
    }
    
    
    EBIconLabel *label = [EBViewFactory parentView:_numbersView
                                     iconTextWithImage:image
                                                  text:price];
    CGRect labelFrame = label.currentFrame;
    
    [iconLabels addObject:label];
    totalWidth += labelFrame.size.width;
    if (_clientDetail.purpose != EClientPurposeTypeLand
        && _clientDetail.purpose != EClientPurposeTypeWorkshop
        && _clientDetail.purpose != EClientPurposeTypeCarport)
    {
        NSString *roomRange = [NSString stringWithFormat:NSLocalizedString(@"format_unit_room", nil), [_clientDetail.roomRange componentsJoinedByString:@"-"]];
        if ([_clientDetail.roomRange[0] floatValue] == [_clientDetail.roomRange[1] floatValue])
        {
            roomRange = [NSString stringWithFormat:NSLocalizedString(@"format_unit_room", nil), [NSString stringWithFormat:@"%.0f", [_clientDetail.roomRange[0]floatValue]]];
        }
        label = [EBViewFactory parentView:_numbersView
                        iconTextWithImage:[UIImage imageNamed:@"icon_room_large"]
                                     text:roomRange];
        totalWidth += label.currentFrame.size.width;
        [iconLabels addObject:label];
    }
    
    NSString *area = [_clientDetail.areaRange componentsJoinedByString:@"-"];
    if ([_clientDetail.areaRange[0] floatValue] == [_clientDetail.areaRange[1] floatValue])
    {
        area = [NSString stringWithFormat:@"%.0f", [_clientDetail.areaRange[0] floatValue]];
    }
    
    label = [EBViewFactory parentView:_numbersView
                    iconTextWithImage:[UIImage imageNamed:@"icon_area_large"]
                                 text:[NSString stringWithFormat:NSLocalizedString(@"format_unit_area", nil), area]];
    totalWidth += label.currentFrame.size.width;
    [iconLabels addObject:label];
    CGFloat gap = (300 - totalWidth) / (iconLabels.count - 1);
    CGFloat xOffset = 10.0;
    for (NSInteger i = 0; i < iconLabels.count; i++)
    {
        EBIconLabel *label = iconLabels[i];
        CGRect oldFrame = label.currentFrame;
        label.frame = CGRectOffset(oldFrame, xOffset, 15);
        xOffset += oldFrame.size.width + gap;
    }
    EBIconLabel *iconLabel = iconLabels.lastObject;
    
    if (_clientDetail.purpose == EClientPurposeTypeLand)
    {
        headerHeight = 15 + 5;
        UILabel *affiliateLabel = [self affiliateInfoLabel : NSLocalizedString(@"house_land_area", nil)];
        [iconLabel addSubview:affiliateLabel];
        
        CGRect frame = iconLabel.frame;
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:frame above:YES];
    }
    else if (_clientDetail.purpose == EClientPurposeTypeShop)
    {
        footerHeight = 15 + 5;
        UILabel *affiliateLabel = [self affiliateInfoLabel:[NSString stringWithFormat:NSLocalizedString(@"house_door_width_format", nil) , _clientDetail.doorWidth.length == 0 ? NSLocalizedString(@"zero_length", nil) : _clientDetail.doorWidth]];
        [iconLabel addSubview:affiliateLabel];
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:iconLabel.frame above:NO];
        
    }
    else if (_clientDetail.purpose == EClientPurposeTypeWorkshop)
    {
        headerHeight = 15 + 5;
        UILabel *affiliateLabel = [self affiliateInfoLabel:NSLocalizedString(@"work_shop_area", nil)];
        [iconLabel addSubview:affiliateLabel];
        
        CGRect frame = iconLabel.frame;
        [self adjustAffiliateInfoLabelFrame:affiliateLabel accordingFrame:frame above:YES];
        
        if (_clientDetail.factoryExtra && _clientDetail.factoryExtra.count > 0)
        {
            CGFloat originalY = frame.origin.y + frame.size.height + headerHeight + 10;
            CGFloat yOffset = originalY;
            NSInteger temp = 0;
            for (int i = 0; i < _clientDetail.factoryExtra.count; i++)
            {
                NSDictionary *item = _clientDetail.factoryExtra[i];
                if ([item[@"single_line"] boolValue])
                {
                    if (temp % 2 == 1)
                    {
                        yOffset += 20;
                    }
                    CGFloat height =[self parentView:_numbersView
                                         addAreaItem:item[@"name"]
                                               value:item[@"value"]
                                             xOffset:0.0
                                             yOffset:yOffset
                                          limitWidth:[EBStyle screenWidth]];
                    if (height > 0)
                    {
                        yOffset += height;
                        temp = 0;
                    }
                    else
                    {
                        if (temp % 2 == 1)
                        {
                            yOffset -= 20;
                        }
                    }
                    
                }
                else
                {
                    CGFloat height = [self parentView:_numbersView
                                          addAreaItem:item[@"name"]
                                                value:item[@"value"]
                                              xOffset:temp % 2 == 0 ? 0 : 160.0
                                              yOffset:yOffset
                                           limitWidth:160.0];
                    if (height > 0)
                    {
                        yOffset += temp % 2 == 0 ? 0 : height;
                        temp ++;
                    }
                    if (i == _clientDetail.factoryExtra.count - 1 && temp % 2 == 1)
                    {
                        yOffset += 20;
                    }
                }
            }
            if (yOffset - originalY > 0)
            {
                footerHeight += yOffset - originalY + 7;
            }
        }
    }
    if (headerHeight > 0 )
    {
        for (EBIconLabel *label in iconLabels)
        {
            label.frame = CGRectOffset(label.frame, 0, headerHeight);
        }
    }
    CGFloat yOffset = 72.5;
    yOffset += headerHeight + footerHeight;
    [self parentView:_numbersView addLine:yOffset];
    CGRect frame = _numbersView.frame;
    frame.size.height = yOffset + 0.5;
    _numbersView.frame = frame;
    [_numbersView setNeedsLayout];
    return _numbersView;
}

- (void)tagsView:(UITableViewCell *)cell
{
    CGFloat xOffset = 10.0, yOffset = 15;
    
    for (NSInteger tag = 80; tag < 83; tag++)
    {
        [[cell.contentView viewWithTag:tag] removeFromSuperview];
    }
    UIImageView *tagView;
    if (_clientDetail.fullPaid)
    {
        tagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tag_price_full"]];
        tagView.frame = CGRectOffset(tagView.frame, xOffset, yOffset);
        xOffset += tagView.frame.size.width + 4;
        tagView.tag = 80;
        [cell.contentView addSubview:tagView];
    }
    
    tagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"tag_rental_%ld", _clientDetail.rentalState]]];
    tagView.frame = CGRectOffset(tagView.frame, xOffset, yOffset);
    xOffset += tagView.frame.size.width + 4;
    tagView.tag = 81;
    [cell.contentView addSubview:tagView];
    
    if (_clientDetail.urgent)
    {
        tagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tag_urgent"]];
        tagView.frame = CGRectOffset(tagView.frame, xOffset, yOffset);
        tagView.tag = 82;
        [cell.contentView addSubview:tagView];
    }
    [self parentView:cell.contentView addLine:43.5];
}


- (void)requireContentView
{
    if (_requireContentView == nil)
    {
        _requireContentView = [[UIView alloc] init];
    }

    for (UIView *subView in _requireContentView.subviews)
    {
        [subView removeFromSuperview];
    }

    CGFloat labelOffset = 15.0;
    
    labelOffset += [self parentView:_requireContentView addKey:NSLocalizedString(@"client_require_district", nil) value:[_clientDetail.districts componentsJoinedByString:@", "] linkValue:nil yOffset:labelOffset];
    labelOffset += [self parentView:_requireContentView addKey:NSLocalizedString(@"client_require_reason", nil) value:_clientDetail.reason linkValue:nil yOffset:labelOffset];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    if (_clientDetail.floorRange.count > 0)
    {
        NSString *floor = [_clientDetail.floorRange componentsJoinedByString:@"-"];
        if ([_clientDetail.floorRange[0] floatValue] == [_clientDetail.floorRange[1] floatValue])
        {
            floor = [NSString stringWithFormat:@"%.0f", [_clientDetail.floorRange[0] floatValue]];
        }
        [tempArray addObject:@{@"name":NSLocalizedString(@"client_require_floor", nil), @"value":[NSString stringWithFormat:NSLocalizedString(@"house_floor_format", nil), floor]}];
    }
    if (_clientDetail.direction.length > 0)
    {
        [tempArray addObject:@{@"name":NSLocalizedString(@"client_require_towards", nil), @"value":_clientDetail.direction}];
    }
    if (_clientDetail.ageRange.count > 0)
    {
        NSString *age = [_clientDetail.ageRange componentsJoinedByString:@"-"];
        if ([_clientDetail.ageRange[0] floatValue] == [_clientDetail.ageRange[1] floatValue])
        {
            age = [NSString stringWithFormat:@"%.0f", [_clientDetail.ageRange[0] floatValue]];
        }
        [tempArray addObject:@{@"name":NSLocalizedString(@"client_require_house_age", nil), @"value":[NSString stringWithFormat:NSLocalizedString(@"house_age_format", nil), age]}];
    }
    
    if (tempArray.count > 0)
    {
        for (int i = 0; i < tempArray.count; i++)
        {
            NSDictionary *item = tempArray[i];
            
            CGFloat height = [self parentView:_requireContentView addKey:item[@"name"] value:item[@"value"] linkValue:nil xOffset:i % 2 == 0 ? 0 : 160 yOffset:labelOffset limitWidth:160];
            labelOffset += i % 2 == 0 ? 0 : height;
            if (i == tempArray.count - 1 && tempArray.count % 2 == 1)
            {
                labelOffset += height;
            }
        }
    }
    
    if (labelOffset > 15)
    {
        [self parentView:_requireContentView addLine:labelOffset += 3 - 0.5];
    }
    
    if (_clientDetail.decoration.length > 0 || _clientDetail.fitment.length > 0)
    {
        labelOffset += 15;
        labelOffset += [self parentView:_requireContentView addKey:NSLocalizedString(@"decoration", nil)
                                  value:_clientDetail.decoration linkValue:nil yOffset:labelOffset];
        labelOffset += [self parentView:_requireContentView addKey:NSLocalizedString(@"facility", nil)
                                  value:_clientDetail.fitment linkValue:nil yOffset:labelOffset];
        labelOffset += 3;
        [self parentView:_requireContentView addLine:labelOffset - 0.5];
        
    }
    if (_clientDetail.extraArray && _clientDetail.extraArray.count > 0)
    {
        labelOffset += 15;
        CGFloat originOffset = labelOffset;
        NSInteger temp = 0;
        for (int i = 0; i < _clientDetail.extraArray.count; i++)
        {
            NSDictionary *item = _clientDetail.extraArray[i];
            if ([item[@"single_line"] boolValue])
            {
                if (temp % 2 == 1)
                {
                    labelOffset += 27;
                }
                CGFloat height = [self parentView:_requireContentView addKey:item[@"name"] value:item[@"value"] linkValue:nil xOffset:0 yOffset:labelOffset limitWidth:[EBStyle screenWidth]];
                if (height > 0)
                {
                    labelOffset += height;
                    temp = 0;
                }
                else
                {
                    if (temp % 2 == 1)
                    {
                        labelOffset -= 27;
                    }
                }
            }
            else
            {
                CGFloat height = [self parentView:_requireContentView addKey:item[@"name"] value:item[@"value"] linkValue:nil xOffset:temp % 2 == 0 ? 0 : 160 yOffset:labelOffset limitWidth:160];
                if (height > 0)
                {
                    labelOffset += temp % 2 == 0 ? 0 : height;
                    temp ++;
                }
                if (i == _clientDetail.extraArray.count - 1 && temp % 2 == 1)
                {
                    labelOffset += 27;
                }
            }
        }
        if (labelOffset - originOffset > 0)
        {
            labelOffset += 3;
            [self parentView:_requireContentView addLine:labelOffset - 0.5];
        }
        else
        {
            labelOffset -= 15;
        }
        
    }

    /*
    // districts
    EBIconLabel *label = [self labelWithYOffset:labelOffset imageName:@"icon_district"
                                           text:[_clientDetail.districts componentsJoinedByString:@", "] parent:_requireContentView];
    labelOffset += 10 + label.currentFrame.size.height;

    // room
    label = [self labelWithYOffset:labelOffset imageName:@"icon_room"
                              text:[NSString stringWithFormat:NSLocalizedString(@"format_unit_room", nil),
                                                              [_clientDetail.roomRange componentsJoinedByString:@"-"]] parent:_requireContentView];
    labelOffset += 10 + label.currentFrame.size.height;

    // area
    label = [self labelWithYOffset:labelOffset imageName:@"icon_area"
                              text:[NSString stringWithFormat:NSLocalizedString(@"format_unit_area", nil),
                                                              [_clientDetail.areaRange componentsJoinedByString:@"-"]] parent:_requireContentView];
    labelOffset += 10 + label.currentFrame.size.height;

    if (_clientDetail.towards.count)
    {
     // towards
        label = [self labelWithYOffset:labelOffset imageName:@"icon_towards"
                                  text:[_clientDetail.towards componentsJoinedByString:@", "] parent:_requireContentView];
        labelOffset += 10 + label.currentFrame.size.height;
    }

    // price
    NSString *priceFormat = _clientDetail.rentalState == EClientRequireTypeRent ?
            NSLocalizedString(@"rent_price_amount", nil) : NSLocalizedString(@"buy_price_amount", nil);
    NSString *priceInfo = [NSString stringWithFormat:priceFormat, [_clientDetail.priceRange[0] floatValue],
                    [_clientDetail.priceRange[1] floatValue]];

    label = [self labelWithYOffset:labelOffset imageName:@"icon_price" text:priceInfo parent:_requireContentView];

    CGRect currentFrame = label.currentFrame;
    CGFloat tagX = currentFrame.origin.x + currentFrame.size.width + 5.0;

    if (_clientDetail.fullPaid)
    {
       UIImageView *tagFull = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tag_price_full"]];
       tagFull.frame = CGRectOffset(tagFull.frame, tagX, labelOffset + 3);
       [_requireContentView addSubview:tagFull];
       tagX += 3 + tagFull.frame.size.width;
    }

    if (_clientDetail.urgent)
    {
       UIImageView *tagUrgent = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tag_urgent"]];
        tagUrgent.frame = CGRectOffset(tagUrgent.frame, tagX, labelOffset + 3);
       [_requireContentView addSubview:tagUrgent];
    }

    labelOffset += 10 + label.currentFrame.size.height;

    CGFloat rtX = currentFrame.origin.x + label.imageView.image.size.width + label.gap;
    RTLabel *rtLabel = [EBViewFactory contactLabelWithFrame:CGRectMake(rtX, labelOffset, 310 - rtX, 55)
                              name:_clientDetail.delegationAgent.name phone:_clientDetail.delegationAgent.phone date:_clientDetail.inputDate];
    rtLabel.delegate = self;
    [_requireContentView addSubview:rtLabel];
    labelOffset += rtLabel.frame.size.height;

//    _clientDetail.note = @"噼里啪啦，挂啦呱啦。哈哈哈哈\r\n噼里啪啦，挂啦呱啦。哈哈哈哈噼里啪啦，挂啦呱啦。哈哈哈哈噼里啪啦，挂啦呱啦。哈哈哈哈噼里啪啦，挂啦呱啦。哈哈哈哈噼里啪啦，挂啦呱啦。哈哈哈哈";
    if (_clientDetail.note.length > 0)
    {
        labelOffset += [EBViewFactory addNote:_clientDetail.note toView:_requireContentView withYOffset:labelOffset];
    }
     */

    _requireContentView.frame = CGRectMake(0, 0, [EBStyle screenWidth], labelOffset);
}

- (void)noteView
{
    if (_clientDetail.memo.length == 0 && _clientDetail.coreMemo.length == 0)
    {
        _noteView = nil;
    }
    else
    {
        if (_noteView == nil)
        {
            _noteView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        
        for (UIView *subView in  _noteView.subviews)
        {
            [subView removeFromSuperview];
        }
        CGFloat yOffset = 15;
        if (_clientDetail.memo.length > 0)
        {
            yOffset += [EBViewFactory addNote:_clientDetail.memo toView:_noteView withYOffset:yOffset];
        }
        if (_clientDetail.coreMemo.length > 0)
        {
            yOffset += yOffset > 15 ? 10 : 0;
            yOffset += [EBViewFactory addNote:_clientDetail.coreMemo toView:_noteView withYOffset:yOffset];
        }
        if (yOffset > 15)
        {
            _noteView.frame = CGRectMake(0, 0, [EBStyle screenWidth], yOffset += 15);
            [self parentView:_noteView addLine:yOffset - 0.5];
        }
        [_noteView setNeedsLayout];
    }
}

- (void)delegationView
{
    if (_delegationView == nil)
    {
        _delegationView = [[UIView alloc] init];
    }
    else
    {
        for (UIView *subView in _delegationView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    CGFloat yOffset = 15;
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_source", nil)
                          value:_clientDetail.source
                      linkValue:nil
                        yOffset:yOffset];
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_inputuser", nil)
                          value:[self getAgentString:_clientDetail.inputAgent]
                      linkValue:[self getAgentLinkString:_clientDetail.inputAgent]
                        yOffset:yOffset];
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_delegationUser", nil)
                          value:[self getAgentString:_clientDetail.delegationAgent]
                      linkValue:[self getAgentLinkString:_clientDetail.delegationAgent]
                        yOffset:yOffset];
    yOffset += [self parentView:_delegationView
                         addKey:NSLocalizedString(@"house_closeuser", nil)
                          value:[self getAgentString:_clientDetail.closeAgent]
                      linkValue:[self getAgentLinkString:_clientDetail.closeAgent]
                        yOffset:yOffset];
    yOffset += yOffset == 15 ? 0 : 3;
    
    if(yOffset != 15)
    {
        [self parentView:_delegationView addLine:0];
        [self parentView:_delegationView addLine:yOffset - 0.5];
    }
    
    _delegationView.frame = CGRectMake(0, 0, [EBStyle screenWidth], yOffset == 15 ? 0 : yOffset);
    [_delegationView setNeedsLayout];
}

- (UIView *)phoneNumberView
{
    UIView *view = [EBViewFactory phoneButtonWithTarget:nil action:nil];
    view.tag = 99;
    return view;
}

- (UIView *)getPhoneNumberView
{
    if (_phoneNumberView)
    {
        for (UIView *view in _phoneNumberView.subviews)
        {
            [view removeFromSuperview];
        }
        [_phoneNumberView addSubview:[EBViewFactory accessPhoneNumberViewForClient:self action:@selector(viewPhoneNumber:) client:_clientDetail view:self.view]];
    }
    else
    {
        _phoneNumberView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 87)];
        [_phoneNumberView addSubview:[EBViewFactory accessPhoneNumberViewForClient:self action:@selector(viewPhoneNumber:) client:_clientDetail view:self.view]];
    }
    return _phoneNumberView;
}

#pragma mark - View Factory

- (EBIconLabel *)labelWithYOffset:(CGFloat)yOffset imageName:(NSString *)name text:(NSString *)text parent:(UIView *)parent
{
    EBIconLabel *label = [[EBIconLabel alloc] initWithFrame:CGRectMake(30, yOffset, 0, 0)];
    label.gap = 25.0;
    label.maxWidth = 280.0;
    label.iconPosition = EIconPositionLeft;
    label.label.font = [UIFont systemFontOfSize:14.0];
    label.label.textColor = [EBStyle blackTextColor];

    label.imageView.image = [UIImage imageNamed:name];
    label.label.text = text;

    [parent addSubview:label];

    return label;
}

- (UILabel *)affiliateInfoLabel:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [EBStyle grayTextColor];
    CGSize size = [EBViewFactory textSize:text font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    label.frame = CGRectMake(0, 0, size.width, size.height);
    label.text = text;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:12.0];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)parentView:(UIView *)parent addLine:(CGFloat)yOffset
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, yOffset, [EBStyle screenWidth], 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    [parent addSubview:line];
}

- (CGFloat)parentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue yOffset:(CGFloat)yOffset
{
    return [self parentView:parent addKey:key value:value linkValue:linkValue yOffset:yOffset limitWidth:[EBStyle screenWidth]];
}

- (CGFloat)parentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth
{
    return [self parentView:parent addKey:key value:value linkValue:linkValue xOffset:0 yOffset:yOffset limitWidth:limitWidth];
}

- (CGFloat)parentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth
{
    return [EBViewFactory parentView:parent addKey:key value:value linkValue:linkValue xOffset:xOffset yOffset:yOffset limitWidth:limitWidth delegate:self];
}

- (CGFloat)parentView:(UIView *)parent addAreaItem:(NSString *)key value:(NSString *)value xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth
{
    if (value == nil || value.length == 0)
    {
        return 0;
    }
    UIFont *font = [UIFont systemFontOfSize:12.0];
    UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0 + xOffset, yOffset, 54, 20)];
    keyLabel.font = font;
    keyLabel.textColor = [EBStyle grayTextColor];
    keyLabel.text = key;
    keyLabel.textAlignment = NSTextAlignmentRight;
    [parent addSubview:keyLabel];
    
    CGSize contentSize = [EBViewFactory textSize:value font:font bounding:CGSizeMake(limitWidth - 10 - 70, MAXFLOAT)];
    if (contentSize.height < 20)
    {
        contentSize.height = 20;
    }
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(70 + xOffset, yOffset, contentSize.width, contentSize.height)];
    contentLabel.font = font;
    contentLabel.textColor = [EBStyle blackTextColor];
    contentLabel.text = value;
    [parent addSubview:contentLabel];
    
    return contentSize.height;
}


//- (void)viewPhoneNumber:(UIButton *)btn
//{
//    if (_clientDetail.timesRemain == 0)
//    {
//        [EBAlert alertWithTitle:nil message:NSLocalizedString(@"view_phone_no_chance_help", nil)
//                            yes:NSLocalizedString(@"yes_known", nil) confirm:^
//        {
//
//        }];
//    }
//    else
//    {
//        [[EBHttpClient sharedInstance] clientRequest:@{@"id":_clientDetail.id, @"type": [EBFilter typeString:_clientDetail.rentalState]}
//                                    viewPhoneNumber:^(BOOL success, id result)
//        {
//            if (success)
//            {
//                NSDictionary *detail = result[@"detail"];
//                _clientDetail.phoneNumbers = detail[@"phone_numbers"];
//                [self refreshDetail];
//                [[EBCache sharedInstance] cacheClientDetail:_clientDetail];
//            }
//        }];
//    }
//
//    [EBTrack event:EVENT_CLICK_CLIENT_VIEW_NUMBER];
//}

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)adjustAffiliateInfoLabelFrame:(UILabel *)affiliateLabel accordingFrame:(CGRect)accordingFrame above:(BOOL)isAbove
{
    CGRect frame = affiliateLabel.frame;
    if (isAbove)
    {
        frame.origin.y = -frame.size.height - 5;
    }
    else
    {
        frame.origin.y = accordingFrame.size.height + 5;
    }
    
    if (frame.size.width > accordingFrame.size.width)
    {
        CGPoint origin = CGPointMake(-(frame.size.width - accordingFrame.size.width) / 2, frame.origin.y);
        if ([affiliateLabel convertPoint:origin toView:_numbersView].x + frame.size.width > [EBStyle screenWidth])
        {
            frame.origin.x = origin.x - ([affiliateLabel convertPoint:origin toView:_numbersView].x + frame.size.width - [EBStyle screenWidth]) - 5;
        }
        else if ([affiliateLabel convertPoint:origin toView:_numbersView].x < 0)
        {
            frame.origin.x = - accordingFrame.origin.x + 5;
        }
        else
        {
            frame.origin = origin;
        }
    }
    else
    {
        frame.origin.x = (accordingFrame.size.width - frame.size.width) / 2;
    }
    affiliateLabel.frame = frame;
}

#pragma mark - Delegate

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url
{
    NSArray *components = [[url absoluteString] componentsSeparatedByString:@"#"];
    
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    if (components.count > 1)
    {
        NSString *phone = components[1];
        
        if (phone.length)
        {
            [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"call_contact", nil) action:^
                                {
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]]];
                                }]];
            
            [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"sms_contact", nil) action:^
                                {
                                    [[ShareManager sharedInstance] shareContent:@{@"to" : phone} withType:EShareTypeMessage
                                                                        handler:^(BOOL success, NSDictionary *info)
                                     {
                                         
                                     }];
                                }]];
        }
    }
    
    EBContact *contact = [[EBContactManager sharedInstance] contactById:_clientDetail.delegationAgent.userId];
    if (contact)
    {
        [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"profile_btn_send_im", nil) action:^
                            {
                                [[EBController sharedInstance] startChattingWith:@[contact] popToConversation:NO];
                            }]];
    }
    
    [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.view];
}

#pragma mark - Method

- (void)getClientOperations
{
    if (_clientOperations == nil)
    {
        _clientOperations = [[NSMutableArray alloc] init];
    }
    else
    {
        [_clientOperations removeAllObjects];
    }
    NSArray *keys = @[@"modify", @"modify_status", @"modify_recommend_tag"];
    for (NSString *key in keys)
    {
        if ([[_clientDetail.clientPri objectForKey:key] boolValue])
        {
            [_clientOperations addObject:[NSString stringWithFormat:@"operation_%@", key]];
        }
    }
}

//- (void)getClientPhone
//{
//    if (!_clientDetail.ownbyme && !_clientDetail.inputbyme)
//    {
//        if (_clientDetail.timesRemain == 0)
//        {
//            [EBAlert alertWithTitle:nil message:NSLocalizedString(@"view_phone_no_chance_help", nil)
//                                yes:NSLocalizedString(@"yes_known", nil) confirm:^
//             {
//                 
//             }];
//        }
//        else
//        {
//            [[EBHttpClient sharedInstance] clientRequest:@{@"id":_clientDetail.id, @"type": [EBFilter typeString:_clientDetail.rentalState]}
//                                         viewPhoneNumber:^(BOOL success, id result)
//             {
//                 if (success)
//                 {
//                     NSDictionary *detail = result[@"detail"];
//                     _clientDetail.phoneNumbers = detail[@"phone_numbers"];
//                     [self refreshDetail];
//                     [[EBCache sharedInstance] cacheClientDetail:_clientDetail];
//                 }
//             }];
//        }
//    }
//    else
//    {
//        [[EBHttpClient sharedInstance] clientRequest:@{@"id":_clientDetail.id, @"type": [EBFilter typeString:_clientDetail.rentalState]}
//                                     viewPhoneNumber:^(BOOL success, id result)
//         {
//             if (success)
//             {
//                 NSDictionary *detail = result[@"detail"];
//                 _clientDetail.phoneNumbers = detail[@"phone_numbers"];
//                 [self refreshDetail];
//                 [[EBCache sharedInstance] cacheClientDetail:_clientDetail];
//             }
//         }];
//    }
//}

- (NSString *)getAgentString:(EBContact *)agent
{
    if (agent == nil) {
        return @"";
    }
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    if (agent.name.length == 0)
    {
        return @"";
    }
    else
    {
        [temp addObject:agent.name];
    }
    if (agent.happenDate.length > 0)
    {
        [temp addObject:agent.happenDate];
    }
    return [temp componentsJoinedByString:@" "];
}

- (NSString *)getAgentLinkString:(EBContact *)agent
{
    if (agent == nil) {
        return @"";
    }
    return [NSString stringWithFormat:NSLocalizedString(@"deleagtion_contact_format", nil), agent.phone == nil ? @"" : agent.phone, agent.name == nil ? @"" : agent.name, agent.happenDate == nil ? @"" : agent.happenDate];
}

@end
