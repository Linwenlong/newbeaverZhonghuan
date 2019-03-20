//
//  FilterView.h
//  beaver
//
//  Created by 何 义 on 14-3-3.
//  Copyright (c) 2014年 eall. All rights reserved.
//


typedef NS_ENUM(NSInteger , EFilterType){
    EFilterTypeHouse = 0,
    EFilterTypeClient = 1,
    EFilterTypeGatherHouse = 2,
};

@protocol FilterViewDelegate;
@class EBFilter;
@class EBCondition;

@interface EBFilterView : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

-(id)initWithFrame:(CGRect)frame custom:(BOOL)custom;
-(id)initWithFrame:(CGRect)frame custom:(BOOL)custom withIsHouseView:(BOOL)isHouseView;

- (void)syncCondition;

@property (nonatomic, assign) EFilterType filterType;
@property (nonatomic, assign) id<FilterViewDelegate> delegate;
@property (nonatomic, strong) EBFilter * filter;
@property (nonatomic, strong) EBCondition *customCondition;

@property (nonatomic,assign) BOOL isHouseView;

//- (void)commitEdit;
- (void)buildTableFooterViewForHouseView;

@end

@protocol FilterViewDelegate<NSObject>
@required
-(void)filterView:(EBFilterView*)filterView filter:(EBFilter *)filter;
@end