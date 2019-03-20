//
//  ClientDataSourceCollection.m
//  beaver
//
//  Created by wangyuliang on 14-6-17.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientDataSourceCollection.h"
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
#import "EBAppointment.h"

@interface ClientDataSourceCollection()
{
    
}

@end

@implementation ClientDataSourceCollection

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
    labelOne.text = NSLocalizedString(@"empty_collected_client", nil);
    
    //    labelOne.textAlignment = NSTextAlignmentCenter;
    //    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x * 0.1, frame.origin.y * 0.4 + 60, frame.origin.x * 0.8, 50)];
    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 120 , [EBStyle screenWidth], 35)];
    labelTwo.text = NSLocalizedString(@"empty_collectedtip_client", nil);
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
    static NSString *cellIdentifier = @"cellCollection";
    
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
            
            itemView.clickBlock = ^(EBClient *client)
            {
                
                self.clickBlock(client);
            };
        }
        if (_marking)
        {
            itemView.marking = YES;
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
