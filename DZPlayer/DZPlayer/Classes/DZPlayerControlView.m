//
//  DZPlayerControlView.m
//  
//
//  Created by linfeng on 3/10/16.
//  Copyright (c) 2016 dingzai. All rights reserved.
//

#import "DZPlayerControlView.h"
#import <MediaPlayer/MediaPlayer.h>

static const CGFloat dzVideoControlBarHeight = 35.0;
static const CGFloat dzVideoControlButtonHeight = 30.0;
static const CGFloat dzVideoControlAnimationTimeInterval = 0.3;
static const CGFloat dzVideoControlTimeLabelFontSize = 10.0;
static const CGFloat dzVideoControlNameLabelFontSize = 15.0;
static const CGFloat dzVideoControlBarAutoFadeOutTimeInterval = 5.0;

@interface DZPlayerControlView ()
//bottomBar
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *fullScreenButton;
@property (nonatomic, strong) UIButton *shrinkScreenButton;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UISlider *cacheProgress;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, assign) BOOL isBarShowing;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
//topBar
@property (nonatomic, strong) DZPlayerTopBarView *topBar;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *airplayBt;
@property (nonatomic, strong) UIButton *lockBt;
@property (nonatomic, strong) UIButton *shareBt;
@property (nonatomic, strong) UIButton *downloadBt;
@property (nonatomic, strong) UIButton *collectBt;
@property (nonatomic, strong) UIButton *naviBackBt;
@property (nonatomic, strong) UILabel  *nameLabel;
//fastView
@property (nonatomic, strong) UIImageView *movieFastView;
@end

@implementation DZPlayerControlView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.topBar];
        [self addSubview:self.movieFastView];
        [self addSubview:self.bottomBar];
        [self.bottomBar addSubview:self.playButton];
        [self.bottomBar addSubview:self.pauseButton];
        self.pauseButton.hidden = YES;
        [self.bottomBar addSubview:self.fullScreenButton];
        [self.bottomBar addSubview:self.shrinkScreenButton];
        self.shrinkScreenButton.hidden = YES;
        [self.bottomBar addSubview:self.cacheProgress];
        [self.bottomBar addSubview:self.progressSlider];
        [self.bottomBar addSubview:self.timeLabel];
        [self addSubview:self.indicatorView];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tapGesture];
        
        UIApplication *app = [UIApplication sharedApplication];
        if (![app isStatusBarHidden]){
            [app setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.topBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds), CGRectGetWidth(self.bounds), dzVideoControlBarHeight);
   
    self.movieFastView.center = self.center;

    self.bottomBar.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds) - dzVideoControlBarHeight, CGRectGetWidth(self.bounds), dzVideoControlBarHeight);
    self.playButton.frame = CGRectMake(CGRectGetMinX(self.bottomBar.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.playButton.bounds)/2, CGRectGetWidth(self.playButton.bounds), CGRectGetHeight(self.playButton.bounds));
    self.pauseButton.frame = self.playButton.frame;
    self.fullScreenButton.frame = CGRectMake(CGRectGetWidth(self.bottomBar.bounds) - CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.fullScreenButton.bounds)/2, CGRectGetWidth(self.fullScreenButton.bounds), CGRectGetHeight(self.fullScreenButton.bounds));
    self.shrinkScreenButton.frame = self.fullScreenButton.frame;
    self.progressSlider.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.progressSlider.bounds)/2, CGRectGetMinX(self.fullScreenButton.frame) - CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.progressSlider.bounds));
    self.cacheProgress.frame = CGRectMake(CGRectGetMaxX(self.playButton.frame), CGRectGetHeight(self.bottomBar.bounds)/2 - CGRectGetHeight(self.cacheProgress.bounds)/2, self.progressSlider.frame.size.width, CGRectGetHeight(self.cacheProgress.bounds));
    self.timeLabel.frame = CGRectMake(CGRectGetMidX(self.progressSlider.frame), CGRectGetHeight(self.bottomBar.bounds) - CGRectGetHeight(self.timeLabel.bounds) - 2.0, CGRectGetWidth(self.progressSlider.bounds)/2, CGRectGetHeight(self.timeLabel.bounds));
    self.indicatorView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    self.isBarShowing = YES;
}

- (void)animateHide{
    if (!self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:dzVideoControlAnimationTimeInterval animations:^{
        self.topBar.alpha = 0.0;
        self.bottomBar.alpha = 0.0;
        self.movieFastView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = NO;
    }];
}

- (void)animateShow{
    if (self.isBarShowing) {
        return;
    }
    [UIView animateWithDuration:dzVideoControlAnimationTimeInterval animations:^{
        self.topBar.alpha = 1.0;
        self.bottomBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isBarShowing = YES;
        [self autoFadeOutControlBar];
    }];
}

- (void)autoFadeOutControlBar{
    if (!self.isBarShowing) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
    [self performSelector:@selector(animateHide) withObject:nil afterDelay:dzVideoControlBarAutoFadeOutTimeInterval];
}

- (void)cancelAutoFadeOutControlBar{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateHide) object:nil];
}

