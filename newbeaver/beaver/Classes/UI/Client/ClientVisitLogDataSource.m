//
//  ClientVisitLogDataSource.m
//  beaver
//
//  Created by wangyuliang on 14-5-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientVisitLogDataSource.h"
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
#import "HouseItemView.h"
#import "EBClientVisitLog.h"
#import "FSBasicImageSource.h"
#import "FSImageViewerViewController.h"
#define  ImageBtnTag 10000
@implementation ClientVisitLogDataSource

- (CGFloat)heightOfRow:(NSInteger)row
{
    CGFloat height;
    if(row < [self.dataArray count])
    {
        EBClientVisitLog *log = self.dataArray[row];
        CGSize contentSize = [EBViewFactory textSize:log.visitContent font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(250, MAXFLOAT)];
        height = 139 + contentSize.height;
    }
    else
    {
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
            EBClientVisitLog *log = self.dataArray[row];
            [[EBController sharedInstance] showHouseDetail:log.house];
        }
        else
        {
            self.clickBlock(self.dataArray[row]);
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRow:(NSInteger)row
{
    EBClientVisitLog *log = self.dataArray[row];
    
    
//    ClientVisitLogDataSourceTableViewCell *Ncell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if (!Ncell) {
//        Ncell =  [[ClientVisitLogDataSourceTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"
//                 ];
//        Ncell.selectionStyle = UITableViewCellSelectionStyleNone;
//        Ncell.itemView.selecting = YES;
//    }
//    Ncell.itemView.selecting = NO;
//    
//    NSInteger timeDate = log.visitDate;
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
//    
//    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timeDate];
//    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
//    NSArray *array = [confromTimespStr componentsSeparatedByString:@" "];
//    
//    NSString *text = nil;
//    if([array count] > 1)
//    {
//        NSArray *dateArray = [array[0] componentsSeparatedByString:@"-"];
//        NSArray *timeArray = [array[1] componentsSeparatedByString:@":"];
//        NSInteger hour = [timeArray[0] intValue];
//        if(hour > 12)
//        {
//            hour = hour - 12;
//            text = [NSString stringWithFormat:@"%@年%@月%@日 下午%ld点", dateArray[0],dateArray[1],dateArray[2],hour];
//            //                time.text = text;
//        }
//        else
//        {
//            text = [NSString stringWithFormat:@"%@年%@月%@日 上午%ld点", dateArray[0],dateArray[1],dateArray[2],hour];
//            //                time.text = text;
//        }
//    }
//    else
//    {
//        text = [NSString stringWithFormat:@"%ld", log.visitDate];
//    }
//    NSString *timeLabelStr = [NSString stringWithFormat:@"%@ %@",text,log.visitUser];
//    NSMutableAttributedString *Mstr = [[NSMutableAttributedString alloc]initWithString:timeLabelStr];
//    NSRange range = [timeLabelStr rangeOfString:log.visitUser];
//    NSDictionary *attri = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blackColor]};
//    [Mstr addAttributes:attri range:range];
//    
//    
//    Ncell.timeLabel.attributedText = Mstr;
//    Ncell.titleLabel.text = log.visitContent;
//    
//    [Ncell.imageBtn addTarget:self action:@selector(showeImage:) forControlEvents:UIControlEventTouchUpInside];
//    Ncell.tag = ImageBtnTag + row;
//    if (log.images.count) {
//        Ncell.imageBtn.alpha = 1;
//        
//    }else{
//        Ncell.imageBtn.alpha = 0;
//    }
//    
//    
//    Ncell.itemView.house = log.house;
//    Ncell.itemView.tag = 88;
// 
//
//    if (_marking)
//    {
//        Ncell.itemView.marking = YES;
//    }
// 
//    if (tableView.isEditing)
//    {
//        UIView *selectedView = [[UIView alloc] init];
//        [selectedView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:Ncell.titleLabel.bottom leftMargin:38]];
//        Ncell.selectedBackgroundView = selectedView;
//    }
//    if ([self.selectedSet containsObject:Ncell.itemView.house])
//    {
//        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO
//                         scrollPosition:UITableViewScrollPositionNone];
//    }
//    return Ncell;
    
    
    
    CGSize contentSize = [EBViewFactory textSize:log.visitContent font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(250, MAXFLOAT)];
    
    
    static NSString *cellIdentifier = @"cell";
    
    ClientVisitLogDataSourceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    HouseItemView *itemView;
    UIButton *imageBtn;
    UIView *view;
    if (cell == nil)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 139 + contentSize.height)];
        
        
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
//                time.text = text;
            }
            else
            {
                text = [NSString stringWithFormat:@"%@年%@月%@日 上午%ld点", dateArray[0],dateArray[1],dateArray[2],hour];
//                time.text = text;
            }
        }
        else
        {
            text = [NSString stringWithFormat:@"%ld", log.visitDate];
        }
        CGSize timeSize = [EBViewFactory textSize:text font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(180, 640)];
        UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(0, 14, timeSize.width, timeSize.height)];
        time.text = text;
        time.tag = 55;
        time.font = [UIFont systemFontOfSize:12];
        time.textColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1];
        [view addSubview:time];
        
       
        
        UILabel *visitUser = [[UILabel alloc] initWithFrame:CGRectMake(timeSize.width + 3, 11.5,view.width - 22- (timeSize.width +3) -50, 18)];
        visitUser.text = log.visitUser;
        visitUser.tag =56;
        visitUser.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        [visitUser setFont:[UIFont boldSystemFontOfSize:14]];
