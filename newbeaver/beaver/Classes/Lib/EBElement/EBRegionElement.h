//
//  EBRegionElement.h
//  beaver
//
//  Created by LiuLian on 8/18/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBPrefixElement.h"

@interface EBRegionElement : EBPrefixElement

@property (nonatomic, strong) NSString *district;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *community;
@property (nonatomic) NSInteger count;
@property (nonatomic) BOOL editAble;

@end
