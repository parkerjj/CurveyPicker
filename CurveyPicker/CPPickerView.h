//
//  CPPickerView.h
//  CurveyPicker
//
//  Created by Parker on 15/5/11.
//  Copyright (c) 2015年 Parker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCMeshTransformView.h"

@class CPPickerView;

@protocol CPPickerViewDataSource <NSObject>
@required
- (NSInteger)pickerViewNumberOfRowsInPickerView:(CPPickerView *)pickerView;
- (NSString*)pickerView:(CPPickerView *)pickerView stringForRow:(NSInteger)row;
@end



@interface CPPickerView : BCMeshTransformView<UITableViewDataSource,UITableViewDelegate>{
    
}
@property (nonatomic,weak) id <CPPickerViewDataSource> dataSource;

- (id)initWithSender:(id)sender;

@end
