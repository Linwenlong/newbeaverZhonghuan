//
//  FollowupTableViewCell.h
//  beaver
//
//  Created by mac on 17/6/21.
//  Copyright © 2017年 eall. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FolowupModel.h"

@interface FollowupTableViewCell : UITableViewCell

@property (nonatomic, strong) void (^btnBack) (NSString *custom_string,NSString *house_title,NSString *document_id,NSString *house_id);

@property (nonatomic, strong)FolowupModel *model;

@end
