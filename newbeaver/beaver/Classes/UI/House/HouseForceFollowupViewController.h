//
//  HouseForceFollowupViewController.h
//  beaver
//
//  Created by mac on 17/10/24.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface HouseForceFollowupViewController : BaseViewController

@property (nonatomic, strong) void(^ returnBlock )(BOOL succeed);

@property (nonatomic, strong) NSString *house_id;

@property (nonatomic, strong) NSArray *phoneNum;//手机号

@end
