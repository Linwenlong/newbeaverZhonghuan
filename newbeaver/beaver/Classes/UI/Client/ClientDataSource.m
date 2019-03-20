//
//  HouseDataSource.m
//  beaver
//
//  Created by 何 义 on 14-3-7.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientDataSource.h"
#import "ClientItemView.h"
#import "EBStyle.h"
#import "EBHttpClient.h"
#import "EBClient.h"
#import "EBHouse.h"
#import "EBViewFactory.h"
#import "EBIconLabel.h"
#import "EBClient.h"
#import "EBController.h"
#import "EBFilter.h"
#import "EBContact.h"

@interface ClientDataSource()
{
//    NSMutableArray *_dataArray;
}
@end

@implementation ClientDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
//    return row == 0 ? 44 : 88;
    return 84;
}

- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row
{
    if (tableView.isEditing)
    {
        [super tableView:tableView didSelectRow:row];
    }
    else
    {
        if (!_marking)
        {
            [[EBController sharedInstance] showClientDetail:self.dataArray[row]];
        }
        else
        {
            self.clickBlock(self.dataArray[row]);
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    static NSString *cellIdentifier = @"cellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    ClientItemView *itemView;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        itemView = [[ClientItemView alloc] initWithFrame:CGRectMake(0.0, 0.0, [EBStyle screenWidth], 84.0)];
        itemView.tag = 88;
        if (tableView.editing)
        {
            itemView.selecting = YES;

            if (self.clickBlock)
            {
                itemView.clickBlock = ^(EBClient *client)
                {
                    
                    self.clickBlock(client);
                };
            }
        }
        if (_marking)
        {
            itemView.marking = YES;
            itemView.changeMarkedStausBlock = ^(BOOL marked)
            {
                if (self.changeMarkedStausBlock)
                {
                    self.changeMarkedStausBlock(marked);
                }
            };
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        [cell.contentView addSubview:itemView];

        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:84.0 leftMargin:72.0]];

        if (tableView.isEditing)
        {
            UIView *selectedView = [[UIView alloc] init];
            [selectedView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:84.5 leftMargin:110]];
            cell.selectedBackgroundView = selectedView;
        }


    }
    else
    {
        itemView = (ClientItemView *)[cell.contentView viewWithTag:88];
    }

    itemView.client = self.dataArray[row];
    itemView.targetHouseId = self.filter.houseId;

    if (tableView.editing && [self.selectedSet containsObject:itemView.client])
    {
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }

    return cell;
}

@end


