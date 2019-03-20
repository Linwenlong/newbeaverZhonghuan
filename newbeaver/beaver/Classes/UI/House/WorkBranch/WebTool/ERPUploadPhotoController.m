//
//  ERPUploadPhotoController.m
//  chowRentAgent
//
//  Created by 凯文马 on 15/11/17.
//  Copyright © 2015年 eallcn. All rights reserved.
//

#import "ERPUploadPhotoController.h"
#import "EBHouse.h"
#import "EBHousePhoto.h"
#import "EBViewFactory.h"
#import "EBBusinessConfig.h"
#import "EBCache.h"
#import "EBAlert.h"
#import "EBController.h"
#import "UIImage+Alpha.h"
#import "MHTextField.h"
#import "EBHousePhotoUploader.h"
#import "EBFilter.h"
#import "RIButtonItem.h"
#import "UIActionSheet+Blocks.h"
#import "UIImageView+AFNetworking.h"
#import "SKImageController.h"
#import "EBHttpClient.h"
#import "IanProgressLoadingView.h"

typedef NS_ENUM(NSInteger , EMHTextFieldEndType)
{
    EMHTextFieldEndTypeEdit = 0,
    EMHTextFieldEndTypeDelete = 1,
};

@interface ERPUploadPhotoController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UITableView *_tableView;
    EBHouse *_house;
    NSMutableArray *_textFields;
    NSMutableArray *_indexLocationSelect;
    BOOL _isLocationEmpty;
    EMHTextFieldEndType _endType;
    NSInteger _deleteRow;
    BOOL _modifyTag;
}
@property (nonatomic, strong) NSMutableArray *uploadPhotos;
@property (nonatomic, strong) IanProgressLoadingView *loadingView;

@end

@implementation ERPUploadPhotoController

- (void)loadView
{
    [super loadView];

    if (_localations == nil)
        _isLocationEmpty = YES;
    else
    {
        if (_localations.count < 1)
            _isLocationEmpty = YES;
        else
            _isLocationEmpty = NO;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:[EBStyle fullScrTableFrame:NO]];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 90;
    [self.view addSubview:_tableView];
    
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [EBStyle screenWidth], 72)];
    [tableHeader addSubview:[EBViewFactory blueButtonWithFrame:CGRectMake(15, 30, 290, 36)
                                                         title:NSLocalizedString(@"house_photo_add_more", nil) target:self
                                                        action:@selector(addMorePhotos)]];
    _tableView.tableHeaderView = tableHeader;
    
    if (_publishTag)
    {
//        "save" = "保存";
        [self addRightNavigationBtnWithTitle:NSLocalizedString(@"save", nil)
                                      target:self action:@selector(finishPhotoEditing)];
    }
    else
    {
//        "toolbar_done" = "完成";
        [self addRightNavigationBtnWithTitle:NSLocalizedString(@"toolbar_done", nil)
                                      target:self action:@selector(finishPhotoEditing)];
    }
//    "photo_desc" = "照片和备注";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_note_close"] style:UIBarButtonItemStyleDone target:self action:@selector(back:)];
    self.title = NSLocalizedString(@"photo_desc", nil);
    _endType = EMHTextFieldEndTypeEdit;
}

- (void)dealloc
{
    
}

#pragma mark - action
- (void)back:(id)sender
{
    if (_publishTag)
    {
        if (_modifyTag)
        {
            [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"confirm_leave_photo_publish", nil)
                                  yes:NSLocalizedString(@"confirm", nil) action:^
             {
                 
                 [self.navigationController popViewControllerAnimated:YES];
             }];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"confirm_leave_photo_upload", nil)
                              yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^
         {
             
             [self.navigationController popViewControllerAnimated:YES];
         }];
    }
}

- (void)finishPhotoEditing
{
    
    [EBTrack event:EVENT_CLICK_HOUSE_UPLOAD];
    
    for (EBHousePhoto *photo in _uploadPhotos) {
        if (!photo.locationDesc) {
            [EBAlert alertError:@"请填写完整信息"];
            return;
        }
    }
    
    NSArray *temp = [[_uploadPhotos reverseObjectEnumerator] allObjects];
    [_uploadPhotos removeAllObjects];
    [self uploadImageAtLast:temp];
}

