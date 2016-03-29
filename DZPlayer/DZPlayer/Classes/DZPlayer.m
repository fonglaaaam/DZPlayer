//
//  DZPlayer.m
//  
//
//  Created by linfeng on 3/10/16.
//  Copyright (c) 2016 dingzai. All rights reserved.
//

#import "DZPlayer.h"
#import <MediaPlayer/MediaPlayer.h>

static const CGFloat dzVideoPlayerControllerAnimationTimeInterval = 0.3f;

@interface DZPlayer ()
@property (nonatomic, strong) UIView *movieBackgroundView;
@property (nonatomic, assign) BOOL isFullscreenMode;
@property (nonatomic, assign) BOOL horizontal;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSTimer *durationTimer;
@property (nonatomic, assign) DZPlayerMoveState moveState;
@property (nonatomic, assign) CGPoint startMovePoint;

@property (nonatomic, strong)UISlider *volumeViewSlider;
@property (nonatomic, strong)UISlider *slider;
@property (nonatomic, assign)CGPoint firstPoint;
@property (nonatomic, assign)CGPoint secondPoint;

@end

@implementation DZPlayer
+ (DZPlayer *)SObject {
    static dispatch_once_t once_t;
    static id sharedObject = nil;
    dispatch_once(&once_t, ^{
        if (sharedObject == nil) {
            sharedObject = [[[self class] alloc] init];
        }
    });
    return sharedObject;
}

- (void)dealloc{
    [self cancelObserver];
}

- (DZPlayer *)initWithFrame:(CGRect)frame{
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor blackColor];
    self.controlStyle = MPMovieControlStyleNone;
    [self.view addSubview:self.videoControl];
    self.videoControl.frame = self.view.bounds;
    [self configObserver];
    [self configControlAction];
    [self configureVolume];
    self.moveState = None;
    self.startMovePoint = CGPointZero;
    return self;
}

#pragma mark - Override Method
- (void)setContentURL:(NSURL *)contentURL{
    [self stop];
    [super setContentURL:contentURL];
    [self play];
}

+ (void)setContentURL:(NSURL *)contentURL{
    DZPlayer *viewController = [[self class] SObject];
    [viewController setContentURL:contentURL];
}

+ (void)setName:(NSString *)name contentUrl:(NSURL *)contentURL{
    DZPlayer *viewController = [[self class] SObject];
    [viewController setContentURL:contentURL];
    viewController.videoControl.nameLabel.text = name;
    
    //获取系统音量
}

#pragma mark - Public Method
+ (void)showInFrame:(CGRect)frame WithClickBlock:(void(^)(NSInteger status, NSDictionary *result))completed dimissCompleteBlock:(void(^)())dimissBolck{
    DZPlayer *viewController = [[[self class] SObject] initWithFrame:frame];
    [viewController showInWindowWithClickBlock:completed dimissCompleteBlock:dimissBolck];
}

+ (BOOL)isExist{
    if ([[DZPlayer SObject].contentURL absoluteString].length != 0 ) {
        return YES;
    }
    return NO;
}

+ (void)fullScreen{
    [[DZPlayer SObject] fullScreenButtonClick];
}

