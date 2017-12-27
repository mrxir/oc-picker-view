//
//  MRPickerView.m
//  MRPickerView
//
//  Created by 🍉 on 2017/6/12.
//  Copyright © 2017年 🍉. All rights reserved.
//

#import "MRPickerView.h"

/**
 数据源类型

 - MRPickerDataSourceTypeArray: 数据源为数组
 - MRPickerDataSourceTypeSingleDateRange: 根据一个日期范围构建日期控件
 - MRPickerDataSourceTypeDoubleDateRange: 根据一对日期控件构建日期控件

 */
typedef NS_ENUM(NSUInteger, MRPickerDataSourceType) {
    MRPickerDataSourceTypeArray,
    MRPickerDataSourceTypeSingleDateRange,
    MRPickerDataSourceTypeDoubleDateRange,
};

@interface MRPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL _isAnimating;
    
    CGAffineTransform _originalTransform;
    
    BOOL _isInitializing;
}

// public >>
@property (nonatomic, assign) MRPickerDataSourceType dataSourceType;
@property (nonatomic, assign) MRDateFormatterStyle dateFormatterStyle;
@property (nonatomic, assign) NSUInteger componentCount;
// public <<


// 用于 MRPickerDataSourceTypeArray >>
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) MRPickerViewSelectCompletionBlock dataSelectCompletion;
@property (nonatomic, strong) MRPickerViewSelectCompletionBlock dataConfirmCompletion;
// MRPickerDataSourceTypeArray <<


// 用于 MRPickerDataSourceTypeSingleDateRange >>
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, strong) MRPickerViewDateSigleRangeSelectCompletionBlock singleRangeSelectCompletion;
@property (nonatomic, strong) MRPickerViewDateSigleRangeSelectCompletionBlock singleRangeConfirmCompletion;
// MRPickerDataSourceTypeSingleDateRange <<


// 用于 MRPickerDataSourceTypeSingleDateRangeFixed2Components >>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *beginMinimumDate;
@property (nonatomic, strong) NSDate *beginMaximumDate;
@property (nonatomic, strong) NSDate *endMinimumDate;
@property (nonatomic, strong) NSDate *endMaximumDate;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, strong) MRPickerViewDateDoubleRangeSelectCompletionBlock doubleRangeSelectCompletion;
@property (nonatomic, strong) MRPickerViewDateDoubleRangeSelectCompletionBlock doubleRangeConfirmCompletion;
// MRPickerDataSourceTypeSingleDateRangeFixed2Components <<





@property (nonatomic, strong) IBOutlet UIView *view;

@property (nonatomic, strong) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) IBOutlet UIView *pickerContentView;

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;

@property (nonatomic, strong) IBOutlet UIView *buttonContentView;

@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) IBOutlet UIButton *confirmButton;

@end

@implementation MRPickerView

#pragma mark - PUBLIC METHOD