- (void)uploadImageAtLast:(NSArray *)images
{
    if (!images.count) {
//        [self.loadingView removeFromSuperview];
        if (_getUpLoadPhotoBlock)
        {
            self.getUpLoadPhotoBlock(_uploadPhotos);
        }
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        if (!self.loadingView) {
//            self.loadingView = [[IanProgressLoadingView alloc] initProgressView];
//            [self.view addSubview:self.loadingView];
        }
        __block EBHousePhoto *photo = images.lastObject;
        NSMutableArray *temp = [images mutableCopy];
        [temp removeLastObject];
        __block NSArray *leftPhotos = [temp copy];
        __weak __typeof(self) weakSelf = self;
        [[EBHttpClient sharedInstance] dataRequest:nil uploadImage:[self imageWithImageRef:photo.thumbnail] withHandler:^(BOOL success, id result){
            __strong __typeof(self) safeSelf = weakSelf;
            if (success) {
                photo.remoteUrl = result[@"url"];
                [safeSelf.uploadPhotos addObject:photo];
            }
            [safeSelf uploadImageAtLast:leftPhotos];
        }];
    }
}

- (UIImage *)imageWithImageRef:(CGImageRef)imageRef
{
    CGFloat factor = _maxWidth / CGImageGetWidth(imageRef) >= 1 ? 1 : _maxWidth / CGImageGetWidth(imageRef);
    return [UIImage imageWithCGImage:imageRef scale:factor orientation:UIImageOrientationUp];
}

- (void)addMorePhotos
{
    _modifyTag = YES; //改成img_num
    if (!_publishTag && _house.image_num + _uploadPhotos.count >= _selectCount)
    {
        NSString *title = nil;
        if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)) {
            if (title == nil) {
                title = @"";
            }
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:@"图片量已达到最大值，无法继续添加" delegate:self cancelButtonTitle:NSLocalizedString(@"anonymous_call_end_confirm", nil) otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        if (_publishTag && _uploadPhotos.count > _selectCount) {
            [EBAlert alertError:[NSString stringWithFormat:@"最多选择%lu张",(unsigned long)_selectCount]];
            return;
        }
        
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        NSString *format = nil;
        for (int i = 0; i < 2; i++)
        {
            format = [NSString stringWithFormat:@"upload_select_%d", i];
            [buttons addObject:[RIButtonItem itemWithLabel:NSLocalizedString(format, nil)
                                                    action:^
                                {
                                    if (i == 0)
                                    {
                                        [[EBController sharedInstance] pickImageWithUrlSourceTypeEx:UIImagePickerControllerSourceTypeCamera curentViewController:self handler:^(UIImage *image, NSURL *url)
                                         {
                                             [self dismissViewControllerAnimated:YES completion:nil];
                                             [self addCameraPhotosForUploading:image url:url];
                                             [_tableView reloadData];
                                         }];
                                    }
                                    else
                                    {
                                        NSUInteger maxNums = 0;
                                        if (_publishTag) {
                                            maxNums = _selectCount - _uploadPhotos.count;
                                        } else {
                                            //改成img_num
                                            maxNums = _selectCount - _house.image_num - _uploadPhotos.count;
                                        }
                                        [SKImageController showMutlSelectPhotoFrom:self maxSelect:maxNums select:^(NSArray *info) {
                                            [self addPhotosForUploading:info];
                                            [_tableView reloadData];
                                        }];
                                        
                                        //                                        AGImagePickerController *pickerController = [[AGImagePickerController alloc] initWithFailureBlock:^(NSError *error)
                                        //                                                                                     {
                                        //                                                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                        //                                                                                     } andSuccessBlock:^(NSArray *info)
                                        //                                                                                     {
                                        //                                                                                         [self dismissViewControllerAnimated:YES completion:nil];
                                        //                                                                                         [self addPhotosForUploading:info];
                                        //                                                                                         [_tableView reloadData];
                                        //                                                                                     } maximumNumberOfPhotosToBeSelected:maxNums];
                                        //
                                        //                                        [self presentViewController:pickerController animated:YES completion:nil];
                                    }
                                }]];
        }
        [[[UIActionSheet alloc] initWithTitle:nil buttons:buttons] showInView:self.view];
    }
}

