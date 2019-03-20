//
//  HouseClientExistViewController.h
//  beaver
//
//  Created by LiuLian on 8/13/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface HouseClientExistViewController : BaseViewController

@property (nonatomic, strong) NSString *title;
@property (nonatomic) BOOL clientFlag;
@property (nonatomic, strong) id data;

@property (nonatomic, copy) void (^goon)(void);
@end
