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


/**
 *  Please use this method to init this object,It will automaticlly setup
 *  the frame where should this CPPickerView be.
 *
 *
 *  @param sender Any UIControl or UIView, It will automaticlly setup
 *                the frame where should this CPPickerView be.
 *
 *  @return CPPickerView Object
 */
- (id)initWithSender:(id)sender;


/**
 *  Set selected row in PickerView, and if the row is not showing
 *  it will scroll to row.
 *
 *  @param rowSelected NSInteger
 *  @param animation   Wanna Animation?
 */
- (void)setSelectedRow:(NSInteger)rowSelected animation:(BOOL)animation;



@end