- (void)uploadPhotos:(NSArray *)photos forHouse:(EBHouse *)house getUpLoadPhotoBlock:(id)retuenUpLoadPhotoBlock
{
    _house = house;
    _uploadPhotos = [[NSMutableArray alloc] init];
    _indexLocationSelect = [[NSMutableArray alloc] init];
    [self addPhotosForUploading:photos];
    self.getUpLoadPhotoBlock = retuenUpLoadPhotoBlock;
}

- (void)addPhotosForUploading:(NSArray *)photoInput
{
    if (!photoInput || photoInput.count == 0) {
        return;
    }
    
    if (!_publishTag)
    {
        for (ALAsset *asset in photoInput)
        {
            if (![self isAdded:[asset.defaultRepresentation url]])
            {
                EBHousePhoto *photo = [[EBHousePhoto alloc] init];
                photo.localUrl = [asset.defaultRepresentation url];
                photo.houseId = _house.id;
                photo.houseType = [EBFilter typeString:_house.rentalState];
                photo.thumbnail = CGImageRetain(asset.thumbnail);
                photo.status = EPhotoAddStatusWaiting;
                photo.publishTag = NO;
                [_uploadPhotos addObject:photo];
                [_indexLocationSelect addObject:@(-1)];
            }
        }
    }
    else
    {
        for (id url in photoInput)
        {
            EBHousePhoto *photo = [[EBHousePhoto alloc] init];
            //            photo.localUrl = url;
            photo.houseId = _house.id;
            photo.houseType = [EBFilter typeString:_house.rentalState];
            photo.status = EPhotoAddStatusWaiting;
            photo.publishTag = YES;
            if ([url isKindOfClass:NSURL.class]) {
                photo.localUrl = url;
            } else if ([url isKindOfClass:ALAsset.class]) {
                if (![self isAdded:[[(ALAsset *)url defaultRepresentation] url]]) {
                    photo.localUrl = [[(ALAsset *)url defaultRepresentation] url];
                    photo.thumbnail = CGImageRetain([(ALAsset *)url thumbnail]);
                }
            }
            [_uploadPhotos addObject:photo];
            [_indexLocationSelect addObject:@(-1)];
        }
    }
}

- (void)uploadCameraPhotos:(UIImage *)cameraPhoto url:(NSURL *)url forHouse:(EBHouse *)house getUpLoadPhotoBlock:retuenUpLoadPhotoBlock
{
    _house = house;
    _uploadPhotos = [[NSMutableArray alloc] init];
    _indexLocationSelect = [[NSMutableArray alloc] init];
    [self addCameraPhotosForUploading:cameraPhoto url:url];
    self.getUpLoadPhotoBlock = retuenUpLoadPhotoBlock;
}

- (void)addCameraPhotosForUploading:(UIImage *)cameraPhoto url:(NSURL *)url
{
    EBHousePhoto *photo = [[EBHousePhoto alloc] init];
    photo.localUrl = url;
    photo.houseId = _house.id;
    photo.houseType = [EBFilter typeString:_house.rentalState];
    photo.thumbnail = CGImageRetain(cameraPhoto.CGImage);
    photo.status = EPhotoAddStatusWaiting;
    [_uploadPhotos addObject:photo];
    [_indexLocationSelect addObject:@(-1)];
}

- (BOOL)isAdded:(NSURL*)url
{
    NSString *strNew=[url absoluteString];
    NSString *temp = nil;
    NSInteger count = [_uploadPhotos count];
    int i = 0;
    for (i = 0; i < count; i ++)
    {
        EBHousePhoto * photo = (EBHousePhoto*)_uploadPhotos[i];
        temp = [photo.localUrl absoluteString];
        if ([strNew compare:temp] == NSOrderedSame)
        {
            return YES;
        }
    }
    return  NO;
}

