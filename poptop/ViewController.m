//
//  ViewController.m
//  poptop
//
//  Created by zhisu on 15/6/1.
//  Copyright (c) 2015年 zhisu. All rights reserved.
//

#import "ViewController.h"
#import "FoldingViewController.h"
#import <POP.h>
@interface ViewController ()
{
    UIButton *_btn;
    UILabel *_la;
    UIImageView *_imageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    

    
   _btn = [UIButton buttonWithType:UIButtonTypeSystem];
    _btn.backgroundColor = [UIColor redColor];
    _btn.frame = CGRectMake(100, 50, 100, 100);
    
    [_btn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn];
    
    
    
    
   _la = [[UILabel alloc]init];
    _la.text = @"3.74";
    _la.frame = CGRectMake(100, 200, 50, 50);
    _la.textColor = [UIColor redColor];
    [self.view addSubview:_la];
    
    
    
    POPBasicAnimation *anim = [POPBasicAnimation animation];
    anim.duration = 10;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"count" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [[obj description] floatValue];};
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            [obj setText:[NSString stringWithFormat:@"%.2f",values[0]]];};
        prop.threshold = 0.01;
    }];
    
    anim.property = prop;
    anim.fromValue = @(0.0);
    anim.toValue = @(100.0);
    
    [_la pop_addAnimation:anim forKey:@"anim"];
    
//    POPBasicAnimation 的 timingFunction 我们定义了动画的方式，慢开慢停。随后通过 POPAnimatableProperty 定义了 POP 如何操作 Label 上的数值。
//    
//    readBlock 中，obj 就是我们的 Label，values 这个是动画作用的属性数组，其值必须是 CGFloat ，之前我们在 Decay Animation 中操作了 bounds
//    
//    那么 values[0]，values1，values2，values3 就分别对应 CGRectMake(0, 0, 20.0, 20.0) 的 0, 0, 20.0, 20.0
//    
//    这里我们只需要操作 Label 上显示的文字，所以只需要一个参数。通过 values[0] = [[obj description] floatValue] 我们告诉 POP 如何获取这个值。
//    
//    相应的我们通过 [obj setText:[NSString stringWithFormat:@”%.2f”,values[0]]] 告诉了 POP 如何改变 Label 的属性。
//    
//    threshold 定义了动画的变化阀值，如果这里使用 1，那么我们就不会看到动画执行时候小数点后面的数字变化。 到此为止，我们的 Counting Label 就完成了，是不是超简单？
    
    
    
    _imageView = [[UIImageView alloc]init];
    _imageView.userInteractionEnabled = YES;
    _imageView.backgroundColor = [UIColor blueColor];
    _imageView.frame = CGRectMake(100, 250, 200, 200);
    [self.view addSubview:_imageView];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGesAction:)];
    [_imageView addGestureRecognizer:pan];
    
    
    
}


-(void)panGesAction:(UIPanGestureRecognizer *)ges
{
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:{
            [_imageView.layer pop_removeAllAnimations];
            
            CGPoint translation = [ges translationInView:_imageView];
            CGPoint center = self.view.center;
            center.x += translation.x;
            center.y += translation.y;
            _imageView.center = center;
            [ges setTranslation:CGPointZero inView:_imageView];
            break;
            
            
        }
       	case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            
            CGPoint velocity = [ges velocityInView:_imageView];
            [self addDecayPositionAnimationWithVelocity:velocity];
            break;
        }
            
        default:
            break;
    }
    
    
    
}
-(void)addDecayPositionAnimationWithVelocity:(CGPoint)velocity
{
    POPDecayAnimation *anim = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerPosition];
    
    anim.velocity = [NSValue valueWithCGPoint:CGPointMake(velocity.x, velocity.y)];
    
    
    anim.deceleration = 0.998;
    
    [_imageView.layer pop_addAnimation:anim forKey:@"AnimationPosition"];
}

-(void)playAction:(UIButton *)btn
{
    
//    衰减的效果
//    POPDecayAnimation *anim = [POPDecayAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//    anim.velocity =  @(100);
//    anim.fromValue = @(25);
//    
//  
//    [_btn.layer pop_addAnimation:anim forKey:@"anim"];
    
    
    
//    //弹动
//    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
//    anim.toValue = [NSValue  valueWithCGRect:CGRectMake(0, 0, 20, 20)];
//    anim.springBounciness = 4.0;
//    anim.springSpeed = 12.0;
//    [_btn.layer pop_addAnimation:anim forKey:@"anim"];
    
    
    
    FoldingViewController *fold = [[FoldingViewController alloc]init];
    [self.navigationController pushViewController:fold animated:YES];

    
    
}



@end
