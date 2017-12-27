//
//  ViewController.m
//  MRPickerView
//
//  Created by 🍉 on 2017/6/12.
//  Copyright © 2017年 🍉. All rights reserved.
//

#import "ViewController.h"

#import "MRPickerView.h"

@implementation ViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        [self showDatePickerWithDatasourceArray];
    } else if (indexPath.row == 1) {
        [self showSingleRangeDatePicker];
    } else if (indexPath.row == 2) {
        [self showDoubleRangeDatePicker];
    }
}

- (void)showDatePickerWithDatasourceArray
{
    NSArray *dates = @[@"2013年",
                       @"2016年",
                       @"2048年"];
    
    [MRPickerView showPickerWithArray:dates
                     selectCompletion:^(NSInteger row) {
                         
                         NSLog(@"选择了 %d 行", (unsigned)row);
                         
                     } confirmCompletion:^(NSInteger row) {
                         
                         NSLog(@"确定了 %d 行", (unsigned)row);
                         
                     }];
    
    [MRPickerView setSelectedRow:1 animated:YES];
}

- (void)showSingleRangeDatePicker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy";
    
    NSDate *miniDate = [dateFormatter dateFromString:@"2014"];
    NSDate *maxiDate = [NSDate date];
    
    [MRPickerView showPickerWithDateFormatterStyle:MRDateFormatterStyleYearMonthDay
                                       minimumDate:miniDate
                                       maximumDate:maxiDate
                                  selectCompletion:^(NSDate *date) {
                                      
                                      NSLog(@"选中了日期: %@", [formatter stringFromDate:date]);
                                      
                                  } confirmCompletion:^(NSDate *date) {
                                      
                                      NSLog(@"确认了日期: %@", [formatter stringFromDate:date]);
                                      
                                  }];
    
    [MRPickerView setSelectedDate:[NSDate date] animated:YES];
}

- (void)showDoubleRangeDatePicker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy/MM/dd";
    
    NSDate *beginMinimumDate = [dateFormatter dateFromString:@"2017/11/11"];
    NSDate *beginMaximumDate = [NSDate date];
    
    NSDate *endMinimumDate = [dateFormatter dateFromString:@"2017/12/12"];
    NSDate *endMaximumDate = [dateFormatter dateFromString:@"2017/12/30"];
    
    [MRPickerView showPickerWithDateFormatter:formatter
                             beginMinimumDate:beginMinimumDate
                             beginMaximumDate:beginMaximumDate
                               endMinimumDate:endMinimumDate
                               endMaximumDate:endMaximumDate
                                       offset:0
                             selectCompletion:^(NSDate *beginDate, NSDate *endDate, NSInteger offset) {
                                 NSLog(@"选中了开始日期: %@ 结束日期: %@ 相隔天数: %d", [formatter stringFromDate:beginDate], [formatter stringFromDate:endDate], (unsigned)offset);
                             } confirmCompletion:^(NSDate *beginDate, NSDate *endDate, NSInteger offset) {
                                 NSLog(@"确认了开始日期: %@ 结束日期: %@ 相隔天数: %d", [formatter stringFromDate:beginDate], [formatter stringFromDate:endDate], (unsigned)offset);
                             }];
    
    [MRPickerView setSelectedBeginDate:[dateFormatter dateFromString:@"2017/11/15"] endDate:[dateFormatter dateFromString:@"2017/12/12"] animated:YES];
}



@end
