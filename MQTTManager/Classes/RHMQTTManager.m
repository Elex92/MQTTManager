//
//  RHMQTTManager.m
//  SandCollections
//
//  Created by RuiHao on 2017/5/8.
//  Copyright © 2017年 RuiHao. All rights reserved.
//

#import "RHMQTTManager.h"
#import "MQTTClientManagerDelegate.h"

#define MQTTHost @""
#define MQTTPort 1111
#define MQTTUserName @""
#define MQTTPassWord @""
@interface RHMQTTManager()<MQTTSessionDelegate>
@property(nonatomic, weak)      id<MQTTClientManagerDelegate> delegate;//代理
@property (nonatomic,strong) MQTTCFSocketTransport * transport;
@end

@implementation RHMQTTManager
+(instancetype)manager
{
    static RHMQTTManager * manager=nil;
    @synchronized(self) {
        if (manager==nil) {
            
            manager=[[RHMQTTManager alloc]init];
        }
    }
    return manager;

}
-(MQTTStatus *)mqttStatus{
    if (!_mqttStatus) {
        _mqttStatus=[[MQTTStatus alloc] init];
    }
    return _mqttStatus;
}
-(MQTTCFSocketTransport*)transport
{
    if (!_transport) {
        _transport=[[MQTTCFSocketTransport alloc]init];
      
     
        _transport.host=MQTTHost;
        
        
        _transport.port=MQTTPort;
    }
    return _transport;
}
-(MQTTSession*)mySession
{
    if (!_mySession) {
        _mySession=[[MQTTSession alloc]init];
        _mySession.transport=self.transport;
        _mySession.delegate=self;
        _mySession.cleanSessionFlag=NO;
       
    
        [_mySession setUserName:MQTTUserName];
        [_mySession setPassword:MQTTPassWord];
       
       
       
        [_mySession connectAndWaitTimeout:1];
        [_mySession addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld context:nil];
    }
    return _mySession;
}
-(void)open
{
   
//    NSString *clientID=[NSString stringWithFormat:@"%@|iOS|%@|%@",[[NSBundle mainBundle] bundleIdentifier],[UIDevice currentDevice].identifierForVendor.UUIDString,PHONE];
 
    [self.mySession connect];
   
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
   
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didMQTTReceiveServerStatus:)]) {
        [self.mqttStatus setStatus:self.mySession.status];
        
        [self.delegate didMQTTReceiveServerStatus:self.mqttStatus];
        
    }
}
- (void)connected:(MQTTSession *)session sessionPresent:(BOOL)sessionPresent
{
    
//    [self subscribeTopic:session ToTopic:@"/00000003/0002/0001/skb/common"];
//    [self subscribeTopic:session ToTopic:[NSString stringWithFormat:@"/00000003/0002/0001/skb/business/%@",PHONE]];
}
#pragma mark ---绑定主题
-(void)subscribeTopic:(MQTTSession*)session ToTopic:(NSString*)topicUrl{
    
    [session subscribeToTopic:topicUrl atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            NSLog(@"失败");
        }else{
//            NSLog(@"----%@",gQoss);
        }
    }];
}
- (void)connectionError:(MQTTSession *)session error:(NSError *)error{
  
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didMQTTReceiveServerStatus:)]) {
        [self.mqttStatus setStatus:session.status];
      
        [self.delegate didMQTTReceiveServerStatus:self.mqttStatus];
    }
}

/*连接状态回调*/
-(void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    
    NSDictionary *events = @{
                             @(MQTTSessionEventConnected): @"connected",
                             @(MQTTSessionEventConnectionRefused): @"connection refused",
                             @(MQTTSessionEventConnectionClosed): @"connection closed",
                             @(MQTTSessionEventConnectionError): @"connection error",
                             @(MQTTSessionEventProtocolError): @"protocoll error",
                             @(MQTTSessionEventConnectionClosedByBroker): @"connection closed by broker"
                             };
    [self.mqttStatus setStatus:session.status];
    [self.mqttStatus setStatusCode:eventCode];
    [self.mqttStatus setStatusInfo:[events objectForKey:@(eventCode)]];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didMQTTReceiveServerStatus:)]) {
        [self.delegate didMQTTReceiveServerStatus:self.mqttStatus];
    }
    
     
    NSLog(@"-----------------MQTT连接状态%@-----------------",[events objectForKey:@(eventCode)]);
}
-(void)disconnect
{
    [self.mySession disconnect];
}
-(void)connect
{
    
  
    if (self.mySession.status==MQTTSessionStatusCreated) {
        [self open];
        return;
    }
    if (self.mySession.status==MQTTSessionStatusError||self.mySession.status==MQTTSessionStatusClosed) {
      
        [self.mySession connectAndWaitTimeout:30];
    }
}
-(void)close
{
  
    [_mySession close];
   
    
}
/**
 注册代理
 
 @param obj 需要实现代理的对象
 */
-(void)registerDelegate:(id)obj{
    self.delegate=obj;
}


/**
 解除代理
 
 @param obj 需要接触代理的对象
 */
-(void)unRegisterDelegate:(id)obj{
    self.delegate=nil;
}


/*收到消息*/
-(void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid{
    NSString *jsonStr=[NSString stringWithUTF8String:data.bytes];
    NSLog(@"-----------------MQTT收到消息主题：%@内容：%@",topic,jsonStr);
    
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(messageTopic:data:)]) {
        
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(messageTopic:jsonStr:)]) {
        [self.delegate messageTopic:topic jsonStr:jsonStr];
    }
}

@end
