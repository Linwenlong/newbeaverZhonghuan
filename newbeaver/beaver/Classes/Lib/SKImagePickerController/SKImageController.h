//
//  SKImageController.h
//  chow
//
//  Created by wangyuliang on 14-12-1.
//  Copyright (c) 2014年 eallcn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBStyle.h"

#define SK_ITEM_GAP     4.f
#define SK_ITEM_WIDTH   (([EBStyle screenWidth] - 5 * SK_ITEM_GAP) / 4.0)

typedef void (^assertSelect)(NSArray *);

@interface SKImageController : NSObject

+ (void)showMutlSelectPhotoFrom:(UIViewController *)viewCtrl maxSelect:(NSInteger)maxSelectNum select:(assertSelect)photoSelect;

@end
