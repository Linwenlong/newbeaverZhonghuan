//
//  GatherSettingViewController.m
//  beaver
//
//  Created by ChenYing on 14-8-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "GatherSettingViewController.h"
#import "EBViewFactory.h"
#import "EBHttpClient.h"
#import "EBCompatibility.h"
#import "SingleChoiceViewController.h"
#import "EBController.h"
#import "EBFilter.h"
#import "VoteToAddViewController.h"
#import "EBSingleChoiceView.h"
#import "EBAlert.h"

@interface GatherSettingViewController ()
{
    UITableView *_tableView;
    NSString *_district1;
    NSString *_district2;
    NSInteger _district1Index;
    NSInteger _district2Index;
    NSArray *_ports;
    UIBarButtonItem *_saveButton;
    NSMutableArray *_excludePorts;
}

@end

@implementation GatherSettingViewController

- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"gather_setting_title", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    _saveButton = [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil)
                                                target:self action:@selector(saveSetting:)];
    _saveButton.enabled = NO;
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    _district1 = NSLocalizedString(@"gather_setting_district_unlimited", nil);
    _district2 = NSLocalizedString(@"gather_setting_district_unlimited", nil);
    
    [self getGatherSetting];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIAction Method

- (void)saveSetting:(id)sender
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"district1"] =  _district1;
    parameters[@"district2"] =  _district2;
    if (_excludePorts)
    {
        parameters[@"exclude_ports"] = [_excludePorts componentsJoinedByString:@";"];
    }
    
    [[EBHttpClient sharedInstance] gatherPublishRequest:parameters updateSetting:^(BOOL success, id result)
    {
        if (success)
        {
            if (self.settingChanged)
            {
                self.settingChanged();
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)toggleExclude:(id)sender
{
    _saveButton.enabled = YES;
    UISwitch *uiSwitch = (UISwitch *)sender;
    NSInteger tag = uiSwitch.tag;
    NSDictionary *port = _ports[tag - 2000 - 3];
    if (port)
    {
        if (uiSwitch.on)
        {
            if ([_excludePorts containsObject:port[@"id"]])
            {
                [_excludePorts removeObject:port[@"id"]];
            }
        }
        else
        {
            if (![_excludePorts containsObject:port[@"id"]])
            {
                [_excludePorts addObject:port[@"id"]];
            }
        }
    }
    
}

- (void)back:(id)sender
{
    if (_saveButton.enabled)
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"alert_save_gather_setting", nil)
                              yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^
         {
             [self dismissViewControllerAnimated:YES completion:nil];
         }];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3 + _ports.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString *cellIdentifier= @"cellForSet";
    if (row < 2)
    {
        cellIdentifier = [NSString stringWithFormat:@"%@_%ld", cellIdentifier, row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        if (row != 1)
        {
            [cell addSubview:[EBViewFactory tableViewSeparatorWithRowHeight:44.0 leftMargin:15.0]];
        }
        cell.textLabel.textColor = [EBStyle blackTextColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.accessoryType = row == 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        if (row == 0 || row == 2)
        {
            RTLabel *label = [[RTLabel alloc] initWithFrame:CGRectMake(130.0, 14.0, row == 0 ? 160.0 : 174, 30.0)];
            label.linkAttributes = @{@"color":@"#197add"};
            label.selectedLinkAttributes = @{@"color":@"#197add44"};
            label.textAlignment = RTTextAlignmentRight;
            label.textColor = [EBStyle blackTextColor];
            label.tag = row + 1000;
            label.font = [UIFont systemFontOfSize:16.0];
            label.delegate = self;
            [cell.contentView addSubview:label];
        }
        else if (row != 1)
        {
            UISwitch *uiSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            CGRect frame = uiSwitch.frame;
            frame.origin.x = [EBStyle screenWidth] - frame.size.width - ([EBCompatibility isIOS7Higher] ? 15.0 : 10.0);
            frame.origin.y = (45.0 - frame.size.height) / 2;
            uiSwitch.frame = frame;
            [uiSwitch addTarget:self action:@selector(toggleExclude:) forControlEvents:UIControlEventValueChanged];

            [cell.contentView addSubview:uiSwitch];
        }
    }
    if (row == 0)
    {
        cell.textLabel.text = NSLocalizedString(@"gather_setting_region", nil);
        RTLabel *label = (RTLabel *)[cell.contentView viewWithTag:row + 1000];
        if (label)
        {
            label.text = [NSString stringWithFormat:NSLocalizedString(@"gather_setting_redion_format", nil),_district1, _district2];
        }
    }
    else
    {
        if (row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"gather_setting_source", nil);
            RTLabel *label = (RTLabel *)[cell.contentView viewWithTag:row + 1000];
            if (label)
            {
                label.text = NSLocalizedString(@"gather_setting_add_source", nil);
            }
        }
        else if (row != 1)
        {
            for (UIView *view in cell.contentView.subviews)
            {
                if ([view isKindOfClass:[UISwitch class]])
                {
                    UISwitch *uiSwitch = (UISwitch *)view;
                    uiSwitch.tag = row + 2000;
                    NSDictionary *port = _ports[row - 3];
                    if (port)
                    {
                        cell.textLabel.text = port[@"name"];
                        uiSwitch.on = ![port[@"exclude"] boolValue];
                    }
                    break;
                }
            }
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - RTLabelDelegate

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL *)url
{
    RTLabel *label = rtLabel;
    if (label.tag == 1000)
    {
        NSArray *choices = [[[EBFilter alloc] init] choicesByIndex:0];
        SingleChoiceViewController *controller = [[SingleChoiceViewController alloc] init];
        controller.title = NSLocalizedString(@"filter_district", nil);
        controller.singleChoiceView.rightIndex = _district2Index;
        controller.singleChoiceView.leftIndex = _district1Index;
        controller.singleChoiceView.title = NSLocalizedString(@"filter_district", nil);
        controller.singleChoiceView.choices = choices;
        controller.singleChoiceView.makeChoice = ^(NSInteger rChoice, NSInteger lChoice){
            _saveButton.enabled = YES;
            _district1Index = lChoice;
            _district2Index = rChoice;
            NSDictionary *district1 = [EBFilter rawDistrictChoices][lChoice];
            _district1 = district1[@"title"];
            _district2 = district1[@"children"][rChoice];
            [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.navigationController popViewControllerAnimated:YES];
        };
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (label.tag == 1002)
    {
        [EBTrack event:EVENT_CLICK_COLLECT_POST_COLLECT_SETTING_VOTE];
        VoteToAddViewController *viewController = [[VoteToAddViewController alloc] init];
        viewController.voteType = EVoteTypeAddSource;
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - Private Method

- (void)getGatherSetting
{
    [[EBHttpClient sharedInstance] gatherPublishRequest:nil getSetting:^(BOOL success, id result)
    {
        if (success)
        {
            NSDictionary *setting = result[@"setting"];
            if (setting)
            {
                _district1 = setting[@"district1"] ? setting[@"district1"] : NSLocalizedString(@"gather_setting_district_unlimited", nil);
                _district2 = setting[@"district2"] ?setting[@"district2"] : NSLocalizedString(@"gather_setting_district_unlimited", nil);
               
                NSDictionary *dictionary = @{@"district1":_district1, @"district2":_district2};
                EBFilter *filter = [[EBFilter alloc] init];
                [filter parseFromDictionary:dictionary];
                
                _district1Index = filter.district1;
                _district2Index = filter.district2;
                if (_district1Index == 0)
                {
                    _district1 = NSLocalizedString(@"gather_setting_district_unlimited", nil);
                }
                if (_district2Index == 0)
                {
                    _district2 = NSLocalizedString(@"gather_setting_district_unlimited", nil);
                }
                
                _ports = setting[@"ports"];
                if (_excludePorts == nil)
                {
                    _excludePorts = [[NSMutableArray alloc] init];
                }
                if (_ports && _ports.count > 0)
                {
                    for (NSDictionary *port in _ports)
                    {
                        if ([port[@"exclude"] boolValue])
                        {
                            [_excludePorts addObject:port[@"id"]];
                        }
                    }
                }
                [_tableView reloadData];
            }
        }
    }];
}

@end
