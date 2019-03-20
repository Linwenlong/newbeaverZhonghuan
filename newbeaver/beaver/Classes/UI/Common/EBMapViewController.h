//
//  EBMapViewController.h
//  beaver
//
//  Created by LiuLian on 12/11/14.
//  Copyright (c) 2014 eall. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, EMMapViewType)
{
    EMMapViewTypeByCoordinate = 0,
    EMMapViewTypeByKeyword = 1
};
typedef NS_ENUM(NSInteger , EBAnnotationType) {
    EBAnnotationTypeByIcon = 1,
};
@interface EBMapViewController : BaseViewController

@property (nonatomic, strong) NSDictionary *poiInfo;

@property (nonatomic, assign) EMMapViewType mapType;

@property (nonatomic, assign) EBAnnotationType AnnotationType;

//添加多个大头针
@property (nonatomic, strong)NSArray *iconsArray;

-(void)addAnnotationsWithArray:(NSArray*)annotations;


@end
