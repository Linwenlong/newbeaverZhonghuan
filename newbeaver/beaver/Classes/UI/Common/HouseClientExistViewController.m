//
//  HouseClientExistViewController.m
//  beaver
//
//  Created by LiuLian on 8/13/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "HouseClientExistViewController.h"
#import "HouseDataSource.h"
#import "MTLJSONAdapter.h"
#import "EBHouse.h"
#import "EBViewFactory.h"
#import "EBClient.h"
#import "ClientDataSource.h"

@interface HouseClientExistViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *_dataObjs;
    
    UITableView *_dataTableView;
    HouseDataSource *_houseDataSource;
    ClientDataSource *_clientDataSource;
}
@end

@implementation HouseClientExistViewController

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
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.title;
    
    [self setData];
    [self setDataTableView];
    [self setHintLabel];
    [self setFooterView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setData
{
    NSArray *tmparr = self.clientFlag ? self.data[@"validate"][@"clients"] : self.data[@"validate"][@"houses"];
    if (!_dataObjs) {
        _dataObjs = [[NSMutableArray alloc] initWithCapacity:tmparr.count];
    }
    NSError *error = nil;
    for (NSDictionary *item in tmparr)
    {
        if (!self.clientFlag) {
            [_dataObjs addObject:[MTLJSONAdapter modelOfClass:EBHouse.class fromJSONDictionary:item error:&error]];
        } else {
            [_dataObjs addObject:[MTLJSONAdapter modelOfClass:EBClient.class fromJSONDictionary:item error:&error]];
        }
    }
}

- (void)setHintLabel
{
    CGFloat dx = 10;
    CGFloat dy = 10;
    NSNumber *number = (NSNumber*)self.data[@"validate"][@"can_continue"];
    BOOL canContinue = [number boolValue];
    NSString *text = self.clientFlag ? (canContinue ? NSLocalizedString(@"client_add_exist_text_hint_0", nil) : NSLocalizedString(@"client_add_exist_text_hint_1", nil)) :  (canContinue ? NSLocalizedString(@"house_add_exist_text_hint_0", nil) : NSLocalizedString(@"house_add_exist_text_hint_2", nil));
    
    UIFont *font = [UIFont systemFontOfSize:14];
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    hintLabel.numberOfLines = 0;
    hintLabel.lineBreakMode = NSLineBreakByCharWrapping;
    hintLabel.font = font;
    hintLabel.backgroundColor = [UIColor clearColor];
    hintLabel.text = text;
    hintLabel.textColor = [EBStyle redTextColor];
    CGSize actualSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(_dataTableView.width-dx*2, 1000) lineBreakMode:NSLineBreakByCharWrapping];
    hintLabel.frame = CGRectMake(dx, dy, actualSize.width, actualSize.height);
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _dataTableView.width, actualSize.height+10)];
    [headView addSubview:hintLabel];
    _dataTableView.tableHeaderView = headView;
}

- (void)setFooterView
{
    NSNumber *number = (NSNumber*)self.data[@"validate"][@"can_continue"];
    BOOL canContinue = [number boolValue];
    if (canContinue) {
        CGRect frame = [EBStyle fullScrTableFrame:NO];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height-44.0, frame.size.width, 44.0)];
        [self.view addSubview:view];
        
        [view addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(10.0, 7, (view.width-30)/2, 30.0) title:NSLocalizedString(@"cancel", nil) target:self
                                                     action:@selector(cancel:)]];
        [view addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(20+(view.width-30)/2, 7, (view.width-30)/2, 30.0) title:NSLocalizedString(@"go_on", nil) target:self
                                                     action:@selector(goon:)]];
        
        _dataTableView.frame = CGRectMake(_dataTableView.left, _dataTableView.top, _dataTableView.width, _dataTableView.height-view.height);
    }
    
}

#define HouseItemViewTag 10000
- (void)setDataTableView
{
    if (!self.clientFlag) {
        if (!_houseDataSource) {
            _houseDataSource = [HouseDataSource new];
        }
        __weak NSMutableArray *weakHouses = _dataObjs;
        _houseDataSource.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id)) {
            NSMutableArray *strongHouses = weakHouses;
            done(YES, strongHouses);
        };
        [_houseDataSource refresh:YES handler:^(BOOL success, id result) {
            
        }];
    } else {
        if (!_clientDataSource) {
            _clientDataSource = [ClientDataSource new];
        }
        __weak NSMutableArray *weakClients = _dataObjs;
        _clientDataSource.requestBlock = ^(NSDictionary *params, void(^done)(BOOL, id)) {
            NSMutableArray *strongClients = weakClients;
            done(YES, strongClients);
        };
        [_clientDataSource refresh:YES handler:^(BOOL success, id result) {
            
        }];
    }
    
    if (!_dataTableView) {
        _dataTableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
        _dataTableView.delegate = self;
        _dataTableView.dataSource = self;
        _dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_dataTableView];
    } else {
        [_dataTableView reloadData];
    }
}

#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataObjs.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.clientFlag) {
        return [_houseDataSource heightOfRow:indexPath.row];
    }
    return [_clientDataSource heightOfRow:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.clientFlag) {
        return [_houseDataSource tableView:tableView cellForRow:indexPath.row];
    }
    return [_clientDataSource tableView:tableView cellForRow:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.clientFlag) {
        [_houseDataSource tableView:tableView didSelectRow:indexPath.row];
    }
    [_clientDataSource tableView:tableView didSelectRow:indexPath.row];
}

#pragma mark - footer btn action
- (void)goon:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
    if (self.goon) {
        self.goon();
    }
}

- (void)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
