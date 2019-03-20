//
//  EBElementParser.h
//  MyQuickDialog
//
//  Created by LiuLian on 7/24/14.
//  Copyright (c) 2014 eallcn. All rights reserved.
//

#define EBElementTypeInput @"input"
#define EBElementTypeSelect @"select"
#define EBElementTypeTextarea @"textarea"

@class EBElementStyle, EBElementView;

@protocol EBElementParserDelegate <NSObject>
@optional

- (CGRect)elementFrame:(EBElementView *)elementView elementIndex:(NSUInteger)index;
- (EBElementStyle *)elementStyle:(EBElementView *)elementView elementIndex:(NSUInteger)index;
- (void)parserDidEndElement:(EBElementView *)elementView elementIndex:(NSUInteger)index;
- (void)parserDidEndData:(NSArray *)elements;

@end

@interface EBElementParser : NSObject

@property (nonatomic, weak) id<EBElementParserDelegate> delegate;

@property (nonatomic, assign) BOOL is_addHouse;//是否是新增房源
@property (nonatomic, assign) BOOL if_start;//是否开启座栋规则
@property (nonatomic, assign) BOOL if_lock;//是否房号锁定

//没有开启座栋规则
- (void)parse:(NSArray *)elements;

//开启楼盘字典的解析 房号未锁定
- (void)parse:(NSArray *)elements lifts:(NSInteger)lifts rooms:(NSInteger)rooms floor:(NSInteger)floor totleFloor:(NSInteger)totleFloor;
//开启楼盘字典的解析 房号锁定
- (void)parse:(NSArray *)elements lifts:(NSInteger)lifts rooms:(NSInteger)rooms floor:(NSInteger)floor totleFloor:(NSInteger)totleFloor room:(NSInteger)room living_room:(NSInteger)living_room washroom:(NSInteger)washroom balcony:(NSInteger)balcony area:(CGFloat)usable_area;

@end
