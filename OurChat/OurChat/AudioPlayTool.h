//
//  AudioPlayTool.h
//  OurChat
//
//  Created by geshu on 16/7/3.
//  Copyright © 2016年 personage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioPlayTool : NSObject
+(void)playWithMessage:(EMMessage *)msg msgLabel:(UILabel *)msgLabel receiver:(BOOL)receiver;

+(void)stop;
@end
