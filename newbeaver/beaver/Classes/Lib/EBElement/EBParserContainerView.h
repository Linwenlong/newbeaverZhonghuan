//
//  EBParserContainerView.h
//  beaver
//
//  Created by LiuLian on 7/31/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EBSelectView.h"
#import "EBElementParser.h"

@interface EBParserContainerView : UIView <EBElementParserDelegate>

@property (nonatomic, strong) NSMutableArray *inputViews;
@property (nonatomic, weak) UIViewController<EBSelectViewDelegate> *controller;

- (EBElementView *)showElementView:(NSArray *)eids;
- (void)hideElementView:(NSArray *)eids;
- (void)addElementView:(EBElementView *)view atIndex:(NSUInteger)index;
- (void)showInView:(UIView *)view toolbar:(UIToolbar *)toolbar;
@end
