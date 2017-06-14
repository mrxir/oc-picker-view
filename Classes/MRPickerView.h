//
//  MRPickerView.h
//  MRPickerView
//
//  Created by 🍉 on 2017/6/12.
//  Copyright © 2017年 🍉. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 日期格式样式

 - MRDateFormatterStyleYear:            components[0] = yyyy年
 - MRDateFormatterStyleYearMonth:       components[0] = yyyy年 components[1] = MM月
 - MRDateFormatterStyleYearMonthDay:    components[0] = yyyy年 components[1] = MM月 components[2] = dd日
 */
typedef NS_ENUM(NSUInteger, MRDateFormatterStyle) {
    MRDateFormatterStyleYear = 0,
    MRDateFormatterStyleYearMonth = 1,
    MRDateFormatterStyleYearMonthDay = 2,
};

typedef void(^MRPickerViewSelectCompletionBlock)(NSInteger row);

typedef void(^MRPickerViewDateSelectCompletionBlock)(NSDate *date, NSDateFormatter *formatter);

@interface MRPickerView : UIView

+ (void)showPickerWithComponents:(NSArray *)components
                selectCompletion:(MRPickerViewSelectCompletionBlock)selectCompletion
               confirmCompletion:(MRPickerViewSelectCompletionBlock)confirmCompletion;

+ (void)showPickerWithDateFormatterStyle:(MRDateFormatterStyle)style
                             minimumDate:(NSDate *)minimumDate
                             maximumDate:(NSDate *)maximumDate
                        selectCompletion:(MRPickerViewDateSelectCompletionBlock)selectCompletion
                       confirmCompletion:(MRPickerViewDateSelectCompletionBlock)confirmCompletion;

+ (void)dismiss;

#pragma mark - SET SELECTED ROW OR DATE METHOD

/**
 设置选中行, 仅在使用 showPickerWithComponents 时有效

 @param row 行数
 @param animated 是否使用动画
 */
+ (void)setSelectedRow:(NSInteger)row animated:(BOOL)animated;

/**
 < ** 暂未实现 ** > 设置选中日期, 仅在使用 showPickerWithDateFormatterStyle 时有效

 @param date 日期
 @param animated 是否使用动画
 */
+ (void)setSelectedDate:(NSDate *)date animated:(BOOL)animated;

/**
 重置选中状态, 默认选中所有 components 的第一行

 @param animated 是否使用动画
 */
+ (void)resetSelectedStatusAnimated:(BOOL)animated;

#pragma mark - ARCHIVE SELECTED STATUS METHOD

/**
 < ** 暂未实现 ** > 保存选中状态

 @param key 该状态所对应的 key, 恢复时需要使用到它
 */
+ (void)rememberSelectedStatusWithKey:(NSString *)key;

/**
 < ** 暂未实现 ** > 恢复选中状态

 @param key 保存选中状态时的 key
 @param animated 是否使用动画
 */
+ (void)recoverSelectedStatusWithKey:(NSString *)key animated:(BOOL)animated;

/**
 < ** 暂未实现 ** > 重置选中状态, 并从归档记录中删除该 key 及保存的状态记录

 @param key 保存选中状态时的 key
 @param animated 是否使用动画
 */
+ (void)resetSelectedStatusWithKey:(NSString *)key animated:(BOOL)animated;

@end

@interface MRPickerView (DateComponents)

+ (NSDate *)dateByAddingUnit:(NSCalendarUnit)unit
                       value:(NSInteger)value
                      toDate:(NSDate *)date;

+ (NSDateComponents *)dateComponentsWithUnit:(NSCalendarUnit)unit
                                    fromDate:(NSDate *)date;

+ (NSDateComponents *)dateComponentsWithUnit:(NSCalendarUnit)unit
                                    fromDate:(NSDate *)startingDate
                                      toDate:(NSDate *)resultDate;

+ (NSRange)rangeOfUnit:(NSCalendarUnit)smaller
                inUnit:(NSCalendarUnit)larger
               forDate:(NSDate *)date;

@end
