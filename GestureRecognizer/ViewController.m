//
//  ViewController.m
//  GestureRecognizer
//
//  Created by HZhenF on 17/3/29.
//  Copyright © 2017年 筝风放风筝. All rights reserved.
//

#import "ViewController.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

/*
 这种方法获取也可以，不过很少用
#define ScreenWidth CGRectGetWidth(self.view.frame)
#define ScreenHeight CGRectGetHeight(self.view.frame)
*/
@interface ViewController ()<UIGestureRecognizerDelegate>
{
    double angle;
}

/**临时保存放大前的ImageView*/
@property(nonatomic,strong) UIImageView *oldImageView;

@property(nonatomic,strong) UIImageView *imageView1;

@property(nonatomic,strong) UIImageView *imageView2;

/**遮罩*/
@property(nonatomic,strong) UIButton *btn_pat;

@property(nonatomic,strong) NSMutableArray *arrMPict;

/**记录图片的索引*/
@property(nonatomic,assign) int index;

/**记录是否长按*/
@property(nonatomic,assign) BOOL flag;

/**长按次数*/
@property(nonatomic,assign) int frequency;

@property(nonatomic,strong) NSTimer *timer;

@end

@implementation ViewController

-(NSTimer *)timer
{
    if (!_timer) {
        _timer =  [[NSTimer alloc] init];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

-(NSMutableArray *)arrMPict
{
    if (!_arrMPict) {
        _arrMPict = [NSMutableArray array];
    }
    return _arrMPict;
}

-(UIButton *)btn_pat
{
    if (!_btn_pat) {
        _btn_pat = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _btn_pat.backgroundColor = [UIColor blackColor];
        _btn_pat.alpha = 0;
        [_btn_pat addTarget:self action:@selector(changeImageViewFrameToSmall) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btn_pat];
    }
    return _btn_pat;
}

-(UIImageView *)imageView1
{
    if (!_imageView1) {
        _imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - 200)*0.5,(CGRectGetHeight(self.view.frame) - 20 - 200)*0.25 ,200 ,200 )];
        _imageView1.userInteractionEnabled = YES;
    }
    [self.view addSubview:_imageView1];
    return _imageView1;
}

-(UIImageView *)imageView2
{
    if (!_imageView2) {
        _imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.imageView1.frame), CGRectGetMaxY(self.imageView1.frame) + 100, 200, 200)];
        _imageView2.userInteractionEnabled = YES;
        [self.view addSubview:_imageView2];
    }
    return _imageView2;
}

-(UIImageView *)oldImageView
{
    if (!_oldImageView) {
        _oldImageView = [[UIImageView alloc] init];
        _oldImageView.userInteractionEnabled = YES;
    }
    return _oldImageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    

    
    for (int i = 1; i <= 2; i ++) {
        [self.arrMPict addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg",i]]];

    }
    
    self.imageView1.image = self.arrMPict[0];
    self.imageView2.image = self.arrMPict[1];
    
    self.index = 0;
    
    //添加手势
    [self addGesture:self.imageView1];
    [self addGesture:self.imageView2];
    

}

/**添加各种手势*/
-(void)addGesture:(UIImageView *)imageView
{
    //单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickControlWithTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [imageView addGestureRecognizer:tap];
    
    //长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onClickControlWithLongPress:)];
    longPress.numberOfTouchesRequired = 1;
    //手指按下多少秒后触发事件
    longPress.minimumPressDuration = 1.5;
    //手指按下后事件响应之前允许手指移动的偏移量
    longPress.allowableMovement = 0;
    [imageView addGestureRecognizer:longPress];
    
    //轻扫手势
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onClickControlWithSwipe:)];
    //允许轻扫的方法(PS:如果这里用分隔符来存放多个方向手势，会出现错误的效果，可以创建多个轻扫手势，然后这些轻扫手势设置不同的轻扫方向，然后全部加入imageView中)
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    swipe.delegate = self;
    [imageView addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swipe1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onClickControlWithSwipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [imageView addGestureRecognizer:swipe1];
    
    //旋转手势
    UIRotationGestureRecognizer *rotation = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onClickControlWithRotation:)];
    [imageView addGestureRecognizer:rotation];
    
    //捏合手势
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onClickControlWithPinch:)];
    [imageView addGestureRecognizer:pinch];
    
    //拖拽手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onClickControlWithPan:)];
    pan.delegate = self;
    [imageView addGestureRecognizer:pan];
    
    
}



/**代理方法，判断能否相应多个手势*/
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //轻扫和拖拽两个手势一起用，会互斥，只认拖拽不认轻扫
//    NSLog(@"%@ - %@", gestureRecognizer.class, otherGestureRecognizer.class);
    return YES;
}


/**拖拽事件*/
-(void)onClickControlWithPan:(UIPanGestureRecognizer *)pan
{
    if (self.btn_pat.alpha == 0) {
        CGPoint point = [pan translationInView:pan.view];
        CGPoint temp = pan.view.center;
        temp.x += point.x;
        temp.y += point.y;
        pan.view.center = temp;
        //和旋转、捏合一样的原理
        [pan setTranslation:CGPointZero inView:pan.view];
    }
}

