//
// ViewController.m
// Runing
//
// Created by wangchao on 15/5/19.
// Copyright (c) 2015年 magic.pocket. All rights reserved.
//

#import "ViewController.h"
#import "XTaskCenter.h"
#import "TimerWorker.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startTask:(id)sender
{
    [[XTaskCenter sharedCenter] fetchDataWithWorker:[[TimerWorker alloc] initWithWorkAmount:10 name:@"wangchao"] complete: ^(id result, NSError *error) {
        if (error)
        {
            NSLog(@"error:%@", error);
        }
        else
        {
            NSLog(@"result: %@", result);
        }
    }];
} /* startTask */

- (IBAction)cancelTask:(id)sender
{
}

@end
