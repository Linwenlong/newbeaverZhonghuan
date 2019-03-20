//
//  ContactsViewController.h
//  beaver
//
//  Created by 何 义 on 14-2-27.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"

@class EBIMGroup;

@interface ContactsViewController : BaseViewController


@property (nonatomic, copy) NSString *selectTitleButton;

@property (nonatomic, copy) void(^returnBlock)(NSString *name ,NSString *userId);

@property (nonatomic, copy) void(^contactsSelected)(NSArray *contacts);
@property (nonatomic, copy) void(^groupSelected)(EBIMGroup *group);
@property (nonatomic, strong) NSArray *filterContacts;

@property (nonatomic, strong) EBSearch *searchHelper;

//lwl
@property (nonatomic, assign) BOOL is_Daily;


@end
