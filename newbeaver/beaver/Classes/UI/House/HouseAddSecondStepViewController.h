//
//  HouseAddSecondStepViewController.h
//  beaver
//
//  Created by LiuLian on 7/30/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "BaseViewController.h"

@class EBHouse;

@interface HouseAddSecondStepViewController : BaseViewController

@property (nonatomic, strong) NSString *purpose;

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic) BOOL editFlag;
@property (nonatomic, weak) EBHouse *house;

@property (nonatomic, strong)NSString * inputDisks;

@end
