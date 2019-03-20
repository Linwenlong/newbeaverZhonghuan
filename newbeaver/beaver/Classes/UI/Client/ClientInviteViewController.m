//
//  ClientInviteViewController.m
//  beaver
//
//  Created by wangyuliang on 14-5-21.
//  Copyright (c) 2014年 eall. All rights reserved.
//
/**
 *  从客源详情 邀请看房按钮点进来
 *
 *  @return
 */

#import "ClientInviteViewController.h"
#import "EBClient.h"
#import "EBSearch.h"
#import "EBFilter.h"
#import "QRScannerViewController.h"   //扫描
#import "QRScannerView.h"
#import "EBHouse.h"
#import "HouseItemView.h"
#import "EBViewFactory.h"
#import "ClientInviteNextViewController.h"
#import "EBAppointment.h"
#import "NSDate-Utilities.h"
#import "UIImage+ImageWithColor.h"
#import "ClientItemView.h"
#import "ClientListViewController.h"//客户列表
#import "ClientTelListViewController.h"
#import "EBAlert.h"
#import "EBShare.h"
//第一个next
@interface ClientInviteViewController () <UITableViewDataSource , UITableViewDelegate>
{
    UITableView *_tableView;
    EBSearch *_searchHelper;
    NSMutableArray *_selectedHouses;
    NSMutableSet *_selectedIds;
    UIBarButtonItem *_rightButtonItem;
    UILabel *_addedLabel;
    UIView *_addedLine;
}

@end

@implementation ClientInviteViewController

- (void)loadView
{
    [super loadView];
    
    _selectedIds = [[NSMutableSet alloc] init];
    _selectedHouses = [[NSMutableArray alloc] init];
    
    if (_viewType == EClientInviteViewTypeAddVisited)
    {
//        "add_visit_house_title"   = "带客户看过的房源";
        self.title = NSLocalizedString(@"add_visit_house_title", nil);
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
        _rightButtonItem = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"btn_add_visit_complete", nil) target:self action:@selector(addVisitHouseCompleted)];
        if (_preSelectedHouses)
        {
            for (EBHouse *house in _preSelectedHouses)
            {
                if (![_selectedIds containsObject:house.id])
                {
                    [_selectedIds addObject:house.id];
                    [_selectedHouses addObject:house];
                }
            }
            _rightButtonItem.enabled = _selectedHouses.count > 0;
        }
        else
        {
            _rightButtonItem.enabled = NO;
        }
    }
    //邀请看房
    else if (_viewType == EClientInviteViewTypeAddInvite)
    {
        self.title = NSLocalizedString(@"invite_title", nil);
        _rightButtonItem = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"nextstep", nil) target:self action:@selector(nextStep)];
        _rightButtonItem.enabled = NO;
    }
    else if (_viewType == EClientInviteViewTypeShareNewHouse)
    {
        self.title = NSLocalizedString(@"select_client_title", nil);
        _rightButtonItem = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"nextstep", nil) target:self action:@selector(nextStep)];
        _rightButtonItem.enabled = NO;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [self buildTableHeaderView];
    _tableView.editing = YES;

    [self.view addSubview:_tableView];

    _searchHelper = [[EBSearch alloc] init];
