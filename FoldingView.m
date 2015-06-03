
//
//  FoldingView.m
//  poptop
//
//  Created by zhisu on 15/6/2.
//  Copyright (c) 2015年 zhisu. All rights reserved.
//

#import "FoldingView.h"
#import "UIImage+Blur.h"
#import <pop/POP.h>


//层级
typedef NS_ENUM(NSInteger, LayerSection)
{
    
    LayerSectionTop,
    LayerSectionBottom
};


@interface FoldingView () <POPAnimationDelegate>




@property(nonatomic)UIImage *image;
@property(nonatomic)UIImageView *topView;
@property(nonatomic)UIImageView *backView;
@property(nonatomic)CAGradientLayer *bottomShadowLayer;
@property(nonatomic)CAGradientLayer *topShadowLayer;
@property(nonatomic)NSUInteger initialLocation;



@end



@implementation FoldingView


-(id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        _image = image;
         [self addBottomView];
        [self addTopView];
        
        [self addGestureRecognizers];

        
    }
    
    return self;
    
    
}


#pragma mark - Private Instance methods

-(void)addTopView
{
    
    UIImage *image = [self imageForSection:LayerSectionTop withImage:self.image];
    
 
    //   CGRectGetMidY 返回矩形顶部的坐标
    self.topView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetMidY(self.bounds))];
    
    self.topView.image = image;
    self.topView.layer.anchorPoint = CGPointMake(0.5, 1.0);
    self.topView.layer.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    self.topView.layer.transform = [self transform3D];
    self.topView.layer.mask = [self maskForSection:LayerSectionTop withRect:self.topView.bounds];
    self.topView.userInteractionEnabled = YES;
    
    //UIViewContentModeScaleAspectFit会保证图片比例不变，而且全部显示在ImageView中，这意味着ImageView会有部分空白。UIViewContentModeScaleAspectFill也会证图片比例不变，但是是填充整个ImageView的，可能只有部分图片显示出来。
    //没有这句图片会错位
    self.topView.contentMode = UIViewContentModeScaleAspectFill;
    
    
    self.backView =[[UIImageView alloc]initWithFrame:self.topView.bounds];
    //设置模糊效果
    self.backView.image = [image blurredImage];
    self.backView.alpha = 0;
    
    
    //设置折叠时图片正面的颜色
    self.topShadowLayer = [CAGradientLayer layer];
    self.topShadowLayer.frame = self.topView.bounds;
    self.topShadowLayer.colors = @[(id) [UIColor clearColor].CGColor,(id)[UIColor blackColor].CGColor];
    self.topShadowLayer.opacity = 0;
    
    
    
    [self.topView addSubview:self.backView];
    [self.topView.layer addSublayer:self.topShadowLayer];
    [self addSubview:self.topView];
    
    
    
    
    
    
    
}

//下半部分的图片效果
- (void)addBottomView
{
    UIImage *image = [self imageForSection:LayerSectionBottom withImage:self.image];
    
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f,
                                                                            CGRectGetMidY(self.bounds),
                                                                            CGRectGetWidth(self.bounds),
                                                                            CGRectGetMidY(self.bounds))];
    bottomView.image = image;
    bottomView.contentMode = UIViewContentModeScaleAspectFill;
    bottomView.layer.mask = [self maskForSection:LayerSectionBottom withRect:bottomView.bounds];
    
    self.bottomShadowLayer = [CAGradientLayer layer];
    self.bottomShadowLayer.frame = bottomView.bounds;
    self.bottomShadowLayer.colors = @[(id)[UIColor redColor].CGColor, (id)[UIColor clearColor].CGColor];
    self.bottomShadowLayer.opacity = 0;
    
    [bottomView.layer addSublayer:self.bottomShadowLayer];
    [self addSubview:bottomView];
}


//裁切图片
-(UIImage *)imageForSection:(LayerSection)section withImage:(UIImage *)image
{
    
    //从哪开始折叠－－ 图片的一半高度
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height/2);
    
    //下面的层 y轴 那么就是图片的一半高度
    if (section == LayerSectionBottom) {
        rect.origin.y = image.size.height/2;
    }
    
    //剪切图片
    CGImageRef imgRef =CGImageCreateWithImageInRect(image.CGImage, rect);
    
    //剪切后的图片转化成iamge
    UIImage *imagePart = [UIImage imageWithCGImage:imgRef];
    //引用计数减1，释放内存
    CGImageRelease(imgRef);
    
    //返回iamge
    return imagePart;
    
    
    
    
}


