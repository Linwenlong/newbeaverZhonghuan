//
//  ClientInviteNextViewController.m
//  beaver
//
//  Created by wangyuliang on 14-5-22.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "ClientInviteNextViewController.h"
#import "EBViewFactory.h"
#import "EBAppointment.h"
#import "EBTimeFormatter.h"
#import "UIActionSheet+Blocks.h"
#import "InviteSendViewController.h"
#import <MapKit/MapKit.h>

/**
 *  邀请客源看房后的下一步，时间地点地图地址
 */
@interface ClientInviteNextViewController ()<UITableViewDataSource , UITableViewDelegate , UITextFieldDelegate>
{
    NSArray *_sectionIndexTitles;
    UITableView *_tableView;
    UIView *_dateView;//日期view
    UIBarButtonItem *_nextStep;
    UITextField *_locationText;//定位view
    UITextField *_addressText;//地址view
    BOOL _addressMoveTag;
}

@end
#define CLIENT_INVITE_VIEW_TAG 300

@implementation ClientInviteNextViewController
- (void)loadView
{
    [super loadView];
//    "invite_title" = "邀请看房";
    self.title = NSLocalizedString(@"invite_title", nil);
    CGRect frame = [EBStyle fullScrTableFrame:NO];
    _tableView = [[UITableView alloc] initWithFrame:frame];
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;

    UIView *footerLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 1.0)];
    UIView *line = [EBViewFactory tableViewSeparatorWithRowHeight:1.0 leftMargin:15.0];
    [footerLine addSubview:line];
    _tableView.tableFooterView = footerLine;

    [self.view addSubview:_tableView];

    _nextStep = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"nextstep", nil)
                                              target:self action:@selector(nextStep)];

    [self setupDatePickerView];
    
    _locationText = [[UITextField alloc] init];
    _locationText.clearsOnBeginEditing = NO;
    _locationText.delegate = self;
    _locationText.font = [UIFont systemFontOfSize:14.0];
    _locationText.textColor = [EBStyle blackTextColor];
    _locationText.borderStyle = UITextBorderStyleNone;
    _locationText.autocorrectionType = UITextAutocorrectionTypeNo;
    _locationText.autocapitalizationType  = UITextAutocapitalizationTypeNone;
    _locationText.returnKeyType = UIReturnKeyDefault;
    _locationText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _locationText.keyboardType = UIKeyboardTypeDefault;
    
    _addressText = [[UITextField alloc] init];
    _addressText.clearsOnBeginEditing = NO;
    _addressText.delegate = self;
    _addressText.font = [UIFont systemFontOfSize:14.0];
    _addressText.textColor = [EBStyle blackTextColor];
    _addressText.borderStyle = UITextBorderStyleNone;
    _addressText.autocorrectionType = UITextAutocorrectionTypeNo;
    _addressText.autocapitalizationType  = UITextAutocapitalizationTypeNone;
    _addressText.returnKeyType = UIReturnKeyDefault;
    _addressText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _addressText.keyboardType = UIKeyboardTypeDefault;
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

