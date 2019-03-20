//
//  ExtraInfoViewController.m
//  beaver
//
//  Created by LiuLian on 7/28/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "ExtraInfoViewController.h"

@interface ExtraInfoViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSString *head;
    
    UITableView *_tableView;
}
@end

@implementation ExtraInfoViewController
@synthesize extraInfos = _extraInfos;

- (id)initWithData:(NSArray *)extraInfos title:(NSString *)title
{
    self = [super init];
    if (self) {
        // Custom initialization
        _extraInfos = extraInfos;
        head = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = head;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO] style:UITableViewStyleGrouped];
    [self.view addSubview:_tableView];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.onDisappear) {
        self.onDisappear();
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _extraInfos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [(NSArray *)_extraInfos[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    cell.textLabel.text = _extraInfos[indexPath.section][indexPath.row][@"name"];
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.onSelect) {
        self.onSelect(indexPath, _extraInfos[indexPath.section][indexPath.row]);
    }
    if (self.onCancel) {
        self.onCancel();
    }
    [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma leftbarbuttonitem action
- (void)cancel
{
    if (self.onCancel) {
        self.onCancel();
    }
}

@end
