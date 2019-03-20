//
//  EBElement.m
//  MyQuickDialog
//
//  Created by LiuLian on 7/22/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBElement.h"
#import "EBElementStyle.h"
#import "EBElementView.h"

@implementation EBElement
@synthesize star = _star;

- (id)init
{
    if (self = [super init]) {
        self.visible = YES;
    }
    return self;
}

- (CGSize)actualSize
{
    return CGSizeZero;
}

- (void)setStar:(NSInteger)star
{
    _star = star;
    if (_star == EBElementViewStarVisible) {
        self.required = YES;
    } else {
        self.required = NO;
    }
}

@end
