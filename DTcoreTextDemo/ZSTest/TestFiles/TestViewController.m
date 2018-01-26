//
//  TestViewController.m
//  Test
//
//  Created by zhoushuai on 16/3/7.
//  Copyright © 2016年 zhoushuai. All rights reserved.
//


#import "TestViewController.h"
#import "TestCoreTextLabelController.h"
#import "TestCoreTextViewController.h"
#import "TestTableViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"测试";
}


#pragma mark - Respond To Events
- (IBAction)TestDTcoreTextBtnClick:(UIButton *)sender {
    switch (sender.tag - 100) {
        case 1:{

            TestCoreTextLabelController *testCoreTextLabelVC = [[TestCoreTextLabelController alloc] init];
            [self.navigationController pushViewController:testCoreTextLabelVC animated:YES];
            break;
        }
        case 2:{
            TestCoreTextViewController *testCoreTextViewVC = [[TestCoreTextViewController alloc] init];
            [self.navigationController pushViewController:testCoreTextViewVC animated:YES];
            break;
        }
        case 3:{
            TestTableViewController *testTabelVC = [[TestTableViewController alloc] init];
            [self.navigationController pushViewController:testTabelVC animated:YES];
            break;
        }
        default:
            break;
    }
}


@end
