//
//  PublishPortAddViewController.m
//  beaver
//
//  Created by wangyuliang on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "PublishPortAddViewController.h"
#import "EBViewFactory.h"
#import "EBContact.h"
#import "EBContactManager.h"
#import "EBPreferences.h"
#import "EBHttpClient.h"
#import "EGORefreshTableHeaderView.h"
#import "UIImageView+WebCache.h"
#import "PublishPortLoginViewController.h"
#import "EBNavigationController.h"
#import "VoteToAddViewController.h"
#import "PortWebLoginViewController.h"

@interface PublishPortAddViewController () <UITableViewDelegate, UITableViewDataSource, EGORefreshTableHeaderDelegate>
{
    NSMutableArray *_portArr;
    
    UITableView *_tableView;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _dataLoading;
}

@end

@implementation PublishPortAddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    /**
     *  LWL 发房端口
     */
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self initVar];
    self.navigationItem.title = NSLocalizedString(@"publish_port_add_title", nil);
    
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableHeaderView = [self buildHeadView];
    [self.view addSubview:_tableView];
    
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.height, _tableView.width, _tableView.height)];
    _refreshHeaderView.delegate = self;
    [_tableView addSubview:_refreshHeaderView];
    
    [self getAvailablePublishPort];
}

- (void)dealloc
{
    if (_tableView) {
        _tableView.delegate = nil;
        _tableView.dataSource = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getAvailablePublishPort
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"type"] = @1;
    
    _dataLoading = YES;
    [[EBHttpClient sharedInstance] gatherPublishRequest:parameters portAvailableList:^(BOOL sucess, id result) {
        _dataLoading = NO;
        
        if (_refreshHeaderView) {
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
        }
        if (sucess) {
            if (![_tableView superview]) {
                [self.view addSubview:_tableView];
            }
            
            if (_portArr == nil) {
                _portArr = [NSMutableArray new];
            }
            [_portArr removeAllObjects];
            [_portArr addObjectsFromArray:result[@"data"]];
            
            [_tableView reloadData];
        }
    }];
}

#pragma mark - tool
- (UIView*)buildHeadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 64)];
    
    CGFloat gap = 3;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"publish_port_vote"]];
    CGSize textSize = [EBViewFactory textSize:NSLocalizedString(@"publish_port_add_vote_other", nil) font:[UIFont systemFontOfSize:16] bounding:CGSizeMake(300, 30)];
    CGRect btnFrame = CGRectMake(0, 0, imageView.frame.size.width + gap + textSize.width, 30);
    imageView.frame = CGRectOffset(imageView.frame, 0, 15 - imageView.frame.size.height / 2);
    UILabel *textLabel = [self createLabel:CGRectMake(imageView.frame.size.width + gap, 15 - textSize.height / 2, textSize.width, textSize.height) title:NSLocalizedString(@"publish_port_add_vote_other", nil) color:[EBStyle darkBlueTextColor]];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:btnFrame];
    [btn addSubview:imageView];
    [btn addSubview:textLabel];
    [btn addTarget:self action:@selector(voteForPort:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectOffset(btn.frame, 56, 22);
    [view addSubview:btn];
    return view;
}

- (UILabel*)createLabel:(CGRect)frame title:(NSString*)title color:(UIColor*)textColor
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font  = [UIFont systemFontOfSize:16.0];
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentLeft;
    label.text = title;
    return label;
}

#pragma mark - action
- (void)doAddPort:(NSDictionary *)port
{
    BOOL forward = [port[@"forward"] boolValue];
    
    if (forward) {
        NSString *url = port[@"url"];
        if (url && url.length > 0) {
            PortWebLoginViewController *webViewCtrl = [[PortWebLoginViewController alloc] init];
            webViewCtrl.hidesBottomBarWhenPushed =  YES;
            webViewCtrl.isEdit = NO;
            webViewCtrl.request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:url]];
            webViewCtrl.port = port;
            [self.navigationController pushViewController:webViewCtrl animated:YES];
        }
    }
    else
    {
        PublishPortLoginViewController *controller = [PublishPortLoginViewController new];
        controller.port = port;
        EBNavigationController *naviController = [[EBNavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:naviController animated:YES completion:^{
            
        }];
    }
}

- (void)voteForPort:(id)sender
{
    [EBTrack event:EVENT_CLICK_COLLECT_POST_POST_PORT_VOTE];
    VoteToAddViewController *viewController = [[VoteToAddViewController alloc] init];
    viewController.voteType = EVoteTypeAddPort;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _portArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"PublishPortCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellPublishPortAdd"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PublishPortAddViewCell *addViewCell = (PublishPortAddViewCell *)[cell.contentView viewWithTag:1000];
    if (!addViewCell) {
        addViewCell = [[PublishPortAddViewCell alloc] initWithData:CGRectMake(0, 0, _tableView.width, 45) port:_portArr[indexPath.row]];
        [cell.contentView addSubview:addViewCell];
        addViewCell.tag = 1000;
        
        __weak PublishPortAddViewController *weakSelf = self;
        addViewCell.addPort = ^(NSDictionary *port) {
            [weakSelf doAddPort:port];
        };
    } else {
        addViewCell.data = _portArr[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    
    [self doAddPort:_portArr[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
    [self getAvailablePublishPort];
}

@end

#pragma mark - PublishPortAddViewCell
@interface PublishPortAddViewCell ()
{
    UIImageView *_imageView;
    UILabel *_label;
}
@end

@implementation PublishPortAddViewCell

- (id)initWithData:(CGRect)frame port:(NSDictionary *)port
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 7, 30, 30)];
        [self addSubview:_imageView];
//        [_imageView setImageWithURL:_data[@"icon"] placeholderImage:[UIImage imageNamed:@"pl_house"]];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, self.width-60, 45.0)];
        _label.font  = [UIFont systemFontOfSize:16.0];
        _label.textColor = [EBStyle blackTextColor];
        [self addSubview:_label];
//        _label.text = _data[@"name"];
        
        [self addSubview:[self createBtn:CGRectMake(self.width-45, 10, 34, 25)]];
        
        [self addSubview:[self addLine:60 top:44.5 width:self.width-60]];
        
        [self setData:port];
    }
    
    return self;
}

- (void)setData:(NSDictionary *)data
{
    _data = data;
    [_imageView setImageWithURL:_data[@"icon"] placeholderImage:[UIImage imageNamed:@"pl_house"]];
    _label.text = _data[@"name"];
}

- (UIView *)addLine:(CGFloat)left top:(CGFloat)top width:(CGFloat)width
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(left, top, width, 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    return line;
}

- (UIButton*)createBtn:(CGRect)frame
{
    UIButton *btn = [EBViewFactory blueButtonWithFrame:frame title:nil target:self action:@selector(addPort:)];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"publish_port_add"]];
    imageView.frame = CGRectOffset(imageView.frame, (frame.size.width - imageView.frame.size.width) / 2, (frame.size.height - imageView.frame.size.height) / 2);
    [btn addSubview:imageView];
    return btn;
}

- (void)addPort:(UIButton*)btn
{
    if (self.addPort) {
        self.addPort(_data);
    }
}
@end
