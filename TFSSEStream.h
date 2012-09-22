//
//  TFSSEStream.h
//  WebApp
//
//  Created by Tomas Franzén on 2012-09-22.
//
//

#import <Foundation/Foundation.h>
@class TFSSEStream;


@interface TFSSEStreamHandler : WARequestHandler
- (id)initWithPath:(NSString*)requestPath;

@property(copy) BOOL(^connectionHandler)(TFSSEStream *stream);
@end



@interface TFSSEStream : WARequestHandler
@property(copy) void(^closeHandler)();

@property(readonly, copy) NSString *lastEventID;
@property(readonly, strong) WARequest *request;

- (void)close;
- (void)sendMessage:(NSString*)data event:(NSString*)eventName ID:(NSString*)ID;
- (void)sendReconnectionDelay:(NSTimeInterval)seconds;
- (void)keepAlive;
@end