//    [_searchHelper setupSearchBarForController:self];

}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}
//搜索房源后 会让下一步可以点击，下面有个列表
#pragma mark -- 下一步
- (void)nextStep
{
    
    if (_viewType == EClientInviteViewTypeAddInvite)
    {
        ClientInviteNextViewController *viewController = [[ClientInviteNextViewController alloc] init];
        viewController.hidesBottomBarWhenPushed = YES;
        //推荐房源的基本信息
        EBAppointment *appointment = [[EBAppointment alloc] init];
        appointment.houseIds = [_selectedIds sortedArrayUsingDescriptors:nil];
        NSInteger time = (NSInteger)NSDate.date.timeIntervalSince1970 + 90000 - ((NSInteger)NSDate.date.timeIntervalSince1970) % 3600;
        appointment.timestamp = time;
        appointment.client = _clientDetail;
        EBHouse *house = [_selectedHouses firstObject];
        appointment.addressTitle = house.district;
        
        viewController.appointment = appointment;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (_viewType == EClientInviteViewTypeShareNewHouse)
    {
        NSArray *clientIds = [_selectedIds allObjects];
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        parameters[@"type"] = @"sale";
        parameters[@"ids"] = [clientIds componentsJoinedByString:@";"];
        
        [EBAlert showLoading:nil];
        [[EBHttpClient sharedInstance] clientRequest:parameters telList:^(BOOL success, id result)
         {
             [EBAlert hideLoading];
             if (success)
             {
                 ClientTelListViewController *viewController = [[ClientTelListViewController alloc] init];
                 
                 if (self.userInfo)
                 {
                     viewController.userInfo = self.userInfo;
                 }
                 else
                 {
                     NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
                     content[@"text"] = [EBShare smsContentForNewHouse:_houseDetail];
                     content[@"url"] = [EBShare contentShareNewHouseUrl:_houseDetail];
                     viewController.userInfo = content;
                 }
                 
                 viewController.clientList = result;
                 [self.navigationController pushViewController:viewController animated:YES];
                 viewController.finishBlock = ^(BOOL success, NSDictionary *info)
                 {
                     if (success)
                     {
                         [self.navigationController popViewControllerAnimated:YES];
                         [EBAlert alertSuccess:nil];
                     }
                     else
                     {
                         if ([info[@"desc"] rangeOfString:@"canceled"].location == NSNotFound)
                         {
                             [EBAlert alertError:NSLocalizedString(info[@"desc"], nil)];
                         }
                         
                     }
                 };
             }
         }];
    }
    
}

- (void)addVisitHouseCompleted
{
    if (self.handleCompleted)
    {
        self.handleCompleted(_selectedHouses);
    }
    if (_viewType == EClientInviteViewTypeAddVisited) {
        [self back:nil];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text fontSize:(CGFloat)size color:(UIColor *)color
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size];
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];

    return label;
}

- (UIView *)buildTableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 363)];
    if (_viewType == EClientInviteViewTypeAddVisited)
    {
        CGRect frame = headerView.frame;
        frame.size.height = 315;
        headerView.frame = frame;
        [headerView addSubview:[self labelWithFrame:CGRectMake(15, 0, [EBStyle screenWidth] -30, 40) text:NSLocalizedString(@"add_visit_house", nil) fontSize:16 color:[EBStyle blackTextColor]]];
    }
    else if(_viewType == EClientInviteViewTypeAddInvite)
    {
        [headerView addSubview:[self labelWithFrame:CGRectMake(15, 0,  [EBStyle screenWidth] -30, 40) text:NSLocalizedString(@"add_invite_house", nil) fontSize:16 color:[EBStyle blackTextColor]]];
    }
    else if(_viewType == EClientInviteViewTypeShareNewHouse)
    {
        CGRect frame = headerView.frame;
        frame.size.height = 273;
        headerView.frame = frame;
        [headerView addSubview:[self labelWithFrame:CGRectMake(15, 0,  [EBStyle screenWidth] -30, 40) text:NSLocalizedString(@"add_share_client", nil) fontSize:16 color:[EBStyle blackTextColor]]];
    }
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(15, 40,  [EBStyle screenWidth] -30, _viewType == EClientInviteViewTypeShareNewHouse ? 180 : 270)];
    containerView.backgroundColor = [UIColor colorWithRed:235/255.0 green:240/255.0 blue:247/255.0 alpha:1];
    containerView.layer.borderColor = [[UIColor colorWithRed:205/255.0 green:216/255.0 blue:230/255.0 alpha:1] CGColor];
    containerView.layer.borderWidth = 1;

    [headerView addSubview:containerView];

    // search
    UIButton *btn = [self buttonWithFrame:CGRectMake(10, 7.5, [EBStyle screenWidth] - 30 - 20, 30) text: _viewType == EClientInviteViewTypeShareNewHouse ? NSLocalizedString(@"search_share_client", nil) : NSLocalizedString(@"search_house_invitepage", nil) tag:1];
    [btn setBackgroundColor:[UIColor colorWithRed:247/255.0 green:249/255.0 blue:252/255.0 alpha:1]];
    [btn.layer setBorderWidth:1.0];
    [btn.layer setBorderColor:[[UIColor colorWithRed:203/255.0 green:204/255.0 blue:214/255.0 alpha:1] CGColor]];
    [btn.layer setCornerRadius:15.0];
    [btn setImage:[UIImage imageNamed:@"btn_icon_search"] forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [containerView addSubview:btn];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 44.5,  [EBStyle screenWidth] - 30, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:205/255.0 green:216/255.0 blue:230/255.0 alpha:1];
    [containerView addSubview:line];

    // qr
