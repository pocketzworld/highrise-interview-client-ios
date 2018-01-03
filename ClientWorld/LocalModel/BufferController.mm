//
//  BufferController.m
//  ClientWorld
//
//  Created by Josh Johnson on 12/12/17.
//  Copyright © 2017 Pocketz World. All rights reserved.
//

#import "BufferController.h"

#import "Avatar_generated.h"
#import "AvatarJoinedEvent_generated.h"
#import "AvatarLeftEvent_generated.h"

#import "ClientMessage_generated.h"
#import "ServerMessage_generated.h"

#import "ConnectRoomRequest_generated.h"
#import "ConnectRoomResponse_generated.h"

#import "VWChatEvent_generated.h"

using namespace rs::high::life;

@implementation BufferController

+ (instancetype)defaultController {
    static BufferController *_bufferController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bufferController = [[BufferController alloc] init];
    });
    return _bufferController;
}

- (NSData *)joinRoomRequestWithUser:(NSString *)userId
                               name:(NSString *)userName
                             roomId:(NSString *)roomId {
    auto fbb = new flatbuffers::FlatBufferBuilder();
    auto roomOffset = fbb->CreateString([roomId UTF8String]);
    auto idOffset = fbb->CreateString([userId UTF8String]);
    auto nameOffset = fbb->CreateString([userName UTF8String]);
    auto joinRoomRequest = fbs::CreateConnectRoomRequest(*fbb, roomOffset, idOffset, nameOffset);

    fbs::ClientMessageBuilder cmbb(*fbb);
    cmbb.add_content_type(fbs::AnyClientContent::AnyClientContent_ConnectRoomRequest);
    cmbb.add_content(joinRoomRequest.Union());
    auto loc = cmbb.Finish();
    fbs::FinishClientMessageBuffer(*fbb, loc);
    
    return [NSData dataWithBytes:fbb->GetBufferPointer() length:fbb->GetSize()];
}

- (NSData *)sendVWMessageRequestFromUser:(NSString *)userId
                                    name:(NSString *)name
                                 message:(NSString *)message {
    auto fbb = new flatbuffers::FlatBufferBuilder();
    auto userOffset = fbb->CreateString([userId UTF8String]);
    auto nameOffset = fbb->CreateString([name UTF8String]);
    auto messageOffset = fbb->CreateString([message UTF8String]);
    auto messageRequest = fbs::CreateVWChatEvent(*fbb, userOffset, nameOffset, messageOffset);

    fbs::ClientMessageBuilder cmbb(*fbb);
    cmbb.add_content_type(fbs::AnyClientContent::AnyClientContent_VWChatEvent);
    cmbb.add_content(messageRequest.Union());
    auto loc = cmbb.Finish();
    fbs::FinishClientMessageBuffer(*fbb, loc);
    
    return [NSData dataWithBytes:fbb->GetBufferPointer() length:fbb->GetSize()];
}

- (NSString *)messageFromReceivedData:(NSData *)data {
    auto serverMessage = fbs::GetServerMessage(data.bytes);
    std::string responseMessage = "Unknown response";
    
    switch (serverMessage->content_type()) {
        case rs::high::life::fbs::AnyServerContent_NONE:
            break;
            
        case rs::high::life::fbs::AnyServerContent_AvatarLeftEvent: {
            auto avatarLeft = serverMessage->content_as_AvatarLeftEvent();
            responseMessage = avatarLeft->userId()->str() + "left. Auf Wiedersehen!";
            break;
        }
        case rs::high::life::fbs::AnyServerContent_AvatarJoinedEvent: {
            auto avatarJoined = serverMessage->content_as_AvatarJoinedEvent();
            responseMessage = avatarJoined->avatar()->userId()->str() + "joined. Wilkommen!";
            break;
        }

        case rs::high::life::fbs::AnyServerContent_ConnectRoomResponse: {
            responseMessage = "Connected";
            break;
        }

        case rs::high::life::fbs::AnyServerContent_VWChatEvent: {
            auto chatMessage = serverMessage->content_as_VWChatEvent();
            responseMessage = chatMessage->sendername()->str() + ": " + chatMessage->message()->str();
            break;
        }
    }
    
    return [NSString stringWithUTF8String:responseMessage.c_str()];
}

@end
