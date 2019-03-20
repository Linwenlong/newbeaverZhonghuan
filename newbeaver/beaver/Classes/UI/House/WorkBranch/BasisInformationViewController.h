//
//  BasisInformationViewController.h
//  beaver
//
//  Created by mac on 17/12/19.
//  Copyright © 2017年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "CKSlideMenu.h"

@interface BasisInformationViewController : BaseViewController

@property (nonatomic, strong)NSNumber * deal_id;//合同id
@property (nonatomic, strong)NSString * deal_code;//合同code
@property (nonatomic, weak)CKSlideMenu *slideMenu;

@end