- (BOOL)shouldPopOnBack
{
    [EBAlert confirmWithTitle:nil message:NSLocalizedString(@"confirm_leave_photo_upload", nil)
                          yes:NSLocalizedString(@"confirm_leave_condition_give_up", nil) action:^
     {
         [self.navigationController popViewControllerAnimated:YES];
     }];
    
    return NO;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _uploadPhotos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    EBHousePhoto *photo = (EBHousePhoto*)_uploadPhotos[row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uploadPhotoCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"uploadPhotoCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 36, 64, 64)];
        imageView.tag = 600;
        [cell.contentView addSubview:imageView];
        
        UIImage *image = [UIImage imageNamed:@"red_delete"];
        UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 16, 40, 40)];
        [deleteBtn setImage:image forState:UIControlStateNormal];
        [deleteBtn setImage:[image imageByApplyingAlpha:0.4] forState:UIControlStateHighlighted];
        deleteBtn.tag = 700;
        [deleteBtn addTarget:self action:@selector(deletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteBtn];
        if (!_isLocationEmpty)
        {
            [self addLine:cell.contentView xOffset:94.0 yOffset:99.5];
            [self addLine:cell.contentView xOffset:94.0 yOffset:55.5];
            
            UIButton *selectLocBtn = [self createIconBt:CGRectMake(94, 20, 226, 26) title:NSLocalizedString(@"location", nil)
                                                   text:photo.locationDesc];
            selectLocBtn.tag = 800;
            [cell.contentView addSubview:selectLocBtn];
            
            MHTextField *noteView = [[MHTextField alloc] initWithFrame:CGRectMake(94, 70, 226, 20)];
            noteView.textColor = [EBStyle blackTextColor];
            noteView.tag = 900;
            noteView.returnKeyType = UIReturnKeyDone;
            noteView.font = [UIFont systemFontOfSize:14.0];
            noteView.scrollView = tableView;
            noteView.hideToolBar = YES;
            noteView.textColor = [EBStyle blackTextColor];
            noteView.placeholderColor = [EBStyle grayTextColor];
            noteView.placeholder = NSLocalizedString(@"note", nil);
            [cell.contentView addSubview:noteView];
            noteView.delegate = self;
            [self pushTextField:noteView];
        }
        
    }
    
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:600];
    if (imageView)
    {
        //        if (photo.publishTag)
        //        {
        //            [imageView setImageWithURL:photo.localUrl placeholderImage:nil];
        //        }
        //        else
        //        {
        //            imageView.image = [UIImage imageWithCGImage:photo.thumbnail];
        //        }
        if ([[photo.localUrl absoluteString] hasPrefix:@"assets"]) {
            if (!photo.thumbnail) {
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                [assetsLibrary assetForURL:photo.localUrl resultBlock:^(ALAsset *asset) {
                    photo.thumbnail = asset.thumbnail;
                    imageView.image = [UIImage imageWithCGImage:photo.thumbnail];
                } failureBlock:^(NSError *error) {
                    
                }];
            } else {
                imageView.image = [UIImage imageWithCGImage:photo.thumbnail];
            }
        } else {
            [imageView setImageWithURL:photo.localUrl placeholderImage:nil];
        }
    }
    
    UILabel *locLabel = (UILabel*)[[cell.contentView viewWithTag:800] viewWithTag:901];
    if (locLabel)
    {
        if (photo.locationDesc == nil)
        {
            locLabel.textColor = [EBStyle grayTextColor];
            locLabel.text = NSLocalizedString(@"house_photo_add_location", nil);
        }
        else
        {
            if (photo.locationDesc.length < 1)
            {
                locLabel.textColor = [EBStyle grayTextColor];
                locLabel.text = NSLocalizedString(@"house_photo_add_location", nil);
            }
            else
            {
                locLabel.textColor = [EBStyle blueTextColor];
                locLabel.text = photo.locationDesc;
            }
        }
    }
    
    MHTextField *noteView = (MHTextField *)[cell.contentView viewWithTag:900];
    if (noteView)
    {
        noteView.text = photo.note;
    }
    noteView.userInteractionEnabled = _memoEnable;
    cell.contentView.tag = row;
    
    return cell;
}

#pragma mark tool

- (void)addLine:(UIView *)parent xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, [EBStyle screenWidth] - xOffset, 0.5)];
    line.backgroundColor = [EBStyle grayClickLineColor];
    [parent addSubview:line];
}

- (UIButton*)createIconBt:(CGRect)frame title:(NSString*)title text:(NSString*)text
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn addTarget:self action:@selector(selectLocation:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    titleLabel.textColor = [EBStyle blackTextColor];
    titleLabel.text = title;
    [btn addSubview:titleLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue_accessory"]];
    imageView.frame = CGRectOffset(imageView.frame, btn.frame.size.width - imageView.frame.size.width - 10, (btn.frame.size.height - imageView.frame.size.height) / 2);
    [btn addSubview:imageView];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn.frame.size.width - imageView.frame.size.width - 15, btn.frame.size.height)];
    textLabel.tag = 901;
    textLabel.textAlignment = NSTextAlignmentRight;
    textLabel.font = [UIFont systemFontOfSize:14.0];
    textLabel.textColor = [EBStyle grayTextColor];
    textLabel.text = text;
    [btn addSubview:textLabel];
    
    return btn;
}

