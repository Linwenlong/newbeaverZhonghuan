//
//  FinanceDetailTableViewCell.h
//  beaver
//
//  Created by mac on 17/11/14.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FinanceDetailModel.h"

@interface FinanceDetailTableViewCell : UITableViewCell

@property (nonatomic, strong)FinanceDetailModel *model;


- (void)setModel:(FinanceDetailModel *)model isContactDetail:(BOOL)isDetail;

@end
