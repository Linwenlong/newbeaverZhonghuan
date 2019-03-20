//
//  MySeeHeaderView.h
//  beaver
//
//  Created by mac on 17/8/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MySeeHeaderViewDelegate <NSObject>

- (void)selectedMonth:(UITapGestureRecognizer *)tap;
        
@end

@interface MySeeHeaderView : UIView

@property (nonatomic, strong)UILabel *month;//月份

@property (nonatomic, weak)id<MySeeHeaderViewDelegate> seeDelegate;

@end
