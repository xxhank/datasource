//
// XTaskCenter.m
// Runing
//
// Created by wangchao on 15/5/19.
// Copyright (c) 2015年 magic.pocket. All rights reserved.
//

#import "XTaskCenter.h"


@implementation XWorker
- (BOOL)isAsynchronous
{
    return YES;
}

- (void)run
{
}

- (void)cancel
{
}

@end

@interface XTaskWorkerOperation : NSOperation
@end

@interface XTaskWorkerOperation ()<XWorkerObserver>
@property (nonatomic, copy) CompleteBlock complete;
@end

@implementation XTaskWorkerOperation
{
    BOOL     _executing;
    BOOL     _finished;
    XWorker *_worker;

    id       _result;
    NSError *_error;
    NSPort  *_port;
}
- (id)initWithWorker:(XWorker*)woker
            complete:(CompleteBlock)complete
{
    self = [super init];

    if (self)
    {
        _executing       = NO;
        _finished        = NO;
        _worker          = woker;
        _worker.observer = self;
        _complete        = [complete copy];
    }
    return self;
} /* initWithWorker */

- (BOOL)isAsynchronous
{
    return YES;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (BOOL)isFinished
{
    return _finished;
}

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    // If the operation is not canceled, begin executing the task.
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
} /* start */

- (void)main
{
    @try
    {
        if (!_worker)
        {
            return;
        }

        [_worker run];

        if (_worker.asynchronous)
        {
            // waiting for the result
            // Do the main work of the operation here.
            NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
            _port = [NSMachPort port];
            [runLoop addPort:_port forMode:NSDefaultRunLoopMode];

            while (!self.isCancelled && !self.isFinished)
            {
                BOOL shouldKeepRunning = [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                NSLog( @"%@", @(shouldKeepRunning) );
            }

            if (self.isCancelled)
            {
                [_worker cancel];
            }
        }

        NSLog(@"%@ will exit", self);
        // [self completeOperation];
    }
    @catch(...)
    {
        // Do not rethrow exceptions.
    }
} /* main */

- (void)cancel
{
    [super cancel];

    _result = nil;
    _error  = [NSError errorWithDomain:XTaskCenterDomain
                                  code:XTaskCenterTaskCancelled
                              userInfo:nil];
    [self performSelector:@selector(completeOperation)];
}

- (void)completeOperation
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    _executing = NO;
    _finished  = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];

    [_port invalidate];

    if (self.complete)
    {
        self.complete(_result, _error);
    }
} /* completeOperation */

#pragma mark - XWorkerObserver
- (void)workFinishedWithResult:(id)result error:(NSError*)error
{
    _result = result;
    _error  = error;
    [self performSelector:@selector(completeOperation)];
}

@end

@interface XTaskCenter ()
@property (nonatomic, strong) NSOperationQueue *queue;
@end
@implementation XTaskCenter

+ (instancetype)sharedCenter
{
    Class exceptClass = [XTaskCenter class];

    if ([[[self class] superclass] isSubclassOfClass:exceptClass])
    {
        @throw [NSException exceptionWithName:@"call singleton from unexcept class"
                                       reason:@"不要在子类上调用该单例方法"
                                     userInfo:@{@"except class":NSStringFromClass(exceptClass)
                                                , @"actual class":NSStringFromClass([self class])}];
    }

    static id              instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[[exceptClass class] alloc] init];
    });


    return instance;
} /* application */

- (void)fetchDataWithWorker:(XWorker*)worker
                   complete:( CompleteBlock )completeBlock
{
    XTaskWorkerOperation *operation = [[XTaskWorkerOperation alloc] initWithWorker:worker complete:completeBlock];

    [self.queue addOperation:operation];
}

- (NSOperationQueue*)queue
{
    if (!_queue)
    {
        _queue      = [[NSOperationQueue alloc] init];
        _queue.name = self.name;
    }

    return _queue;
}

@end

int const      XTaskCenterTaskCancelled = -10000;
NSString*const XTaskCenterDomain        = @"xtask-center";
