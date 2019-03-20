//
//  ClientHisInviteViewController.m
//  beaver
//
//  Created by wangyuliang on 14-6-23.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientHisInviteViewController.h"
#import "EBClient.h"
#import "EBSearch.h"
#import "EBFilter.h"
#import "QRScannerViewController.h"
#import "QRScannerView.h"
#import "EBHouse.h"
#import "HouseItemView.h"
#import "EBViewFactory.h"
#import "ClientInviteNextViewController.h"
#import "EBAppointment.h"
#import "NSDate-Utilities.h"
#import "UIImage+ImageWithColor.h"
#import <MapKit/MapKit.h>
#import "ClientInviteViewController.h"
#import "ClientDetailViewController.h"

@interface ClientHisInviteViewController () <UITableViewDataSource , UITableViewDelegate>
{
    UITableView *_tableView;
    UIBarButtonItem *_nextStep;
}

@end

@implementation ClientHisInviteViewController

- (void)loadView
{
    [super loadView];
    
    self.title = NSLocalizedString(@"invite_title", nil);
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [self buildTableHeaderView];
    _tableView.editing = NO;
    _nextStep = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"invite", nil)
                                              target:self action:@selector(nextStep)];
    _nextStep.enabled = YES;
    
    [self.view addSubview:_tableView];
    UIImage *backImage = [UIImage imageNamed:@"icon_back"];
    UIBarButtonItem *buttonback =[[UIBarButtonItem alloc]initWithImage:backImage style:UIBarButtonItemStyleDone target:self action:@selector(leftBack)];
    self.navigationItem.leftBarButtonItem = buttonback;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_tableView reloadData];
}

- (void)leftBack
{
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *popToViewController = nil;
    for (UIViewController *viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[ClientDetailViewController class]])
        {
            popToViewController = viewController;
            break;
        }
    }
    
    if (popToViewController)
    {
        dispatch_after(DISPATCH_TIME_NOW + NSEC_PER_SEC / 2, dispatch_get_main_queue(), ^{
                [self.navigationController popToViewController:popToViewController animated:YES];
            });
    }
}

-(void)nextStep
{
    ClientInviteViewController *viewController = [[ClientInviteViewController alloc] init];
    viewController.clientDetail = _clientDetail;
    viewController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (UIView *)buildTableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 38)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, [EBStyle screenWidth] - 2 * 15, 38)];
    label.text = NSLocalizedString(@"appoint_history", nil);
    label.font = [UIFont systemFontOfSize:14.0];
    label.textColor = [EBStyle blackTextColor];
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    return headerView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _appointArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 64;
    if([_appointArray count] > [indexPath row])
    {
        EBAppointment *appointment = [_appointArray objectAtIndex:[indexPath row]];
        if ((appointment.latitude != 0) && (appointment.longitude != 0))
        {
            height = height + 90;
        }
        height = height + 84 * [appointment.houses count];
        height = height + 10;
    }
    return  height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellTag = 0;
    NSInteger mapTag = 0;
    EBAppointment *appointment = nil;
    CGFloat height = 64;
    if([_appointArray count] > [indexPath row])
    {
        appointment = [_appointArray objectAtIndex:[indexPath row]];
        if ((appointment.latitude != 0) && (appointment.longitude != 0))
        {
            height = height + 90;
            mapTag = 1;
        }
        height = height + 84 * [appointment.houses count];
        cellTag = cellTag + [appointment.houses count];
        height = height + 10;
    }
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"hisAppointment_%ld_%ld", cellTag, mapTag];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(14, 0, 292, height - 14)];
        containerView.layer.borderColor = [[UIColor colorWithRed:205/255.0 green:216/255.0 blue:230/255.0 alpha:1] CGColor];
        containerView.layer.borderWidth = 1;
        
        UILabel *date = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 272, 18)];
        date.tag = 66;
        date.font = [UIFont boldSystemFontOfSize:12.0];
        date.textColor = [EBStyle blackTextColor];
        date.textAlignment = NSTextAlignmentLeft;
//        date.text = timeShow;
        [containerView addSubview:date];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, 272, 26)];
        title.tag = 77;
        title.font = [UIFont systemFontOfSize:16.0];
        title.textColor = [EBStyle blackTextColor];
        title.textAlignment = NSTextAlignmentLeft;
        [containerView addSubview:title];
        
        CGFloat uiHeight = 54;
        if ((appointment.latitude != 0) && (appointment.longitude != 0))
        {
            
            UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(10, uiHeight, 272, 18)];
            address.tag = 55;
            address.font = [UIFont systemFontOfSize:12.0];
            address.textColor = [EBStyle grayTextColor];
            address.textAlignment = NSTextAlignmentLeft;
//            address.text = appointment.addressDetail;
            [containerView addSubview:address];
            uiHeight = uiHeight + 18;
            
            //!地图
            UIView *mapContainer = [self buildMapView:uiHeight];
            mapContainer.tag = 44;
