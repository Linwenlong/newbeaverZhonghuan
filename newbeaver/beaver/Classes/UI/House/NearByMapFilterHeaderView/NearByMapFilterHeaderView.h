//
//  NearByMapFilterHeaderView.h
//  beaver
//
//  Created by linger on 16/2/25.
//  Copyright © 2016年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBFilter.h"
@protocol NearByMapFilterHeaderViewDelegate<NSObject>

- (void)filterChoiceChanged:(NSInteger)filterIndex;
- (void)popupViewWillShow;

- (void)filterToSeleted:(NSDictionary *)agrs;
@end

@interface NearByMapFilterHeaderView : UIView

@property (nonatomic, assign) NSInteger houseType;
@property (nonatomic, strong) EBFilter *filter;
@property (nonatomic, assign) id<NearByMapFilterHeaderViewDelegate> delegate;

- (void)toggleSortOrderView;
- (BOOL)dismissPopUpView;

@end