+ (void)showPickerWithArray:(NSArray *)array
           selectCompletion:(MRPickerViewSelectCompletionBlock)selectCompletion
          confirmCompletion:(MRPickerViewSelectCompletionBlock)confirmCompletion
{
    MRPickerView *pickerView = [MRPickerView sharedView];
    pickerView.dataSourceType = MRPickerDataSourceTypeArray;
    pickerView.array = array;
    pickerView.componentCount = 1;
    pickerView.dataSelectCompletion = selectCompletion;
    pickerView.dataConfirmCompletion = confirmCompletion;
    [pickerView.cancelButton addTarget:pickerView action:@selector(didClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView.confirmButton addTarget:pickerView action:@selector(didClickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView show];
}

+ (void)showPickerWithDateFormatterStyle:(MRDateFormatterStyle)style
                             minimumDate:(NSDate *)minimumDate
                             maximumDate:(NSDate *)maximumDate
                        selectCompletion:(MRPickerViewDateSigleRangeSelectCompletionBlock)selectCompletion
                       confirmCompletion:(MRPickerViewDateSigleRangeSelectCompletionBlock)confirmCompletion
{
    MRPickerView *pickerView = [MRPickerView sharedView];
    pickerView.dataSourceType = MRPickerDataSourceTypeSingleDateRange;
    pickerView.dateFormatterStyle = style;
    pickerView.componentCount = style+1;
    pickerView.minimumDate = minimumDate;
    pickerView.maximumDate = maximumDate;
    pickerView.singleRangeSelectCompletion = selectCompletion;
    pickerView.singleRangeConfirmCompletion = confirmCompletion;
    [pickerView.cancelButton addTarget:pickerView action:@selector(didClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView.confirmButton addTarget:pickerView action:@selector(didClickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView show];
}

+ (void)showPickerWithDateFormatter:(NSDateFormatter *)dateFormatter
                   beginMinimumDate:(NSDate *)beginMinimumDate
                   beginMaximumDate:(NSDate *)beginMaximumDate
                     endMinimumDate:(NSDate *)endMinimumDate
                     endMaximumDate:(NSDate *)endMaximumDate
                             offset:(NSInteger)offset
                   selectCompletion:(MRPickerViewDateDoubleRangeSelectCompletionBlock)selectCompletion
                  confirmCompletion:(MRPickerViewDateDoubleRangeSelectCompletionBlock)confirmCompletion
{
    MRPickerView *pickerView = [MRPickerView sharedView];
    pickerView.dataSourceType = MRPickerDataSourceTypeDoubleDateRange;
    pickerView.dateFormatter = dateFormatter;
    pickerView.componentCount = 2;
    pickerView.beginMinimumDate = beginMinimumDate;
    pickerView.beginMaximumDate = beginMaximumDate;
    pickerView.endMinimumDate = endMinimumDate;
    pickerView.endMaximumDate = endMaximumDate;
    pickerView.offset = offset;
    pickerView.doubleRangeSelectCompletion = selectCompletion;
    pickerView.doubleRangeConfirmCompletion = confirmCompletion;
    [pickerView.cancelButton addTarget:pickerView action:@selector(didClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView.confirmButton addTarget:pickerView action:@selector(didClickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView show];
    
}

+ (void)setSelectedRow:(NSInteger)row animated:(BOOL)animated
{
    MRPickerView *picker = [MRPickerView sharedView];
    
    if (picker.dataSourceType == MRPickerDataSourceTypeArray) {
        
        if (row > [picker.pickerView numberOfRowsInComponent:0]) {
            NSLog(@" | * [ERROR] row %d is out of bounds with array [0, ..., %d]",
                  (unsigned)row,
                  (unsigned)picker.array.count);
        } else {
            [picker.pickerView selectRow:row inComponent:0 animated:animated];
        }
        
        
    }
    
}

+ (void)setSelectedDate:(NSDate *)date animated:(BOOL)animated
{
    MRPickerView *picker = [MRPickerView sharedView];
    NSDateComponents *dateComponents = [MRPickerView dateComponentsWithUnit:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:picker.minimumDate toDate:date];
    if (picker.componentCount >= 1) [picker.pickerView selectRow:dateComponents.year inComponent:0 animated:animated];
    if (picker.componentCount >= 2) [picker.pickerView selectRow:dateComponents.month inComponent:1 animated:animated];
    if (picker.componentCount >= 3) [picker.pickerView selectRow:dateComponents.day inComponent:2 animated:animated];
}

+ (void)setSelectedBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate animated:(BOOL)animated
{
    MRPickerView *picker = [MRPickerView sharedView];
    NSDateComponents *beginDateComponents = [MRPickerView dateComponentsWithUnit:NSCalendarUnitDay fromDate:picker.beginMinimumDate toDate:beginDate];
    NSDateComponents *endDateComponents = [MRPickerView dateComponentsWithUnit:NSCalendarUnitDay fromDate:picker.beginMinimumDate toDate:endDate];
    [picker.pickerView selectRow:beginDateComponents.day inComponent:0 animated:animated];
    [picker.pickerView selectRow:endDateComponents.day inComponent:1 animated:animated];
}

+ (void)resetSelectedStatusAnimated:(BOOL)animated
{
    MRPickerView *picker = [MRPickerView sharedView];
    for (NSInteger i = 0; i < picker.pickerView.numberOfComponents; i ++) {
        [picker.pickerView selectRow:0 inComponent:i animated:animated];
    }
}

+ (void)dismiss
{
    [[MRPickerView sharedView] dismiss];
}

#pragma mark - INIT

+ (instancetype)sharedView
{
    static MRPickerView *sharedView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedView = [[MRPickerView alloc] init];
    });
    return sharedView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initializationWithOwner:self];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self initializationWithOwner:self];
    }
    return self;
}

- (void)initializationWithOwner:(id)owner
{
    _isInitializing = YES;
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:owner options:nil];
    
    self.frame = [[UIScreen mainScreen] bounds];
    self.view.frame = self.bounds;
    [self addSubview:self.view];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizingMask = self.autoresizingMask;
    _isInitializing = NO;
    
}

