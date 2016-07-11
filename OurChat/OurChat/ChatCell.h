//
//  ChatCell.h
//  OurChat
//
//  Created by geshu on 16/7/1.
//  Copyright © 2016年 personage. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *ReccerCell = @"ReceiverCell";
static NSString *SenderCell = @"SenderCell";

@interface ChatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
/** 消息模型，内部set方法 显示文字 */
@property (nonatomic, strong) EMMessage *message;

-(CGFloat)cellHeghit;
@end
