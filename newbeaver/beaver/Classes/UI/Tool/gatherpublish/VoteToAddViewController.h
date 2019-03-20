//
//  VoteToAddViewController.h
//  beaver
//
//  Created by ChenYing on 14-8-31.
//  Copyright (c) 2014年 eall. All rights reserved.
//

#import "BaseViewController.h"
#import "EBBaseModel.h"
#import "EBPagedDataSource.h"

typedef NS_ENUM(NSInteger , EVoteType)
{
    EVoteTypeAddSource = 0,
    EVoteTypeAddPort = 1,
};

@interface EBVote : EBBaseModel

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *voteCount;
@property (nonatomic, assign) BOOL voted;

@end

@interface EBVoteDataSource : EBPagedDataSource

@property (nonatomic, copy) void(^voteBlock)();

@end

@interface VoteToAddViewController : BaseViewController

@property (nonatomic, assign) EVoteType voteType;

@end
