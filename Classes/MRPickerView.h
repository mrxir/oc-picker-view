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

typedef void(^MRPickerViewDateSigleRangeSelectCompletionBlock)(NSDate *date);

typedef void(^MRPickerViewDateDoubleRangeSelectCompletionBlock)(NSDate *beginDate, NSDate *endDate, NSInteger offset);

typedef void(^MRPickerViewCancelCompletionBlock)(void);

@interface MRPickerView : UIView

/** 使用数组填充选择器，实质上与日期无关。 */
+ (void)showPickerWithArray:(NSArray *)array
           selectCompletion:(MRPickerViewSelectCompletionBlock)selectCompletion
          confirmCompletion:(MRPickerViewSelectCompletionBlock)confirmCompletion;

+ (void)setSelectedRow:(NSInteger)row animated:(BOOL)animated;


/** 使用单个日期约束构建选择控件，style 样式决定 components 数 */
+ (void)showPickerWithDateFormatterStyle:(MRDateFormatterStyle)style
                             minimumDate:(NSDate *)minimumDate
                             maximumDate:(NSDate *)maximumDate
                        selectCompletion:(MRPickerViewDateSigleRangeSelectCompletionBlock)selectCompletion
                       confirmCompletion:(MRPickerViewDateSigleRangeSelectCompletionBlock)confirmCompletion;

+ (void)setSelectedDate:(NSDate *)date animated:(BOOL)animated;

/** 使用成对的日期约束构建选择控件，components 数固定为 2，style 样式仅决定每个 component 中的显示样式
 *  当 offset!=0 时忽略 endMinimumDate 和 endMaximumDate 参数，由 beginMinimumDate，beginMaximumDate 和 offset 计算而成
 *  offset 单位为天
 */
+ (void)showPickerWithDateFormatter:(NSDateFormatter *)dateFormatter
                   beginMinimumDate:(NSDate *)beginMinimumDate
                   beginMaximumDate:(NSDate *)beginMaximumDate
                     endMinimumDate:(NSDate *)endMinimumDate
                     endMaximumDate:(NSDate *)endMaximumDate
                             offset:(NSInteger)offset
                   selectCompletion:(MRPickerViewDateDoubleRangeSelectCompletionBlock)selectCompletion
                  confirmCompletion:(MRPickerViewDateDoubleRangeSelectCompletionBlock)confirmCompletion;

+ (void)setSelectedBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate animated:(BOOL)animated;

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
//+ (void)rememberSelectedStatusWithKey:(NSString *)key;

/**
 < ** 暂未实现 ** > 恢复选中状态

 @param key 保存选中状态时的 key
 @param animated 是否使用动画
 */
//+ (void)recoverSelectedStatusWithKey:(NSString *)key animated:(BOOL)animated;

/**
 < ** 暂未实现 ** > 重置选中状态, 并从归档记录中删除该 key 及保存的状态记录

 @param key 保存选中状态时的 key
 @param animated 是否使用动画
 */
//+ (void)resetSelectedStatusWithKey:(NSString *)key animated:(BOOL)animated;

+ (void)cancel:(MRPickerViewCancelCompletionBlock)cancelCompletionBlock;

+ (void)dismiss;

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