//            MKMapView *mapView = (MKMapView *)[mapContainer viewWithTag:99];
//            [self updateMapView:mapView appointment:appointment];
            [containerView addSubview:mapContainer];
            UIButton *clickBtn = [[UIButton alloc] init];
            clickBtn.tag = 100 + [indexPath row];
            [containerView addSubview:clickBtn];
            [clickBtn addTarget:self action:@selector(mapDetail:) forControlEvents:UIControlEventTouchUpInside];
            clickBtn.frame = CGRectMake(mapContainer.frame.origin.x, mapContainer.frame.origin.y, mapContainer.frame.size.width, mapContainer.frame.size.height);
            
            uiHeight = uiHeight + 72;
        }
        for (int i = 0; i < appointment.houses.count; i++)
        {
//            EBHouse * house = appointment.houses[i];
            HouseItemView *itemView = [[HouseItemView alloc] initWithFrame:CGRectMake(-2, uiHeight, 272, 84)];
            //            itemView.backgroundColor = [UIColor grayColor];
//            itemView.house = house;
            [itemView changeSize];
            itemView.tag = 10001 + i;
            [containerView addSubview:itemView];
            uiHeight = uiHeight + 84;
        }
        containerView.tag = 99;
        [cell.contentView addSubview:containerView];
    }
    UIView *containerView = [cell.contentView viewWithTag:99];
    if (containerView)
    {
        UILabel *dateLabel = (UILabel *)[containerView viewWithTag:66];
        if (dateLabel)
        {
            dateLabel.text = [self formatTimeShow:appointment.timestamp];
        }
        UILabel *titleLabel = (UILabel *)[containerView viewWithTag:77];
        if (titleLabel)
        {
            titleLabel.text = appointment.addressTitle;
        }
        if ((appointment.latitude != 0) && (appointment.longitude != 0))
        {
            
            UILabel *address = (UILabel *)[containerView viewWithTag:55];
            if (address)
            {
                address.text = appointment.addressDetail;
            }
            
            UIView *mapContainer = [containerView viewWithTag:44];
            if (mapContainer)
            {
                MKMapView *mapView = (MKMapView *)[mapContainer viewWithTag:99];
                [self updateMapView:mapView appointment:appointment];
            }
        }
        for (int i = 0; i < appointment.houses.count; i++)
        {
            EBHouse * house = appointment.houses[i];
            HouseItemView *itemView = (HouseItemView *)[containerView viewWithTag:10001 + i];
            if (itemView)
            {
                itemView.house = house;
            }
        }
    }
    return cell;
}

- (void)mapDetail:(UIButton *)btn
{
    NSInteger row = btn.tag - 100;
    EBAppointment *appointment = [_appointArray objectAtIndex:row];
    NSMutableDictionary *poiInfo = [[NSMutableDictionary alloc] init];
    [poiInfo setObject:appointment.addressTitle forKey:@"name"];
    [poiInfo setObject:[NSString stringWithFormat:@"%f",appointment.latitude] forKey:@"lat"];
    [poiInfo setObject:[NSString stringWithFormat:@"%f",appointment.longitude] forKey:@"lon"];
    [poiInfo setObject:appointment.addressDetail forKey:@"address"];
    [[EBController sharedInstance] showLocationInMap:poiInfo showKeywordLocation:NO];
}

#pragma mark - UITableViewDelegate>

- (void)updateMapView:(MKMapView *)mapView appointment:(EBAppointment *)appointment
{
    if (mapView == nil)
    {
        return;
    }
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(appointment.latitude, appointment.longitude);
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;
    
    mapView.region = region;
}

- (UIView *)buildMapView:(CGFloat) height
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(12, height, 270, 72)];
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:container.bounds];
    UIImageView *centerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_center_icon"]];
    centerIcon.center = mapView.center;
    
    [container addSubview:mapView];
    [container addSubview:centerIcon];
    mapView.userInteractionEnabled = NO;
    mapView.tag = 99;
    
    return container;
}

- (NSString *)formatTimeShow:(NSInteger)time
{
    NSString *timeShow = @"";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSArray *array = [confromTimespStr componentsSeparatedByString:@" "];
    
    if([array count] > 1)
    {
        NSArray *dateArray = [array[0] componentsSeparatedByString:@"-"];
        NSArray *timeArray = [array[1] componentsSeparatedByString:@":"];
        if(([dateArray count] > 2) && ([timeArray count] > 2))
        {
            int hour = [timeArray[0] intValue];
            if( hour == 0)
            {
                timeShow = [NSString stringWithFormat:@"%@年%@月%@日 上午%d:%@",dateArray[0],dateArray[1],dateArray[2],12,timeArray[1]];
            }
            else if (hour == 12)
            {
                timeShow = [NSString stringWithFormat:@"%@年%@月%@日 下午%d:%@",dateArray[0],dateArray[1],dateArray[2],12,timeArray[1]];
            }
            else if( (hour < 12) && (hour > 0) )
            {
                timeShow = [NSString stringWithFormat:@"%@年%@月%@日 上午%d:%@",dateArray[0],dateArray[1],dateArray[2],hour,timeArray[1]];
            }
            else
            {
                hour = hour - 12 ;
                timeShow = [NSString stringWithFormat:@"%@年%@月%@日 下午%d:%@",dateArray[0],dateArray[1],dateArray[2],hour,timeArray[1]];
            }
        }
        else
            timeShow = confromTimespStr;
    }
    else
    {
        timeShow = confromTimespStr;
    }
    return timeShow;
}

@end
