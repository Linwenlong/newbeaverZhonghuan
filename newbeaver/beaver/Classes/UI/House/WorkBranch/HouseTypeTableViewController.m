//
//  houseTypeTableViewController.m
//  beaver
//
//  Created by hfy on 16/7/25.
//  Copyright © 2016年 eall. All rights reserved.
//

#import "HouseTypeTableViewController.h"
#import"EBController.h"

@interface HouseTypeTableViewController ()

@end

@implementation HouseTypeTableViewController

-(NSArray *)houseTypeChoiceArr{

    if (_houseTypeChoiceArr == nil) {
        _houseTypeChoiceArr = [NSArray array];
    }
    return _houseTypeChoiceArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.houseTypeChoiceArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.houseTypeChoiceArr[indexPath.row];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *str = _houseTypeChoiceArr[indexPath.row];
    if (self.myblock) {
        self.myblock(str);
    }
    
     [[EBController sharedInstance].currentNavigationController popViewControllerAnimated:YES ];
}

@end