//    btn = [self buttonWithFrame:CGRectMake(0, 45, 290, 45) text:NSLocalizedString(@"qr_house_invitepage", nil) tag:2];
//    [btn setImage:[UIImage imageNamed:@"icon_list_qr"] forState:UIControlStateNormal];
//    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
//    [containerView addSubview:btn];
    
    NSArray *texts = @[NSLocalizedString(@"qr_house_invitepage", nil),
                       NSLocalizedString(@"btn_match_house", nil),
                       NSLocalizedString(@"sel_rencent_house", nil),
                       NSLocalizedString(@"sel_mark_house", nil),
                       NSLocalizedString(@"sel_commond_house", nil)];
    if (_viewType == EClientInviteViewTypeAddVisited)
    {
        texts = @[NSLocalizedString(@"sel_invited_house", nil),
                  NSLocalizedString(@"qr_house_invitepage", nil),
                  NSLocalizedString(@"sel_rencent_house", nil),
                  NSLocalizedString(@"sel_mark_house", nil),
                  NSLocalizedString(@"sel_commond_house", nil)];
    }
    else if (_viewType == EClientInviteViewTypeShareNewHouse)
    {
        texts = @[NSLocalizedString(@"input_code_scan_client", nil),
                  NSLocalizedString(@"sel_rencent_client", nil),
                  NSLocalizedString(@"sel_collected_client", nil)];
    }
    for (NSInteger i = 2; i < texts.count + 2; i++)
    {
        line = [[UIView alloc] initWithFrame:CGRectMake(0, 45 *(i - 1) - 0.5 ,  [EBStyle screenWidth] -30, 0.5)];
        line.backgroundColor = [UIColor colorWithRed:205/255.0 green:216/255.0 blue:230/255.0 alpha:1];
        [containerView addSubview:line];

        btn = [self buttonWithFrame:CGRectMake(0, 45 * (i - 1),  [EBStyle screenWidth] -30, 45) text:texts[i - 2] tag:i];
        [containerView addSubview:btn];
    }
    
    if (_viewType == EClientInviteViewTypeAddInvite || _viewType == EClientInviteViewTypeShareNewHouse)
    {
        _addedLabel = [self labelWithFrame:CGRectMake(15, _viewType == EClientInviteViewTypeAddInvite ? 315 : 315 - 90,  [EBStyle screenWidth] -30, 48) text:_viewType == EClientInviteViewTypeAddInvite ? NSLocalizedString(@"added_invite_house", nil) : NSLocalizedString(@"added_share_client", nil) fontSize:16 color:[EBStyle blackTextColor]];
        _addedLabel.hidden = YES;
        [headerView addSubview:_addedLabel];
        _addedLine = [[UIView alloc] initWithFrame:CGRectMake(0, _viewType == EClientInviteViewTypeAddInvite ? 352.5 : 352.5 - 90, [EBStyle screenWidth], 0.5)];
        _addedLine.backgroundColor = [UIColor colorWithRed:205/255.0 green:216/255.0 blue:230/255.0 alpha:1];
        _addedLine.hidden = YES;
        [headerView addSubview:_addedLine];
    }
    return  headerView;
}

- (UIButton *)buttonWithFrame:(CGRect)frame text:(NSString *)text  tag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:text forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];

    [btn setTitleColor:[UIColor colorWithRed:123/255.0f green:133/255.0f blue:150/255.0f alpha:1.0f] forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.adjustsImageWhenHighlighted = NO;
    btn.tag = tag;

    if (tag > 1)
    {
        [btn setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0xdc/255.0f green:0xe5/255.0f blue:0xf2/255.0f alpha:1.0]]
                       forState:UIControlStateHighlighted];
    }

    [btn addTarget:self action:@selector(addHouse:) forControlEvents:UIControlEventTouchUpInside];

    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);

    return btn;
}

