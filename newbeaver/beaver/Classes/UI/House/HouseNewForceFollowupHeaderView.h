//
//  HouseNewForceFollowupHeaderView.h
//  beaver
//
//  Created by mac on 17/11/17.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderViewDelegate <NSObject>

- (void)phoneNumberClick:(NSString *)str;

@end


@interface HouseNewForceFollowupHeaderView : UIView

@property (nonatomic, weak) id<HeaderViewDelegate> headerViewDelegate;
-(instancetype)initWithFrame:(CGRect)frame name:(NSString *)name phones:(NSArray *)phones;

@end
