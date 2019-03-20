//
//  HouseEditViewController.m
//  beaver
//
//  Created by wangyuliang on 14-7-31.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseEditViewController.h"
#import "HouseEditFirstStepViewController.h"
#import "RIButtonItem.h"
#import "UIAlertView+Blocks.h"
#import "EBHttpClient.h"
#import "EBFilter.h"
#import "EBCache.h"
#import "HouseAddSecondStepViewController.h"
#import "HouseAddViewController.h"
#import "EBAlert.h"

#define ITEM_TEXT_Y_GAP           10.0
#define ITEM__GAP                 20.0
#define ITEM__TITLE_HEIGHT        30.0
#define ITEM__PARA_HEIGHT         20.0
#define ITEM_VIEW_X_GAP           14.0
#define ITEM_TEXT_X_GAP           20.0


@interface HouseEditViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *_tableView;
}

@end

@implementation HouseEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"house_edit_title", nil);
    
    CGRect frame = [EBStyle fullScrTableFrame:NO];
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [self buildTableHeaderView];
    [self.view addSubview:_tableView];
}

- (UIView *)buildTableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, [EBStyle screenWidth] - 2 * 14, 30)];
    label.textColor = [EBStyle blackTextColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = NSLocalizedString(@"house_edit_page_header", nil);
    [headerView addSubview:label];
    return headerView;
}

#pragma -mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifierEmpty = @"HouseEditCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierEmpty];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierEmpty];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    UIView *itemView = [cell.contentView viewWithTag:100];
    if (itemView)
    {
        [itemView removeFromSuperview];
    }
    [cell.contentView addSubview:[self buildItemView:indexPath.row]];
    
    return cell;
}

- (UIView*)buildItemView:(NSInteger)row
{
    CGFloat height = [self heightForRow:row];
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(ITEM_VIEW_X_GAP, 0, [EBStyle screenWidth] - 2 * ITEM_VIEW_X_GAP, height - ITEM__GAP)];
    itemView.tag = 100;
    itemView.backgroundColor = [UIColor colorWithRed:235/255.0 green:240/255.0 blue:247/255.0 alpha:1];
    [self addImageFor:itemView];
    [self addTextView:itemView row:row];
    return itemView;
}

- (void)addImageFor:(UIView *)itemView
{
    if (itemView)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory_arrow"]];
        imageView.frame = CGRectOffset(imageView.frame, itemView.frame.size.width - 10 - imageView.frame.size.width, (itemView.frame.size.height - imageView.frame.size.height) / 2);
        [itemView addSubview:imageView];
    }
}
- (void)addTextView:(UIView*)itemView row:(NSInteger)row
{
    if (itemView)
    {
        [itemView addSubview:[self createTitleLabel:row]];
        NSInteger count = 0;
        if (row == 0)
        {
            count = 2;
        }
        else if (row == 1)
        {
            count = 3;
        }
        else if (row == 2)
        {
            count = 6;
        }
        for (int i = 0; i < count; i ++)
        {
            [itemView addSubview:[self createTextLabel:row order:i]];
        }
    }
}

- (UILabel*)createTitleLabel:(NSInteger)row
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(ITEM_TEXT_X_GAP, ITEM_TEXT_Y_GAP, [EBStyle screenWidth] - 2 * ITEM_VIEW_X_GAP - ITEM_TEXT_X_GAP, 30)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [EBStyle blackTextColor];
    titleLabel.font = [UIFont systemFontOfSize:16.0];
    NSString *format = [NSString stringWithFormat:@"house_edit_item_title_%ld", row];
    titleLabel.text = NSLocalizedString(format, nil);
    return titleLabel;
}

- (UILabel*)createTextLabel:(NSInteger)row order:(NSInteger)order
{
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(ITEM_TEXT_X_GAP, ITEM_TEXT_Y_GAP + 30 + order * 20, [EBStyle screenWidth] - 2 * ITEM_VIEW_X_GAP - ITEM_TEXT_X_GAP, 20)];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textColor = [EBStyle blackTextColor];
    NSString *format = [NSString stringWithFormat:@"house_edit_item%ld_text_%ld", row, order];
    textLabel.text = NSLocalizedString(format, nil);
    return textLabel;
}

#pragma -mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForRow:indexPath.row];
}

