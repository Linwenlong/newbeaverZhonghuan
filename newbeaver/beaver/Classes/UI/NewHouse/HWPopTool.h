//
//  HWPopTool.h
//  HWPopTool
//
//  Created by HenryCheng on 16/1/11.
//  Copyright © 2016年 www.igancao.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MyViewController;
/**
 *  关闭按钮的位置
 */
typedef NS_ENUM(NSInteger, ButtonPositionType) {
    /**
     *  无
     */
    ButtonPositionTypeNone = 0,
    /**
     *  左上角
     */
    ButtonPositionTypeLeft = 1 << 0,
    /**
     *  右上角
     */
    ButtonPositionTypeRight = 2 << 0
};
/**
 *  蒙板的背景色
 */
typedef NS_ENUM(NSInteger, ShadeBackgroundType) {
    /**
     *  渐变色
     */
    ShadeBackgroundTypeGradient = 0,
    /**
     *  固定色
     */
    ShadeBackgroundTypeSolid = 1 << 0
};

typedef void(^completeBlock)(void);


/**
 *  自定义的view
 */
@interface MyView : UIView
@property (weak, nonatomic) CALayer *styleLayer;
@property (strong, nonatomic) UIColor *popBackgroundColor;
@end

//遮罩
@interface shadeView : UIView

@end

/**
 *  自定义的button
 */
@interface MainButton : UIButton

@end
/**
 *  自定义的VC
 */
@interface MyViewController : UIViewController

@property (weak, nonatomic) shadeView *styleView;

@end

@interface HWPopTool : NSObject

@property (strong, nonatomic) UIColor *popBackgroudColor;//弹出视图的背景色
@property (assign, nonatomic) BOOL tapOutsideToDismiss;//点击蒙板是否弹出视图消失
@property (assign, nonatomic) ButtonPositionType closeButtonType;//关闭按钮的类型
@property (assign, nonatomic) ShadeBackgroundType shadeBackgroundType;//蒙板的背景色

/**
 *  创建一个实例
 *
 *  @return CHWPopTool
 */

+ (HWPopTool *)sharedInstance;
/**
 *  弹出要展示的View
 *
 *  @param presentView show View
 *  @param animated    是否动画
 */

- (MyViewController*)showWithPresentView:(UIView *)presentView animated:(BOOL)animated;
/**
 *  关闭弹出视图
 *
 *  @param complete complete block
 */
- (void)closeWithBlcok:(void(^)())complete;

//
- (MyViewController*)getMainController;

@end

