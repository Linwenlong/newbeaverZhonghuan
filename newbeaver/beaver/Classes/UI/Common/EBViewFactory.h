//
//  WidgetFactory.h
//  beaver
//
//  Created by 何 义 on 14-2-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//
#import "EBHouse.h"
#import "EBClient.h"
#import "RTLabel.h"
#import "EBIconLabel.h"

@class RTLabel;

typedef NS_ENUM(NSInteger , EBPhoneType)
{
    EBPhoneTypeDisableOther = 101,
    EBPhoneTypeDisableOwn,
    EBPhoneTypeEnableOtherCall,
    EBPhoneTypeEnableOtherView,
    EBPhoneTypeEnableOwnCall,
    EBPhoneTypeEnableOwnView,

    EBPhoneTypeHouseDisableOther = EBPhoneTypeDisableOther,
    EBPhoneTypeHouseDisableOwn = EBPhoneTypeDisableOwn,
    EBPhoneTypeHouseEnableOtherCall = EBPhoneTypeEnableOtherCall,
    EBPhoneTypeHouseEnableOtherView = EBPhoneTypeEnableOtherView,
    EBPhoneTypeHouseEnableOwnCall = EBPhoneTypeEnableOwnCall,
    EBPhoneTypeHouseEnableOwnView = EBPhoneTypeEnableOwnView,

    EBPhoneTypeClientDisableOther = EBPhoneTypeDisableOther,
    EBPhoneTypeClientDisableOwn = EBPhoneTypeDisableOwn,
    EBPhoneTypeClientEnableOtherCall = EBPhoneTypeEnableOtherCall,
    EBPhoneTypeClientEnableOtherView = EBPhoneTypeEnableOtherView,
    EBPhoneTypeClientEnableOwnCall = EBPhoneTypeEnableOwnCall,
    EBPhoneTypeClientEnableOwnView = EBPhoneTypeEnableOwnView,

    EBPhoneTypeHouseEnableShowNum,
    EBPhoneTypeHouseDisableShowNum,

    EBPhoneTypeHouseShowNumSingle,
    EBPhoneTypeHouseShowNumMutli,
    EBPhoneTypeClienthowNumSingle,
    EBPhoneTypeClientShowNumMutli
};

@interface EBViewFactory : NSObject

+ (UIButton *)blueButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)selector;
+ (UIButton *)countButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)selector;
+ (void)updateCountButton:(UIButton *)btn count:(NSInteger)count;

+ (UIButton *)redButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)selector;
+ (UIButton *)lightGreenButtonWithFrame:(CGRect)frame title:(NSString *)title target:(id)target action:(SEL)selector;
+ (UIView *)tableViewSeparatorWithRowHeight:(CGFloat)height leftMargin:(CGFloat)leftMargin;
+ (UIView *)tableViewSeparatorWithRowHeight:(CGFloat)height width:(CGFloat)width leftMargin:(CGFloat)leftMargin;
+ (void)view:(UIView *)view setSeparatorHidden:(BOOL)hidden;
+ (UIView *)defaultTableViewSeparator;
+ (UILabel *)valueViewFromCell:(UITableViewCell *)cell accessory:(BOOL)accessory;
+ (UIScrollView *)pagerScrollView:(BOOL)inTab;
+ (UIRefreshControl *)refreshControlForTableView:(UITableView *)tableView;
+ (UIImageView *)imageViewWithFrame:(CGRect)frame url:(NSString *)url;
//+ (UILabel *)tagLabelWithText:(NSString *)text color:(UIColor *)color;
+ (CGSize)textSize:(NSString *)text font:(UIFont *)font bounding:(CGSize)size;
+ (UILabel *)lastNameLabel;
+ (UIImageView *)avatarImageView:(CGFloat)size;
+ (UIButton *)avatarImageButton:(CGFloat)size;
+ (UIButton *)accessPhoneNumberBtn:(NSInteger)remainTimes isHouse:(BOOL)isHouse;
+ (UIView *)accessPhoneNumberViewForHouse:(id)target action:(SEL)action house:(EBHouse *)house view:(UIView *)faView;
+ (UIView *)accessPhoneNumberViewForClient:(id)target action:(SEL)action client:(EBClient *)client view:(UIView *)faView;
+ (UIView *)qrCodeNumberView:(NSString *)text;
+ (UIView *)accessoryView:(id)target action:(SEL)action forHouse:(BOOL)forHouse;
+ (CGFloat)addNote:(NSString *)note toView:(UIView *)parentView withYOffset:(CGFloat)yOffset;
+ (UIButton *)buttonWithImage:(UIImage *)image;
+ (RTLabel*)contactLabelWithFrame:(CGRect)frame name:(NSString *)name phone:(NSString *)phone date:(NSString *)date;
+ (UIView *)phoneButtonWithTarget:(id)target action:(SEL)action;
+ (UIButton *)smsPhoneNumberBtn:(NSString *)phone;
+ (UILabel *)timestampLabel;
+ (UIImageView *)bubbleImageView:(BOOL)isIncoming;
+ (UIImage *)imageFromGender:(NSString *)gender big:(BOOL)big;
+ (UITableViewCell *)loadingMoreCellFor:(UITableView *)tableView cellHeight:(CGFloat)height cellIdentifier:(NSString *)identifier;
+ (CGFloat)parentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth delegate:(id<RTLabelDelegate>)delegate;
+ (EBIconLabel *)parentView:(UIView *)parent iconTextWithImage:(UIImage *)image text:(NSString *)text;
+ (void)parentView:(UIView *)parent addLine:(CGFloat)yOffset;
+ (CGFloat)parentView:(UIView *)parent addRecommendTag:(NSArray *)recommendTags xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth tagColor:(UIColor *)tagColor;
+ (UIView*)lineWithHeight:(CGFloat)height left:(CGFloat)leftMargin right:(CGFloat)rightMargin;
+ (CGFloat)myParentView:(UIView *)parent addKey:(NSString *)key value:(NSString *)value linkValue:(NSString *)linkValue xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset limitWidth:(CGFloat)limitWidth delegate:(id<RTLabelDelegate>)delegate;

//普通通话
+ (UIView *)accessNewPhoneNumberViewForHouse:(id)target action:(SEL)action house:(EBHouse *)house view:(UIView *)faView;

//隐号通话
+ (UIView *)accessPhoneHiddenNumberViewForHouse:(EBHouse *)house view:(UIView *)faView;


+ (UIView *)accessoryNewView:(id)target action:(SEL)action;

@end
