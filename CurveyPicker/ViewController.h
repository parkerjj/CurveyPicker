//
//  ViewController.h
//  CurveyPicker
//
//  Created by Parker on 15/5/11.
//  Copyright (c) 2015年 Parker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPPickerView.h"

@interface ViewController : UIViewController<CPPickerViewDataSource>{
    IBOutlet UILabel *_label;
}


@end

