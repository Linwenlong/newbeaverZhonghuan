//
//  StoreFinanceViewController.m
//  beaver
//
//  Created by mac on 17/11/13.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "StoreFinanceViewController.h"
#import "CostCountViewController.h"
#import "FinanceViewController.h"

@interface StoreFinanceViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray * sectionArray;
    UITableView *_tableView;
}
@end

@implementation StoreFinanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"门店财务";
    
    sectionArray = [NSMutableArray array];
    _isShowCompanyMoney == YES ? [sectionArray addObject:@"公司收入分账"] : 1;
    _isShowStoneAccount == YES ? [sectionArray addObject:@"门店佣金分账"] : 1;
    _isShowReimbursement == YES ? [sectionArray addObject:@"报销划账管理"] : 1;
    _isShowFee == YES ? [sectionArray addObject:@"费用统计"] : 1;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenW, kScreenH-64)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    [_tableView setLayoutMargins:UIEdgeInsetsZero];
    [self.view addSubview:_tableView];
    [self beaverStatistics:@"StoreFinance"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return sectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    
    cell.textLabel.text = sectionArray[indexPath.row];
    
    //修改图片尺寸大小
    UIImage *icon = [UIImage imageNamed:sectionArray[indexPath.row]];
    CGSize itemSize = CGSizeMake(30, 30);
    UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [icon drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *accessory = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 7, 11)];
    accessory.image = [UIImage imageNamed:@"jiantou"];
    cell.accessoryView = accessory;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *currentStr = sectionArray[indexPath.row];
    
    NSLog(@"currentStr=%@",currentStr);
     if ([currentStr isEqualToString:@"费用统计"]){
        //门店财务
        CostCountViewController *ccvc = [[CostCountViewController alloc]init];
         
         ccvc.monthfinance = _monthfinance;
         ccvc.halfmonthfinance = _halfmonthfinance;
         ccvc.dayfinance = _dayfinance;
         ccvc.tenfinance = _tenfinance;
         
        ccvc.hidesBottomBarWhenPushed = YES;
        if ([_financeDec isEqualToString:@"半月结"]) {
            ccvc.costCountType = ZHCostCountTypeHalfMonth;
        }else if ([_financeDec isEqualToString:@"单日结"]){
            ccvc.costCountType = ZHCostCountTypeDay;
        }else if ([_financeDec isEqualToString:@"月结统计"]){
            ccvc.costCountType = ZHCostCountTypeMonth;
        }else if ([_financeDec isEqualToString:@"十日结佣"]){
            ccvc.costCountType = ZHCostCountTypeTen;
        }
        ccvc.totletype = _finProfile;
         ccvc.financeDec = _financeDec;
        [self.navigationController pushViewController:ccvc animated:YES];
     }else{
          FinanceViewController *fvc = [[FinanceViewController alloc]init];
         if ([currentStr isEqualToString:@"公司收入分账"]) {
              fvc.finaceType = ZHFinanceTypeCompanyIncomeLedger;
         }else if ([currentStr isEqualToString:@"门店佣金分账"]){
             fvc.finaceType = ZHFinanceTypeStoreCommission;
         }else if ([currentStr isEqualToString:@"报销划账管理"]){
             fvc.finaceType = ZHFinanceTypeReimbursementAccountManagement;
         }
         fvc.hidesBottomBarWhenPushed = YES;
         [self.navigationController pushViewController:fvc animated:YES];
     }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}


@end
