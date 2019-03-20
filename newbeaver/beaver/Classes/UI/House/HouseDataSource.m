//
//  HouseDataSource.m
//  beaver
//
//  Created by 何 义 on 14-3-7.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseDataSource.h"
#import "HouseItemView.h"
#import "EBHouse.h"
#import "EBViewFactory.h"
#import "EBController.h"
#import "EBFilter.h"
#import "EBStyle.h"

@interface HouseDataSource()
@end

@implementation HouseDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
//    return row == 0 ? 44 : 88;
    return 84;
}

- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row
{
    if (!tableView.editing)
    {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"OPEN_CONTROLLER"
//                                                            object:nil userInfo:@{
//                @"type":@"house_detail",
//                @"data":_dataArray[row]
//        }];
        [[EBController sharedInstance] showHouseDetail:self.dataArray[row]];
    }
    else
    {
        [super tableView:tableView didSelectRow:row];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    static NSString *cellIdentifier = @"cellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    HouseItemView *itemView;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        itemView = [[HouseItemView alloc] initWithFrame:CGRectMake(0.0, 0.0, [EBStyle screenWidth], 84.0)];
        itemView.tag = 88;
        if (tableView.editing)
        {
            itemView.selecting = YES;
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
        }
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:itemView];
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:84.0 leftMargin:5.0]];

        if (tableView.isEditing)
        {
            UIView *selectedView = [[UIView alloc] init];
            [selectedView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:84.5 leftMargin:43.0]];
            cell.selectedBackgroundView = selectedView;
        }
    }
    else
    {
        itemView = (HouseItemView *)[cell.contentView viewWithTag:88];
    }

    itemView.showImage = _showImage;
    itemView.targetClientId = self.filter.clientId;
    itemView.house = self.dataArray[row];

    if (tableView.editing && [self.selectedSet containsObject:itemView.house])
    {
       [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO
                        scrollPosition:UITableViewScrollPositionNone];
    }

    return cell;
}

@end