- (void)setupDatePickerView
{
    _dateView = [[UIView alloc] initWithFrame:CGRectMake(0, 640, [EBStyle screenWidth], 300)];
    _dateView.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 40)];
    label.backgroundColor = [UIColor colorWithRed:65/255.0 green:65/255.0 blue:70/255.0 alpha:1];
    [_dateView addSubview:label];

    UIButton *cancelBt = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 60, 40)];
    [cancelBt setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    [_dateView addSubview:cancelBt];
    [cancelBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBt.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [cancelBt addTarget:self action:@selector(dismissDatePicker:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *certainBt = [[UIButton alloc] initWithFrame:CGRectMake([EBStyle screenWidth]-69-10, 0, 60, 40)];
    [certainBt setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [certainBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    certainBt.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [certainBt addTarget:self action:@selector(confirmDatetime:) forControlEvents:UIControlEventTouchUpInside];
    [_dateView addSubview:certainBt];

    UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, [EBStyle screenWidth], 260)];
    pickerView.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    pickerView.datePickerMode = UIDatePickerModeDateAndTime ;
    pickerView.tag = 301;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_appointment.timestamp];
    [pickerView setDate:date];
    [_dateView addSubview:pickerView];
    [self.view addSubview:_dateView];
}

//下一步，进入发送邀请控制器
-(void) nextStep
{
   InviteSendViewController *sendViewController = [[InviteSendViewController alloc] init];
   sendViewController.appointment = _appointment;
   sendViewController.client = _appointment.client;

   [self.navigationController pushViewController:sendViewController animated:YES];
}

-(void) dismissDatePicker:(UIButton *)btn
{
    [UIView animateWithDuration:0.5 animations:^
    {
        CGRect frame = [EBStyle fullScrTableFrame:NO];
        _dateView.frame = CGRectMake(0, frame.size.height, [EBStyle screenWidth], 260);
    }];
}

-(void)confirmDatetime:(UIButton *)btn
{
    [UIView animateWithDuration:0.5 animations:^
     {
         CGRect frame = [EBStyle fullScrTableFrame:NO];
         _dateView.frame = CGRectMake(0, frame.size.height, [EBStyle screenWidth], 260);
     }];
    UIDatePicker *datePicker = (UIDatePicker *)[_dateView viewWithTag:301];
    _appointment.timestamp = (NSInteger)datePicker.date.timeIntervalSince1970;

    [_tableView reloadData];
}


#pragma -mark UITableViewDataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _sectionIndexTitles;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierEmpty = @"InviteCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifierEmpty];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierEmpty];
        cell.textLabel.textColor = [EBStyle blackTextColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.backgroundColor = [UIColor whiteColor];
        if([indexPath row] == 0)
        {
            CGRect frame = cell.bounds;
            UIView *view = [[UIView alloc] initWithFrame:frame];
            view.tag = 300;
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10 + 10, 0, 80, frame.size.height)];
            labelTitle.text = NSLocalizedString(@"time_invitepage", nil);
            labelTitle.font = [UIFont systemFontOfSize:14.0];;
            labelTitle.textColor = [EBStyle blackTextColor];
            labelTitle.tag = CLIENT_INVITE_VIEW_TAG + 1;
            UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, frame.size.width - 90, frame.size.height)];
            labelText.font = [UIFont systemFontOfSize:14.0];
            labelText.textColor = [EBStyle blueTextColor];
            labelText.tag = CLIENT_INVITE_VIEW_TAG + 2;
            [view addSubview:labelTitle];
            [view addSubview:labelText];
            [cell addSubview:view];
        }
        else if ([indexPath row] == 1)
        {
            CGRect frame = cell.bounds;
            UIView *view = [[UIView alloc] initWithFrame:frame];
            view.tag = 300;
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10 + 10, 0, 80, frame.size.height)];
            labelTitle.text = NSLocalizedString(@"location_invitepage", nil);
            labelTitle.font = [UIFont systemFontOfSize:14.0];;
            labelTitle.textColor = [EBStyle blackTextColor];
            labelTitle.tag = CLIENT_INVITE_VIEW_TAG + 1;
            
            _locationText.frame = CGRectMake(90, 0, 210, frame.size.height);
