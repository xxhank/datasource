//
// TimerWorker.h
// Runing
//
// Created by wangchao on 15/5/19.
// Copyright (c) 2015年 magic.pocket. All rights reserved.
//

#import "XTaskCenter.h"

@interface TimerWorker : XWorker
@property (nonatomic, strong) NSString *name;
- (instancetype)initWithWorkAmount:(int)amount
                              name:(NSString*)name NS_DESIGNATED_INITIALIZER;
@end
