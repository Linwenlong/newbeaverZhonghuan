//
//  SideSlipAllCategoryTableViewCell.m
//  ZYSideSlipFilter
//
//  Created by zhiyi on 16/10/14.
//  Copyright © 2016年 zhiyi. All rights reserved.
//

#import "SideSlipAllCategoryTableViewCell.h"
#import "FilterAllCategoryViewController.h"
#import "FilterAddressController.h"
#import "NameAndDepermentViewController.h"
#import "StaffViewController.h"

@interface SideSlipAllCategoryTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) ZYSideSlipFilterRegionModel *regionModel;
@property (nonatomic, assign)NSInteger curr;

@end

@implementation SideSlipAllCategoryTableViewCell
+ (NSString *)cellReuseIdentifier {
    return @"SideSlipAllCategoryTableViewCell";
}

+ (instancetype)createCellWithIndexPath:(NSIndexPath *)indexPath {
    SideSlipAllCategoryTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"SideSlipAllCategoryTableViewCell" owner:nil options:nil][0];

    
    
    return cell;
}
- (void)resetDataTest{
    NSLog(@"asdasdasd");
    self.controlLabel.text = @"全部";
    self.regionModel.selectedItemList = nil;
}


- (void)updateCellWithModel:(ZYSideSlipFilterRegionModel **)model
                  indexPath:(NSIndexPath *)indexPath {
    if (_curr == 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetDataTest) name:@"clearStaff" object:nil];
    }
    _curr++;
    
    self.regionModel = *model;
    _titleLabel.text = self.regionModel.regionTitle;
    
}
- (IBAction)clickBackgroundButton:(id)sender {
    
    NSLog(@"%@",self.titleLabel.text);
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"isSelectedStaff"]integerValue] == 1) {
        [EBAlert alertError:@"只能查看自己的工作总结" length:2.0f];
        return;
    }
    if ([self.titleLabel.text isEqualToString:@"部门"]) {
        NameAndDepermentViewController *controller = [[NameAndDepermentViewController alloc] init];
        controller.returnBlock = ^(NSString *dept_id,NSString *dept_name){
            NSLog(@"dept_id=%@",dept_id);
            NSLog(@"dept_name=%@",dept_name);
            _controlLabel.text = dept_name;
            NSArray *arr = @[dept_id,dept_name];
            _regionModel.selectedItemList = arr;
        };
        if ([self.delegate respondsToSelector:@selector(sideSlipTableViewCellNeedsPushViewController:animated:)]) {
            [self.delegate sideSlipTableViewCellNeedsPushViewController:controller animated:YES];
        }
    }else{
        StaffViewController *controller = [[StaffViewController alloc] init];
        controller.returnBlock = ^(NSString *name ,NSString *userId){
            NSLog(@"name=%@",name);
            NSLog(@"userId=%@",userId);
            _controlLabel.text = name;
            NSArray *arr = @[userId,name];
            _regionModel.selectedItemList = arr;
        };
        if ([self.delegate respondsToSelector:@selector(sideSlipTableViewCellNeedsPushViewController:animated:)]) {
            [self.delegate sideSlipTableViewCellNeedsPushViewController:controller animated:YES];
        }
    }
   
}
@end