//            _locationText.placeholder = _appointment.addressTitle;
            
            UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, frame.size.width - 90, frame.size.height)];
            labelText.font = [UIFont systemFontOfSize:14.0];
            labelText.textColor = [EBStyle blackTextColor];
            
            _locationText.tag = CLIENT_INVITE_VIEW_TAG + 3;
            [view addSubview:labelTitle];
            [view addSubview:_locationText];
            [cell addSubview:view];
        }
        else if ([indexPath row] == 2)
        {
            CGRect frame = cell.bounds;
            UIView *view = [[UIView alloc] initWithFrame:frame];
            view.tag = 300;
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10 + 10, 0, 80, frame.size.height)];
            labelTitle.text = NSLocalizedString(@"map_invitepage", nil);
            labelTitle.font = [UIFont systemFontOfSize:14.0];;
            labelTitle.textColor = [EBStyle blackTextColor];
            labelTitle.tag = CLIENT_INVITE_VIEW_TAG + 1;
            
            UIButton *btn = [EBViewFactory blueButtonWithFrame:CGRectMake(90, 9, 160, 26) title:NSLocalizedString(@"geographical_position", nil)
                                                        target:self action:@selector(selectLocation:)];
            
            UIImage *bgN = [[UIImage imageNamed:@"btn_blue_r_n"] stretchableImageWithLeftCapWidth:15 topCapHeight:2];
            UIImage *bgP = [[UIImage imageNamed:@"btn_blue_r_p"] stretchableImageWithLeftCapWidth:15 topCapHeight:2];
            [btn setBackgroundImage:bgN forState:UIControlStateNormal];
            [btn setBackgroundImage:bgP forState:UIControlStateHighlighted];
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [btn setTitleColor:[EBStyle darkBlueTextColor] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"btn_icon_location"] forState:UIControlStateNormal];
            btn.tag = 77;
            
            [view addSubview:labelTitle];
            [view addSubview:btn];
            [cell addSubview:view];
        }
        else if ([indexPath row] == 3)
        {
            CGRect frame = cell.bounds;
            UIView *view = [[UIView alloc] initWithFrame:frame];
            view.tag = 300;
            UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(10 + 10, 0, 80, frame.size.height)];
            labelTitle.text = NSLocalizedString(@"address_invitepage", nil);
            labelTitle.font = [UIFont systemFontOfSize:14.0];
            labelTitle.textColor = [EBStyle blackTextColor];
            labelTitle.tag = CLIENT_INVITE_VIEW_TAG + 1;
            
            _addressText.frame = CGRectMake(90, 0, 210, frame.size.height);
            //            _addressText.placeholder = _appointment.addressDetail;
            
            UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 210, frame.size.height)];
            labelText.font = [UIFont systemFontOfSize:14.0];
            labelText.textColor = [EBStyle blackTextColor];
            _addressText.tag = CLIENT_INVITE_VIEW_TAG + 4;
            [view addSubview:labelTitle];
            [view addSubview:_addressText];
            [cell addSubview:view];
        }

        if (indexPath.row < 3)
        {
           [cell addSubview:[EBViewFactory defaultTableViewSeparator]];
        }
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (indexPath.row != 2)
    {
        if(indexPath.row == 0)
        {
            UILabel *valueLabel = (UILabel *)[[cell viewWithTag:300] viewWithTag:CLIENT_INVITE_VIEW_TAG + 2];
            valueLabel.text = [EBTimeFormatter formatAppointmentTime:_appointment.timestamp];
        }
        else if (indexPath.row == 1)
        {
            UITextField *textField = (UITextField *)[[cell viewWithTag:300] viewWithTag:CLIENT_INVITE_VIEW_TAG + 3];
            textField.text = _appointment.addressTitle;
        }
        else if (indexPath.row == 3)
        {
            UITextField *textField = (UITextField *)[[cell viewWithTag:300] viewWithTag:CLIENT_INVITE_VIEW_TAG + 4];
            textField.text = _appointment.addressDetail;
        }
    }
    else if (indexPath.row == 2)
    {
        UIButton *btn = (UIButton *)[[cell viewWithTag:300] viewWithTag:77];
        UIView *line = (UIView *)[cell viewWithTag:-87];
        if (_appointment.latitude > 0)
        {
            btn.hidden = YES;
            line.frame = CGRectMake(line.frame.origin.x, 140, line.frame.size.width, line.frame.size.height);

            UIView *mapContainer = [[cell viewWithTag:300] viewWithTag:88];
            mapContainer.hidden = NO;
            if (!mapContainer)
            {
                mapContainer = [self buildMapView];
                mapContainer.tag = 88;
                [[cell viewWithTag:300] addSubview:mapContainer];
            }

            MKMapView *mapView = (MKMapView *)[mapContainer viewWithTag:99];
            [self updateMapView:mapView];
        }
        else
        {
           btn.hidden = NO;
            line.frame = CGRectMake(line.frame.origin.x, 44, line.frame.size.width, line.frame.size.height);
           [[cell viewWithTag:300] viewWithTag:88].hidden = YES;
        }
    }


    
    return cell;
}

