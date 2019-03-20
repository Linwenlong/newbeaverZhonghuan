//
//  NearByMapViewController.h
//  beaver
//
//  Created by linger on 16/2/1.
//  Copyright © 2016年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBFilter.h"
#import <MAMapKit/MAMapKit.h>

@protocol EBListDataSource;

typedef NS_ENUM(NSInteger, EMMapViewType)
{
    EMMapViewTypeByCoordinate = 0,
    EMMapViewTypeByKeyword = 1
};
typedef NS_ENUM(NSInteger , EBAnnotationType) {
    EBAnnotationTypeByIcon = 1,
};
@interface NearByMapViewController : BaseViewController

@property (nonatomic, strong) NSDictionary *poiInfo;

@property (nonatomic, assign) EMMapViewType mapType;

@property (nonatomic, assign) EBAnnotationType AnnotationType;

@property (nonatomic, strong) NSDictionary *appParam;

//添加多个大头针
@property (nonatomic, strong)NSArray *iconsArray;

-(void)addAnnotationsWithArray:(NSArray*)annotations withIsWap:(BOOL)isWap withType:(NSString *)type;


@end


@interface customerPointAnnotation : MAPointAnnotation
/**
 *  house id
 */
@property (nonatomic,copy)NSString *Mid;

/**
 *  status
 */
@property (nonatomic,copy)NSString *status;

/**
 *  类型
 */
@property (nonatomic,copy)NSString *type;

/**
 *  openUrl
 */
@property (nonatomic,copy)NSString *url;
/**
 *  打开方式
 */
@property (nonatomic,assign)BOOL isWap;

/**
 *  community_id
 */
@property (nonatomic,copy)NSString *community_id;


@end


