//
//  AZSViewController.m
//  AZSocketIO
//
//  Created by 島田克弥 on 2014/06/28.
//  Copyright (c) 2014年 shimada-k. All rights reserved.
//

#import "AZSViewController.h"

#import <AZSocketIO/AZSocketIO.h>

@interface AZSViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userid;

// Socket.IOクライアント
@property (nonatomic, strong) AZSocketIO *socketIO;

@end

@implementation AZSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // ホストとポート番号を指定してAZSocketIOインスタンス生成
    self.socketIO = [[AZSocketIO alloc] initWithHost:@"tkoal.dip.jp"
                                             andPort:@"3000"
                                              secure:NO];
    //self.socketIO.transport = [NSMutableSet setWithObject:@"websocket"];
    self.socketIO.reconnect = NO; // Socket.IOサーバへ接続できなかった場合リトライしない
    
    // メッセージを受信した時に実行されるBlocks
    [self.socketIO setMessageRecievedBlock:^(id data) {
        NSLog(@"data: %@", data);
    }];
    
    // イベントを受信したときに実行されるBlocks
    [self.socketIO setEventRecievedBlock:^(NSString *eventName, id data) {
        NSLog(@"eventName: %@, data: %@", eventName, data);
    }];
    
    // エラーを受信したときに実行されるBlocks
    [self.socketIO setErrorBlock:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
    // 切断されたときに実行されるBlocks
    [self.socketIO setDisconnectedBlock:^{
        NSLog(@"Disconnected!");
    }];
    
    // message:receiveイベント受信時の処理
    [self.socketIO addCallbackForEventName:@"message:receive" callback:^(NSString *eventName, id data) {
        
        NSString *promixity_str = [NSString stringWithFormat:@"%@",data[0]];
        NSString *userid_str = [NSString stringWithFormat:@"%@",data[1]];
        NSLog(@"promixity_str %@", promixity_str);
        
        UIColor *color = NULL;
        
        // 敵がすごく近くにいる
        if ([promixity_str isEqualToString:@"CLProximityImmediate"]) {
            color =[UIColor colorWithRed:0.647 green:0.165 blue: 0.165 alpha:1.0];
            NSLog(@"eventNameImid: %@, data: %@", eventName, data);
        }
        // 敵が近くにいる
        else if([promixity_str isEqualToString:@"CLProximityNear"]){
            color =[UIColor colorWithRed:1.0 green:0.647 blue: 0 alpha:1.0];
            NSLog(@"eventNameNear: %@, data: %@", eventName, data);
        }
        // 敵が遠くにいる
        else if([promixity_str isEqualToString:@"CLProximityFar"]){
            color =[UIColor colorWithRed:1.0 green:1.0 blue: 0 alpha:1.0];
            NSLog(@"eventNameFar: %@, data: %@", eventName, data);
        }
        
        self.userid.text = userid_str;
        self.view.backgroundColor = color;
        NSLog(@"eventName: %@, data: %@", eventName, data[0]);
    }];

    // 接続開始
    [self.socketIO connectWithSuccess:^{
        NSLog(@"Success connecting!");
    } andFailure:^(NSError *error) {
        NSLog(@"Failure connecting. error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
