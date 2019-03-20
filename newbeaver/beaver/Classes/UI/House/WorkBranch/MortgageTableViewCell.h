//
//  MortgageTableViewCell.h
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface MortgageTableViewCell : UITableViewCell

@property (nonatomic, strong) void(^confrim)(NSInteger tag);

@property (nonatomic, strong)NSDictionary * dic;

@end
