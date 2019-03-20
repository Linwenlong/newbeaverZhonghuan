//
//  HouseCollectionDataSource.m
//  beaver
//
//  Created by wangyuliang on 14-6-17.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseCollectionDataSource.h"
#import "HouseItemView.h"
#import "EBHouse.h"
#import "EBViewFactory.h"
#import "EBController.h"
#import "EBFilter.h"
#import "EBStyle.h"

@interface HouseCollectionDataSource()
@end

@implementation HouseCollectionDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
    return 84;
}

- (UIView *)emptyView:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *labelOne = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, [EBStyle screenWidth], 35)];
    labelOne.textAlignment = NSTextAlignmentCenter;
    labelOne.textColor = [EBStyle blackTextColor];
    labelOne.font = [UIFont systemFontOfSize:14.0];
    labelOne.textColor = [EBStyle grayTextColor];
    labelOne.backgroundColor = [UIColor clearColor];
    labelOne.text = NSLocalizedString(@"empty_collected_house", nil);
    
    //    labelOne.textAlignment = NSTextAlignmentCenter;
    //    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x * 0.1, frame.origin.y * 0.4 + 60, frame.origin.x * 0.8, 50)];
    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 120 , [EBStyle screenWidth], 35)];
    labelTwo.text = NSLocalizedString(@"empty_collectedtip_house", nil);
    labelTwo.font = [UIFont systemFontOfSize:12.0];
    labelTwo.textAlignment = NSTextAlignmentCenter;
    labelTwo.textColor = [EBStyle grayTextColor];
    labelTwo.backgroundColor = [UIColor clearColor];
    [view addSubview:labelOne];
    [view addSubview:labelTwo];
    
    return view;
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
        
//        itemView.backgroundColor = [UIColor redColor];
        
        itemView.tag = 88;
        if (tableView.editing)
        {
            itemView.selecting = YES;
        }
        if (_marking)
        {
            itemView.marking = YES;
        }
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
