//
//  PublishOrderPortViewController.m
//  beaver
//
//  Created by wangyuliang on 14-9-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "PublishOrderPortViewController.h"
#import "EBViewFactory.h"
#import "EBTimeFormatter.h"
#import "EBHttpClient.h"
#import "EBAlert.h"
#import "PublishHouseSuccessViewController.h"
#import "EBNavigationController.h"
#import "EBHousePhoto.h"
#import "EBHousePhotoUploader.h"
#import "PublishPortAddViewController.h"
#import "UIImage+Alpha.h"
#import "EBController.h"
#import "EBPublishPhotoUploader.h"

@interface PublishOrderPortViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
    UISwitch *_switchView;
    UIView *_dateView;
    UILabel *_placeLabel;
    UILabel *_setTimeLabel;
    UIView *_shadeView;
    BOOL _switchStatus;
    
    NSMutableArray *_portArray;
    NSInteger _publishTime;
    
    BOOL _isRepublish;
    
    NSMutableSet *_selectedSet;
}

@end

@implementation PublishOrderPortViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self initVar];
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.tableHeaderView = [self buildHeadView];
    if (!_isRepublish) {
        _tableView.tableFooterView = [self buildFootView];
    }
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.allowsMultipleSelectionDuringEditing = YES;
    _tableView.allowsSelectionDuringEditing = YES;
    [_tableView setEditing:YES animated:NO];
    
    _shadeView = [[UIView alloc] initWithFrame:self.view.frame];
    _shadeView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *backTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateResign:)];
    [_shadeView addGestureRecognizer:backTapGes];
    
    [self.view addSubview:_tableView];
    if (!_isRepublish) {
        [self getPublishPort];
    }
    [self setupDatePickerView];
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"publish_select_port", nil);
    [self addRightNavigationBtnWithTitle:NSLocalizedString(@"commit", nil) target:self action:@selector(submit)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_isRepublish) {
        [self getPublishPort];
    }
    if (_isRepublish) {
        self.navigationItem.title = @"修改发布时间";
    } else {
        self.navigationItem.title = NSLocalizedString(@"publish_select_port", nil);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
- (void)initVar
{
    _switchStatus = NO;
    _publishTime = 0;
    
    _isRepublish = _params[@"publish_id"] ? YES : NO;
}

- (UIView*)buildFootView
{
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(6, 12.5, 140, 28)];
    UIImage *addImage = [UIImage imageNamed:@"btn_add"];
    [btn setImage:addImage forState:UIControlStateNormal];
    [btn setImage:[addImage imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
    [btn setTitle:[NSString stringWithFormat:@"  %@", NSLocalizedString(@"publish_port_add_title", nil)] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [btn setTitleColor:[EBStyle darkBlueTextColor] forState:UIControlStateNormal];
    [btn setTitleColor:[[EBStyle darkBlueTextColor] colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addPort:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 40)];
    [view addSubview:btn];
    return view;
}

- (UIView*)buildHeadView
{
    UIView *view;
    if (_switchStatus)
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 112)];
    }
    else
    {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 65)];
    }
    CGFloat heightSectionOne = 46;
    CGFloat heightSectionTwo = 47;
    
    [view addSubview:[self createLabel:CGRectMake(14, 0, 200, 46) text:NSLocalizedString(@"publish_order_time", nil) font:[UIFont systemFontOfSize:16.0] textColor:[EBStyle blackTextColor]]];
    
    _switchView = [[UISwitch alloc] initWithFrame:CGRectMake(258, 7, 50, 32)];
    [_switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_switchView setOn:_switchStatus];
    [view addSubview:_switchView];
    
    [view addSubview:[self addLine:heightSectionOne - 0.5 left:0 right:0]];
    
    if (_switchStatus)
    {
        _placeLabel = [self createLabel:CGRectMake(14, heightSectionOne, 292, 47) text:NSLocalizedString(@"publish_order_set_time", nil) font:[UIFont systemFontOfSize:16.0] textColor:[EBStyle grayTextColor]];
        [view addSubview:_placeLabel];
        
        _setTimeLabel = [self createLabel:CGRectMake(14, heightSectionOne, 292, 47) text:nil font:[UIFont systemFontOfSize:16.0] textColor:[EBStyle darkBlueTextColor]];
        _setTimeLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *setTimeTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setTime:)];
        setTimeTapGes.numberOfTapsRequired = 1;
        [_setTimeLabel addGestureRecognizer:setTimeTapGes];
        [view addSubview:_setTimeLabel];
    }
    if (!_isRepublish)
    {
        UIView *intervalView;
        if (_switchStatus)
        {
            intervalView = [[UIView alloc] initWithFrame:CGRectMake(0, heightSectionOne + heightSectionTwo, [EBStyle screenWidth], 19)];
        }
        else
        {
            intervalView = [[UIView alloc] initWithFrame:CGRectMake(0, heightSectionOne, [EBStyle screenWidth], 19)];
        }
        intervalView.backgroundColor = [UIColor colorWithRed:239 / 255.f green:242 / 255.f blue:247 / 255.f alpha:1.0];
        [view addSubview:intervalView];
    }
    return view;
}