//删除选中的图片
- (void)deletePhoto:(UIButton*)btn
{
    _modifyTag = YES;
    NSInteger row = btn.superview.tag;
    _deleteRow = row;
    NSInteger count = [_tableView numberOfRowsInSection:0];
    for (int i = 0; i < count; i ++)
    {
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (cell)
        {
            MHTextField *noteView = (MHTextField *)[cell.contentView viewWithTag:900];
            if (noteView)
            {
                if ([noteView isFirstResponder])
                {
                    _endType = EMHTextFieldEndTypeDelete;
                }
            }
        }
    }
    
    [_uploadPhotos removeObjectAtIndex:row];
    [_indexLocationSelect removeObjectAtIndex:row];
    //    [_tableView reloadData];
    [_tableView reloadSections:[[NSIndexSet alloc] initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)selectLocation:(UIButton*)btn
{
    _modifyTag = YES;
    NSInteger row = btn.superview.tag;
    EBHousePhoto *photo = (EBHousePhoto*)_uploadPhotos[row];

    [[EBController sharedInstance] promptChoices:_localations
                                      withChoice:[_indexLocationSelect[row] integerValue] title:NSLocalizedString(@"house_photo_add_location", nil)
                                          header:nil
                                          footer:nil completion:^(NSInteger rightChoice)
     {
         photo.locationDesc = _localations[rightChoice];
         NSNumber *num = [NSNumber numberWithInteger:rightChoice];
         _indexLocationSelect[row] = num;
         //         if (photo.note)
         //         {
         //             if (photo.note.length < 1)
         //             {
         //                 photo.note = locations[rightChoice];
         //             }
         //         }
         //         else
         //         {
         //             photo.note = locations[rightChoice];
         //         }
         [_tableView reloadData];
     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    for (MHTextField *field in _textFields)
    {
        [field resignFirstResponder];
    }
    
    _tableView.contentOffset = CGPointMake(0, 0);
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger index = textField.superview.tag;
    if (_endType == EMHTextFieldEndTypeEdit)
    {
        
        EBHousePhoto *photo = _uploadPhotos[index];
        photo.note = textField.text;
    }
    else
    {
        _endType = EMHTextFieldEndTypeEdit;
        if (_deleteRow < index)
        {
            if (index + 1 < _uploadPhotos.count)
            {
                EBHousePhoto *photo = _uploadPhotos[index + 1];
                photo.note = textField.text;
            }
        }
        else if (_deleteRow > index)
        {
            EBHousePhoto *photo = _uploadPhotos[index];
            photo.note = textField.text;
        }
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self.keyboardWillHideNotificationObserver];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _modifyTag = YES;
    [self setKeyboardWillHideNotificationObserver:[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *notification){
        [self keyboardWillHide:notification];
    }]];
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    UITextField *textField;
//    [textField resignFirstResponder];
//}

- (void)pushTextField:(MHTextField *)textField
{
    if (_textFields == nil)
    {
        _textFields = [[NSMutableArray alloc] init];
    }
    
    [_textFields addObject:textField];
    textField.textFields = _textFields;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //    CGRect currentFrame = [self convertRect:self.bounds toView:superScrollview];
    //    CGRect originFrame = _tableView.frame;
    //    CGFloat height;
    //    CGFloat contenFloat;
    //    if (_tableView.contentSize.height < originFrame.size.height) {
    //        contenFloat = originFrame.size.height;
    //    }
    //    else
    //    {
    //        contenFloat = _tableView.contentSize.height;
    //    }
    //    
    //    if (contenFloat - _tableView.contentOffset.y > originFrame.size.height)
    //    {
    //        height = _tableView.contentOffset.y;
    //    }
    //    else
    //    {
    //        height = contenFloat - originFrame.size.height;
    //    }
    //    [_tableView setContentOffset:CGPointMake(0, height) animated:YES];
}



@end
