//
//  LWLAlertView.h
//  beaver
//
//  Created by mac on 17/10/10.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LWLAlertViewDelegate <NSObject>

- (void)alertViewSelectedBtn:(UIButton *)btn;

@end

@interface LWLAlertView : UIView

@property (nonatomic, weak) id<LWLAlertViewDelegate> alertViewDelegate;

@end
