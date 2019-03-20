//
//  ClientDataSourceInvite.m
//  beaver
//
//  Created by wangyuliang on 14-5-20.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientDataSourceInvite.h"
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


@interface ClientDataSourceInvite()
{
    //    NSMutableArray *_dataArray;
}
@end

@implementation ClientDataSourceInvite

- (CGFloat)heightOfRow:(NSInteger)row
{
    return 110;
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
            EBAppointment *appointment = self.dataArray[row];
            [[EBController sharedInstance] showClientDetail:appointment.client];
        }
        else
        {
            self.clickBlock(self.dataArray[row]);
        }
    }
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
    labelOne.text = NSLocalizedString(@"empty_invite_client", nil);

//    labelOne.textAlignment = NSTextAlignmentCenter;
//    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x * 0.1, frame.origin.y * 0.4 + 60, frame.origin.x * 0.8, 50)];
    UILabel *labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 120 , [EBStyle screenWidth], 35)];
    labelTwo.text = NSLocalizedString(@"empty_invitetip_client", nil);
    labelTwo.font = [UIFont systemFontOfSize:12.0];
    labelTwo.textAlignment = NSTextAlignmentCenter;
    labelTwo.textColor = [EBStyle grayTextColor];
    labelTwo.backgroundColor = [UIColor clearColor];
    [view addSubview:labelOne];
    [view addSubview:labelTwo];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    static NSString *cellIdentifier = @"cellIdentifier";
    EBAppointment *appointment = self.dataArray[row];
    NSInteger time = appointment.timestamp;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSArray *array = [confromTimespStr componentsSeparatedByString:@" "];
    NSString *timeShow;
    if([array count] > 1)
    {
        NSArray *dateArray = [array[0] componentsSeparatedByString:@"-"];
        NSArray *timeArray = [array[1] componentsSeparatedByString:@":"];
        if(([dateArray count] > 2) && ([timeArray count] > 2))
        {
            int hour = [timeArray[0] intValue];
            if( hour == 0)
            {
                timeShow = [NSString stringWithFormat:@"   %@年%@月%@日 上午%d:%@",dateArray[0],dateArray[1],dateArray[2],12,timeArray[1]];
            }
            else if (hour == 12)
            {
                timeShow = [NSString stringWithFormat:@"   %@年%@月%@日 下午%d:%@",dateArray[0],dateArray[1],dateArray[2],12,timeArray[1]];
            }
            else if( (hour < 12) && (hour > 0) )
            {
                timeShow = [NSString stringWithFormat:@"   %@年%@月%@日 上午%d:%@",dateArray[0],dateArray[1],dateArray[2],hour,timeArray[1]];
            }
            else
            {
                hour = hour - 12 ;
                timeShow = [NSString stringWithFormat:@"   %@年%@月%@日 下午%d:%@",dateArray[0],dateArray[1],dateArray[2],hour,timeArray[1]];
            }
        }
        else
            timeShow = confromTimespStr;
    }
    else
    {
        timeShow = confromTimespStr;
    }
    
    NSString *title = [NSString stringWithFormat:@"%@ %@",timeShow , appointment.addressTitle];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    ClientItemView *itemView;
    if (cell == nil)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 100)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 30)];
        label.text = title;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithRed:138/255.0 green:151/255.0 blue:181.0/255 alpha:1.0];
//        label.textColor = [UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:1];
//        NSString *text = @"其实没什么";
//        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
//        [attributeString setAttributes:@{NSForegroundColorAttributeName : [UIColor redColor],   NSFontAttributeName : [UIFont systemFontOfSize:13]} range:NSMakeRange(2, 1)];
//        label.attributedText = attributeString;
        
//        label.font = [UIFont fontWithName:[label fontName] size:13];
        UIColor *labelColor= [UIColor colorWithRed:239/255.0 green:241/255.0 blue:246/255.0 alpha:1];
        label.backgroundColor = labelColor;
        [view addSubview:label];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        itemView = [[ClientItemView alloc] initWithFrame:CGRectMake(0, 30, [EBStyle screenWidth], 70)];
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
        
        [view addSubview:itemView];
        
        [cell.contentView addSubview:view];
        
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:110.5 leftMargin:72.0]];
        
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
    
    itemView.client = appointment.client;
    itemView.targetHouseId = self.filter.houseId;
    
    if (tableView.editing && [self.selectedSet containsObject:itemView.client])
    {
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

@end