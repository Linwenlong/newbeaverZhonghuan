//
//  EBCheckView.h
//  beaver
//
//  Created by LiuLian on 7/27/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "EBPrefixView.h"

@class EBCheckView;

@protocol EBCheckViewDelegate <EBElementViewDelegate>

- (void)checkViewDidChanged:(EBCheckView *)checkView;

@end

@interface EBCheckView : EBPrefixView

@property (nonatomic, weak) id<EBCheckViewDelegate> delegate;

- (BOOL)checked;
@end
