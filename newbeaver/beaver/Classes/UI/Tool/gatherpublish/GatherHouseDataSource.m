//
//  GatherHouseDataSource.m
//  beaver
//
//  Created by ChenYing on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherHouseDataSource.h"
#import "GatherHouseItemView.h"
#import "EBViewFactory.h"
#import "EBGatherHouse.h"
#import "EBStyle.h"

@implementation GatherHouseDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
    if(row < [self.dataArray count])
    {
        EBGatherHouse *house = self.dataArray[row];
        CGFloat height = [EBViewFactory textSize:house.title font:[UIFont boldSystemFontOfSize:14.0] bounding:CGSizeMake(240.0, MAXFLOAT)].height;
        if (height < 34)
        {
            return 105.0 - 17.0;
        }
        
    }
    return 105.0;
}

- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row
{
    [EBTrack event:EVENT_CLICK_COLLECT_POST_COLLECT_HOUSE];
    [[EBController sharedInstance] showGatherHouseDetail:self.dataArray[row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    EBGatherHouse *house = self.dataArray[row];
    NSString *cellIdentifier = @"cellIdentifier1";
    CGFloat rowHeight = 105.0;
    CGFloat height = [EBViewFactory textSize:house.title font:[UIFont boldSystemFontOfSize:14.0] bounding:CGSizeMake(240.0, MAXFLOAT)].height;
    if (height < 34)
    {
        cellIdentifier = @"cellIdentifier2";
        rowHeight -= 17.0;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    GatherHouseItemView *itemView;
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        itemView = [[GatherHouseItemView alloc] initWithFrame:CGRectMake(0.0, 0.0, [EBStyle screenWidth], rowHeight)];
        itemView.tag = 88;
        [cell.contentView addSubview:itemView];
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:rowHeight leftMargin:5.0]];
    }
    else
    {
        itemView = (GatherHouseItemView *)[cell.contentView viewWithTag:88];
    }
    itemView.house = self.dataArray[row];
    itemView.showHouseType = _showHouseType;
    
    return cell;
}

@end
