//
//  DZPlayerControlView.h
//  
//
//  Created by linfeng on 3/10/16.
//  Copyright (c) 2016 dingzai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface DZPlayerTopBarView : UIView
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *airplayBt;
@property (nonatomic, strong) UIButton *lockBt;
@property (nonatomic, strong) UIButton *shareBt;
@property (nonatomic, strong) UIButton *downloadBt;
@property (nonatomic, strong) UIButton *collectBt;
@property (nonatomic, strong) UIButton *naviBackBt;
@property (nonatomic, strong) UILabel  *nameLabel;
@end

@interface DZPlayerControlView : UIView
@property (nonatomic, strong, readonly) UIImageView *movieFastView;
@property (nonatomic, strong, readonly) DZPlayerTopBarView *topBar;
@property (nonatomic, strong, readonly) UIView *bottomBar;
@property (nonatomic, strong, readonly) UIButton *playButton;
@property (nonatomic, strong, readonly) UIButton *pauseButton;
@property (nonatomic, strong, readonly) UIButton *fullScreenButton;
@property (nonatomic, strong, readonly) UIButton *shrinkScreenButton;
@property (nonatomic, strong, readonly) UISlider *progressSlider;
@property (nonatomic, strong, readonly) UISlider *cacheProgress;
@property (nonatomic, strong, readonly) UIButton *closeButton;
@property (nonatomic, strong, readonly) UILabel *timeLabel;
@property (nonatomic, strong, readonly) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong, readonly) UIButton *airplayBt;
@property (nonatomic, strong, readonly) UIButton *lockBt;
@property (nonatomic, strong, readonly) UIButton *shareBt;
@property (nonatomic, strong, readonly) UIButton *downloadBt;
@property (nonatomic, strong, readonly) UIButton *collectBt;
@property (nonatomic, strong, readonly) UIButton *naviBackBt;
@property (nonatomic, strong, readonly) UILabel  *nameLabel;

- (void)animateHide;
- (void)animateShow;
- (void)autoFadeOutControlBar;
- (void)cancelAutoFadeOutControlBar;

@end