- (void)onTap:(UITapGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.isBarShowing) {
            [self animateHide];
        } else {
            [self animateShow];
        }
    }
}

#pragma mark - Property

- (DZPlayerTopBarView *)topBar{
    if (!_topBar) {
        _topBar = [DZPlayerTopBarView new];
        _topBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _topBar;
}

- (UIView *)bottomBar{
    if (!_bottomBar) {
        _bottomBar = [UIView new];
        _bottomBar.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _bottomBar;
}

- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:[self videoImageName:@"ic_play_circle_outline_white"]] forState:UIControlStateNormal];
        _playButton.bounds = CGRectMake(0, 0, dzVideoControlBarHeight, dzVideoControlBarHeight);
    }
    return _playButton;
}

- (UIButton *)pauseButton{
    if (!_pauseButton) {
        _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pauseButton setImage:[UIImage imageNamed:[self videoImageName:@"ic_pause_circle_outline_white"]] forState:UIControlStateNormal];
        _pauseButton.bounds = CGRectMake(0, 0, dzVideoControlBarHeight, dzVideoControlBarHeight);
    }
    return _pauseButton;
}

- (UIButton *)fullScreenButton{
    if (!_fullScreenButton) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"ic_fullscreen_white"]] forState:UIControlStateNormal];
        _fullScreenButton.bounds = CGRectMake(0, 0, dzVideoControlBarHeight, dzVideoControlBarHeight);
    }
    return _fullScreenButton;
}

- (UIButton *)shrinkScreenButton{
    if (!_shrinkScreenButton) {
        _shrinkScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shrinkScreenButton setImage:[UIImage imageNamed:[self videoImageName:@"ic_fullscreen_exit_white"]] forState:UIControlStateNormal];
        _shrinkScreenButton.bounds = CGRectMake(0, 0, dzVideoControlBarHeight, dzVideoControlBarHeight);
    }
    return _shrinkScreenButton;
}

- (UISlider *)progressSlider{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider setThumbImage:[UIImage imageNamed:[self videoImageName:@"kr-video-player-point"]] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
        [_progressSlider setMaximumTrackTintColor:[[UIColor alloc]initWithRed:250 green:250 blue:250 alpha:0.3]];
        _progressSlider.value = 0.f;
        _progressSlider.continuous = YES;
    }
    return _progressSlider;
}

-(UISlider *)cacheProgress{
    if (!_cacheProgress){
        _cacheProgress = [[UISlider alloc] init];
        _cacheProgress.userInteractionEnabled = false;
        [_cacheProgress setMaximumTrackTintColor:[UIColor clearColor]];
        [_cacheProgress setMinimumTrackTintColor:[[UIColor alloc]initWithRed:255 green:255 blue:255 alpha:0.4]];
        _cacheProgress.thumbTintColor = [UIColor clearColor];
        [_cacheProgress setThumbTintColor:[UIColor clearColor]];//iPad 不隐藏
        _cacheProgress.value = 0.f;
        _progressSlider.continuous = YES;
    }
    return _cacheProgress;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:dzVideoControlTimeLabelFontSize];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.bounds = CGRectMake(0, 0, dzVideoControlTimeLabelFontSize, dzVideoControlTimeLabelFontSize);
    }
    return _timeLabel;
}

- (UIActivityIndicatorView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_indicatorView stopAnimating];
    }
    return _indicatorView;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = self.topBar.closeButton;
    }
    return _closeButton;
}

- (UIButton *)airplayBt{
    if (!_airplayBt) {
        _airplayBt = self.topBar.airplayBt;
    }
    return _airplayBt;
}

- (UIButton *)shareBt{
    if (!_shareBt) {
        _shareBt = self.topBar.shareBt;
    }
    return _shareBt;
}

- (UIButton *)downloadBt{
    if (!_downloadBt) {
        _downloadBt = self.topBar.downloadBt;
    }
    return _shareBt;
}

- (UIButton *)lockBt{
    if (!_lockBt) {
        _lockBt = self.topBar.lockBt;
    }
    return _lockBt;
}

- (UIButton *)collectBt{
    if (!_collectBt) {
        _collectBt = self.topBar.collectBt;
    }
    return _collectBt;
}

- (UIButton *)naviBackBt{
    if (!_naviBackBt) {
        _naviBackBt = self.topBar.naviBackBt;
    }
    return _naviBackBt;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = self.topBar.nameLabel;
    }
    return _nameLabel;
}

- (UIImageView *)movieFastView{
    if (!_movieFastView) {
        _movieFastView = [[UIImageView alloc]init];
        _movieFastView.alpha = 0.0;
//        _movieFastView.image = [UIImage imageNamed:[self videoImageName:@"kr-video-player-play"]];
        _movieFastView.bounds = CGRectMake(0, 0, 150, 150);
    }
    return _movieFastView;
}

#pragma mark - Private Method
- (NSString *)videoImageName:(NSString *)name{
    if (name) {
//        NSString *path = [NSString stringWithFormat:@"KRVideoPlayer.bundle/%@",name];
//        return path;
        return name;
    }
    return nil;
}
@end


@interface DZPlayerTopBarView ()
@end

