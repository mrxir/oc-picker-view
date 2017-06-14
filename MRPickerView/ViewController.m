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
- (IBAction)didClickYearSelectButton:(UIButton *)button;

@end

@implementation ViewController

- (void)didClickYearSelectButton:(UIButton *)button
{
    NSArray *dates = @[@"2013年",
                       @"2016年",
                       @"2048年"];
    
    [MRPickerView showPickerWithComponents:dates
                          selectCompletion:^(NSInteger row) {
                              
                              NSLog(@"选择了 %d 行", (unsigned)row);
                              
                          } confirmCompletion:^(NSInteger row) {
                              
                              NSLog(@"确定了 %d 行", (unsigned)row);
                              
                          }];
    
    [MRPickerView setSelectedRow:5 animated:YES];
}

- (void)didClickDateSelectButton:(UIButton *)button
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    
    NSDate *miniDate = [dateFormatter dateFromString:@"2014"];
    NSDate *maxiDate = [NSDate date];
    
    [MRPickerView showPickerWithDateFormatterStyle:MRDateFormatterStyleYearMonthDay
                                       minimumDate:miniDate
                                       maximumDate:maxiDate
                                  selectCompletion:^(NSDate *date, NSDateFormatter *formatter) {
                                      
                                      NSLog(@"选中了日期: %@", [formatter stringFromDate:date]);
                                      
                                  } confirmCompletion:^(NSDate *date, NSDateFormatter *formatter) {
                                      
                                      NSLog(@"确认了日期: %@", [formatter stringFromDate:date]);
                                      
                                  }];
}

@end