- (UIView *)addLine:(CGFloat) height left:(CGFloat)left right:(CGFloat)right
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(left, height, [EBStyle screenWidth] - left - right, 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    return line;
}

- (UILabel*)createLabel:(CGRect)frame text:(NSString*)text font:(UIFont*)font textColor:(UIColor*)color
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentLeft;
    label.font = font;
    label.textColor = color;
    label.text = text;
    return label;
}

- (void)setViewForCell:(UITableViewCell*)cell title:(NSString*)title text:(NSString*)text
{
    if (cell)
    {
        if (!title || [title isKindOfClass:NSNull.class]) {
            title = @"";
        }
        if (!text || [text isKindOfClass:NSNull.class]) {
            text = @"";
        }
        
        CGFloat gap = 7;
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        CGSize titleSize = [EBViewFactory textSize:title font:[UIFont systemFontOfSize:16.0] bounding:CGSizeMake(200, 46)];
//        CGSize textSize = [EBViewFactory textSize:text font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(120, 46)];
        UILabel *titleLabel = [self createLabel:CGRectMake(5, 0, titleSize.width, 46) text:title font:[UIFont systemFontOfSize:16.0] textColor:[EBStyle blackTextColor]];
        UILabel *textLabel = [self createLabel:CGRectMake(titleLabel.frame.origin.x + titleSize.width + gap, 0, cell.contentView.frame.size.width - titleSize.width - gap - 5.0 - 40, 46) text:text font:[UIFont systemFontOfSize:14.0] textColor:[EBStyle grayTextColor]];
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:textLabel];
    }
}

- (void)setupDatePickerView
{
    _dateView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height + 100, [EBStyle screenWidth], 300)];
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
    
    UIButton *certainBt = [[UIButton alloc] initWithFrame:CGRectMake(250, 0, 60, 40)];
    [certainBt setTitle:NSLocalizedString(@"confirm", nil) forState:UIControlStateNormal];
    [certainBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    certainBt.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [certainBt addTarget:self action:@selector(confirmDatetime:) forControlEvents:UIControlEventTouchUpInside];
    [_dateView addSubview:certainBt];
    
    UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, [EBStyle screenWidth], 260)];
    pickerView.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    pickerView.datePickerMode = UIDatePickerModeDateAndTime ;
    pickerView.tag = 301;
    NSInteger time = (NSInteger)NSDate.date.timeIntervalSince1970 + 90000 - ((NSInteger)NSDate.date.timeIntervalSince1970) % 3600;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    [pickerView setDate:date];
    [_dateView addSubview:pickerView];
    [self.view addSubview:_dateView];
}

- (void)getPublishPort
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [[EBHttpClient sharedInstance] gatherPublishRequest:parameters portAuthList:^(BOOL sucess, id result)
    {
        if (sucess) {
            if (_portArray == nil)
            {
                _portArray = [NSMutableArray new];
            }
            [_portArray removeAllObjects];
            [_portArray addObjectsFromArray:result[@"data"]];
            if (_selectedSet == nil)
            {
                _selectedSet = [[NSMutableSet alloc] init];
            }
            [_selectedSet removeAllObjects];
            if (_portArray.count > 0)
            {
                for (NSDictionary *port in _portArray)
                {
                    [_selectedSet addObject:port[@"id"]];
                }
            }
            [_tableView reloadData];
        }
    }];
}