#pragma mark - SHOW HIDE

- (void)show
{
   
    if (_isAnimating == YES) {
        return;
    }
    
    self.frame = [[UIScreen mainScreen] bounds];
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    CGFloat ty = ceilf(CGRectGetHeight(self.pickerContentView.bounds) * 1.0f);
    _originalTransform = CGAffineTransformMakeTranslation(0, ty);
    
    // bg
    self.backgroundView.alpha = 0;
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _isAnimating = YES;
        self.backgroundView.alpha = 1;
    } completion:NULL];
    
    // picker content view
    self.pickerContentView.transform = _originalTransform;
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:1.2 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _isAnimating = YES;
        self.pickerContentView.alpha = 1;
        self.pickerContentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _isAnimating = NO;
    }];
    
    // set selected status
    [MRPickerView resetSelectedStatusAnimated:NO];
    
}

- (void)dismiss
{
    if (_isAnimating == YES) {
        return;
    }
    
    // background view
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _isAnimating = YES;
        self.backgroundView.alpha = 0;
    } completion:NULL];
    
    // picker content view
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:1.2 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _isAnimating = YES;
        self.pickerContentView.transform = _originalTransform;
    } completion:^(BOOL finished) {
        _isAnimating = NO;
        [self removeFromSuperview];
    }];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [[MRPickerView sharedView] dismiss];
}

#pragma mark - UIACTION

- (void)didClickCancelButton:(UIButton *)button
{
    [self handleCancelAction];
}

- (void)didClickConfirmButton:(UIButton *)button
{
    [self handleConfirmAction];
    [self handleCancelAction];
}

- (void)handleSelectAction
{
    __weak typeof(self) _self = self;
    
    if (self.dataSourceType == MRPickerDataSourceTypeArray) {
        
        if (self.dataSelectCompletion != NULL) {
            self.dataSelectCompletion([_self.pickerView selectedRowInComponent:0]);
        }
        
    } else if (self.dataSourceType == MRPickerDataSourceTypeSingleDateRange) {
        
        if (self.singleRangeSelectCompletion != NULL) {
            self.singleRangeSelectCompletion([_self selectedDate]);
        }
        
    } else if (self.dataSourceType == MRPickerDataSourceTypeDoubleDateRange) {
        
        if (self.doubleRangeSelectCompletion != NULL) {
            self.doubleRangeSelectCompletion([_self selectedBeginDate], [_self selectedEndDate], [_self selectedRangeOffset]);
        }
        
    }
}

- (void)handleConfirmAction
{
    __weak typeof(self) _self = self;
    
    if (self.dataSourceType == MRPickerDataSourceTypeArray) {
        
        if (self.dataConfirmCompletion != NULL) {
            self.dataConfirmCompletion([_self.pickerView selectedRowInComponent:0]);
        }
        
    } else if (self.dataSourceType == MRPickerDataSourceTypeSingleDateRange) {
        
        if (self.singleRangeConfirmCompletion != NULL) {
            self.singleRangeConfirmCompletion([_self selectedDate]);
        }
        
    } else if (self.dataSourceType == MRPickerDataSourceTypeDoubleDateRange) {
        
        if (self.doubleRangeConfirmCompletion != NULL) {
            self.doubleRangeConfirmCompletion([_self selectedBeginDate], [_self selectedEndDate], [_self selectedRangeOffset]);
        }
        
    }
}

