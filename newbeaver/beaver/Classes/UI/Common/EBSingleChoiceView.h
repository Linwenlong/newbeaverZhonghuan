//
//  SingleChoiceViewController.h
//  beaver
//
//  Created by 何 义 on 14-3-2.
//  Copyright (c) 2014年 eall. All rights reserved.
//
typedef enum{
    CustomNone,
    CustomArea,
    CustomPriceRent,
    CustomPriceSale,
}CustomConditionType;

typedef void(^TChoiceMadeBlock)(NSInteger rightIndex, NSInteger leftIndex);

@interface EBSingleChoiceView : UIView<UIAlertViewDelegate>

@property (nonatomic, assign) BOOL hideRowZero;
@property (nonatomic, assign) BOOL touchBackDisabled;
@property (nonatomic, copy) TChoiceMadeBlock makeChoice;
@property (nonatomic, strong) NSArray *choices;
@property (nonatomic, assign) NSInteger rightIndex;
@property (nonatomic, assign) NSInteger leftIndex;
@property (nonatomic, copy) NSString *footerText;
@property (nonatomic, copy) NSString *headerText;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger houseType;

@end
