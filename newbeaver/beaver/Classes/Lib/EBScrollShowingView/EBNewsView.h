//
//  EBNewsView.h
//  beaver
//
//  Created by 凯文马 on 15/12/15.
//  Copyright © 2015年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBNews;

typedef void(^EBNewsViewClickNewsBlock)(EBNews *news);

@interface EBNewsView : UIView

/**
 *  EBNews 数组
 */
@property (nonatomic, strong) NSArray *news;

/**
 *  点击执行操作
 */
@property (nonatomic, copy) EBNewsViewClickNewsBlock clickAction;

+ (instancetype)newsViewWithNews:(NSArray *)news clickAction:(EBNewsViewClickNewsBlock)clickAction;

+ (instancetype)newsViewWithNews:(NSArray *)news timeInterval:(CGFloat)timeInterval clickAction:(EBNewsViewClickNewsBlock)clickAction;

@end

@interface EBNews : NSObject

@property (nonatomic, strong) NSNumber *ID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSString *urlStr;

+ (instancetype)newsWithId:(NSNumber *)ID title:(NSString *)title info:(NSString *)info url:(NSString *)url;

@end

@interface EBNewsCell : UITableViewCell

+ (EBNewsCell *)cellWithTableView:(UITableView *)tableView news:(EBNews *)news;
@property (nonatomic, strong) EBNews *news;


@end