- (void)updateMapView:(MKMapView *)mapView
{
    MKCoordinateRegion region;
    region.center = CLLocationCoordinate2DMake(_appointment.latitude, _appointment.longitude);
    region.span.latitudeDelta = 0.005;
    region.span.longitudeDelta = 0.005;

    mapView.region = region;
}

- (UIView *)buildMapView
{
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(90, 15, 210, 110)];

    MKMapView *mapView = [[MKMapView alloc] initWithFrame:container.bounds];
    UIImageView *centerIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_center_icon"]];
    centerIcon.center = mapView.center;

    [container addSubview:mapView];
    [container addSubview:centerIcon];
    mapView.userInteractionEnabled = NO;
    mapView.tag = 99;

    return container;
}

- (void)mapClicked
{
    [[[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"cancel", nil)]
                    destructiveButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"delete", nil) action:^
                    {
                        _appointment.addressDetail = nil;
                        _appointment.latitude = 0;
                        _appointment.longitude = 0;
                        [_tableView reloadData];
                    }]
                         otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"modify", nil) action:^
                         {
                             [self selectLocation:nil];
                         }], nil] showInView:self.view];
}

- (void)selectLocation:(UIButton *)btn
{
    [[EBController sharedInstance] pickLocationWithBlock:^(NSDictionary *poiInfo)
    {
        _appointment.addressDetail = [poiInfo[@"address"] copy];
        _appointment.latitude = [poiInfo[@"lat"] floatValue];
        _appointment.longitude = [poiInfo[@"lon"] floatValue];

        [_tableView reloadData];
    } pickBySend:NO];
}

#pragma -mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2)
    {
        if (_appointment.latitude > 0)
        {
            return 140;
        }
        else
        {
            return 44;
        }
    }
    else
    {
        return  44.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_locationText resignFirstResponder];
    [_addressText resignFirstResponder];
    if([indexPath row] == 0)
    {
        [UIView animateWithDuration:0.5 animations:^
        {
            CGRect frame = [EBStyle fullScrTableFrame:NO];
            _dateView.frame = CGRectMake(0, frame.size.height - 250, [EBStyle screenWidth], 260);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^
         {
             CGRect frame = [EBStyle fullScrTableFrame:NO];
             _dateView.frame = CGRectMake(0, frame.size.height, [EBStyle screenWidth], 260);
         }];
    }
    if ([indexPath row] == 2 && _appointment.latitude > 0)
    {
        
         [self mapClicked];
    }
    if(_addressMoveTag)
    {
        _addressMoveTag = NO;
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frame = [EBStyle fullScrTableFrame:NO];
            _tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
        }];
    }
}

#pragma -mark UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.5 animations:^
     {
         CGRect frame = [EBStyle fullScrTableFrame:NO];
         _dateView.frame = CGRectMake(0, frame.size.height, [EBStyle screenWidth], 260);
     }];
    if(textField.tag == CLIENT_INVITE_VIEW_TAG + 4)
    {
        if(_appointment.longitude > 0)
        {
            _addressMoveTag = true;
            [UIView animateWithDuration:0.5 animations:^{
                CGRect frame = [EBStyle fullScrTableFrame:NO];
                _tableView.frame = CGRectMake(frame.origin.x, frame.origin.y - 90, frame.size.width, frame.size.height);
            }];
        }
    }
    return YES;
}

@end
