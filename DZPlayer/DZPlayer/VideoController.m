//
//  VideoController.m
//  DZPlayer
//
//  Created by dz on 16/3/16.
//  Copyright © 2016年 linfeng. All rights reserved.
//

#import "VideoController.h"
#import "DZPlayer.h"


@implementation VideoController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self playRemoteVideo:@"http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"];
}

- (void)playRemoteVideo:(NSString *)urlString{
    NSURL *videoURL = [NSURL URLWithString:urlString];
    [self playVideoWithURL:videoURL];
}

- (void)playVideoWithURL:(NSURL *)url{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    __weak typeof(self)weakSelf = self;
    
    [DZPlayer showInFrame:CGRectMake(0, 0, width, width*(9.0/16.0))
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
                   case DZPClickCollect:{/* Do What U Want */}break;
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
}
@end
