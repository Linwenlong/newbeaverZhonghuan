//
//  UnderLineLabel.h
//  beaver
//
//  Created by wangyuliang on 14-8-14.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnderLineLabel : UILabel
{
    UIControl *_actionView;
    UIColor *_orginalColor;
    UIColor *_highlightedColor;
    BOOL _shouldUnderline;
}

@property (nonatomic, retain) UIColor *highlightedColor;
@property (nonatomic, assign) BOOL shouldUnderline;

- (void)setText:(NSString *)text andCenter:(CGPoint)center;
- (void)addTarget:(id)target action:(SEL)action;
- (void)setTitleColor:(UIColor*)color;

@end