- (void)showInWindowWithClickBlock:(void (^)(NSInteger, NSDictionary *))completed dimissCompleteBlock:(void(^)())dimissBolck{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (!keyWindow) {
        keyWindow = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [keyWindow addSubview:self.view];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:dzVideoPlayerControllerAnimationTimeInterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    self.clickBlock = completed;
    self.dimissCompleteBlock = dimissBolck;
}

- (void)dismiss{
    [self stopDurationTimer];
    [self stop];
    [UIView animateWithDuration:dzVideoPlayerControllerAnimationTimeInterval animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if (self.dimissCompleteBlock) {
            self.dimissCompleteBlock();
        }
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Private Method
- (void)configObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
    
}

- (void)cancelObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configControlAction{
    [self.videoControl.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
    
    [self.videoControl.naviBackBt addTarget:self action:@selector(naviBackBtClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.lockBt addTarget:self action:@selector(lockBtClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.airplayBt addTarget:self action:@selector(airplayBtClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.collectBt addTarget:self action:@selector(collectBtClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControl.shareBt addTarget:self action:@selector(shareBtClick) forControlEvents:UIControlEventTouchUpInside];

}

//获取系统音量
- (void)configureVolume{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
//    NSError *setCategoryError = nil;
//    BOOL success = [[AVAudioSession sharedInstance]
//                    setCategory: AVAudioSessionCategoryPlayback
//                    error: &setCategoryError];
//    
//    if (!success) { /* handle the error in setCategoryError */ }
}


- (void)onMPMoviePlayerPlaybackStateDidChangeNotification{
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        self.videoControl.pauseButton.hidden = NO;
        self.videoControl.playButton.hidden = YES;
        [self startDurationTimer];
        [self.videoControl.indicatorView stopAnimating];
        [self.videoControl autoFadeOutControlBar];
    } else {
        self.videoControl.pauseButton.hidden = YES;
        self.videoControl.playButton.hidden = NO;
        [self stopDurationTimer];
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            [self.videoControl animateShow];
        }
    }
}

- (void)onMPMoviePlayerLoadStateDidChangeNotification{
    if (self.loadState & MPMovieLoadStateStalled) {
        [self.videoControl.indicatorView startAnimating];
    }
}

- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification{
    
}

- (void)onMPMovieDurationAvailableNotification{
    [self setProgressSliderMaxMinValues];
}

- (void)naviBackBtClick{
    if (self.isFullscreenMode) {
        [self shrinkScreenButtonClick];        
    }else{
        [self closeButtonClick];
        self.clickBlock(DZPClickBack,nil);
    }
}

- (void)lockBtClick{
    if(self.videoControl.lockBt.selected == NO){
        self.videoControl.lockBt.selected = YES;
        self.videoControl.bottomBar.hidden = YES;
        for (UIView *subView in self.videoControl.topBar.subviews) {
            if(subView != self.videoControl.lockBt){
                subView.alpha = 0;
                subView.userInteractionEnabled = NO;
            }
        }
    }else{
        self.videoControl.lockBt.selected = NO;
        self.videoControl.bottomBar.hidden = NO;
        for (UIView *subView in self.videoControl.topBar.subviews) {
            subView.alpha = 1;
            subView.userInteractionEnabled = YES;
        }
    }
    self.clickBlock(DZPClickLock,nil);
}

- (void)airplayBtClick{
    if(self.videoControl.airplayBt.selected == NO){
        self.videoControl.airplayBt.selected = YES;
    }else{
        self.videoControl.airplayBt.selected = NO;
    }
    self.clickBlock(DZPClickAirplay,nil);
}

- (void)collectBtClick{
    if(self.videoControl.collectBt.selected == NO){
        self.videoControl.collectBt.selected = YES;
    }else{
        self.videoControl.collectBt.selected = NO;
    }
    self.clickBlock(DZPClickCollect,nil);
}

- (void)shareBtClick{
    self.clickBlock(DZPClickShare,nil);
}

- (void)playButtonClick{
    [self play];
    self.videoControl.playButton.hidden = YES;
    self.videoControl.pauseButton.hidden = NO;
}

- (void)pauseButtonClick{
    [self pause];
    self.videoControl.playButton.hidden = NO;
    self.videoControl.pauseButton.hidden = YES; 
}

- (void)closeButtonClick{
    [self dismiss];
}

- (void)fullScreenButtonClick{
    if (self.isFullscreenMode) {
        return;
    }
    self.originFrame = self.view.frame;
    CGFloat height = [[UIScreen mainScreen] bounds].size.width;
    CGFloat width = [[UIScreen mainScreen] bounds].size.height;
    CGRect frame = CGRectMake((height - width) / 2, (width - height) / 2, width, height);;
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = frame;
        [self.view setTransform:CGAffineTransformMakeRotation(M_PI_2)];
    } completion:^(BOOL finished) {
        self.isFullscreenMode = YES;
        self.horizontal = YES;
        self.videoControl.fullScreenButton.hidden = YES;
        self.videoControl.shrinkScreenButton.hidden = NO;
    }];
}

- (void)shrinkScreenButtonClick{
    if (!self.isFullscreenMode) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        [self.view setTransform:CGAffineTransformIdentity];
        self.frame = self.originFrame;
    } completion:^(BOOL finished) {
        self.isFullscreenMode = NO;
        self.videoControl.fullScreenButton.hidden = NO;
        self.videoControl.shrinkScreenButton.hidden = YES;
    }];
}

- (void)pan:(UIPanGestureRecognizer *)gesture{
    CGPoint locationPoint = [gesture locationInView:self.videoControl];
    CGPoint veloctyPoint = [gesture velocityInView:self.videoControl];

    UIImage *image0 = [UIImage imageNamed:@"ic_fast_forward_white"];
    UIImage *image1 = [UIImage imageNamed:@"ic_fast_backward_white"];
    if(!CGRectContainsPoint(self.videoControl.bottomBar.frame, locationPoint) && (self.videoControl.lockBt.selected!=YES)){
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan:
            {
                if (self.moveState != None) {
                    gesture.enabled = NO;
                    gesture.enabled = YES;
                }
                
                self.startMovePoint = locationPoint;
                if (fabs(veloctyPoint.y) > fabs(veloctyPoint.x)) { //上下移动 声音
                    if (locationPoint.x > self.videoControl.bounds.size.width / 2) {
                        self.moveState = Volume;
                    }else { // 状态改为显示亮度调节
                        self.moveState = Bright;
                    }
                }else { //左右移动 播放进度
                    self.moveState = Progress;
                    [self pause];
                    [self.videoControl cancelAutoFadeOutControlBar];
                    self.videoControl.movieFastView.image = veloctyPoint.x >= 0 ? image0 : image1;
                    self.videoControl.movieFastView.alpha = 1;
                }
            }
                break;
            case UIGestureRecognizerStateChanged:
            {
                switch (self.moveState) {
                    case Volume:{
                        self.volumeViewSlider.value -= veloctyPoint.y / 10000;
                    }
                        break;
                    case Bright:{
                        [UIScreen mainScreen].brightness -= veloctyPoint.y / 10000;
                    }
                        break;

                    case Progress:{
    //                    dist        slider.value
    //                   -----   =  ---------------
    //            screen.width        self.draution
                        CGFloat dist = locationPoint.x - self.startMovePoint.x;
                        double time = floor(dist*self.duration/self.view.frame.size.width);
                        double totalTime = floor(self.duration);
                        time += self.videoControl.progressSlider.value;
//                        self.videoControl.progressSlider.value = time;//进度随手势移动 但是过快
                        [self setTimeLabelValues:time totalTime:totalTime];
                        [self setCurrentPlaybackTime:floor(time)];
                        self.videoControl.movieFastView.image = dist > 0 ? image0 : image1;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            {
                switch (self.moveState) {
                    case Volume:{
                        self.moveState = None;
                    }
                        break;
                    case Progress:{
                        [self play];
                        self.videoControl.playButton.selected = YES;
                        [self.videoControl autoFadeOutControlBar];
                        [UIView animateWithDuration:0.3f animations:^{
                            self.videoControl.movieFastView.alpha = 0;
                        } completion:nil];
                        self.moveState = None;
                    }
                        break;
                default:
                    {
                        self.moveState = None;
                    }
                        break;
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)setProgressSliderMaxMinValues {
    CGFloat duration = self.duration;
    self.videoControl.progressSlider.minimumValue = 0.f;
    self.videoControl.progressSlider.maximumValue = floor(duration);
    
    self.videoControl.cacheProgress.minimumValue = 0.f;
    self.videoControl.cacheProgress.maximumValue = floor(duration);
}

- (void)progressSliderTouchBegan:(UISlider *)slider {
    [self pause];
    NSLog(@"Began value %f",slider.value);
    [self.videoControl cancelAutoFadeOutControlBar];
}

- (void)progressSliderTouchEnded:(UISlider *)slider {
    NSLog(@"End value %f",slider.value);
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self.videoControl autoFadeOutControlBar];
}

- (void)progressSliderValueChanged:(UISlider *)slider {
    NSLog(@"Change value %f",slider.value);
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

- (void)monitorVideoPlayback{
    double currentTime = floor(self.currentPlaybackTime);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    self.videoControl.progressSlider.value = ceil(currentTime);
    
    double cacheTime = floor(self.playableDuration);
    self.videoControl.cacheProgress.value = ceil(cacheTime);
}

- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);;
    double secondsRemaining = floor(fmod(totalTime, 60.0));;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.videoControl.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}

- (void)startDurationTimer{
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopDurationTimer{
    [self.durationTimer invalidate];
}

- (void)fadeDismissControl{
    [self.videoControl animateHide];
}

- (void)updateValue:(UISlider *)slider{
    self.slider.value = slider.value;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch *touch in event.allTouches) {
        
        self.firstPoint = [touch locationInView:self.view];
        
    }
    
    UISlider *slider = (UISlider *)[self.view viewWithTag:1000];
    slider.value = self.slider.value;
    NSLog(@"touchesBegan");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for(UITouch *touch in event.allTouches) {
        
        self.secondPoint = [touch locationInView:self.view];
        
    }
    NSLog(@"firstPoint==%f || secondPoint===%f",self.firstPoint.y,self.secondPoint.y);
    NSLog(@"first-second==%f",self.firstPoint.y - self.secondPoint.y);
    
    self.slider.value += (self.firstPoint.y - self.secondPoint.y)/500.0;
    
    UISlider *slider = (UISlider *)[self.view viewWithTag:1000];
    slider.value = self.slider.value;
    NSLog(@"value == %f",self.slider.value);
    self.firstPoint = self.secondPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesEnded");
    self.firstPoint = self.secondPoint = CGPointZero;
}

#pragma mark - Property
- (DZPlayerControlView *)videoControl{
    if (!_videoControl) {
        _videoControl = [[DZPlayerControlView alloc] init];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_videoControl addGestureRecognizer:panGesture];
    }
    return _videoControl;
}

- (UIView *)movieBackgroundView{
    if (!_movieBackgroundView) {
        _movieBackgroundView = [UIView new];
        _movieBackgroundView.alpha = 0.0;
        _movieBackgroundView.backgroundColor = [UIColor blackColor];
    }
    return _movieBackgroundView;
}

- (void)setFrame:(CGRect)frame{
    [self.view setFrame:frame];
    [self.videoControl setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [self.videoControl setNeedsLayout];
    [self.videoControl layoutIfNeeded];
}
@end