- (void)handleCancelAction
{
    [MRPickerView dismiss];
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.componentCount;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = 0;
    
    if (self.dataSourceType == MRPickerDataSourceTypeArray) {
        
        rows = self.array.count;
        
    } else if (self.dataSourceType == MRPickerDataSourceTypeSingleDateRange) {
        
        // year
        if (self.dateFormatterStyle == MRDateFormatterStyleYear) {
            
            rows = [MRPickerView dateComponentsWithUnit:NSCalendarUnitYear
                                               fromDate:self.minimumDate
                                                 toDate:self.maximumDate].year + 1;
            
            // year month
        } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonth) {
            
            if (component == 0) {
                
                rows = [MRPickerView dateComponentsWithUnit:NSCalendarUnitYear
                                                   fromDate:self.minimumDate
                                                     toDate:self.maximumDate].year + 1;
            } else if (component == 1) {
                
                // rows 应该是当年的月份, 如果当年正好是今年, 则不能超过当前月份
                
                NSDateComponents *dateComponents = [MRPickerView dateComponentsWithUnit:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.maximumDate];
                
                if ([self selectedYear] == dateComponents.year) {
                    
                    rows = dateComponents.month;
                    
                } else {
                    
                    rows = 12;
                }
                
            }
            
            // year month day
        } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonthDay) {
            
            if (component == 0) {
                
                rows = [MRPickerView dateComponentsWithUnit:NSCalendarUnitYear
                                                   fromDate:self.minimumDate
                                                     toDate:self.maximumDate].year + 1;
            } else if (component == 1) {
                
                NSDateComponents *dateComponents = [MRPickerView dateComponentsWithUnit:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:self.maximumDate];
                
                if ([self selectedYear] == dateComponents.year) {
                    
                    rows = dateComponents.month;
                    
                } else {
                    
                    rows = 12;
                }
                
            } else if (component == 2) {
                
                NSInteger selectedYear = [self selectedYear];
                
                NSInteger selectedMonth = [self selectedMonth];
                
                NSDateComponents *dateComponents = [MRPickerView dateComponentsWithUnit:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.maximumDate];
                
                if ([self selectedYear] == dateComponents.year && [self selectedMonth] == dateComponents.month) {
                    
                    rows = dateComponents.day;
                    
                } else {
                    
                    // DAY ========================================================================//
                    
                    static NSDateFormatter *yearMonthDateFormatter = nil;
                    if (!yearMonthDateFormatter) {
                        yearMonthDateFormatter = [[NSDateFormatter alloc] init];
                        yearMonthDateFormatter.dateFormat = @"yyyy-MM";
                    }
                    
                    NSString *yearMonthDateDescription = [NSString stringWithFormat:@"%04d-%02d", (unsigned)selectedYear, (unsigned)selectedMonth];
                    
                    NSDate *yearMonthDate = [yearMonthDateFormatter dateFromString:yearMonthDateDescription];
                    
                    NSRange yearMonthDayRange = [MRPickerView rangeOfUnit:NSCalendarUnitDay
                                                                   inUnit:NSCalendarUnitMonth
                                                                  forDate:yearMonthDate];
                    
                    rows = yearMonthDayRange.length;
                    
                    // ======================================================================== DAY//
                    
                }
                
            }
            
        }
        
    } else if (self.dataSourceType == MRPickerDataSourceTypeDoubleDateRange) {
        
        // begin
        if (component == 0) {
           rows = [MRPickerView dateComponentsWithUnit:NSCalendarUnitDay fromDate:self.beginMinimumDate toDate:self.beginMaximumDate].day+1;
        // end
        } else if (component == 1) {
            rows = [MRPickerView dateComponentsWithUnit:NSCalendarUnitDay fromDate:self.endMinimumDate toDate:self.endMaximumDate].day+1;
        }
        
    }
    
    return rows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    
    if (self.dataSourceType == MRPickerDataSourceTypeArray) {
        title = [NSString stringWithFormat:@"%@", self.array[row]];
    } else if (self.dataSourceType == MRPickerDataSourceTypeSingleDateRange) {
        
        // year
        if (self.dateFormatterStyle == MRDateFormatterStyleYear) {
            
            NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitYear value:row toDate:self.minimumDate];
            
            title = [self stringFromDate:date withStyle:MRDateFormatterStyleYear clip:YES];
        
        // year month
        } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonth) {
            
            if (component == 0) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitYear value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYear clip:YES];
                
            } else if (component == 1) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitMonth value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYearMonth clip:YES];
                
            }
        
        // year month day
        } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonthDay) {
            
            if (component == 0) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitYear value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYear clip:YES];
                
            } else if (component == 1) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitMonth value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYearMonth clip:YES];
                
            } else if (component == 2) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitDay value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYearMonthDay clip:YES];
                
            }
            
        }
        
    } else if (self.dataSourceType == MRPickerDataSourceTypeDoubleDateRange) {
        
        if (component == 0) {
            
            NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitDay value:row toDate:self.beginMinimumDate];
            
            title = [self.dateFormatter stringFromDate:date];
            
        } else if (component == 1) {
            
            NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitDay value:row toDate:self.endMinimumDate];
            
            title = [self.dateFormatter stringFromDate:date];
            
        }
        
    }
    
    return title;
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (component != 2) {
            [pickerView reloadAllComponents];
        }
    } completion:NULL];
    
    // need to handle select action after picker reload
    [self handleSelectAction];
    
}

