//
//  EBSelectElement.m
//  MyQuickDialog
//
//  Created by LiuLian on 7/23/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBSelectElement.h"

@implementation EBSelectElement

- (id)init
{
    self = [super init];
    if (self) {
        self.selectedIndex = -1;
    }
    return self;
}
@end
