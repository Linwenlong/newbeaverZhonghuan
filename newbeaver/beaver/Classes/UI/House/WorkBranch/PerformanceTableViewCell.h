//
//  PerformanceTableViewCell.h
//  beaver
//
//  Created by mac on 17/8/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PerformanceRankingModel;

@interface PerformanceTableViewCell : UITableViewCell

- (void)setHidden:(BOOL)hidden model:(PerformanceRankingModel *)model num:(NSInteger)num;

@end
