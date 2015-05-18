//
//  CPPickerView.m
//  CurveyPicker
//
//  Created by Parker on 15/5/11.
//  Copyright (c) 2015年 Parker. All rights reserved.
//

#define kCellHeight 44.0f
#define kLineWidth 1.0f
#define kAutoRemoveDuration 5.0f


#import "CPPickerView.h"
#import "BCMutableMeshTransform+Convenience.h"
#import <QuartzCore/QuartzCore.h>

@interface CPPickerView(){
    UIView *_initSender;
    UITableView *_tableView;
    CGFloat _leftOrRightSign;  // Left: -1  Right: 1
    CGPoint _senderPointInSSuperView;
    CAGradientLayer *_gradientLayer;        // 渐变背景
    
    NSThread *_timerThread;
    BOOL    _userAlreadyTouched;            //User Touched
}

@end

CGAffineTransform CGAffineTransformMakeRotationAt(CGFloat angle, CGPoint pt){
    const CGFloat fx = pt.x, fy = pt.y, fcos = cos(angle), fsin = sin(angle);
    return CGAffineTransformMake(fcos, fsin, -fsin, fcos, fx - fx * fcos + fy * fsin, fy - fx * fsin - fy * fcos);
};

CGAffineTransform GetCGAffineTransformRotateAroundPoint(float centerX, float centerY ,float x ,float y ,float angle){
    x = x - centerX; //计算(x,y)从(0,0)为原点的坐标系变换到(CenterX ，CenterY)为原点的坐标系下的坐标
    y = y - centerY; //(0，0)坐标系的右横轴、下竖轴是正轴,(CenterX,CenterY)坐标系的正轴也一样
    
    CGAffineTransform  trans = CGAffineTransformMakeTranslation(x, y);
    trans = CGAffineTransformRotate(trans,angle);
    trans = CGAffineTransformTranslate(trans,-x, -y);
    return trans;
}


@implementation CPPickerView


- (void)dealloc{
    [_timerThread cancel];
    _timerThread = nil;

}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        CGRect tableViewRect = CGRectZero;
        if (_leftOrRightSign == -1.0f) {
            // Left
            tableViewRect = CGRectMake(_senderPointInSSuperView.x, 0, frame.size.width - _senderPointInSSuperView.x, frame.size.height);
            
        }else{
            // Right
            tableViewRect = CGRectMake(0, 0, frame.size.width, frame.size.height);

        }
        
        _tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
        [_tableView setContentInset:UIEdgeInsetsMake(_tableView.frame.size.height/2-kCellHeight/2, 0, _tableView.frame.size.height/2-kCellHeight/2, 0)];
        [_tableView setShowsVerticalScrollIndicator:NO];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [self.contentView addSubview:_tableView];
        
        
        UIView *shadowViewLeft = [[UIView alloc] initWithFrame:CGRectMake(_tableView.frame.origin.x, _tableView.frame.origin.y, 1.0f, _tableView.frame.size.height)];
        [shadowViewLeft setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        [shadowViewLeft.layer setShadowColor:[UIColor blackColor].CGColor];
        [shadowViewLeft.layer setShadowOffset:CGSizeMake(1, 0)];
        [shadowViewLeft.layer setShadowRadius:10.0f];
        [shadowViewLeft.layer setShadowOpacity:1.0f];
        [self.contentView addSubview:shadowViewLeft];
        
        
        
        UIView *shadowViewRight = [[UIView alloc] initWithFrame:CGRectMake(_tableView.frame.origin.x+_tableView.frame.size.width, _tableView.frame.origin.y, 1.0f, _tableView.frame.size.height)];
        [shadowViewRight setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        [shadowViewRight.layer setShadowColor:[UIColor blackColor].CGColor];
        [shadowViewRight.layer setShadowOffset:CGSizeMake(-1, 0)];
        [shadowViewRight.layer setShadowRadius:10.0f];
        [shadowViewRight.layer setShadowOpacity:1.0f];
        [self.contentView addSubview:shadowViewRight];
        
        
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        
        _gradientLayer = [CAGradientLayer layer];  // 设置渐变效果
        _gradientLayer.bounds = self.contentView.bounds;
        _gradientLayer.borderWidth = 0;
        
        _gradientLayer.frame = self.bounds;
        _gradientLayer.colors = [NSArray arrayWithObjects:
                                 (id)[[UIColor clearColor] CGColor],
                                 (id)[[UIColor blackColor] CGColor],
                                 (id)[[UIColor blackColor] CGColor],
                                 (id)[[UIColor blackColor] CGColor],
                                 (id)[[UIColor clearColor] CGColor], nil];
        _gradientLayer.startPoint = CGPointMake(0.5, 0.05);
        _gradientLayer.endPoint = CGPointMake(0.5, 0.95);
        
        self.contentView.layer.mask = _gradientLayer;
        
        _userAlreadyTouched = YES;
        
        _timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(checkTimerToRemoveSelf) object:nil];
        [_timerThread start];
        
    }
    return self;
}



