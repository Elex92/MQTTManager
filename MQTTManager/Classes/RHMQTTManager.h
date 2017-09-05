//
//  RHMQTTManager.h
//  SandCollections
//
//  Created by RuiHao on 2017/5/8.
//  Copyright © 2017年 RuiHao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MQTTClient.h>
#import "MQTTStatus.h"

@interface RHMQTTManager : NSObject
@property (nonatomic,strong) MQTTSession * mySession;
@property(nonatomic, strong)    MQTTStatus *mqttStatus;//连接服务器状态

+(instancetype)manager;
/**
 *  打开MQTT
 */
-(void)open;
/**
 *  断开连接
 */
-(void)disconnect;
/**
 *  重新连接连接
 */
-(void)connect;

/**
 *  关闭MQTT
 */
-(void)close;
/**
 注册代理
 
 @param obj 需要实现代理的对象
 */
-(void)registerDelegate:(id)obj;


/**
 解除代理
 
 @param obj 需要接触代理的对象
 */
-(void)unRegisterDelegate:(id)obj;
@end
