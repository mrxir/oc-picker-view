//
//  MRPickerView.m
//  MRPickerView
//
//  Created by 🍉 on 2017/6/12.
//  Copyright © 2017年 🍉. All rights reserved.
//

#import "MRPickerView.h"

@interface MRPickerView ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL _isAnimating;
    
    CGAffineTransform _originalTransform;
}

@property (nonatomic, strong) NSArray *components;

@property (nonatomic, strong) IBOutlet UIView *view;

@property (nonatomic, strong) IBOutlet UIView *backgroundView;

@property (nonatomic, strong) IBOutlet UIView *pickerContentView;

@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;

@property (nonatomic, strong) IBOutlet UIView *buttonContentView;

@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) IBOutlet UIButton *confirmButton;

@end

@implementation MRPickerView

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
    [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:owner options:nil];
    
    self.frame = [[UIScreen mainScreen] bounds];
    self.view.frame = self.bounds;
    [self addSubview:self.view];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizingMask = self.autoresizingMask;
    
}

#pragma mark - SHOW HIDE

+ (void)showPickerWithComponents:(NSArray *)components
              defaultSelectedRow:(NSInteger)row
                selectCompletion:(MRPickerViewSelectCompletionBlock)selectCompletion
{
    MRPickerView *pickerView = [MRPickerView sharedView];
    pickerView.components = components;
    [pickerView show];
}

+ (void)dismiss
{
    [[MRPickerView sharedView] dismiss];
}

- (void)show
{
   
    if (_isAnimating == YES) {
        return;
    }
    
    self.frame = [[UIScreen mainScreen] bounds];
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    CGFloat ty = ceilf(CGRectGetHeight(self.pickerContentView.bounds) * 0.5f);
    _originalTransform = CGAffineTransformMakeTranslation(0, ty);
    
    // bg
    self.backgroundView.alpha = 0;
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _isAnimating = YES;
        self.backgroundView.alpha = 1;
    } completion:NULL];
    
    // picker content view
    self.pickerContentView.alpha = 0;
    self.pickerContentView.transform = _originalTransform;
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:1.2 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _isAnimating = YES;
        self.pickerContentView.alpha = 1;
        self.pickerContentView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        _isAnimating = NO;
    }];
    
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
        self.pickerContentView.alpha = 0;
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

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.components.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.components[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

@end
