//
//  TransferAndLoanTableViewCell.h
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransferAndLoanTableViewCell : UITableViewCell

@property (nonatomic, strong)NSDictionary *dic;

- (void)setStatusTransfer:(NSDictionary *)dic isLoan:(BOOL)isLoan;

@end