/**捏合事件*/
-(void)onClickControlWithPinch:(UIPinchGestureRecognizer *)pinch
{
    pinch.view.transform = CGAffineTransformScale(pinch.view.transform, pinch.scale, pinch.scale);
    /*
     和旋转一样的原理，如果不把捏合程度每次都变为1，也会累乘
     */
    pinch.scale = 1.0;
}

/**旋转事件*/
-(void)onClickControlWithRotation:(UIRotationGestureRecognizer *)rotation
{
    if (self.btn_pat.alpha == 1) {
        rotation.view.transform = CGAffineTransformRotate(rotation.view.transform, rotation.rotation);
        //注意，这里每次旋转后都让旋转弧度归零
        /*
          因为每次旋转，rotation.rotatin都是累加的
          比如说:从0开始旋转，第一次旋转了1，那么结果应该是0+1=1  此时rotation.rotatin = 1
                然后再旋转1，那么就是0+1+1，结果应该是2         但是！此时rotation.rotatin = 2(因为是累加的，他是相对于原点移动了2)
                这个时候就会产生错误的结果     产生错误结果原因:0+1+2=3    所以就会越转越快了，因为结果错误
          解决办法:每次旋转后，让rotation.rotatin归零，不需要他给我累加，移动1就变1
         */
        rotation.rotation = 0;
    }
}

/**轻扫事件*/
-(void)onClickControlWithSwipe:(UISwipeGestureRecognizer *)swipe
{
    UIImageView *imageView =  (UIImageView *)swipe.view;
    
    if ((self.btn_pat.alpha == 1) && (swipe.direction == UISwipeGestureRecognizerDirectionRight)) {
        if (self.index <= 0) {
            imageView.image = self.arrMPict[self.index];
        }
        else
        {
            self.index -- ;
            imageView.image = self.arrMPict[self.index];
        }
    }
    else if((self.btn_pat.alpha == 1) && (swipe.direction == UISwipeGestureRecognizerDirectionLeft))
    {
        if (self.index >= self.arrMPict.count - 1) {
            imageView.image = self.arrMPict[self.index];
        }
        else
        {
            self.index ++ ;
            imageView.image = self.arrMPict[self.index];
        }
    }
}


/**长按事件*/
-(void)onClickControlWithLongPress:(UILongPressGestureRecognizer *)longPress
{
    /*
     长按有三个状态:
     第一，长按下去，直到刚触发事件  longPress.state = 1  UIGestureRecognizerStateBegan
     第二，长按下去后(不松开手指)，手指上下左右移动   longPress.state = 2 UIGestureRecognizerStateChanged
     第三，长按结束，松开手指   longPress.state = 3 UIGestureRecognizerStateEnded
     */
    if (longPress.state == 1) {
        self.frequency ++ ;
        if (!self.flag) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(transformAction:) userInfo:longPress repeats:YES];
        }
        else
        {
            self.flag = NO;
            [self.timer invalidate];
            self.timer = nil;
        }
    }
    else if(longPress.state == 3)
    {
        //长按的次数如果是奇数次，那么就旋转
        //第一次是旋转，第二次停止，第三次旋转，第四次停止...
        if(self.frequency % 2 != 0)
        {
            self.flag = YES;
        }
        else
        {
            self.flag = NO;
        }
    }
}

/**NSTimer调用的方法*/
-(void)transformAction:(NSTimer *)timer
{
    UILongPressGestureRecognizer * longPress = [timer userInfo];
    longPress.view.transform = CGAffineTransformRotate(longPress.view.transform, 0.02);
    
}

/**单击事件*/
-(void)onClickControlWithTap:(UITapGestureRecognizer *)tap
{
    //保存变化前的frame
    if (self.btn_pat.alpha == 0) {
            //UIImageView中frame和image属性都要保存，否则为null
            self.oldImageView.frame = tap.view.frame;
            self.oldImageView.bounds = tap.view.bounds;
            UIImageView *imgView = (UIImageView *)tap.view;
            self.oldImageView.image= imgView.image;
            [UIView animateWithDuration:1.0f animations:^{
            [self.view addSubview:self.btn_pat];
            [self.view bringSubviewToFront:tap.view];
                if (self.frequency % 2 != 0) {
                    tap.view.bounds = CGRectMake(0, 0, tap.view.bounds.size.width * 1.5, tap.view.bounds.size.height * 1.5);
                    tap.view.center = CGPointMake(ScreenWidth *0.5, (ScreenHeight - 20) * 0.5);
                }
                else
                {
                    tap.view.frame = CGRectMake(0, (ScreenHeight - ScreenWidth)*0.5, ScreenWidth, ScreenWidth);
                }
            self.btn_pat.alpha = 1;
        }];
    }
    else
    {
        [self changeImageViewFrameToSmall];
    }
}

/**恢复图片到原来大小位置*/
-(void)changeImageViewFrameToSmall
{
    UIImageView *tempImageView = [[self.view subviews] lastObject];
    [UIView animateWithDuration:1.0f animations:^{
        tempImageView.frame = self.oldImageView.frame;
        tempImageView.bounds = self.oldImageView.bounds;
        tempImageView.transform = self.oldImageView.transform;
        self.btn_pat.alpha = 0;
    } completion:^(BOOL finished) {
        tempImageView.image = self.oldImageView.image;
    }];
}

@end
