//
//  BufferController.h
//  ClientWorld
//
//  Created by Josh Johnson on 12/12/17.
//  Copyright © 2017 Pocketz World. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BufferController : NSObject

+ (instancetype)defaultController;

- (NSData *)joinRoomRequestWithUser:(NSString *)userId
                               name:(NSString *)userName
                             roomId:(NSString *)roomId;

- (NSData *)sendVWMessageRequestFromUser:(NSString *)userId
                                    name:(NSString *)name
                                 message:(NSString *)message;

- (NSString *)messageFromReceivedData:(NSData *)data;

@end
