//
//  NewHouseFilingDataSource.m
//  beaver
//
//  Created by ChenYing on 14-8-4.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "NewHouseFilingDataSource.h"
#import "EBViewFactory.h"
#import "EBStyle.h"
#import "EBController.h"
#import "EBNewHouseFollow.h"
#import "NewHouseWebViewController.h"
#import "EBController.h"

@implementation NewHouseFilingDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
    CGFloat height;
    if(row < [self.dataArray count])
    {
        EBNewHouseFollow *log = self.dataArray[row];
        if (log.statusNote.length > 0)
        {
            NSString *format = log.status.integerValue == -1 ? @"filing_reject_reason_format" : @"filing_memo_format";
            CGSize contentSize = [EBViewFactory textSize:[NSString stringWithFormat:NSLocalizedString(format, nil), log.statusNote] font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(290, MAXFLOAT)];
            height = 97 + contentSize.height + 2;
        }
        else
        {
            height = 97;
        }
        
    }
    else
    {
        height = 97;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    EBNewHouseFollow *follow = self.dataArray[row];
    NSString *format = follow.status.integerValue == -1 ? @"filing_reject_reason_format" : @"filing_memo_format";
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        CGFloat yOffset = 10.0;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 17.0)];
        textLabel.font = [UIFont systemFontOfSize:14.0];
        textLabel.textColor = [EBStyle blackTextColor];
        textLabel.tag = 1000;
        [cell.contentView addSubview:textLabel];
        
//        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameSize.width + 15.0 + 10.0, yOffset, 290.0 - nameSize.width - 10.0, 17.0)];
//        textLabel.font = [UIFont systemFontOfSize:12.0];
//        textLabel.textColor = [EBStyle grayTextColor];
//        textLabel.tag = 1001;
//        [cell.contentView addSubview:textLabel];
        
        yOffset += 17.0 + 2.0;
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 17.0)];
        textLabel.font = [UIFont systemFontOfSize:14.0];
        textLabel.textColor = [EBStyle blackTextColor];
        textLabel.tag = 1002;
        [cell.contentView addSubview:textLabel];
        yOffset += 17.0 + 2.0;
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 15.0)];
        textLabel.font = [UIFont systemFontOfSize:12.0];
        textLabel.textColor = [EBStyle grayTextColor];
        textLabel.tag = 1003;
        [cell.contentView addSubview:textLabel];
        yOffset += 15.0 + 3.0;
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 21.0)];
        textLabel.layer.borderColor = [EBStyle blackTextColor].CGColor;
        textLabel.layer.borderWidth = 0.5;
        textLabel.font = [UIFont systemFontOfSize:14.0];
        textLabel.textColor = [EBStyle blackTextColor];
        textLabel.tag = 1004;
        [cell.contentView addSubview:textLabel];
        yOffset += 21.0 + 2.0;
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yOffset, 290.0, 17.0)];
        textLabel.font = [UIFont systemFontOfSize:14.0];
        textLabel.textColor = [EBStyle grayTextColor];
        textLabel.numberOfLines = 0;
        textLabel.tag = 1005;
        [cell.contentView addSubview:textLabel];
        
        yOffset += 17.0 + 10.0;
        UIView *sepatator = [EBViewFactory tableViewSeparatorWithRowHeight:yOffset - 0.5 leftMargin:[EBStyle separatorLeftMargin]];
        sepatator.tag = 1006;
        [cell.contentView addSubview:sepatator];
    }
//    CGSize nameSize = [EBViewFactory textSize:follow.clientName font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(160.0, 17.0)];
    CGSize noteSize = CGSizeMake(0.0, 0.0);
    if (follow.statusNote.length > 0)
    {
        noteSize = [EBViewFactory textSize:[NSString stringWithFormat:NSLocalizedString(format, nil), follow.statusNote] font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(290, MAXFLOAT)];
    }
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:1000];
    textLabel.text = [NSString stringWithFormat:@"%@   %@", follow.clientName, follow.clientPhone];
//    textLabel = (UILabel *)[cell.contentView viewWithTag:1001];
//    CGRect frame = textLabel.frame;
//    frame.origin.x = nameSize.width + 15.0 + 10.0;
//    frame.size.width = 290.0 - nameSize.width - 10.0;
//    textLabel.frame = frame;
//    textLabel.text = follow.clientPhone;
    textLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    textLabel.text = follow.projectName;
    textLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    textLabel.text = follow.updateDate;
    textLabel = (UILabel *)[cell.contentView viewWithTag:1004];
    textLabel.text = [NSString stringWithFormat:@" %@",follow.statusTitle];
    textLabel = (UILabel *)[cell.contentView viewWithTag:1005];
    CGRect frame = frame = textLabel.frame;
    frame.size.height = noteSize.height;
    textLabel.frame = frame;
    if (follow.statusNote.length > 0)
    {
        textLabel.text = [NSString stringWithFormat:NSLocalizedString(format, nil), follow.statusNote];
    }
    UIView *sepatator = (UILabel *)[cell.contentView viewWithTag:1006];
    frame = sepatator.frame;
    frame.origin.y = 97 + noteSize.height - 0.5 + (noteSize.height == 0 ? 0 : 2);
    sepatator.frame = frame;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRow:(NSInteger)row
{
    EBNewHouseFollow *follow = self.dataArray[row];
    NewHouseWebViewController *viewController = [[NewHouseWebViewController alloc] init];
    NSString *URLString = [NSString stringWithFormat:@"%@/%@",NSLocalizedString(@"new_house_follow_detail", nil), follow.id];
    viewController.requestURL = URLString;
    viewController.follow = follow;
    [[[EBController sharedInstance] currentNavigationController] pushViewController:viewController animated:YES];
//    [[EBController sharedInstance] showFilingDetailView];
}

@end
