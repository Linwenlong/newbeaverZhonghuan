//
//  WorkBrokerModelViewController.h
//  beaver
//
//  Created by mac on 18/1/17.
//  Copyright © 2018年 eall. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, WorkType){
    LWLWorkTypeAdd = 1,
    LWLWorkTypeEdit = 2
} ;

@interface WorkBrokerModelViewController : BaseViewController


@property (nonatomic, assign)WorkType modelType;

@property (nonatomic, strong) NSString *document_id;

@property (nonatomic, strong) NSDictionary *dic;    

@property (nonatomic, strong) NSDictionary *dayData;    //日数据
@property (nonatomic, strong) NSDictionary *monthData;  //月数据

@end
