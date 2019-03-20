//
//  EBRangeView.h
//  beaver
//
//  Created by LiuLian on 8/11/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBPrefixView.h"

@class EBInputView;

@interface EBRangeView : EBPrefixView

@property (nonatomic, strong) EBInputView *minInputView;
@property (nonatomic, strong) EBInputView *maxInputView;

@end
