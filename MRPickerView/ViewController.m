//
//  ViewController.m
//  MRPickerView
//
//  Created by 🍉 on 2017/6/12.
//  Copyright © 2017年 🍉. All rights reserved.
//

#import "ViewController.h"

#import "MRPickerView.h"

@interface ViewController ()

- (IBAction)didClickDateSelectButton:(UIButton *)button;

@end

@implementation ViewController

- (void)didClickDateSelectButton:(UIButton *)button
{
    NSArray *dates = @[@"2017年06月12日",
                       @"2017年06月13日",
                       @"2017年06月14日",
                       @"2017年06月15日",
                       @"2017年06月16日"];
    
    [MRPickerView showPickerWithComponents:dates defaultSelectedRow:2 selectCompletion:^(NSInteger row) {
        
        NSLog(@"row %d", (unsigned)row);
        
    }];
    
}

@end
