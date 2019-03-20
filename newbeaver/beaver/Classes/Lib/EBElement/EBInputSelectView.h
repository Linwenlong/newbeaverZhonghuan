//
//  EBInputSelectView.h
//  beaver
//
//  Created by LiuLian on 8/7/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBPrefixView.h"

@class EBInputView, EBSelectView;

@interface EBInputSelectView : EBPrefixView

@property (nonatomic, strong) EBInputView *inputView;
@property (nonatomic, strong) EBSelectView *selectView;

@end
