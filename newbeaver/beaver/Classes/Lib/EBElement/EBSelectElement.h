//
//  EBSelectElement.h
//  MyQuickDialog
//
//  Created by LiuLian on 7/23/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBInputElement.h"

@interface EBSelectElement : EBInputElement

@property (nonatomic, strong) NSArray *options;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSString *display;
@property (nonatomic, strong) NSString *match;
@property (nonatomic) BOOL multiSelect;
@property (nonatomic, strong) NSArray *selectedIndexes;
@end