- (id)initWithSender:(id)sender{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    if ([sender isKindOfClass:[UIGestureRecognizer class]]) {
        sender = [(UIGestureRecognizer*)sender view];
    }
    
    if ([sender isKindOfClass:[UIView class]]) {
        _initSender = sender;
        
        UIView *senderView = sender;
        UIView *supersuperView = senderView.superview;
        while (supersuperView.superview != nil) {
            supersuperView = supersuperView.superview;
        }
        
        _senderPointInSSuperView = [supersuperView convertPoint:CGPointMake(0, 0) fromView:_initSender];
        CGRect selfRect;
        _leftOrRightSign = 0.0f;     // Left: -1  Right: 1
        
        if (_senderPointInSSuperView.x+_initSender.frame.size.width/2 < screenSize.width/2) {
            //Sender is on the LEFT of the screen
            selfRect = CGRectMake(0, 0, _senderPointInSSuperView.x+senderView.frame.size.width, supersuperView.frame.size.height);
            _leftOrRightSign = -1;
        }else{
            //Sender is on the RIGHT of the screen.
            selfRect = CGRectMake(_senderPointInSSuperView.x, 0, supersuperView.frame.size.width-_senderPointInSSuperView.x, supersuperView.frame.size.height);
            _leftOrRightSign = 1;
        }
        
        
        self = [self initWithFrame:selfRect];
        if (self) {
            BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:30 numberOfColumns:1];
            
            CGPoint np = CGPointMake(0.7f, 0.5f);
            if (_leftOrRightSign == -1.0f) {
                //LEFT
                np = CGPointMake(1.5f, 0.5f);
            }else{
                //RIGHT
                np = CGPointMake(0.5f, 0.5f);
            }
            
            [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
                float dy = vertex.to.y - np.y;
                float bend = 5 * (1.0f - expf(-dy * dy));
                if (_leftOrRightSign == -1.0f) {
                    //LEFT
                    vertex.to.x = (vertex.to.x)* 0.7f + bend * (1.0 - np.x) + 0.3f;
                }else{
                    //RIGHT
                    vertex.to.x = (vertex.to.x) * 0.7f + bend * (1.0 - np.x);
                }
                return vertex;
            }];

            self.meshTransform = transform;
            
            [self setCenter:CGPointMake(self.center.x, senderView.center.y)];
            
        }
        return self;
    }
    
    return nil;
}


- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    
    CATransition* transition = [CATransition animation];
    transition.startProgress = 0;
    transition.endProgress = 1.0;
    transition.type = kCATransitionPush;
    transition.subtype = _leftOrRightSign == -1 ? kCATransitionFromLeft : kCATransitionFromRight;
    transition.duration = .25f;
    
    // Add the transition animation to both layers
    [self.layer addAnimation:transition forKey:@"transition"];


}

- (void)autolayoutCellForCenter{
    CGFloat y = _tableView.bounds.origin.y+ _tableView.frame.size.height/2;
    NSIndexPath *centerIndexPath = [_tableView indexPathForRowAtPoint:CGPointMake(_tableView.frame.size.width/2, y)];
    [_tableView scrollToRowAtIndexPath:centerIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}


- (void)setSelectedRow:(NSInteger)rowSelected animation:(BOOL)animation{
    NSArray *selectedRows = [_tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedRows) {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowSelected inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:animation];
    [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:rowSelected inSection:0] animated:animation scrollPosition:UITableViewScrollPositionNone];
    
    if ([_delegate respondsToSelector:@selector(pickerView:didSelectRow:)]) {
        [_delegate pickerView:self didSelectRow:rowSelected];
    }
}


- (void)checkTimerToRemoveSelf{
    if ([[NSThread currentThread] isMainThread]) {
        return;
    }
    while (YES) {
        if (_userAlreadyTouched == YES) {
            _userAlreadyTouched = NO;
            [NSThread sleepForTimeInterval:kAutoRemoveDuration];
        }else{
            [self performSelectorOnMainThread:@selector(removeFromSuperview) withObject:self waitUntilDone:YES];
            [NSThread exit];
        }
    }

    
    
}

- (void)removeFromSuperview{

    [UIView animateWithDuration:.25f delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [self setAlpha:0.0f];
    } completion:^(BOOL finished) {
        if (finished) {
            [super removeFromSuperview];
        }
    }];
}

#pragma mark - Delegate & DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger count = 0;
    if ([_dataSource respondsToSelector:@selector(pickerViewNumberOfRowsInPickerView:)]) {
        count = [_dataSource pickerViewNumberOfRowsInPickerView:self];
    }
    return count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        [cell setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:0.7f]];
    }
    NSString *text = @"";
    if ([_dataSource respondsToSelector:@selector(pickerView:stringForRow:)]) {
        text = [_dataSource pickerView:self stringForRow:indexPath.row];
    }
    [cell.textLabel setText:text];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self setSelectedRow:indexPath.row animation:YES];
    _userAlreadyTouched = YES;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate){
        // 滚动中 不作处理
        return;
    }
    [self autolayoutCellForCenter];
    _userAlreadyTouched = YES;

    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"结束滚动");
    [self autolayoutCellForCenter];
    _userAlreadyTouched = YES;


}


@end
