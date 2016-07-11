//
//  ConversationViewController.m
//  OurChat
//
//  Created by geshu on 16/6/18.
//  Copyright © 2016年 personage. All rights reserved.
//

#import "ConversationViewController.h"
#import "EaseMob.h"
#import "ChatViewController.h"

@interface ConversationViewController () <EMChatManagerDelegate>
/** 历史会话记录 */
@property (nonatomic, strong) NSArray *conversations;
/** 好友的名称 */
@property (nonatomic, copy) NSString *buddyUsername;
@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //获取历史会话纪录
    [self loadConversations];
    
}

-(void)loadConversations
{
    //1.从内存获取历史会话纪录
    NSArray *conversation = [[EaseMob sharedInstance].chatManager conversations];
    //2.内存没有，则从数据库Conversation表
    if (conversation.count == 0) {
        conversation = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
//     NSLog(@"zzzzzzz %@",conversation);
    self.conversations = conversation;
    
    //显示总的未读数
    [self showTabBarBadge];
}

#pragma mark -好友添加代理被同意
-(void)didAcceptedByBuddy:(NSString *)username
{
    NSString *message = [NSString stringWithFormat:@"%@同意了你的好友请求",username];
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加消息"
    //                                                    message:message
    //                                                   delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
    //    [alert show];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友添加消息"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:nil];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -好友添加被拒绝
- (void)didRejectedByBuddy:(NSString *)username
{
    NSString *message = [NSString stringWithFormat:@"%@拒绝了你的好友请求",username];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友添加消息"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:nil];
    
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友添加请求"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action) {
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:nil];
    }];
    UIAlertAction *canceAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleCancel  handler:^(UIAlertAction *action){
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:username reason:@"不认识" error:nil];
    }];
    [alert addAction:defaultAction];
    [alert addAction:canceAction];
    [self presentViewController:alert animated:YES completion:nil];
  
}


#pragma mark -监听被好友删除
-(void)didRemovedByBuddy:(NSString *)username
{
    NSString *message = [username stringByAppendingString:@"删除你了"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"被好友删除" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defatultAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:defatultAction];
}



#pragma mark -chatManager代理方法
//1.监听网络状态
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    if (connectionState == eEMConnectionDisconnected) {
        NSLog(@"网络断开……");
    } else {
        NSLog(@"网络通了……");
    }
}

-(void)willAutoReconnect{
    NSLog(@"将自动重连接...");
    self.title = @"连接中....";
}

-(void)didAutoReconnectFinishedWithError:(NSError *)error{
    if (!error) {
        NSLog(@"自动重连接成功...");
        self.title = @"Conversation";
    }else{
        NSLog(@"自动重连接失败... %@",error);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 自动登录的回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (!error) {
        NSLog(@"%s 自动登录成功 %@",__FUNCTION__, loginInfo);
    }else{
        NSLog(@"自动登录失败 %@",error);
    }
    
}

#pragma mark - Table view data source
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversations.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ConversationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //获取会话模型
    EMConversation *converastion = self.conversations[indexPath.row];

    //1.显示数据，用户，时间
//    cell.textLabel.text = converastion.chatter;
    cell.textLabel.text = [NSString stringWithFormat:@"%@未读消息数:%ld",converastion.chatter,[converastion unreadMessagesCount]];
    
    //获取消息体
    // 获取消息体
    id body = converastion.latestMessage.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = body;
        cell.detailTextLabel.text = textBody.text;
        
    }else if ([body isKindOfClass:[EMVoiceMessageBody class]]){
        EMVoiceMessageBody *voiceBody = body;
        cell.detailTextLabel.text = [voiceBody displayName];
        
    }else if([body isKindOfClass:[EMImageMessageBody class]]){
        EMImageMessageBody *imgBody = body;
        cell.detailTextLabel.text = imgBody.displayName;
        
    }else{
        cell.detailTextLabel.text = @"未知消息类型";
    }
//    cell.detailTextLabel.text = @"ConversationCell";
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //进入到聊天控制器
    //1.从storybaord加载聊天控制器
    ChatViewController *chatVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ChatPage"];
    //会话
    EMConversation *conversation = self.conversations[indexPath.row];
    EMBuddy *buddy = [EMBuddy buddyWithUsername:conversation.chatter];
    //2.设置好友属性
    chatVc.buddy = buddy;
    
    //3.展现聊天界面
    [self.navigationController pushViewController:chatVc animated:YES];
    
    
}

#pragma mark 未读消息数改变
- (void)didUnreadMessagesCountChanged{
    //更新表格
    [self.tableView reloadData];
    //显示总的未读数
    [self showTabBarBadge];
    
}

#pragma mark 历史会话列表更新
-(void)didUpdateConversationList:(NSArray *)conversationList{
    
    //给数据源重新赋值
    self.conversations = conversationList;
    
    //刷新表格
    [self.tableView reloadData];
    
    //显示总的未读数
    [self showTabBarBadge];
    
}

-(void)dealloc
{
    //移除聊天管理器的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

-(void)showTabBarBadge{
    //遍历所有的会话记录，将未读取的消息数进行累加
    
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in self.conversations) {
        totalUnreadCount += [conversation unreadMessagesCount];
    }
    
    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",totalUnreadCount];
    
}




@end
