//
//  AGIPCGridCell.h
//  AGImagePickerController
//
//  Created by Artur Grigor on 17.02.2012.
//  Copyright (c) 2012 - 2013 Artur Grigor. All rights reserved.
//  
//  For the full copyright and license information, please view the LICENSE
//  file that was distributed with this source code.
//  

#import <UIKit/UIKit.h>

#import "AGImagePickerController.h"
#import "AGIPCAssetsController.h"

@interface AGIPCGridCell : UITableViewCell <AGIPCGridItemDelegate>

@property (strong) NSArray *items;
@property (ag_weak) AGImagePickerController *imagePickerController;
@property (ag_weak) AGIPCAssetsController *assetsController;

- (id)initWithImagePickerController:(AGImagePickerController *)imagePickerController assetsController:(AGIPCAssetsController *)assetsController items:(NSArray *)items andReuseIdentifier:(NSString *)identifier;

@end
