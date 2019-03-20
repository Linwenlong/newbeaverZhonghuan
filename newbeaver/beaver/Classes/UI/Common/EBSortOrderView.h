//
//  SingleChoiceViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//

typedef void(^TSortChoiceBlock)(NSInteger sortIndex);

@interface EBSortOrderView : UIView

@property (nonatomic, copy) TSortChoiceBlock chooseSort;
@property (nonatomic, strong) NSArray *orders;
@property (nonatomic, assign) NSInteger sortIndex;

@end
