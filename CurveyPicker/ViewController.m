//
//  ViewController.m
//  CurveyPicker
//
//  Created by Parker on 15/5/11.
//  Copyright (c) 2015年 Parker. All rights reserved.
//

#import "ViewController.h"

#define kLastNameArray @[@"赵",@"钱",@"孙",@"李",@"周",@"吴",@"郑",@"王",@"冯",@"陈",@"楚",@"卫",@"蒋",@"沈",@"韩",@"杨",@"欧阳",@"西门",@"轩辕"]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *longGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_label addGestureRecognizer:longGR];
    
    [_label setUserInteractionEnabled:YES];

}


- (IBAction)longPress:(id)sender{
    CPPickerView *pickerView = [[CPPickerView alloc] initWithSender:sender];
    [pickerView setDataSource:self];
    [self.view addSubview:pickerView];
    
}


- (IBAction)clearScreen:(id)sender{
    for (UIView *view in self.view.subviews) {
        if ([view isMemberOfClass:[CPPickerView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)pickerViewNumberOfRowsInPickerView:(CPPickerView *)pickerView{
    return [kLastNameArray count];
}


- (NSString*)pickerView:(CPPickerView *)pickerView stringForRow:(NSInteger)row{
    return [kLastNameArray objectAtIndex:row];
}
@end
