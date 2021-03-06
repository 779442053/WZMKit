//
//  WZMNewsDataProvider.h
//  APPIcon
//
//  Created by WangZhaomeng on 2017/8/19.
//  Copyright © 2017年 MaoChao Network Co. Ltd. All rights reserved.
//

#import "WZMBaseDataProvider.h"
#import "WZMNewsModel.h"

@interface WZMNewsDataProvider : WZMBaseDataProvider

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray *currentList;

- (instancetype)initWithFileName:(NSString *)fileName;

@end
