//
//  BrokerInsertView.h
//  beaver
//
//  Created by mac on 18/1/30.
//  Copyright © 2018年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrokerInsertView : UIView

@property (strong, nonatomic)UIImageView *deleteImage;//删除图片
@property (strong, nonatomic)UILabel *nameField;
@property (strong, nonatomic)UIButton *chooseClientCode;
@property (strong, nonatomic)UITextView *contentTextView;
@property (strong, nonatomic)UILabel *tipLable;

@property (strong, nonatomic)UIView *backView;


@end
