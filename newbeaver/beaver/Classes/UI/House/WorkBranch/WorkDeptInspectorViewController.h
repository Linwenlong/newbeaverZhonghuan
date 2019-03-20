//
//  WorkDeptInspectorViewController.h
//  beaver
//
//  Created by mac on 18/1/19.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, InsperctorWorkType){
    LWLWorkInsperctorTypeAdd = 1,
    LWLWorkInsperctorTypeEdit = 2
} ;

@interface WorkDeptInspectorViewController : BaseViewController

@property (nonatomic, assign)InsperctorWorkType modelType;

@property (nonatomic, strong) NSString *document_id;
@property (nonatomic, strong) NSDictionary *dic;    //查看数组

@property (nonatomic, strong) NSDictionary *dayData;        //日数据
@property (nonatomic, strong) NSDictionary *monthData;      //月数据
@property (nonatomic, strong) NSArray *regionList;     //区域数据


@end
