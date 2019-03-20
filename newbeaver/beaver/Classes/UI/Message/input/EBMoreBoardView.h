//
//  EBMoreBoardView.h
//
//  Created by jack on 13-10-19.
//  Copyright (c) 2013年 appkefu.com. All rights reserved.
//

@protocol EBMoreBoardViewDelegate;

@interface EBMoreBoardView : UIView

@property (nonatomic, assign) id<EBMoreBoardViewDelegate> delgate;

@end


@protocol EBMoreBoardViewDelegate<NSObject>

-(void)moreBoardView:(EBMoreBoardView *)boardView itemClicked:(NSInteger)index;

@end