- (CGFloat)heightForRow:(NSInteger)row
{
    CGFloat height = 0;
    if (row == 0)
    {
        height = ITEM_TEXT_Y_GAP * 2 + ITEM__GAP + ITEM__TITLE_HEIGHT + ITEM__PARA_HEIGHT * 2;
    }
    else if (row == 1)
    {
        height = ITEM_TEXT_Y_GAP * 2 + ITEM__GAP + ITEM__TITLE_HEIGHT + ITEM__PARA_HEIGHT * 3;
    }
    else if (row == 2)
    {
        height = ITEM_TEXT_Y_GAP * 2 + ITEM__GAP + ITEM__TITLE_HEIGHT + ITEM__PARA_HEIGHT * 6;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1)
    {
//        if (indexPath.row == 1) {
//            [EBAlert alertError:@"暂时屏蔽了修改座栋,单元,房号等信息。" length:2.0f];
//            return;
//        }
        
        if (_houseDetail.phoneNumbers && _houseDetail.phoneNumbers.count > 0)
        {
            [self showEditView:indexPath.row];
        }
        else if (_houseDetail.inputbyme)
        {
            NSDictionary *params = @{@"id":_houseDetail.id, @"type": [EBFilter typeString:_houseDetail.rentalState],@"contract_code":_houseDetail.contractCode};
            NSString *viewPhoneNumberUri = BEAVER_HOUSE_VIEW_PHONE_NUMBER;
            [EBAlert showLoading:nil];
            [[EBHttpClient sharedInstance] ebPost:viewPhoneNumberUri parameters:params handler:^(BOOL success, NSDictionary *result)
             {
                 if (success)
                 {
                     [EBAlert hideLoading];
                     NSDictionary *detail = result[@"detail"];
                     _houseDetail.phoneNumbers = detail[@"phone_numbers"];
                     _houseDetail.address = detail[@"address"];
                     _houseDetail.coreMemo = detail[@"core_memo"];
                     _houseDetail.name = detail[@"name"];
                     [[EBCache sharedInstance] cacheHouseDetail:_houseDetail];
                     [self showEditView:indexPath.row];
                 }
                 
             }];
        }
        else if (_houseDetail.timesRemain > 0)
        {
            //编辑 x 信息需消耗“当日看电话个数”,是否继续? (您今天还可查看 y 个,需消耗 1 个)
            NSString *format = [NSString stringWithFormat:@"house_edit_hastime_warn_%ld",indexPath.row];
            NSString *mes = [NSString stringWithFormat:NSLocalizedString(format, nil), _houseDetail.timesRemain];
            NSString *title = nil;
            if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                if (title == nil) {
                    title = @"";
                }
            }
            [[[UIAlertView alloc] initWithTitle:title
                                        message:mes
                               cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"cancel", nil) action:nil]
                               otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"anonymous_call_continue", nil) action:^{
                [[EBHttpClient sharedInstance] houseRequest:@{@"id":_houseDetail.id, @"type": [EBFilter typeString:_houseDetail.rentalState]}
                                            viewPhoneNumber:^(BOOL success, id result)
                 {
                     if (success)
                     {
                         NSDictionary *detail = result[@"detail"];
                         _houseDetail.phoneNumbers = detail[@"phone_numbers"];
                         _houseDetail.address = detail[@"address"];
                         _houseDetail.name = detail[@"name"];
                         [[EBCache sharedInstance] cacheHouseDetail:_houseDetail];
                         [self showEditView:indexPath.row];
                     }
                 }];
            }], nil] show];
        }
        else
        {
            //很抱歉,编辑 x 信息需消耗“当日看电话个数”, 您今天还可查看 0 个,所以无法操作。您可以联系 贵公司 ERP 管理员,请其以 admin 身份登录 ERP, 在“手机 APP 管理”下调整“看电话设置”。
            NSString *warn = [NSString stringWithFormat:@"house_edit_nostime_warn_%ld",indexPath.row];
            NSString *title = nil;
            if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
                if (title == nil) {
                    title = @"";
                }
            }
            [[[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(warn, nil) cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"anonymous_call_end_confirm", nil) action:nil] otherButtonItems:nil] show];
        }
    }
    else
    {
        [self showEditView:indexPath.row];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)showEditView:(NSUInteger) row
{
    if (row == 0) {
        HouseEditFirstStepViewController *controller = [HouseEditFirstStepViewController new];
        controller.house = _houseDetail;
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (row == 1) {
        HouseAddSecondStepViewController *controller = [HouseAddSecondStepViewController new];
        controller.editFlag = YES;
        controller.house = _houseDetail;
        if (_houseDetail.purpose == 9) {
            controller.purpose = @"住宅";
        }else if (_houseDetail.purpose == 8){
            controller.purpose = @"写字楼";
        }else if (_houseDetail.purpose == 5){
            controller.purpose = @"商铺";
        }else if (_houseDetail.purpose == 2){
            controller.purpose = @"厂房";
        }else{
            controller.purpose = @"其他";
        }
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (row == 2) {
        HouseAddViewController *controller = [HouseAddViewController new];
        controller.editFlag = YES;
        controller.house = _houseDetail;
        controller.is_addHouse = NO;
        controller.if_start = _houseDetail.if_start;//是否开启座栋规则
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
