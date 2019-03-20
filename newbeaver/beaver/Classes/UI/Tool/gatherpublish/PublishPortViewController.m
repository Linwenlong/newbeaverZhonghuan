//
//  PublishPortViewController.m
//  beaver
//
//  Created by wangyuliang on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "PublishPortViewController.h"
#import "EBHttpClient.h"
#import "EBViewFactory.h"
#import "PublishPortAddViewController.h"
#import "EBContact.h"
#import "EBContactManager.h"
#import "EBPreferences.h"
#import "EBAlert.h"
#import "EGORefreshTableHeaderView.h"
#import "UIActionSheet+Blocks.h"
#import "PublishPortLoginViewController.h"
#import "EBNavigationController.h"
#import "PortWebLoginViewController.h"

@interface PublishPortViewController () <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate>
{
    UITableView *_tableView;
    UIView *_checkView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _dataLoading;
    
    NSMutableArray *_portArray;
    NSMutableArray *_portStateArray;
    NSTimer *_resendTimer;
    NSInteger _resendCount;
    BOOL _checkTag;
    
    CGFloat _offset;
}

@end

@implementation PublishPortViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"发房端口";
    [self addRightNavigationBtnWithTitle:@"+添加" target:self action:@selector(addPort)];
    
    CGRect frame = [EBStyle fullScrTableFrame:NO];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - 54)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.height, _tableView.width, _tableView.height)];
    _refreshHeaderView.delegate = self;
    [_tableView addSubview:_refreshHeaderView];
    _checkTag = NO;
    _offset = 100;

//    [self getPublishPort];
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPublishPort];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (_resendTimer != nil)
    {
        [_resendTimer invalidate];
        _resendTimer = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPublishPort
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    _dataLoading = YES;
    [[EBHttpClient sharedInstance] gatherPublishRequest:parameters portAuthList:^(BOOL sucess, id result) {
        _dataLoading = NO;
        if (_refreshHeaderView) {
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
        }
        
        if (sucess) {
            if (![_tableView superview]) {
                [self.view addSubview:_tableView];
            }
            
            if (_portArray == nil) {
                _portArray = [NSMutableArray new];
            }
            [_portArray removeAllObjects];
            [_portArray addObjectsFromArray:result[@"data"]];
            
            if (_portArray.count == 0) {
                [self setCheckButton:NO];
            } else {
                [self setCheckButton:YES];
            }
            [_tableView reloadData];
        }
    }];
}

- (void)setCheckButton:(BOOL)show
{
    if (show) {
        CGRect frame = [EBStyle fullScrTableFrame:NO];
        if (!_checkView)
        {
            _checkView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-54.0, frame.size.width, 54.0)];
            UIButton *footBtn = [EBViewFactory blueButtonWithFrame:CGRectMake(15.0, 7, _checkView.width-30, 40.0) title:@"检查端口有效性" target:self action:@selector(checkAvailable:)];
            footBtn.tag = 500;
            [_checkView addSubview:footBtn];
            [self.view addSubview:_checkView];
        }
        else
        {
            _checkView.frame = CGRectMake(0, frame.size.height-54.0, frame.size.width, 54.0);
        }
        _tableView.frame = CGRectMake(_tableView.left, _tableView.top, _tableView.width, frame.size.height - 54);
    } else
    {
        CGRect frame = [EBStyle fullScrTableFrame:NO];
        if (_checkView)
        {
            _checkView.frame = CGRectMake(0, frame.size.height-54.0 + _offset, frame.size.width, 54.0);
            _tableView.frame = [EBStyle fullScrTableFrame:YES];
        }
        else
        {
            _checkView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-54.0 + 100, frame.size.width, 54.0)];
            UIButton *footBtn = [EBViewFactory blueButtonWithFrame:CGRectMake(15.0, 7, _checkView.width-30, 40.0) title:@"检查端口有效性" target:self action:@selector(checkAvailable:)];
            footBtn.tag = 500;
            [_checkView addSubview:footBtn];
            [self.view addSubview:_checkView];
        }
    }
}

