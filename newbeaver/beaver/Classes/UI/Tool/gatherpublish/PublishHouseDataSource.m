//
//  PublishHouseDataSource.m
//  beaver
//
//  Created by wangyuliang on 14-9-3.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "PublishHouseDataSource.h"
#import "EBViewFactory.h"
#import "RIButtonItem.h"
#import "UIActionSheet+Blocks.h"
#import "PublishHouseViewController.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "EBController.h"
#import "PublishHouseWebViewController.h"

@implementation PublishHouseDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
    if(row < [self.dataArray count])
    {
        NSInteger status = [self.dataArray[row][@"status"] intValue];
        if (status < 0)
        {
            if (_showItemType == EPublishHouseItemRecord)
            {
                NSInteger count = self.dataArray.count;
                if (row < count)
                {
                    NSInteger status = [self.dataArray[row][@"status"] intValue];
                    if (status < 1)
                    {
                        NSString *error = NSLocalizedString(@"publish_record_fail_tip", nil);
                        if (![self.dataArray[row][@"error_info"] isKindOfClass:[NSNull class]]) {
                            NSString *temp = self.dataArray[row][@"error_info"];
                            if (temp.length > 0)
                            {
                                error = [NSString stringWithFormat:NSLocalizedString(@"publish_record_fail_tip_format", nil), self.dataArray[row][@"error_info"]];
//                                error = self.dataArray[row][@"error_info"];
                            }
                        }
                        CGSize textSize = [EBViewFactory textSize:error font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(220, 60)];
                        CGFloat height = 36;
                        if (textSize.height < 36)
                        {
                            height = textSize.height;
                        }
                        return 92 + height + 3;
                    }
                    else
                    {
                        return 92;
                    }
                }
            }
            else
            {
                return 92;
            }
        }
        else
        {
            return 92;
        }
//        EBGatherHouse *house = self.dataArray[row];
//        CGFloat height = [EBViewFactory textSize:house.title font:[UIFont boldSystemFontOfSize:14.0] bounding:CGSizeMake(240.0, MAXFLOAT)].height;
//        if (height < 34)
//        {
//            return 105.0 - 17.0;
//        }
        
    }
    return 92;
}

- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row
{
    if (_showItemType == EPublishHouseItemOrder)
    {
        NSMutableArray *buttons = [NSMutableArray new];
        [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"publish_appoint_change", nil) action:^{
            PublishHouseViewController *controller = [PublishHouseViewController new];
            controller.params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.dataArray[row][@"id"], @"publish_id", nil];
            controller.showActionSheet = YES;
            [[[EBController sharedInstance] currentNavigationController] pushViewController:controller animated:YES];
        }]];
        [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"publish_appoint_delete", nil) action:^{
            [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"publish_appoint_delete_warn", nil)
                                  yes:NSLocalizedString(@"publish_appoint_delete_certain", nil) action:^
             {
                 [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"id": self.dataArray[row][@"id"]} deletePublishedHouse:^(BOOL success, id result) {
                     if (success) {
                         if (self.refreshBlock)
                         {
                             self.refreshBlock(YES);
                         }
                         [EBAlert alertSuccess:NSLocalizedString(@"publish_appoint_delete_success", nil)];
                     }
                 }];
             }];
        }]];
        NSString *title = self.dataArray[row][@"error_info"];
        if ([title isKindOfClass:[NSNull class]])
        {
            title = nil;
        }
        [[[UIActionSheet alloc] initWithTitle:title buttons:buttons] showInView:[[EBController sharedInstance] currentNavigationController].view];
    }
    else
    {
        if ([_touchTag[row] intValue] == 1)
        {
            NSString *url;
            if ([self.dataArray[row][@"published_url"] isKindOfClass:[NSNull class]])
            {
                url = nil;
            }
            else
            {
                url = self.dataArray[row][@"published_url"];
            }
            if (url && url.length > 0)
            {
                PublishHouseWebViewController *webViewController = [[PublishHouseWebViewController alloc] init];
                webViewController.hidesBottomBarWhenPushed = YES;
                webViewController.request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
                webViewController.recordId = self.dataArray[row][@"id"];
                
                [[EBController sharedInstance].currentNavigationController pushViewController:webViewController animated:YES];
//                [[EBController sharedInstance] openWebViewWithUrl:[[NSURL alloc] initWithString:url]];
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    CGFloat rowHeight = [self heightOfRow:row];
    NSString *cellIdentifier = @"cellIdentifierPublishHouse";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    PublishHouseItemView *itemView;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        itemView = [[PublishHouseItemView alloc] initWithFrame:CGRectMake(0.0, 0.0, [EBStyle screenWidth], rowHeight)];
        itemView.tag = 200;
        itemView.row = row;
        itemView.touchTag = [_touchTag[row] intValue];
        itemView.delegate = self;
//        UITapGestureRecognizer *refreshTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refresh:)];
//        refreshTapGes.numberOfTapsRequired = 1;
//        [itemView.refreshView addGestureRecognizer:refreshTapGes];
//        UITapGestureRecognizer *tipTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tip:)];
//        tipTapGes.numberOfTapsRequired = 1;
//        [itemView.tipView addGestureRecognizer:tipTapGes];
        
        [cell.contentView addSubview:itemView];
//        UIView *line = [EBViewFactory tableViewSeparatorWithRowHeight:rowHeight - 0.5 leftMargin:5.0];
//        line.tag = 999;
//        [cell addSubview:line];
//        [cell.contentView bringSubviewToFront:line];
    }
    else
    {
        itemView = (PublishHouseItemView *)[cell viewWithTag:200];
        itemView.frame = CGRectMake(0.0, 0.0, [EBStyle screenWidth], rowHeight);
        itemView.row = row;
        itemView.touchTag = [_touchTag[row] intValue];
        itemView.delegate = self;
        
//        UIView *line = [cell.contentView viewWithTag:999];
//        line.frame = CGRectMake(line.frame.origin.x, rowHeight - line.frame.size.height - 0.5, line.frame.size.width, line.frame.size.height);
//        [cell bringSubviewToFront:line];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    itemView.publishHouse = self.dataArray[row];
    itemView.showItemType = _showItemType;
    
    return cell;
}

- (void)createTouchTag
{
    _touchTag = [[NSMutableArray alloc] init];
    NSInteger count = self.dataArray.count;
    for (int i = 0; i < count; i ++)
    {
        NSInteger status = [self.dataArray[i][@"status"] intValue];
        if (status == 1)
        {
            [_touchTag addObject:@(1)];
        }
        else if(status < 0)
        {
            [_touchTag addObject:@(2)];
        }
        else
        {
            [_touchTag addObject:@(0)];
        }
    }
}

#pragma mark - PublishHouseItemDelegate
- (void)refreshTouchTag:(NSInteger)row tag:(NSInteger)tag handlback:(httpHandBlock)handlback
{
    if (row < _touchTag.count)
    {
        if (tag == 3)
        {
            [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"id": self.dataArray[row][@"id"]} refreshPublishHouse:^(BOOL success, id result)
             {
                 if (success)
                 {
                     if (self.refreshBlock)
                     {
                         self.refreshBlock(YES);
                     }
                 }
                 else
                 {
                     handlback(success);
                 }
             }];
        }
        else
        {
            _touchTag[row] = @(tag);
            if (tag == 2)
            {
                if ([self.dataArray[row][@"status"] integerValue] <= 0) {
                    NSMutableArray *buttons = [NSMutableArray new];
                    [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"publish_record_change", nil) action:^{
                        PublishHouseViewController *controller = [PublishHouseViewController new];
                        controller.params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.dataArray[row][@"id"], @"publish_id", nil];
                        controller.showActionSheet = YES;
                        [[[EBController sharedInstance] currentNavigationController] pushViewController:controller animated:YES];
                    }]];
                    [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(@"publish_record_delete", nil) action:^{
                        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"publish_record_delete_warn", nil)
                                              yes:NSLocalizedString(@"publish_appoint_delete_certain", nil) action:^
                         {
                             [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"id": self.dataArray[row][@"id"]} deletePublishedHouse:^(BOOL success, id result) {
                                 if (success) {
                                     if (self.refreshBlock)
                                     {
                                         self.refreshBlock(YES);
                                     }
                                     [EBAlert alertSuccess:NSLocalizedString(@"publish_record_delete_success", nil)];
                                 }
                             }];
                         }];
                    }]];
                    NSString *title = self.dataArray[row][@"error_info"];
                    if ([title isKindOfClass:[NSNull class]])
                    {
                        title = nil;
                    }
                    [[[UIActionSheet alloc] initWithTitle:title buttons:buttons] showInView:[[EBController sharedInstance] currentNavigationController].view];
                }
            }
        }
    }
}

//#pragma mark - acton
//- (void)refresh:(UITapGestureRecognizer*)sender
//{
//    
//}
//
//- (void)tip:(UITapGestureRecognizer*)sender
//{
//    
//}


@end