@implementation DZPlayerTopBarView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.closeButton];
        [self addSubview:self.airplayBt];
        [self addSubview:self.lockBt];
        [self addSubview:self.shareBt];
        [self addSubview:self.downloadBt];
        [self addSubview:self.collectBt];
        [self addSubview:self.naviBackBt];
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.closeButton.bounds), CGRectGetMinX(self.bounds), CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));
    
    self.naviBackBt.frame = CGRectMake(CGRectGetMinX(self.bounds), CGRectGetHeight(self.bounds)/2 - CGRectGetHeight(self.naviBackBt.bounds)/2, CGRectGetWidth(self.naviBackBt.bounds), CGRectGetHeight(self.naviBackBt.bounds));
    
    self.nameLabel.frame = CGRectMake(dzVideoControlBarHeight, CGRectGetHeight(self.bounds)/2 - CGRectGetHeight(self.nameLabel.bounds)/2, 150 , CGRectGetHeight(self.nameLabel.bounds));
    
    NSInteger i = 2;
    for (UIView *subView in self.subviews) {
        if (subView.hidden == NO) {
            if (subView != self.closeButton && subView != self.naviBackBt && subView != self.nameLabel) {
                subView.frame = CGRectMake(CGRectGetWidth(self.bounds) - CGRectGetWidth(self.closeButton.bounds)*i++, CGRectGetMinX(self.bounds), CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));
            }
        }else{
            if (subView != self.closeButton && subView != self.naviBackBt && subView != self.nameLabel) {
                subView.frame = CGRectMake(-40, -40, CGRectGetWidth(self.closeButton.bounds), CGRectGetHeight(self.closeButton.bounds));
            }
        }
    }
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:[self videoImageName:@"ic_close_white"]] forState:UIControlStateNormal];
        _closeButton.bounds = CGRectMake(0, 0, dzVideoControlBarHeight, dzVideoControlBarHeight);
    }
    return _closeButton;
}

- (UIButton *)airplayBt{
    if (!_airplayBt) {
        _airplayBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_airplayBt setImage:[UIImage imageNamed:[self videoImageName:@"btn_player_airplay"]] forState:UIControlStateNormal];
        [_airplayBt setImage:[UIImage imageNamed:[self videoImageName:@"btn_player_airplay_on"]] forState:UIControlStateSelected];
        _airplayBt.bounds = CGRectMake(0, 0, dzVideoControlButtonHeight, dzVideoControlButtonHeight);
    }
    return _airplayBt;
}

- (UIButton *)shareBt{
    if (!_shareBt) {
        _shareBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBt setImage:[UIImage imageNamed:[self videoImageName:@"bar_btn_share"]] forState:UIControlStateNormal];
        _shareBt.bounds = CGRectMake(0, 0, dzVideoControlButtonHeight, dzVideoControlButtonHeight);
    }
    return _shareBt;
}

- (UIButton *)downloadBt{
    if (!_shareBt) {
        _shareBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBt setImage:[UIImage imageNamed:[self videoImageName:@"bar_btn_share"]] forState:UIControlStateNormal];
        _shareBt.bounds = CGRectMake(0, 0, dzVideoControlButtonHeight, dzVideoControlButtonHeight);
    }
    return _shareBt;
}

- (UIButton *)lockBt{
    if (!_lockBt) {
        _lockBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBt setImage:[UIImage imageNamed:[self videoImageName:@"btn_player_lock"]] forState:UIControlStateNormal];
        [_lockBt setImage:[UIImage imageNamed:[self videoImageName:@"ic_lock_on"]] forState:UIControlStateSelected];
        _lockBt.bounds = CGRectMake(0, 0, dzVideoControlButtonHeight, dzVideoControlButtonHeight);
    }
    return _lockBt;
}

- (UIButton *)collectBt{
    if (!_collectBt) {
        _collectBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectBt setImage:[UIImage imageNamed:[self videoImageName:@"ic_star_white"]] forState:UIControlStateNormal];
        [_collectBt setImage:[UIImage imageNamed:[self videoImageName:@"ic_star_white_on"]] forState:UIControlStateSelected];
        _collectBt.bounds = CGRectMake(0, 0, dzVideoControlButtonHeight, dzVideoControlButtonHeight);
    }
    return _collectBt;
}

- (UIButton *)naviBackBt{
    if (!_naviBackBt) {
        _naviBackBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [_naviBackBt setImage:[UIImage imageNamed:[self videoImageName:@"ic_navigate_white"]] forState:UIControlStateNormal];
        _naviBackBt.bounds = CGRectMake(0, 0, dzVideoControlButtonHeight, dzVideoControlButtonHeight);
    }
    return _naviBackBt;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:dzVideoControlNameLabelFontSize];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.bounds = CGRectMake(0, 0, dzVideoControlNameLabelFontSize, dzVideoControlNameLabelFontSize);
    }
    return _nameLabel;
}

#pragma mark - Private Method
- (NSString *)videoImageName:(NSString *)name{
    if (name) {
        //        NSString *path = [NSString stringWithFormat:@"KRVideoPlayer.bundle/%@",name];
        //        return path;
        return name;
    }
    return nil;
}
@end
