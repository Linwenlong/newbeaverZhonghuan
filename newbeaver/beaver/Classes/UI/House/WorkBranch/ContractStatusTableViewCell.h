//
//  ContractStatusTableViewCell.h
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ContractStatusTableViewDelegate <NSObject>

- (void)btnClickContractStatus:(UIButton *)btn;

@end

@interface ContractStatusTableViewCell : UITableViewCell

@property (nonatomic, weak)id<ContractStatusTableViewDelegate> ContractDelegate;

@property (nonatomic, strong)NSDictionary * dic;

@end
