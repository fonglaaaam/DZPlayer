# DZPlayer
    simple way to play video in iOS  
    基于MPMoviePlayerController，支持横竖屏，上下滑动调节音量、屏幕亮度，左右滑动调节播放进度，缓冲进度显示（有点小问题）,锁屏（下载，社交分享，收藏，airplay等按钮已经包含，功能请自行在回调中实现）。 Based on MPMoviePlayerController, support for the horizontal screen, vertical screen (full screen playback can also lock the screen direction), the upper and lower slide to adjust the volume, the screen brightness, or so slide to adjust the playback progress。

##代码实现
```
 CGFloat width = [UIScreen mainScreen].bounds.size.width;
    __weak typeof(self)weakSelf = self;
     [DZPlayer showInFrame:CGRectMake(0, 20, width, width*(9.0/16.0))
                                                 WithClickBlock:^(NSInteger DZPClickType, NSDictionary *result) {
            switch (DZPClickType) {
                case DZPClickBack:{
                    if (weakSelf.navigationController != nil){
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    }
                }
                    break;
                case DZPClickPlay:{/* Do What U Want */}break;
                case DZPClickPuase:{/* Do What U Want */}break;
                case DZPClickFullScreen:{/* Do What U Want */}break;
                case DZPClickShrinkScreen:{/* Do What U Want */}break;
                case DZPClickSlidervalue:{ /* Do What U Want */}break;
                case DZPClickClose:{/* Do What U Want */}break;
                case DZPClickCollect:{
                    //模拟网络请求失败
                    double delayInSeconds = 1.0;
                    dispatch_time_t failTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(failTime, dispatch_get_main_queue(), ^(void){
                        [DZPlayer SObject].videoControl.collectBt.selected = NO;
                    });
                }break;
                case DZPClickAirplay:{/* Do What U Want */}break;
                case DZPClickDownload:{/* Do What U Want */}break;
                case DZPClickDanMu:{/* Do What U Want */}break;
                default:
                    break;
            }
    } dimissCompleteBlock:^{

    }];
    
//    [DZPlayer setContentURL:url];
    [DZPlayer setName:@"中华小当家" contentUrl:url];
    [DZPlayer SObject].videoControl.airplayBt.hidden = YES;
    [DZPlayer SObject].videoControl.shareBt.hidden = YES;
    [DZPlayer SObject].videoControl.playButton.hidden = YES;
```

模拟器没办法显示音量亮度的调节 请在真机上测试

![手机旋转设置](https://raw.githubusercontent.com/fonglaaaam/DZPlayer/master/DZPlayer/DZPlayer/setting.png)

![模拟器演示](https://raw.githubusercontent.com/fonglaaaam/DZPlayer/master/DZPlayer/DZPlayer/DZPlayer.gif)

