//
//  AudioPlayTool.m
//  OurChat
//
//  Created by geshu on 16/7/3.
//  Copyright © 2016年 personage. All rights reserved.
//

#import "AudioPlayTool.h"
#import "EMCDDeviceManager.h"

@implementation AudioPlayTool
//正在执行动画的ImageView
static UIImageView *animatingImageView;

+(void)playWithMessage:(EMMessage *)msg msgLabel:(UILabel *)msgLabel receiver:(BOOL)receiver{
    
    // 把以前的动画移除
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
    
    //1.播放语音
    //获取语音路径
    EMVoiceMessageBody *voiceBody = msg.messageBodies[0];
    
    // 本地语音文件路径
    NSString *path = voiceBody.localPath;
    
    // 如果本地语音文件不存在，使用服务器语音
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:path]) {
        path = voiceBody.remotePath;
    }
    
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error) {
        
        NSLog(@"语音播放完成 %@",error);
        // 移除动画
        [animatingImageView stopAnimating];
        [animatingImageView removeFromSuperview];
        
        
    }];
    
    //2.添加动画
    //2.1创建一个UIImageView 添加到Label上
    UIImageView *imgView = [[UIImageView alloc] init];
    [msgLabel addSubview:imgView];
    
    //2.2添加动画图片
    if (receiver) {
        imgView.animationImages = @[[UIImage imageNamed:@"chat_receiver_audio_playing000"],
                                    [UIImage imageNamed:@"chat_receiver_audio_playing001"],
                                    [UIImage imageNamed:@"chat_receiver_audio_playing002"],
                                    [UIImage imageNamed:@"chat_receiver_audio_playing003"]];
        imgView.frame = CGRectMake(0, 0, 30, 30);
    }else{
        imgView.animationImages = @[[UIImage imageNamed:@"chat_sender_audio_playing_000"],
                                    [UIImage imageNamed:@"chat_sender_audio_playing_001"],
                                    [UIImage imageNamed:@"chat_sender_audio_playing_002"],
                                    [UIImage imageNamed:@"chat_sender_audio_playing_003"]];
        
        imgView.frame = CGRectMake(msgLabel.bounds.size.width - 30, 0, 30, 30);
    }
    
    imgView.animationDuration = 1;
    [imgView startAnimating];
    animatingImageView = imgView;
    
}

+(void)stop
{
    //停止播放语音
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    //移除动画
    [animatingImageView stopAnimating];
    [animatingImageView removeFromSuperview];
}













@end
