//
//  MRPickerView.h
//  MRPickerView
//
//  Created by 🍉 on 2017/6/12.
//  Copyright © 2017年 🍉. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MRPickerViewSelectCompletionBlock)(NSInteger row);

@interface MRPickerView : UIView

+ (void)showPickerWithComponents:(NSArray *)components
              defaultSelectedRow:(NSInteger)row
                selectCompletion:(MRPickerViewSelectCompletionBlock)selectCompletion;

@end
