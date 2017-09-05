//
//  MQTTStatus.h
//  SandCollections
//
//  Created by 沈丰元 on 2017/6/1.
//  Copyright © 2017年 RuiHao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MQTTClient.h"
@interface MQTTStatus : NSObject
//状态
@property(nonatomic,assign) MQTTSessionStatus status;
//状态
@property(nonatomic,assign) MQTTSessionEvent statusCode;
//状态信息
@property(nonatomic,copy)  NSString *statusInfo;
@end
