//
//  EBSelectOptionsViewController.h
//  beaver
//
//  Created by LiuLian on 7/28/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface EBSelectOptionsViewController : BaseViewController

@property (nonatomic, strong) NSArray *options;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) BOOL multiSelect;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;
@property (nonatomic, strong) NSString *head;

@property (nonatomic, copy) void (^onSelect)(NSInteger selectedIndex);
@property (nonatomic, copy) void (^onCancel)();
@property (nonatomic, copy) void (^onMultiSelect)(NSArray *selectedIndexes);

- (id)initWithData:(NSString *)title options:(NSArray *)options selectedIndex:(NSInteger)selectedIndex;
@end
