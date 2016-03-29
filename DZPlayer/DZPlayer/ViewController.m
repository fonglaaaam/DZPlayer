//
//  ViewController.m
//  DZPlayer
//
//  Created by dz on 16/3/15.
//  Copyright © 2016年 linfeng. All rights reserved.
//

#import "ViewController.h"
#import "DZPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self playRemoteVideo:nil];
}

- (IBAction)playLocalVideo:(id)sender{
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"basketball" withExtension:@"mov"];
    [self playVideoWithURL:videoURL];
}

- (IBAction)playRemoteVideo:(id)sender{
    NSURL *videoURL = [NSURL URLWithString:@"http://krtv.qiniudn.com/150522nextapp"];
    [self playVideoWithURL:videoURL];
}

- (void)playVideoWithURL:(NSURL *)url{
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
        UIApplication *app = [UIApplication sharedApplication];
        if ([app isStatusBarHidden]){
            [app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
    }];
    
//    [DZPlayer setContentURL:url];
    [DZPlayer setName:@"中华小当家" contentUrl:url];
    [DZPlayer SObject].videoControl.airplayBt.hidden = YES;
    [DZPlayer SObject].videoControl.shareBt.hidden = YES;
    [DZPlayer SObject].videoControl.playButton.hidden = YES;
}

@end
