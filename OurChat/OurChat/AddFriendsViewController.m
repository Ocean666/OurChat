//
//  AddFriendsViewController.m
//  OurChat
//
//  Created by geshu on 16/6/19.
//  Copyright © 2016年 personage. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "EaseMob.h"

@interface AddFriendsViewController () <EMChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)addFriendAction:(UIButton *)sender {
    
    NSString *username = self.textField.text;
    //向服务器发送一个添加好友的的请求
    NSString *loginUserName = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    NSString *message = [@"我是" stringByAppendingString:loginUserName];
    EMError *error = nil;
    [[EaseMob sharedInstance].chatManager addBuddy:username message:message error:&error];
    if (error) {
        NSLog(@"添加好友有问题 %@",error);
    }else{
        NSLog(@"添加好友没有问题");
    }
    
}



@end
