//
//  AddressBookViewController.m
//  OurChat
//
//  Created by geshu on 16/6/26.
//  Copyright © 2016年 personage. All rights reserved.
//

#import "AddressBookViewController.h"
#import "EaseMob.h"
#import "ChatViewController.h"

@interface AddressBookViewController () <EMChatManagerDelegate>
@property (nonatomic, strong) NSArray *buddyList;

@end

@implementation AddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    // 获取好友列表数据
    self.buddyList =  [[EaseMob sharedInstance].chatManager buddyList];
    
    
    /* 注意
     * 1.好友列表buddyList需要在自动登录成功后才有值
     * 2.buddyList的数据是从 本地数据库获取
     * 3.如果要从服务器获取好友列表 调用chatManger下面的方法
     【-(void *)asyncFetchBuddyListWithCompletion:onQueue:】;
     * 4.如果当前有添加好友请求，环信的SDK内部会往数据库的buddy表添加好友记录
     * 5.如果程序删除或者用户第一次登录，buddyList表是没记录，
     解决方案
     1》要从服务器获取好友列表记录
     2》用户第一次登录后，自动从服务器获取好友列表
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddyList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"BuddyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    //获取好友模型
    EMBuddy *buddy = self.buddyList[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    cell.textLabel.text = buddy.username;
 
    return cell;
}

#pragma mark - chatmanger代理
#pragma mark - 监听自动登录成功
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (!error) {
        //获取好友列表
        self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        NSLog(@"==%@",self.buddyList);
        [self.tableView reloadData];
    }
}

#pragma mark 好友添加请求同意
-(void)didAcceptedByBuddy:(NSString *)username
{
    //把好友显示到表格
    [self loadBuddyListFromServer];
}

#pragma mark -从服务器获取好友列表
-(void)loadBuddyListFromServer
{
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        self.buddyList = buddyList;
        [self.tableView reloadData];
    } onQueue:nil];
}

#pragma mark －好友列表数据被更新
-(void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd
{
    NSLog(@"好友的列表被更新");
    self.buddyList = buddyList;
    [self.tableView reloadData];
}

#pragma mark 删除好友
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //获取移除好友的名字
        EMBuddy *buddy = self.buddyList[indexPath.row];
        NSString *deleteUserName = buddy.username;
        //删除好友
        [[EaseMob sharedInstance].chatManager removeBuddy:deleteUserName removeFromRemote:YES error:nil];
    }
}

#pragma mark 被好友删除
-(void)didRemovedByBuddy:(NSString *)username
{
    [self loadBuddyListFromServer];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //往聊天控制器 传递一个 buddy的值
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[ChatViewController class]]) {
        //获取点击的行
        NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
        
        ChatViewController *chatVc = destVC;
        chatVc.buddy = self.buddyList[selectedRow];
    }
    
}


@end
