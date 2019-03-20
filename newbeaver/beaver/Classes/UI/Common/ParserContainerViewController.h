//
//  ParserContainerViewController.h
//  beaver
//
//  Created by LiuLian on 8/7/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBInputView.h"
#import "EBSelectView.h"
#import "EBTextareaView.h"
#import "EBCheckView.h"
#import "EBParserContainerView.h"

@interface ParserContainerViewController : BaseViewController <EBSelectViewDelegate, EBInputViewDelegate, EBTextareaViewDelegate, EBCheckViewDelegate>


@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) EBParserContainerView *parserContainerView;

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *previousBarButton;
@property (nonatomic, strong) UIBarButtonItem *nextBarButton;
@property (nonatomic, strong) EBElementView *currentElementView;

//是否是新增房源
@property (nonatomic, assign)BOOL is_addHouse;//是否是新增房源

@property (nonatomic,assign) BOOL if_lock;//房号是否锁定

@property (nonatomic,assign) BOOL if_start;//是否开启楼盘zidian

//lwl 开启了座栋规则 房号未锁定 没有面积跟房型  梯 户  楼层 总楼层
- (void)initParserContainer:(id)result lifts:(NSInteger)lifts rooms:(NSInteger)rooms floor:(NSInteger)floor totleFloor:(NSInteger)totleFloor;
//开启了座栋规则 房号锁定 面积跟房型  梯 户  楼层 总楼层
- (void)initParserContainer:(id)result lifts:(NSInteger)lifts rooms:(NSInteger)rooms floor:(NSInteger)floor totleFloor:(NSInteger)totleFloor room:(NSInteger)room living_room:(NSInteger)living_room washroom:(NSInteger)washroom balcony:(NSInteger)balcony area:(CGFloat)usable_area;

//没有开启座栋规则
- (void)initParserContainer:(id)result;

- (NSMutableDictionary *)setReqParams:(NSMutableDictionary *)params;
- (BOOL)validateElementView:(EBElementView *)view;
- (void)resetViews;
- (void)keyboardWillHide;
@end