#pragma mark - UNIT TOOL METHOD

- (NSInteger)selectedYear
{
    // selected row in year components
    NSInteger selectedYearComponentsRow = [self.pickerView selectedRowInComponent:0];
    
    // get selected year
    NSDate *dateForSelectedYearComponentsRow = [MRPickerView dateByAddingUnit:NSCalendarUnitYear
                                                                        value:selectedYearComponentsRow
                                                                       toDate:self.minimumDate];
    
    NSDateComponents *dateComponentsForSelectedYearComponentsRow = [MRPickerView dateComponentsWithUnit:NSCalendarUnitYear
                                                                                               fromDate:dateForSelectedYearComponentsRow];
    
    NSInteger selectedYear = dateComponentsForSelectedYearComponentsRow.year;
    
    return selectedYear;
}

- (NSInteger)selectedMonth
{
    // selected row in month components
    NSInteger selectedMonthComponentsRow = [self.pickerView selectedRowInComponent:1];
    
    // get selected month
    NSDate *dateForSelectedMonthComponentsRow = [MRPickerView dateByAddingUnit:NSCalendarUnitMonth
                                                                         value:selectedMonthComponentsRow
                                                                        toDate:self.minimumDate];
    
    NSDateComponents *dateComponentsForSelectedMonthComponentsRow = [MRPickerView dateComponentsWithUnit:NSCalendarUnitMonth
                                                                                                fromDate:dateForSelectedMonthComponentsRow];
    
    NSInteger selectedMonth = dateComponentsForSelectedMonthComponentsRow.month;
    
    return selectedMonth;
}

- (NSInteger)selectedDay
{
    // selected row in day components
    NSInteger selectedDayComponentsRow = [self.pickerView selectedRowInComponent:2];
    
    // get selected day
    NSDate *dateForSelectedDayComponentsRow = [MRPickerView dateByAddingUnit:NSCalendarUnitDay
                                                                       value:selectedDayComponentsRow
                                                                      toDate:self.minimumDate];
    
    NSDateComponents *dateComponentsForSelectedDayComponentsRow = [MRPickerView dateComponentsWithUnit:NSCalendarUnitDay
                                                                                              fromDate:dateForSelectedDayComponentsRow];
    
    NSInteger selectedDay = dateComponentsForSelectedDayComponentsRow.day;
    
    return selectedDay;
    
}