//        [view addSubview:visitUser];
        
        
     

        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, 270, contentSize.height)];
        content.text = log.visitContent;
        [content setNumberOfLines:0];
        content.tag =57;
        content.font = [UIFont systemFontOfSize:12];
        content.textColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1];
        [view addSubview:content];
        
        
        cell = [[ClientVisitLogDataSourceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        itemView = [[HouseItemView alloc] initWithFrame:CGRectMake(0, 39 + contentSize.height, [EBStyle screenWidth] - 28, 84)];
//        [itemView changeSize];
        itemView.backgroundColor = [UIColor colorWithRed:239/255.0 green:241/255.0 blue:246/255.0 alpha:1];
        itemView.tag = 88;
        if (tableView.editing)
        {
            itemView.selecting = YES;
            
//            itemView.clickBlock = ^(EBHouse *house)
//            {
//                self.clickBlock(client);
//            };
        }
        if (_marking)
        {
            itemView.marking = YES;
        }
        
        [view addSubview:itemView];
        
        [cell.contentView addSubview:view];
        
        [cell.contentView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:139 + contentSize.height - 0.5 leftMargin:0.0]];
        
        cell.imageBtn = [[UIButton alloc]initWithFrame:CGRectMake([EBStyle screenWidth] - 40 - 80, visitUser.top, 80, 36 )];
        cell.imageBtn.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 44/2, 36/2)];
        imageView.image = [UIImage imageNamed:@"dkjl_img"];
        [cell.imageBtn addSubview:imageView];
        imageView.center = CGPointMake(cell.imageBtn.width/2.0, cell.imageBtn.height/2.0);
        
        [cell.contentView addSubview:cell.imageBtn];
        
        if (tableView.isEditing)
        {
            UIView *selectedView = [[UIView alloc] init];
            [selectedView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:139 + contentSize.height - 0.5 leftMargin:38]];
            cell.selectedBackgroundView = selectedView;
        }
    }
   
    itemView = (HouseItemView *)[cell.contentView viewWithTag:88];
    itemView.house = log.house;
    
    
    
    
    cell.imageBtn.tag = row + ImageBtnTag;
    [cell.imageBtn addTarget:self action:@selector(showeImage:) forControlEvents:UIControlEventTouchUpInside];

    if (log.images.count) {
        cell.imageBtn.alpha = 1;
        
    }else{
        cell.imageBtn.alpha = 0;
    }
    
    if (tableView.editing && [self.selectedSet containsObject:itemView.house])
    {
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }
    
    
    
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
            //                time.text = text;
        }
        else
        {
            text = [NSString stringWithFormat:@"%@年%@月%@日 上午%ld点", dateArray[0],dateArray[1],dateArray[2],hour];
            //                time.text = text;
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"%ld", log.visitDate];
    }
    
    NSString * timeName = [NSString stringWithFormat:@"%@ %@",text,log.visitUser];
    NSRange range = [timeName rangeOfString:log.visitUser];
    NSMutableAttributedString *Mstr = [[NSMutableAttributedString alloc]initWithString:timeName];
    NSDictionary *attr = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:12]};
    [Mstr addAttributes:attr range:range];
    

    CGSize timeSize = [EBViewFactory textSize:timeName font:[UIFont systemFontOfSize:12] bounding:CGSizeMake(180, 640)];
    UILabel *time = (UILabel *)[cell viewWithTag:55];
//    time.text = text;
    time.frame =CGRectMake(0, 14, timeSize.width, timeSize.height);
//    time.backgroundColor = [UIColor redColor];
    time.attributedText = Mstr;
    
//    UILabel *visitUser = (UILabel *)[cell viewWithTag:56];
//    visitUser.text = log.visitUser;
//    visitUser.frame = CGRectMake(time.right + 3, 11.5,view.width - 22- (time.right +3) -50, 18);
    
    
    
    UILabel *content = (UILabel *)[cell viewWithTag:57];
    content.text = log.visitContent;


    
    
    
    return cell;
    
}
- (void)showeImage:(UIButton *)btn
{
    EBClientVisitLog *log = self.dataArray[btn.tag - ImageBtnTag];
    
    self.imageBlock(log);
}

@end



@implementation ClientVisitLogDataSourceTableViewCell

 - (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

@end
