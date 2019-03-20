//
//  ZHDCCustomSheet.h
//  CentralManagerAssistant
//
//  Created by mac on 17/2/9.
//  Copyright © 2017年 wenlongLin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZHDCCustomSheetDelegate <NSObject>

-(void)clickButton:(NSUInteger)buttonTag superView:(id)object;

@end

@interface ZHDCCustomSheet : UIView

@property (nonatomic,weak) id<ZHDCCustomSheetDelegate>delegate;

-(ZHDCCustomSheet*)initWithButtons:(NSArray*)allButtons;

@end