- (void)finishPublish:(NSString *)publishHouseId
{
    PublishHouseSuccessViewController *controller = [PublishHouseSuccessViewController new];
    EBNavigationController *navi = [[EBNavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navi animated:YES completion:^{
        NSMutableArray *controllerArr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [controllerArr removeLastObject];
        [controllerArr removeLastObject];
        [self.navigationController setViewControllers:controllerArr];
    }];
    
    NSMutableArray *localPhotos = [NSMutableArray new];
    for (NSString *url in _photos) {
        if ([url hasPrefix:@"assets"]) {
            EBHousePhoto *photo = [[EBHousePhoto alloc] init];
            photo.localUrl = [NSURL URLWithString:url];
            photo.houseId = publishHouseId;
            photo.status = EPhotoAddStatusWaiting;
            [localPhotos addObject:photo];
        }
    }
    if (localPhotos.count > 0) {
        [[EBPublishPhotoUploader sharedInstance] addPublishPhotos:localPhotos];
    }
}

#pragma mark - action
- (void)dateResign:(UITapGestureRecognizer*)sender
{
    [_shadeView removeFromSuperview];
    [UIView animateWithDuration:0.5 animations:^
     {
         CGRect frame = [EBStyle fullScrTableFrame:NO];
         _dateView.frame = CGRectMake(0, frame.size.height, [EBStyle screenWidth], 260);
     }];
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
    _publishTime = (NSInteger)datePicker.date.timeIntervalSince1970;
    _setTimeLabel.text = [EBTimeFormatter formatAppointmentTime:_publishTime];
    _placeLabel.hidden = YES;
}

- (void)switchValueChanged:(id)sender
{
    UISwitch *switchBtn = sender;
    _switchStatus = switchBtn.isOn;
    _tableView.tableHeaderView = [self buildHeadView];
//    [UIView animateWithDuration:0.5 animations:^{
//        _tableView.tableHeaderView = [self buildHeadView];
//    }];
}

- (void)setTime:(UITapGestureRecognizer*)sender
{
    [UIView animateWithDuration:0.5 animations:^
     {
         CGRect frame = [EBStyle fullScrTableFrame:NO];
         _dateView.frame = CGRectMake(0, frame.size.height - 250, [EBStyle screenWidth], 260);
         _shadeView.frame = CGRectMake(0, 0, [EBStyle screenWidth], frame.size.height - 250);
         [self.view addSubview:_shadeView];
     }];
}

- (void)addPort:(UITapGestureRecognizer*)sender
{
    PublishPortAddViewController *viewController = [[PublishPortAddViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)submit
{
    if (_switchStatus && (!_setTimeLabel.text || [_setTimeLabel.text isEqualToString:@""])) {
        [EBAlert alertError:@"请设置预约发布时间"];
        return;
    }
    
    if (!_isRepublish) {
        if (!_portArray || _portArray.count == 0) {
            [EBAlert alertError:@"请添加端口"];
            return;
        }
        
        NSArray *selectedRows = [_tableView indexPathsForSelectedRows];
        if (selectedRows.count == 0) {
            [EBAlert alertError:@"请选择端口"];
            return;
        }
    }
    
    NSString *photoUrls = @"";
    NSUInteger localPhotoCount = 0;
    for (NSString *url in _photos) {
        if (![url hasPrefix:@"assets"]) {
            photoUrls = [photoUrls stringByAppendingString:[NSString stringWithFormat:@"%@;", url]];
        } else {
            localPhotoCount++;
        }
    }
    if (photoUrls.length > 0) {
        photoUrls = [photoUrls substringToIndex:photoUrls.length-1];
    }
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = NSLocalizedString(@"appointment_time_format", nil);
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    NSUInteger orderTime = (NSUInteger)[[df dateFromString:_setTimeLabel.text] timeIntervalSince1970];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:_params];
    parameters[@"photo_urls"] = photoUrls;
    parameters[@"upload_count"] = @(localPhotoCount);
    parameters[@"order_time"] = _switchStatus ? @(orderTime) : @"";
    
    __weak PublishOrderPortViewController *weakSelf = self;
    [EBAlert showLoading:nil];
    if (_isRepublish) {
        [[EBHttpClient sharedInstance] gatherPublishRequest:parameters republishHouse:^(BOOL success, id result) {
            [EBAlert hideLoading];
            if (success) {
                [weakSelf finishPublish:[result[@"id"] stringValue]];
            }
        }];
    } else {
        NSArray *selectedRows = [_tableView indexPathsForSelectedRows];
        NSString *authIds = @"";
        for (NSIndexPath *path in selectedRows) {
            authIds = [authIds stringByAppendingString:[NSString stringWithFormat:@"%@;", _portArray[path.row][@"id"]]];
        }
        authIds = [authIds substringToIndex:authIds.length-1];
        parameters[@"auth_ids"] = authIds;
        [[EBHttpClient sharedInstance] gatherPublishRequest:parameters publishHouse:^(BOOL success, id result) {
            [EBAlert hideLoading];
            if (success) {
                [weakSelf finishPublish:[result[@"id"] stringValue]];
            }
        }];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedSet addObject:_portArray[indexPath.row][@"id"]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedSet removeObject:_portArray[indexPath.row][@"id"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isRepublish)
    {
        return 0;
    }
    return _portArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cellPublishOrder";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0f width:277.0f leftMargin:43.0f]];
        UIView *selectedView = [[UIView alloc] init];
        [selectedView addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0f width:277.0f leftMargin:43.0f]];
        cell.selectedBackgroundView = selectedView;
    }
    [self setViewForCell:cell title:_portArray[indexPath.row][@"port_name"] text:_portArray[indexPath.row][@"account"]];
//    cell.selected = YES;
    if ([_selectedSet containsObject:_portArray[indexPath.row][@"id"]])
    {
        [tableView selectRowAtIndexPath:indexPath animated:NO
                         scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

@end
