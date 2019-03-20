//
//  BasisInformationTableViewCell.h
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BasisInformationDelegate <NSObject>

- (void)call:(NSString *)iphone;

@end

@interface BasisInformationTableViewCell : UITableViewCell

@property (nonatomic, weak)id<BasisInformationDelegate> basisDelegate;

@property (nonatomic, strong)NSDictionary * dic;


@end
