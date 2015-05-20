//
// XTaskCenter.h
// Runing
//
// Created by wangchao on 15/5/19.
// Copyright (c) 2015年 magic.pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompleteBlock)( id result, NSError *error );

@protocol XWorkerObserver <NSObject>
- (void)workFinishedWithResult:(id)result error:(NSError*)error;
@end

@interface XWorker : NSObject
@property (nonatomic, assign, getter = isAsynchronous) BOOL asynchronous;
@property (nonatomic, weak) id<XWorkerObserver>             observer;
- (void)run;
- (void)cancel;
@end


extern int const      XTaskCenterTaskCancelled;
extern NSString*const XTaskCenterDomain;

@interface XTaskCenter : NSObject
@property (nonatomic, strong) NSString *name;
+ (instancetype)sharedCenter;
- (void)fetchDataWithWorker:(XWorker*)worker
                   complete:( CompleteBlock )completeBlock;
@end
