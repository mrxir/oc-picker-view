//
//  MRPickerView.m
//  MRPickerView
//
//  Created by 🍉 on 2017/6/12.
//  Copyright © 2017年 🍉. All rights reserved.
//

#import "MRPickerView.h"

typedef NS_ENUM(NSUInteger, MRPickerDataType) {
    MRPickerDataTypeData,
    MRPickerDataTypeDate,
};

@interface MRPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL _isAnimating;
    
    CGAffineTransform _originalTransform;
    
    BOOL _isInitializing;
}

@property (nonatomic, assign) MRPickerDataType dataType;

@property (nonatomic, assign) MRDateFormatterStyle dateFormatterStyle;

@property (nonatomic, strong) NSArray *components;

@property (nonatomic, strong) NSDate *minimumDate;

@property (nonatomic, strong) NSDate *maximumDate;

@property (nonatomic, strong) MRPickerViewSelectCompletionBlock dataSelectCompletion;
@property (nonatomic, strong) MRPickerViewSelectCompletionBlock dataConfirmCompletion;

@property (nonatomic, strong) MRPickerViewDateSelectCompletionBlock dateSelectCompletion;
@property (nonatomic, strong) MRPickerViewDateSelectCompletionBlock dateConfirmCompletion;

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

+ (void)showPickerWithComponents:(NSArray *)components
                selectCompletion:(MRPickerViewSelectCompletionBlock)selectCompletion
               confirmCompletion:(MRPickerViewSelectCompletionBlock)confirmCompletion
{
    MRPickerView *pickerView = [MRPickerView sharedView];
    pickerView.dataType = MRPickerDataTypeData;
    pickerView.components = components;
    pickerView.dataSelectCompletion = selectCompletion;
    pickerView.dataConfirmCompletion = confirmCompletion;
    [pickerView.cancelButton addTarget:pickerView action:@selector(didClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView.confirmButton addTarget:pickerView action:@selector(didClickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView show];
}

+ (void)showPickerWithDateFormatterStyle:(MRDateFormatterStyle)style
                             minimumDate:(NSDate *)minimumDate
                             maximumDate:(NSDate *)maximumDate
                        selectCompletion:(MRPickerViewDateSelectCompletionBlock)selectCompletion
                       confirmCompletion:(MRPickerViewDateSelectCompletionBlock)confirmCompletion
{
    MRPickerView *pickerView = [MRPickerView sharedView];
    pickerView.dataType = MRPickerDataTypeDate;
    pickerView.dateFormatterStyle = style;
    pickerView.minimumDate = minimumDate;
    pickerView.maximumDate = maximumDate;
    pickerView.dateSelectCompletion = selectCompletion;
    pickerView.dateConfirmCompletion = confirmCompletion;
    [pickerView.cancelButton addTarget:pickerView action:@selector(didClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView.confirmButton addTarget:pickerView action:@selector(didClickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
    [pickerView show];
}

+ (void)dismiss
{
    [[MRPickerView sharedView] dismiss];
}

+ (void)setSelectedRow:(NSInteger)row animated:(BOOL)animated
{
    MRPickerView *picker = [MRPickerView sharedView];
    
    if (picker.dataType == MRPickerDataTypeData) {
        
        if (row > [picker.pickerView numberOfRowsInComponent:0]) {
            NSLog(@" | * [ERROR] row %d is out of count in components %d",
                  (unsigned)row,
                  (unsigned)picker.components.count);
        } else {
            [picker.pickerView selectRow:row inComponent:0 animated:animated];
        }
        
        
    }
    
}

+ (void)setSelectedDate:(NSDate *)date animated:(BOOL)animated
{
    /*
    MRPickerView *picker = [MRPickerView sharedView];
    
    NSDateComponents *dateComponents = [MRPickerView dateComponentsWithUnit:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    */
}

+ (void)resetSelectedStatusAnimated:(BOOL)animated;
{
    MRPickerView *picker = [MRPickerView sharedView];
    
    for (NSInteger i = 0; i < picker.pickerView.numberOfComponents; i ++) {
        
        [picker.pickerView selectRow:0 inComponent:i animated:animated];
        
    }
    
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
    
    if (self.dataType == MRPickerDataTypeData) {
        
        if (self.dataSelectCompletion != NULL) {
            self.dataSelectCompletion([_self.pickerView selectedRowInComponent:0]);
        }
        
    } else if (self.dataType == MRPickerDataTypeDate) {
        
        if (self.dateSelectCompletion != NULL) {
            self.dateSelectCompletion([_self selectedDate], [_self dateFormatter]);
        }
        
    }
}

- (void)handleConfirmAction
{
    __weak typeof(self) _self = self;
    
    if (self.dataType == MRPickerDataTypeData) {
        
        if (self.dataConfirmCompletion != NULL) {
            self.dataConfirmCompletion([_self.pickerView selectedRowInComponent:0]);
        }
        
    } else if (self.dataType == MRPickerDataTypeDate) {
        
        if (self.dateConfirmCompletion != NULL) {
            self.dateConfirmCompletion([_self selectedDate], [_self dateFormatter]);
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
    NSInteger components = 0;
    
    if (self.dataType == MRPickerDataTypeData) {
        components = 1;
    } else {
        
        if (self.dateFormatterStyle == MRDateFormatterStyleYear) {
            components = 1;
        } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonth) {
            components = 2;
        } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonthDay) {
            components = 3;
        }
        
    }
    
    return components;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = 0;
    
    if (self.dataType == MRPickerDataTypeData) {
        
        rows = self.components.count;
        
    } else {
        
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
        
    }
    
    return rows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    
    if (self.dataType == MRPickerDataTypeData) {
        title = [NSString stringWithFormat:@"%@", self.components[row]];
    } else {
        
        // year
        if (self.dateFormatterStyle == MRDateFormatterStyleYear) {
            
            NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitYear value:row toDate:self.minimumDate];
            
            title = [self stringFromDate:date withStyle:MRDateFormatterStyleYear];
        
        // year month
        } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonth) {
            
            if (component == 0) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitYear value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYear];
                
            } else if (component == 1) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitMonth value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYearMonth];
                
            }
        
        // year month day
        } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonthDay) {
            
            if (component == 0) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitYear value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYear];
                
            } else if (component == 1) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitMonth value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYearMonth];
                
            } else if (component == 2) {
                
                NSDate *date = [MRPickerView dateByAddingUnit:NSCalendarUnitDay value:row toDate:self.minimumDate];
                
                title = [self stringFromDate:date withStyle:MRDateFormatterStyleYearMonthDay];
                
            }
            
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

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    if (self.dateFormatterStyle == MRDateFormatterStyleYear) {
        dateFormatter.dateFormat = @"yyyy年";
    } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonth) {
        dateFormatter.dateFormat = @"yyyy年MM月";
    } else if (self.dateFormatterStyle == MRDateFormatterStyleYearMonthDay) {
        dateFormatter.dateFormat = @"yyyy年MM月dd日";
    }
    
    return dateFormatter;
}

// not self dateFormatterStyle, but current components needed style
- (NSString *)stringFromDate:(NSDate *)date withStyle:(MRDateFormatterStyle)style
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
    if (style == MRDateFormatterStyleYear) {
        dateFormatter.dateFormat = @"yyyy年";
    } else if (style == MRDateFormatterStyleYearMonth) {
        dateFormatter.dateFormat = @"MM月";
    } else if (style == MRDateFormatterStyleYearMonthDay) {
        dateFormatter.dateFormat = @"dd日";
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
