//
//  EBRadioGroup.h
//  beaver
//
//  Created by 何 义 on 14-3-10.
//  Copyright (c) 2014年 eall. All rights reserved.
//

typedef void(^EBRadioCheckBlock)(NSInteger checkedIndex);

@interface EBRadioGroup : UIView

@property (nonatomic, strong) NSArray *radios;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) EBRadioCheckBlock checkBlock;

@end