//点击邀请看房tableview上面的按钮
- (void)addHouse:(UIButton *)btn
{
    //选完推荐房源之后的回调
    void(^handleSelection)(NSArray *)  = ^(NSArray *selectedArray){
 
        NSArray *vcs = self.navigationController.viewControllers;
        
        if (vcs.count == 8) {
            id vc = vcs[vcs.count - 2];
            [self.navigationController popToViewController:vc animated:YES];
        }else if(vcs.count== 9){
            id vc = vcs[vcs.count - 3];
            [self.navigationController popToViewController:vc animated:YES];
        }else{
           [self.navigationController popViewControllerAnimated:YES];
        }
#pragma mark -- 修改成上面 4.2
//        if (vcs.count>=3) {
//            id vc = vcs[vcs.count - 3];
//            [self.navigationController popToViewController:vc animated:YES];
//        }else{
//            [self.navigationController popViewControllerAnimated:YES];
//        }


        [_searchHelper.displayController setActive:NO];

        if (_viewType == EClientInviteViewTypeAddInvite || _viewType == EClientInviteViewTypeAddVisited)
        {
            for (EBHouse *house in selectedArray)
            {
                if (![_selectedIds containsObject:house.id])
                {
                    [_selectedIds addObject:house.id];
                    [_selectedHouses insertObject:house atIndex:0];
                }
            }
        }
        else if (_viewType == EClientInviteViewTypeShareNewHouse)
        {
            for (EBClient *client in selectedArray)
            {
                if (![_selectedIds containsObject:client.id])
                {
                    [_selectedIds addObject:client.id];
                    [_selectedHouses insertObject:client atIndex:0];
                }
            }
        }
        [_tableView reloadData];
        _rightButtonItem.enabled = _viewType == EClientInviteViewTypeAddVisited ? YES : _selectedHouses.count > 0;
        _addedLabel.hidden = !(_selectedHouses.count > 0);
        _addedLine.hidden = !(_selectedHouses.count > 0);
    };

    NSInteger tag = btn.tag;
    if (tag == 1)
    {
        if (_viewType == EClientInviteViewTypeShareNewHouse)
        {
            [_searchHelper searchClientWithSelection:handleSelection];
        }
        else if (_viewType == EClientInviteViewTypeAddVisited || _viewType == EClientInviteViewTypeAddInvite)
        {
            [_searchHelper searchHouseWithSelection:handleSelection];
        }
    }
    else if ((tag == 2 && _viewType == EClientInviteViewTypeAddInvite)
             || (tag == 3 && _viewType == EClientInviteViewTypeAddVisited)
             || (tag == 2 && _viewType == EClientInviteViewTypeShareNewHouse))
    {
        QRScannerViewController *scannerViewController = [[QRScannerViewController alloc] init];

        scannerViewController.infoFetched = ^(id info)
        {
            if (_viewType == EClientInviteViewTypeAddInvite || _viewType == EClientInviteViewTypeAddVisited)
            {
                EBHouse *house = info;
                if (![_selectedIds containsObject:house.id])
                {
                    [_selectedIds addObject:house.id];
                    [_selectedHouses insertObject:house atIndex:0];
                    [_tableView reloadData];
                }
            }
            else if (_viewType == EClientInviteViewTypeShareNewHouse)
            {
                EBClient *client = info;
                if (![_selectedIds containsObject:client.id])
                {
                    [_selectedIds addObject:client.id];
                    [_selectedHouses insertObject:client atIndex:0];
                    [_tableView reloadData];
                }
            }
            [self.navigationController popViewControllerAnimated:NO];

            _rightButtonItem.enabled = EClientInviteViewTypeAddVisited ? YES : _selectedHouses.count > 0;
            _addedLabel.hidden = !(_selectedHouses.count > 0);
            _addedLine.hidden = !(_selectedHouses.count > 0);
        };

        __block QRScannerViewController *weakScanner = scannerViewController;
        scannerViewController.shouldFetchInfo = ^BOOL(NSArray *info)
        {
            NSString *targetType = _viewType == EClientInviteViewTypeShareNewHouse ? @"client" : @"house";
            NSString *subType = _viewType == EClientInviteViewTypeShareNewHouse ? @"": [EBFilter typeString:_clientDetail.rentalState];

            if (![targetType isEqualToString:info[0]])
            {
                NSString *key = [NSString stringWithFormat:@"qr_hint_%@_mismatch", targetType];
                [weakScanner.scannerView
                        showHint:NSLocalizedString(key, nil) duration:5.0];
                return NO;
            }
            else if (![subType isEqualToString:info[1]] && _viewType != EClientInviteViewTypeShareNewHouse)
            {
                NSString *key = [NSString stringWithFormat:@"qr_hint_%@_mismatch_%@", targetType, subType];
                [weakScanner.scannerView showHint:NSLocalizedString(key, nil) duration:5.0];
                return NO;
            }
            else
            {
                return YES;
            }
        };

        [self.navigationController pushViewController:scannerViewController animated:YES];
    }
    else
    {//按钮匹配房源
        if (_viewType == EClientInviteViewTypeAddInvite || _viewType == EClientInviteViewTypeAddVisited)
        {
            EHouseListType listType = tag == 3 && _viewType == EClientInviteViewTypeAddInvite ?EHouseListTypeMatchHousesForClient :((tag == 4) ? EHouseListTypeRecent :
                                                                                                                                    ((tag == 5) ? EHouseListTypeMarkedHousesForClient :((tag == 2 && _viewType == EClientInviteViewTypeAddVisited) ? EHouseListTypeInvited :EHouseListTypeRecommendedHousesForClient)));
            NSString *title = tag == 3 && _viewType == EClientInviteViewTypeAddInvite ? NSLocalizedString(@"btn_match_house", nil) : ((tag == 4) ? NSLocalizedString(@"recent_view", nil) :
                                                                                                                                      ((tag == 5) ?    NSLocalizedString(@"btn_marked", nil):((tag == 2 && _viewType == EClientInviteViewTypeAddVisited) ? NSLocalizedString(@"invited_house_title", nil): NSLocalizedString(@"btn_recommended", nil))));
            
            EBFilter *filter = nil;
            if (tag != 4)
            {
                filter = [[EBFilter alloc] init];
                [filter parseFromClient:_clientDetail withDetail:tag == 6];
            }
            //进入新房列表
            HouseListViewController *listViewController = [[EBController sharedInstance] showHouseListWithType:listType filter:filter title:title client:_clientDetail];
            listViewController.handleSelections = handleSelection;
        }
        else if (_viewType == EClientInviteViewTypeShareNewHouse)
        {
            EClientListType listType = tag == 3 ? EClientListTypeRecent : EClientListTypeCollected;
            NSString *title = tag == 3 ? NSLocalizedString(@"recent_view", nil) : NSLocalizedString(@"collected", nil);
            ClientListViewController *listViewController = [[EBController sharedInstance] showClientListWithType:listType filter:nil title:title house:nil];
            listViewController.handleSelections = handleSelection;
        }
    }
}


