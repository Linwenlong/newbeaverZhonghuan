//
//  EBProgressView.h
//  beaver
//
//  Created by wangyuliang on 14-7-9.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EBProgressDelegate;

@interface EBProgressView : UIView

@property (assign, nonatomic) id<EBProgressDelegate> delegate;
@property (nonatomic, copy) CGFloat(^progressGet)();

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth;
- (void)play;
- (void)updateProgress:(CGFloat)progress;

@end

@protocol EBProgressDelegate <NSObject>

- (void)didUpdateProgressView;

@end