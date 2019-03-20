//
//  EBFilterHeader.h
//  beaver
//
//  Created by 何 义 on 14-3-7.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "EBViewPager.h"

@class EBFilter;

@protocol EBFilterHeaderDelegate<NSObject>

- (void)filterChoiceChanged:(NSInteger)filterIndex;
- (void)popupViewWillShow;

@end


@interface EBFilterHeader : UIView

@property (nonatomic, strong) EBFilter *filter;
@property (nonatomic, assign) id<EBFilterHeaderDelegate> delegate;

- (void)toggleSortOrderView;
- (BOOL)dismissPopUpView;

@end
