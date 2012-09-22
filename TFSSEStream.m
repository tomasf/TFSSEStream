//
//  TFSSEStream.m
//  WebApp
//
//  Created by Tomas Franzén on 2012-09-22.
//
//

#import "TFSSEStream.h"
#import <WebAppKit/WAPrivate.h>

@interface TFSSEStream ()
@property(readwrite, strong) WARequest *request;
@property(readwrite, copy) NSString *lastEventID;
@property(strong) WAResponse *response;
@property(copy) BOOL(^connectionHandler)(TFSSEStream *stream);
@end


@implementation TFSSEStream


- (id)initWithRequest:(WARequest*)request connectionHandler:(BOOL(^)(TFSSEStream *stream))handler {
	if(!(self = [super init])) return nil;
	
	self.request = request;
	self.lastEventID = [request valueForHeaderField:@"Last-Event-ID"];
	self.connectionHandler = handler;
	
	return self;
}


- (void)handleRequest:(WARequest *)request response:(WAResponse *)response socket:(GCDAsyncSocket *)socket {
	NSAssert(self.connectionHandler != nil, @"connectionHandler can't be nil!");
	
	if(!self.connectionHandler(self)) {
		response.statusCode = 403;
		[response finish];
		return;
	}
	
	self.response = response;
	self.response.mediaType = @"text/event-stream";
	self.response.progressive = YES;
	[self.response sendHeader];
}


- (void)close {
	[self.response finish];
}


- (void)sendMessage:(NSString *)data event:(NSString *)eventName ID:(NSString *)ID {
	NSMutableString *string = [NSMutableString string];
	
	if(eventName)
		[string appendFormat:@"event: %@\n", eventName];
	if(ID)
		[string appendFormat:@"id: %@\n", ID];
	
	NSArray *lines = [data componentsSeparatedByString:@"\n"];
	for(NSString *line in lines)
		[string appendFormat:@"data: %@\n", line];
	
	[string appendString:@"\n"];
	[self.response appendString:string];
}


- (void)sendReconnectionDelay:(NSTimeInterval)seconds {
	[self.response appendFormat:@"retry: %d\n\n", (int)(seconds * 1000.0)];
}


- (void)keepAlive {
	[self.response appendString:@":\n\n"];
}


- (void)connectionDidClose {
	if(self.closeHandler)
		self.closeHandler();
}


@end





@interface TFSSEStreamHandler ()
@property(copy) NSString *path;
@end


@implementation TFSSEStreamHandler


- (id)initWithPath:(NSString*)requestPath {
	if(!(self = [super init])) return nil;
	self.path = requestPath;
	return self;
}


- (BOOL)canHandleRequest:(WARequest *)request {
	return [request.method isEqual:@"GET"] && [request.path isEqual:self.path];
}


- (WARequestHandler*)handlerForRequest:(WARequest*)request {
	TFSSEStream *stream = [[TFSSEStream alloc] initWithRequest:request connectionHandler:self.connectionHandler];
	return stream;
}


@end