- (void)setViewForCell:(UITableViewCell*)cell title:(NSString*)title text:(NSString*)text check:(BOOL)check finish:(BOOL)finish state:(NSInteger)state desc:(NSString*)desc
{
    if (cell)
    {
        if (!title || [title isKindOfClass:NSNull.class]) {
            title = @"";
        }
        if (!text || [text isKindOfClass:NSNull.class]) {
            text = @"";
        }
        
        CGFloat textGap = 4;
        UIView *view = [cell.contentView viewWithTag:900];
        if (!view)
        {
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 46)];
            view.tag = 900;
        }
        
        CGSize titleSize = [EBViewFactory textSize:title font:[UIFont systemFontOfSize:14.0] bounding:CGSizeMake(260, 20)];
        CGSize textSize = [EBViewFactory textSize:text font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(200, 20)];
        
        UILabel *titleLabel = (UILabel*)[view viewWithTag:901];
        if (titleLabel)
        {
            titleLabel.text = title;
        }
        else
        {
            titleLabel = [self createLabel:CGRectMake(14, (view.frame.size.height - titleSize.height - textGap - textSize.height) / 2.0, 200, titleSize.height) text:title font:[UIFont systemFontOfSize:14.0] textColor:[EBStyle blackTextColor]];
            titleLabel.tag = 901;
            [view addSubview:titleLabel];
        }
        
        UILabel *textLabel = (UILabel*)[view viewWithTag:902];
        if (textLabel)
        {
            textLabel.text = text;
        }
        else
        {
            textLabel = [self createLabel:CGRectMake(14, titleLabel.frame.origin.y + titleSize.height + textGap, 200, textSize.height) text:text font:[UIFont systemFontOfSize:12.0] textColor:[EBStyle grayTextColor]];
            textLabel.tag = 902;
            [view addSubview:textLabel];
        }
        
        UIImageView *sucImageView = (UIImageView*)[view viewWithTag:911];
        if (!sucImageView)
        {
            sucImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_tick"]];
            sucImageView.frame = CGRectOffset(sucImageView.frame, [EBStyle screenWidth] - sucImageView.frame.size.width - 14, (view.frame.size.height - sucImageView.frame.size.height) / 2.0);
            sucImageView.tag = 911;
            [view addSubview:sucImageView];
        }
        if (check)
        {
            if (finish)
            {
                if (state == 1)
                {
                    sucImageView.hidden = NO;
                }
                else
                {
                    sucImageView.hidden = YES;
                }
            }
            else
            {
                sucImageView.hidden = YES;
            }
        }
        else
        {
            sucImageView.hidden = YES;
        }
        
        UIActivityIndicatorView *activeView = (UIActivityIndicatorView*)[view viewWithTag:912];
        if (!activeView)
        {
            activeView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(sucImageView.frame.origin.x, sucImageView.frame.origin.y, sucImageView.frame.size.width, sucImageView.frame.size.height)];
            activeView.tag = 912;
            activeView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//            activeView.center = CGPointMake(sucImageView.frame.origin.x + sucImageView.frame.size.width / 2.0, sucImageView.frame.origin.y + sucImageView.frame.size.height / 2.0);
//            activeView.frame = CGRectMake(sucImageView.frame.origin.x, sucImageView.frame.origin.y, sucImageView.frame.size.width, sucImageView.frame.size.height);
            activeView.color = [UIColor grayColor];
            [activeView startAnimating];
            [view addSubview:activeView];
        }
        if (check)
        {
            if (finish)
            {
                [activeView stopAnimating];
                activeView.hidden = YES;
            }
            else
            {
                [activeView startAnimating];
                activeView.hidden = NO;
            }
        }
        else
        {
            [activeView stopAnimating];
            activeView.hidden = YES;
        }
        
        CGSize outdateSize = [EBViewFactory textSize:NSLocalizedString(@"publish_port_outdate", nil) font:[UIFont systemFontOfSize:12.0] bounding:CGSizeMake(200, 20)];
        UILabel *stateLabel = (UILabel*)[view viewWithTag:913];
        if (!stateLabel)
        {
            stateLabel = [self createLabel:CGRectMake(view.frame.size.width - 214, (view.frame.size.height - outdateSize.height) / 2.0, 200, outdateSize.height) text:NSLocalizedString(@"publish_port_outdate", nil) font:[UIFont systemFontOfSize:12.0] textColor:[EBStyle redTextColor]];
            stateLabel.tag = 913;
            stateLabel.textAlignment = NSTextAlignmentRight;
            [view addSubview:stateLabel];
        }
        if (check)
        {
            if (finish)
            {
                if (state == 1)
                {
                    stateLabel.hidden = YES;
                }
                else
                {
                    stateLabel.hidden = NO;
                    stateLabel.text = desc;
                }
            }
            else
            {
                stateLabel.hidden = YES;
            }
        }
        else
        {
            stateLabel.hidden = YES;
        }
        
