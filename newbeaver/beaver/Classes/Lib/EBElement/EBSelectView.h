//
//  EBSelectView.h
//  MyQuickDialog
//
//  Created by LiuLian on 7/23/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#import "EBPrefixView.h"

@class EBSelectView;

@protocol EBSelectViewDelegate <EBElementViewDelegate>

- (void)selectViewShouldShowOptions:(EBSelectView *)selectView options:(NSArray *)options selectedIndex:(NSInteger)index;
//- (void)selectViewDidSelectOptions:(EBSelectView *)selectView options:(NSArray *)options selectedIndex:(NSUInteger)index;
@end

@interface EBSelectView : EBPrefixView

- (BOOL)checkEmpty;

//- (void)setSelectValue:(NSInteger)selectedIndex;
@end
