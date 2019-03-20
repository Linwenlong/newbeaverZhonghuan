//
//  HouseInviteDataSource.m
//  beaver
//
//  Created by wangyuliang on 14-5-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "HouseVisitLogDataSource.h"
#import "EBStyle.h"
#import "EBHttpClient.h"
#import "EBHouse.h"
#import "EBViewFactory.h"
#import "EBIconLabel.h"
#import "EBContact.h"
#import "EBPrice.h"
#import "EBController.h"
#import "EBFilter.h"
#import "UIImageView+AFNetworking.h"
#import "ClientItemView.h"
#import "EBHouseVisitLog.h"


@implementation HouseVisitLogDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
    CGFloat height;
    if(row < [self.dataArray count]){
        EBHouseVisitLog *log = self.dataArray[row];
        CGSize contentSize = [EBViewFactory textSize:log.visitContent font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(292, 640)];
        height = 139 + contentSize.height;
    }
    else{
        height = 157;
    }
    return height;
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
            EBHouseVisitLog *log = self.dataArray[row];
            [[EBController sharedInstance] showClientDetail:log.client];
        }
        else
        {
            self.clickBlock(self.dataArray[row]);
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    EBHouseVisitLog *log = self.dataArray[row];
    CGSize contentSize = [EBViewFactory textSize:log.visitContent font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(292, 640)];
    
    
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    ClientItemView *itemView;
    if (cell == nil)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 139 + contentSize.height)];
        NSInteger timeDate = log.visitDate;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeDate];
        NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
        NSArray *array = [confromTimespStr componentsSeparatedByString:@" "];
        
        NSString *text = nil;
        if([array count] > 1)
        {
            NSArray *dateArray = [array[0] componentsSeparatedByString:@"-"];
            NSArray *timeArray = [array[1] componentsSeparatedByString:@":"];
            NSInteger hour = [timeArray[0] intValue];
            if(hour > 12)
            {
                hour = hour - 12;
                text = [NSString stringWithFormat:@"%@年%@月%@日 下午%ld点", dateArray[0],dateArray[1],dateArray[2],hour];
            }
            else
            {
                text = [NSString stringWithFormat:@"%@年%@月%@日 上午%ld点", dateArray[0],dateArray[1],dateArray[2],hour];
            }
        }
        else
        {
            text = [NSString stringWithFormat:@"%ld", log.visitDate];
        }
        CGSize timeSize = [EBViewFactory textSize:text font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(180, 640)];
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(14, 14, timeSize.width, timeSize.height)];
        time.text = text;
        time.font = [UIFont systemFontOfSize:12];
        time.textColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1];
        [view addSubview:time];
        
        UILabel *visitUser = [[UILabel alloc] initWithFrame:CGRectMake(14 + timeSize.width + 3, 11.5, 140, 18)];
        visitUser.text = log.visitUser;
        visitUser.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        [visitUser setFont:[UIFont boldSystemFontOfSize:14]];
        [view addSubview:visitUser];
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(14, 32, 292, contentSize.height)];
        content.text = log.visitContent;
        [content setNumberOfLines:0];
        content.font = [UIFont systemFontOfSize:12];
        content.textColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1];
        [view addSubview:content];
        
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        itemView = [[ClientItemView alloc] initWithFrame:CGRectMake(14, 39 + contentSize.height, [EBStyle screenWidth] - 28, 84)];
        [itemView moveLocation];
        itemView.backgroundColor = [UIColor colorWithRed:239/255.0 green:241/255.0 blue:246/255.0 alpha:1];
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
        }
        
        [view addSubview:itemView];
        
        [cell.contentView addSubview:view];
        
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:139 + contentSize.height - 0.5 leftMargin:0.0]];
        
        if (tableView.isEditing)
        {
            UIView *selectedView = [[UIView alloc] init];
            [selectedView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:139 + contentSize.height - 0.5 leftMargin:0]];
            cell.selectedBackgroundView = selectedView;
        }
        
        
    }
    else
    {
        itemView = (ClientItemView *)[cell.contentView viewWithTag:88];
    }

    itemView.client = log.client;

    if (tableView.editing && [self.selectedSet containsObject:itemView.client])
    {
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

@end