//        [view addSubview:[self addLine:14 top:view.frame.size.height - 0.5 width:306]];
        [cell.contentView addSubview:[self addLine:14 top:view.frame.size.height - 0.5 width:306]];
        [cell.contentView addSubview:view];
    }
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

- (UIView *)addLine:(CGFloat)left top:(CGFloat)top width:(CGFloat)width
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(left, top, width, 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    return line;
}

- (BOOL)checkFinish:(NSArray*)array
{
    NSInteger count = array.count;
    int i = 0;
    for (; i < count; i ++)
    {
        NSNumber *number = (NSNumber*)array[i][@"finished"];
        BOOL finish = [number boolValue];
        if (!finish)
        {
            return NO;
        }
    }
    return YES;
}

#pragma mark - action
- (void)addPort
{
    PublishPortAddViewController *viewController = [[PublishPortAddViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)checkAvailable:(UIButton*)btn
{
    btn.enabled = NO;
    _checkTag = YES;
    _portStateArray = nil;
    [_tableView reloadData];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [[EBHttpClient sharedInstance] gatherPublishRequest:params portCheckAuthStatus:^(BOOL success, id result) {
        if (success)
        {
            if (_resendTimer && _resendTimer.isValid)
            {
                [_resendTimer invalidate];
            }
            _resendCount = 10;
            _resendTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(getListState:) userInfo:nil repeats:YES];
        }
    }];
}

- (void)getListState:(UITapGestureRecognizer*)sender
{
    _resendCount --;
    if (_resendCount > 0)
    {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [[EBHttpClient sharedInstance] gatherPublishRequest:params portAuthStatusList:^(BOOL success, id result) {
            if (success)
            {
                if (_portStateArray == nil)
                {
                    _portStateArray = [[NSMutableArray alloc] init];
                }
                [_portStateArray removeAllObjects];
                [_portStateArray addObjectsFromArray:result];
                if ([self checkFinish:_portStateArray])
                {
                    if (_resendTimer && _resendTimer.isValid)
                    {
                        [_resendTimer invalidate];
                        UIButton *footBtn = (UIButton*)[_checkView viewWithTag:500];
                        footBtn.enabled = YES;
                    }
                }
                [_tableView reloadData];
            }
        }];
    }
    else
    {
        if(_resendTimer && _resendTimer.isValid)
        {
            [_resendTimer invalidate];
            UIButton *footBtn = (UIButton*)[_checkView viewWithTag:500];
            footBtn.enabled = YES;
        }
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_portArray.count == 0) {
        return _tableView.height;
    }
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_portArray) {
        return 0;
    }
    if (_portArray.count == 0) {
        return 1;
    }
    return _portArray.count;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    UITableViewCell *cell = nil;
    if (_portArray.count == 0)
    {
        identifier = @"EmptyDataCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell.contentView addSubview:[self emptyView:tableView.bounds]];
        }
    } else
    {
        identifier = @"PublishPortCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        if (_checkTag)
        {
            if (_portStateArray)
            {
                NSString *idStr = _portArray[indexPath.row][@"id"];
                for (int i = 0; i < _portStateArray.count; i ++)
                {
                    if ([idStr isEqualToString:_portStateArray[i][@"id"]])
                    {
                        NSNumber *number = (NSNumber*)_portStateArray[i][@"finished"];
                        BOOL finish = [number boolValue];
                        [self setViewForCell:cell title:_portArray[indexPath.row][@"port_name"] text:_portArray[indexPath.row][@"account"] check:YES finish:finish state:[_portStateArray[i][@"state"] integerValue] desc:_portStateArray[i][@"desc"]];
                        break;
                    }
                }
            }
            else
            {
                [self setViewForCell:cell title:_portArray[indexPath.row][@"port_name"] text:_portArray[indexPath.row][@"account"] check:YES finish:NO state:0 desc:nil];
            }
        }
        else
        {
            [self setViewForCell:cell title:_portArray[indexPath.row][@"port_name"] text:_portArray[indexPath.row][@"account"] check:NO finish:YES state:-1 desc:nil];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
//        cell.textLabel.text = _portArray[indexPath.row][@"port_name"];
//        cell.detailTextLabel.text = _portArray[indexPath.row][@"account"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    
    __weak PublishPortViewController *weakSelf = self;
    NSMutableArray *buttons = [NSMutableArray new];
    [buttons addObject:[RIButtonItem itemWithLabel:@"修改登录信息" action:^{
        BOOL forward = [_portArray[indexPath.row][@"forward"] boolValue];
        if (forward) {
             NSString *url = _portArray[indexPath.row][@"url"];
            if (url && url.length > 0) {
                PortWebLoginViewController *viewCtrl = [[PortWebLoginViewController alloc] init];
                viewCtrl.request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
                viewCtrl.port = _portArray[indexPath.row];
                viewCtrl.isEdit = YES;
                EBNavigationController *navi = [[EBNavigationController alloc] initWithRootViewController:viewCtrl];
                [weakSelf presentViewController:navi animated:YES completion:^{
                    
                }];
            }
        }
        else
        {
            PublishPortLoginViewController *controller = [PublishPortLoginViewController new];
            controller.port = _portArray[indexPath.row];
            controller.isEdit = YES;
            controller.editSuccess = ^(NSDictionary *port) {
                //            [weakSelf getPublishPort];
                //            [weakSelf egoRefreshTableHeaderDidTriggerRefresh:_refreshHeaderView];
                _portArray[indexPath.row] = port;
                [_tableView reloadData];
            };
            EBNavigationController *navi = [[EBNavigationController alloc] initWithRootViewController:controller];
            [weakSelf presentViewController:navi animated:YES completion:^{
                
            }];
        }
    }]];
    [buttons addObject:[RIButtonItem itemWithLabel:@"删除端口" action:^{
        [EBAlert confirmWithTitle:nil message:@"您确认要删除这个端口么？" yes:@"确认" action:^{
            [[EBHttpClient sharedInstance] gatherPublishRequest:@{@"id": _portArray[indexPath.row][@"id"]} portDeleteAuth:^(BOOL success, id result) {
                if (success) {
                    [_portArray removeObjectAtIndex:indexPath.row];
                    [tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                    if (_portArray.count > 0)
                    {
                        [self setCheckButton:YES];
                    }
                    else
                    {
                        [self setCheckButton:NO];
                    }
                }
            }];
        }];
    }]];
    [[[UIActionSheet alloc] initWithTitle:@"请选择" buttons:buttons] showInView:self.view];
    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView reloadData];
}

- (UIView *)emptyView:(CGRect)frame
{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *labelOne = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, view.width, 35)];
    labelOne.textAlignment = NSTextAlignmentCenter;
    labelOne.textColor = [EBStyle blackTextColor];
    labelOne.font = [UIFont systemFontOfSize:14.0];
    labelOne.textColor = [EBStyle grayTextColor];
    labelOne.backgroundColor = [UIColor clearColor];
    labelOne.text = NSLocalizedString(@"empty_publish_port", nil);
    [view addSubview:labelOne];
    
    return view;
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}

#pragma mark - EGORefreshTableHeaderDelegate
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _dataLoading;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self getPublishPort];
}

@end
