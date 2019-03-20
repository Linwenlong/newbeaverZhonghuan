//
//  SearchView.h
//  beaver
//
//  Created by mac on 17/5/2.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchViewDelegate <NSObject>

- (void)didSelected:(UIButton *)lable;

@end


@interface SearchView : UIView

@property (nonatomic, assign)id  <SearchViewDelegate> searchViewDelegate;

/**
 *  多个标签
 *
 *  @param frame  frame
 *  @param lables  Array Lables
 *  @param color  background of lable
 *  @param title  title of self
 *
 *  @return self
 */
-(instancetype)initWithFrame:(CGRect)frame arrayLables:(NSArray *)lables lableBackGroundColor:(UIColor *)color withTitle:(NSString *)title;



@end