#pragma -mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return _selectedHouses.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (_viewType == EClientInviteViewTypeAddInvite || _viewType == EClientInviteViewTypeAddVisited)
    {
        HouseItemView *itemView;
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            itemView = [[HouseItemView alloc] initWithFrame:CGRectZero];
            itemView.tag = 88;
            itemView.selecting = YES;
            [cell.contentView addSubview:itemView];
            [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:84.0 leftMargin:5.0]];
            
            cell.shouldIndentWhileEditing = NO;
        }
        else
        {
            itemView = (HouseItemView *)[cell.contentView viewWithTag:88];
        }
        
        itemView.house = _selectedHouses[indexPath.row];
    }
    else if (_viewType == EClientInviteViewTypeShareNewHouse)
    {
        ClientItemView *itemView;
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            itemView = [[ClientItemView alloc] initWithFrame:CGRectZero];
            itemView.tag = 88;
            itemView.selecting = YES;
            [cell.contentView addSubview:itemView];
            [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:84.0 leftMargin:5.0]];
            
            cell.shouldIndentWhileEditing = NO;
        }
        else
        {
            itemView = (ClientItemView *)[cell.contentView viewWithTag:88];
        }
        
        itemView.client = _selectedHouses[indexPath.row];
    }
    return  cell;
}

#pragma -mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   return 84;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    EBHouse *house = _selectedHouses[indexPath.row];
    [_selectedHouses removeObjectAtIndex:indexPath.row];
    [_selectedIds removeObject:house.id];

    _rightButtonItem.enabled = EClientInviteViewTypeAddVisited ? YES : _selectedHouses.count > 0;
    _addedLabel.hidden = !(_selectedHouses.count > 0);
    _addedLine.hidden = !(_selectedHouses.count > 0);

    [tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
