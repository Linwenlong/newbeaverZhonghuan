//
//  EBElement.h
//  MyQuickDialog
//
//  Created by LiuLian on 7/22/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

@interface EBElement : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *eid;
@property (nonatomic, strong) NSString *reg;
@property (nonatomic) BOOL required;
@property (nonatomic) BOOL visible;
@property (nonatomic) NSInteger star;
@property (nonatomic) BOOL cannot_edit;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, copy) void (^onSelect)(void);

- (CGSize)actualSize;
@end
