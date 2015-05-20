//
// TimerWorker.m
// Runing
//
// Created by wangchao on 15/5/19.
// Copyright (c) 2015年 magic.pocket. All rights reserved.
//

#import "TimerWorker.h"

@implementation TimerWorker
{
    int      _amount;
    NSTimer *_timer;
}

- (instancetype)initWithWorkAmount:(int)amount name:(NSString*)name
{
    self = [super init];

    if (self)
    {
        _amount = amount;
        _name   = name;
    }
    return self;
}

- (void)run
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:.5
                                              target:self
                                            selector:@selector(workAtCompany:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)cancel
{
    if ([_timer isValid])
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)workAtCompany:(id)sender
{
    if (_amount == 0)
    {
        [self.observer workFinishedWithResult:@"100%" error:nil];
        [self cancel];
    }
    else
    {
        NSLog(@"%@ is working...", self.name);
        _amount--;
    }
} /* workAtCompany */

@end
