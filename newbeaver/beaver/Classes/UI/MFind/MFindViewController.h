//
//  MFindViewController.h
//  beaver
//  发现
//  Created by zhaoyao on 15/12/16.
//  Copyright © 2015年 eall. All rights reserved.
//

#import "BaseViewController.h"

@interface MFindViewController : BaseViewController

@end

@interface foundItem : NSObject
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *des;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSNumber *tips;

+ (instancetype)itemWithImg:(NSString *)img title:(NSString *)title subInfo:(NSString *)info;

@end


@interface EBFindCell : UITableViewCell
@property (nonatomic, strong)foundItem *items;
+ (EBFindCell *)cellWithTableview:(UITableView *)tableview withItem:(foundItem *)it;
@end