//
//  DZPlayer.h
//  
//
//  Created by linfeng on 3/10/16.
//  Copyright (c) 2016 dingzai. All rights reserved.
//

@import MediaPlayer;
#import "DZPlayerControlView.h"

typedef NS_ENUM(NSInteger, DZPClickType) {
    DZPClickBack                = 0,
    DZPClickPlay                = 1,
    DZPClickPuase               = 2,
    DZPClickFullScreen,
    DZPClickShrinkScreen,
    DZPClickSlidervalue,
    DZPClickClose,
    DZPClickCollect,
    DZPClickDownload,
    DZPClickAirplay,
    DZPClickDanMu,
    DZPClickLock,
    DZPClickShare
};

typedef NS_ENUM(NSInteger, DZPlayerMoveState) {
    None                = 0,
    Progress            = 1,
    Volume              = 2,
    Bright
};

@interface DZPlayer : MPMoviePlayerController

@property (nonatomic, strong) DZPlayerControlView *videoControl;
@property (nonatomic, copy)void(^dimissCompleteBlock)(void);
@property (nonatomic, assign) CGRect frame;
@property(nonatomic, copy)void (^clickBlock)(NSInteger clickType, NSDictionary *result);

- (instancetype)initWithFrame:(CGRect)frame;
- (void)showInWindowWithClickBlock:(void(^)(NSInteger status, NSDictionary *result))completed dimissCompleteBlock:(void(^)())dimissBolck;
- (void)dismiss;

+ (DZPlayer *)SObject;
+ (BOOL)isExist;
+ (void)setName:(NSString *)name contentUrl:(NSURL *)contentURL;
+ (void)setContentURL:(NSURL *)contentURL;
+ (void)showInFrame:(CGRect)frame WithClickBlock:(void(^)(NSInteger status, NSDictionary *result))completed dimissCompleteBlock:(void(^)())dimissBolck;
+ (void)fullScreen;
@end