//通过矩阵来改变一个图层的几何形状
//CATransform3D 的数据结构定义了一个同质的三维变换（4x4 CGFloat值的矩阵），用于图层的旋转，缩放，偏移，歪斜和应用的透视。
//CATransform3DIdentity 是单位矩阵，该矩阵没有缩放，旋转，歪斜，透视。该矩阵应用到图层上，就是设置默认值。
//struct CATransform3D
//{
//    CGFloat     m11（x缩放）,    m12（y切变）,      m13（旋转）,     m14（）;
//    
//    CGFloat     m21（x切变）,    m22（y缩放）,      m23（）,             m24（）;
//    
//    CGFloat     m31（旋转）,      m32（ ）,               m33（）,               m34（透视效果，要操作的这个对象要有旋转的角度，否则没有效果。正直/负值都有意义）;
//    
//    CGFloat     m41（x平移）,     m42（y平移）,     m43（z平移）,     m44（）;
//};
-(CATransform3D)transform3D
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5/-2000;
    return transform;
}


//CALAYER动画的子类
-(CAShapeLayer *)maskForSection:(LayerSection)section withRect:(CGRect)rect
{
    
    CAShapeLayer *layerMask = [CAShapeLayer layer];
    UIRectCorner corners = (section == LayerSectionTop) ? 3 :12;
    layerMask.path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(5, 5)].CGPath;
    
    return layerMask;
    
}


//添加手势，长按和拖动
- (void)addGestureRecognizers
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handlePan:)];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(poke)];
    
    [self.topView addGestureRecognizer:panGestureRecognizer];
    [self.topView addGestureRecognizer:tapGestureRecognizer];
}
//刚进入动画向后弯曲5度
- (void)poke
{
    [self rotateToOriginWithVelocity:5];
}
- (void)rotateToOriginWithVelocity:(CGFloat)velocity
{
    POPSpringAnimation *rotationAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
    if (velocity > 0) {
        rotationAnimation.velocity = @(velocity);
    }
    rotationAnimation.springBounciness = 18.0f;
    rotationAnimation.dynamicsMass = 2.0f;
    rotationAnimation.dynamicsTension = 200;
    rotationAnimation.toValue = @(0);
    rotationAnimation.delegate = self;
    [self.topView.layer pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

//往下拖动动图片时
- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialLocation = location.y;
    }
    
    if ([[self.topView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] < -M_PI_2) {
        self.backView.alpha = 1.0;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.topShadowLayer.opacity = 0.0;
        self.bottomShadowLayer.opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        [CATransaction commit];
    } else {
        self.backView.alpha = 0.0;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        CGFloat opacity = (location.y-self.initialLocation)/(CGRectGetHeight(self.bounds)-self.initialLocation);
        self.bottomShadowLayer.opacity = opacity;
        self.topShadowLayer.opacity = opacity;
        [CATransaction commit];
    }
    
    if ([self isLocation:location inView:self]) {
        CGFloat conversionFactor = -M_PI / (CGRectGetHeight(self.bounds) - self.initialLocation);
        POPBasicAnimation *rotationAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        
        rotationAnimation.duration = 0.01;
        rotationAnimation.toValue = @((location.y-self.initialLocation)*conversionFactor);
        [self.topView.layer pop_addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    } else {
        recognizer.enabled = NO;
        recognizer.enabled = YES;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled) {
        [self rotateToOriginWithVelocity:0];
    }
}
- (BOOL)isLocation:(CGPoint)location inView:(UIView *)view
{
    if ((location.x > 0 && location.x < CGRectGetWidth(self.bounds)) &&
        (location.y > 0 && location.y < CGRectGetHeight(self.bounds))) {
        return YES;
    }
    return NO;
}



#pragma mark -popAnimationDelegate
-(void)pop_animationDidApply:(POPAnimation *)anim
{
    
    CGFloat currentValue = [[anim valueForKey:@"currentValue"]floatValue];
    if (currentValue > -M_PI_2) {
        self.backView.alpha = 0;
        [CATransaction begin];
          //显式事务默认开启动画效果,kCFBooleanTrue关闭
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        self.bottomShadowLayer.opacity = -currentValue/M_PI;
        self.topShadowLayer.opacity = -currentValue/M_PI;
        //提交动画
        [CATransaction commit];
        
        
    }
    
    
}

@end
