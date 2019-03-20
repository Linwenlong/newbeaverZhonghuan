//
//  MortgageCalcView.h
//  beaver
//
//  Created by 何 义 on 14-2-28.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EMortgageType) {
    EMortgageTypeCommercial = 0,
    EMortgageTypeFund = 1,
    EMortgageTypeCombination = 2
};

typedef NS_ENUM(NSInteger, EMortgagePayType) {
    EMortgagePayTypeInterest = 0,     // 等额本息
    EMortgagePayTypePrincipal
};

typedef NS_ENUM(NSInteger, EMortgageCalcType) {
    EMortgageCalcTypeAmount = 0,
    EMortgageCalcTypeUnit
};

typedef NS_ENUM(NSInteger, EMortgageRowType) {
    EMortgageRowTypeSelect = 0,
    EMortgageRowTypeInput
};

@class MortgageHelper;
@protocol MortgageCalcViewDelegate;

@interface MortgageCalcView : UIView <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

- (id)initWithFrame:(CGRect)frame withMortgageType:(EMortgageType)mortgageType;
- (void)checkTextViewBecomeFirst;

@property (nonatomic, assign) EMortgageType type;
@property (nonatomic, assign) id<MortgageCalcViewDelegate> delegate;
@property (nonatomic, readonly) UITableView * tableView;
@property (nonatomic, readonly) MortgageHelper *mortgageHelper;

@end

@protocol MortgageCalcViewDelegate<NSObject>
@required
-(void)calcView:(MortgageCalcView*)calcView showResult:(NSArray *)result;
@end

typedef NS_ENUM(NSInteger, EMortgageDataItem) {
    EMortgageDataItemPayType = 0,  // 还款方式
    EMortgageDataItemCalcType = 1, // 计算方式
    EMortgageDataItemPriceUnit = 2, // 单价
    EMortgageDataItemArea = 3, // 面积
    EMortgageDataItemPercent = 4, // 按揭成数
    EMortgageDataItemPeriods = 5, // 按揭期数
    EMortgageDataItemInterestRate = 6, // 利率
    EMortgageDataItemFundAmount = 7, // 公积金贷款
    EMortgageDataItemCommercialAmount = 8, // 商业贷款
    EMortgageDataItemAmount = 9, // 贷款总额
    EMortgageDataItemInterestRateF = 10 //公积金利率
};

@interface MortgageHelper  : NSObject

@property (nonatomic, assign) EMortgageType mortgageType;
@property (nonatomic, assign) EMortgageCalcType calcType;

- (NSInteger)numberOfRows;
- (NSArray *)calcResult;
- (BOOL)calJudge;
- (NSArray *)dataIndexes;
- (NSMutableDictionary *)dataOfRow:(NSInteger)row;
- (NSString *)displayForDataItem:(EMortgageDataItem)item;
- (NSArray *)choicesByDataItem:(EMortgageDataItem)dataItem;
-(void)updateItem:(EMortgageDataItem)dataItem value:(id)value;
- (void)updateItemSet;

@end