- (NSDate *)selectedDate
{
    NSDateFormatter *dateFormatter = [self dateFormatter];
    
    NSMutableString *dateDescription = [NSMutableString string];
    
    if (self.dateFormatterStyle >= MRDateFormatterStyleYear) {
        [dateDescription appendFormat:@"%04d年", (unsigned)[self selectedYear]];
    }
    
    if (self.dateFormatterStyle >= MRDateFormatterStyleYearMonth) {
        [dateDescription appendFormat:@"%02d月", (unsigned)[self selectedMonth]];
    }
    
    if (self.dateFormatterStyle >= MRDateFormatterStyleYearMonthDay) {
        [dateDescription appendFormat:@"%02d日", (unsigned)[self selectedDay]];
    }
    
    return [dateFormatter dateFromString:dateDescription];
    
}

- (NSDate *)selectedBeginDate
{
    return [MRPickerView dateByAddingUnit:NSCalendarUnitDay value:[self.pickerView selectedRowInComponent:0] toDate:self.beginMinimumDate];
}

- (NSDate *)selectedEndDate
{
    return [MRPickerView dateByAddingUnit:NSCalendarUnitDay value:[self.pickerView selectedRowInComponent:1] toDate:self.endMinimumDate];
}

- (NSInteger)selectedRangeOffset
{
    return [MRPickerView dateComponentsWithUnit:NSCalendarUnitDay fromDate:[self selectedBeginDate] toDate:[self selectedEndDate]].day;
}

// not self dateFormatterStyle, but current components needed style
- (NSString *)stringFromDate:(NSDate *)date withStyle:(MRDateFormatterStyle)style clip:(BOOL)clip
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    if (clip) {
        if (style == MRDateFormatterStyleYear) {
            dateFormatter.dateFormat = @"yyyy年";
        } else if (style == MRDateFormatterStyleYearMonth) {
            dateFormatter.dateFormat = @"MM月";
        } else if (style == MRDateFormatterStyleYearMonthDay) {
            dateFormatter.dateFormat = @"dd日";
        }
    } else {
        if (style == MRDateFormatterStyleYear) {
            dateFormatter.dateFormat = @"yyyy年";
        } else if (style == MRDateFormatterStyleYearMonth) {
            dateFormatter.dateFormat = @"yyyy年MM月";
        } else if (style == MRDateFormatterStyleYearMonthDay) {
            dateFormatter.dateFormat = @"yyyy年MM月dd日";
        }
    }
    
    return [dateFormatter stringFromDate:date];
}

@end

#pragma mark - EXTENSION

@implementation MRPickerView (DateComponents)

+ (NSCalendar *)sharedCalendar
{
    static NSCalendar *s_calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_calendar = [NSCalendar currentCalendar];
    });
    return s_calendar;
}

+ (NSDate *)dateByAddingUnit:(NSCalendarUnit)unit value:(NSInteger)value toDate:(NSDate *)date
{
    return [[MRPickerView sharedCalendar] dateByAddingUnit:unit
                                                     value:value
                                                    toDate:date
                                                   options:0];
}

+ (NSDateComponents *)dateComponentsWithUnit:(NSCalendarUnit)unit fromDate:(NSDate *)date
{
    return [[MRPickerView sharedCalendar] components:unit
                                            fromDate:date];
}

+ (NSDateComponents *)dateComponentsWithUnit:(NSCalendarUnit)unit
                                    fromDate:(NSDate *)startingDate
                                      toDate:(NSDate *)resultDate
{
    return [[MRPickerView sharedCalendar] components:unit
                                            fromDate:startingDate
                                              toDate:resultDate
                                             options:0];
}

+ (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
{
    return [[MRPickerView sharedCalendar] rangeOfUnit:smaller
                                               inUnit:larger
                                              forDate:date];
}

@end
