//
//  AddFirstStepViewController.h
//  beaver
//
//  Created by LiuLian on 7/31/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "BaseViewController.h"

@class EBInputElement, EBInputView, EBSelectElement, EBSelectView, EBRadioGroup;

typedef NS_ENUM(NSInteger, EBEditType)
{
    EBEditTypeAdd = 1,
    EBEditTypeEdit = 2
};

@interface AddFirstStepViewController : BaseViewController

@property (nonatomic) BOOL addType;//0：房源；1：客源
@property (nonatomic) EBEditType actionType;
@property (nonatomic, strong) NSString *purpose;
@property (nonatomic, strong) NSArray *wantNew;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) EBInputView *nameInputView;
@property (nonatomic, strong) EBSelectView *nameSelectView;
@property (nonatomic, strong) EBInputView *telInputView;
@property (nonatomic, strong) EBSelectView *telSelectView;

@property (nonatomic, strong) EBRadioGroup *wantRadioGroup;
@property (nonatomic, strong) EBRadioGroup *accessoryRadioGroup;

- (void)nextStep;
- (void)endEdit;
- (void)inputviewresignFirstResponder;
- (void)setBackAlert:(BOOL)flag;
@end
