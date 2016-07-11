//
//  SettingViewController.m
//  OurChat
//
//  Created by geshu on 16/6/27.
//  Copyright © 2016年 personage. All rights reserved.
//

#import "SettingViewController.h"
#import "EaseMob.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *logoutBt;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 当前登录的用户名
    NSString *loginUsername = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    
    NSString *title = [NSString stringWithFormat:@"log out(%@)",loginUsername];
    
    //1.设置退出按钮的文字
    [self.logoutBt setTitle:title forState:UIControlStateNormal];

}
- (IBAction)logoutAction:(UIButton *)sender {
    //UnbindDeviceToken 不绑定DeviceToken
    // DeviceToken 推送用
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (error) {
            NSLog(@"退出失败 %@",error);
            
        }else{
            NSLog(@"退出成功");
            // 回到登录界面
            self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Login" bundle:nil].instantiateInitialViewController;
            
        }
    } onQueue:nil];
}







@end
