//
//  EBSelectOptionsViewController.m
//  beaver
//
//  Created by LiuLian on 7/28/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBSelectOptionsViewController.h"

@interface EBSelectOptionsViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *optionsTableView;
}
@end

@implementation EBSelectOptionsViewController
@synthesize options = _options, selectedIndex = _selectedIndex, head;

- (id)initWithData:(NSString *)title options:(NSArray *)options selectedIndex:(NSInteger)selectedIndex
{
    if (self = [super init]) {
        head = title;
        _options = options;
        _selectedIndex = selectedIndex;
    }
    return self;
}

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
    // Do any additional setup after loading the view.]
    self.navigationItem.title = head;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    if (self.multiSelect) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(ok)];
    }
    
//    self.view.backgroundColor = [UIColor redColor];
    optionsTableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    optionsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    optionsTableView.delegate = self;
    optionsTableView.dataSource = self;
    [self.view addSubview:optionsTableView];
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

#pragma mark -
#pragma tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.multiSelect) {
        return _options.count;
    }
    return _options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"optionCell";
    UITableViewCell *cell = [optionsTableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (!self.multiSelect) {
        cell.textLabel.text = _options[indexPath.row];
        if (_selectedIndex == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
//        if (indexPath.row == 0) {
//            cell.textLabel.text = @"请选择";
//        } else {
//            cell.textLabel.text = _options[indexPath.row-1];
//        }
//        if (_selectedIndex + 1 == indexPath.row) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        } else {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//        }
    } else {
        cell.textLabel.text = _options[indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryNone;
        for (NSNumber *number in self.selectedIndexes) {
            if ([number integerValue] == indexPath.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                break;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.multiSelect) {
        _selectedIndex = indexPath.row;
        [tableView reloadData];
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
        if (self.onSelect) {
            self.onSelect(indexPath.row);
        }
        if (self.onCancel) {
            self.onCancel();
        }
    } else {
        if ([self tableView:tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
            for (NSNumber *number in self.selectedIndexes) {
                if ([number integerValue] == indexPath.row) {
                    [self.selectedIndexes removeObject:number];
                    break;
                }
            }
        } else {
            [self.selectedIndexes addObject:[NSNumber numberWithInt:indexPath.row]];
        }
        [tableView reloadData];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)cancel
{
    if (self.onCancel) {
        self.onCancel();
    }
}

- (void)ok
{
    if (self.onMultiSelect) {
        self.onMultiSelect(self.selectedIndexes);
    }
    if (self.onCancel) {
        self.onCancel();
    }
}

@end
