//
//  CustomConditionViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-11.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBController.h"

@class EBCondition;

@interface CustomConditionViewController : BaseViewController

@property(nonatomic, assign) ECustomConditionViewType customType;
@property(nonatomic, strong) EBCondition *condition;
@property(nonatomic, strong) EBCondition *orgCondition;

- (BOOL)compareCondition:(EBCondition *)curCondition orgCondition:(EBCondition *)orgCondition;
- (BOOL) compareProperty:(id)curProperty orgProperty:(id)orgProperty type:(NSString*)type;

@end