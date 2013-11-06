//
//  SNHTTPRequestOperationWrapper.m
//

#import "SNHTTPRequestOperationWrapper.h"
#import "AFJSONUtilities.h"
#import "SNNetworkClient+Image.h"

static NSString * SNAFJSONStringFromParameters(NSDictionary *parameters)
{
    NSError *error = nil;
    NSData *JSONData = AFJSONEncode(parameters, &error);
    
    if (!error) {
        return [[[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding] autorelease];
    } else {
        return nil;
    }
}

@interface AFHTTPRequestOperation (SNHTTPRequestOperationWrapper)
@property (readonly, nonatomic) dispatch_queue_t failureCallbackQueue;
@end

@interface SNNetworkClient (SNHTTPRequestOperationWrapper)
- (void)bindingWrapperToSafeBlockObject:(SNHTTPRequestOperationWrapper *)wrapper;
@end

@interface SNHTTPRequestOperationWrapper ()
@property (nonatomic, retain) AFHTTPRequestOperation *operation;
@end

@implementation SNHTTPRequestOperationWrapper

@synthesize client;
@synthesize operation;
@synthesize request;
@synthesize settings;
@synthesize safeBlockObjectIdentifier;
@synthesize uploadProgressBlock = uploadProgressBlock;
@synthesize downloadProgressBlock = downloadProgressBlock;

#pragma mark - Memory management

- (id)initWithWithRequest:(NSMutableURLRequest *)_request
             successBlock:(SNHTTPRequestOperationSuccessBlock)_successBlock
             failureBlock:(SNHTTPRequestOperationFailureBlock)_failureBlock
{
    if ((self = [super init]))
    {
        successBlock = [_successBlock copy];
        failureBlock = [_failureBlock copy];
        request = [_request retain];
    }
    
    return self;
}

- (void)dealloc
{
    client = nil;
    
    [safeBlockObjectIdentifier release], safeBlockObjectIdentifier = nil;
    [settings release], settings = nil;
    [request release], request = nil;
    [operation release], operation = nil;
    [successBlock release], successBlock = nil;
    [failureBlock release], failureBlock = nil;
    [uploadProgressBlock release], uploadProgressBlock = nil;
    [downloadProgressBlock release], downloadProgressBlock = nil;
    
    [super dealloc];
}

//- (SNHTTPRequestOperationSuccessBlock)successBlock
//{
//    return successBlock;
//}
//
//- (SNHTTPRequestOperationFailureBlock)failureBlock
//{
//    return failureBlock;
//}

- (void)cancel
{
    [client cancelWrapper:self];
}

- (void)drop
{
    [self cancel];

    [settings release], settings = nil;
    [request release], request = nil;
    [successBlock release], successBlock = nil;
    [failureBlock release], failureBlock = nil;
    [uploadProgressBlock release], uploadProgressBlock = nil;
    [downloadProgressBlock release], downloadProgressBlock = nil;
}

- (void)setSafeBlockObjectIdentifier:(NSString *)_safeBlockObjectIdentifier
{
    [_safeBlockObjectIdentifier retain];
    [safeBlockObjectIdentifier release];
    safeBlockObjectIdentifier = _safeBlockObjectIdentifier;
    
    [client bindingWrapperToSafeBlockObject:self];
}

#pragma mark - Re-process request

- (void)resendWithProperties:(NSDictionary *)properties
{
    [self cancel];
    
    [client resendOperationWithWrapper:self properties:properties];
}

- (NSMutableURLRequest *)requestWithResendProperties:(NSDictionary *)properties
{
    NSMutableURLRequest *_request = [[self.request copy] autorelease];
    
    if (!properties)
    {
        return _request;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:properties];
    
    NSString *method = [_request HTTPMethod];
    NSString *requestTag = [_request valueForHTTPHeaderField:kSNNetworkRequestHeaderTagName];
    
    if ([method isEqualToString:@"GET"] || [method isEqualToString:@"HEAD"] || [method isEqualToString:@"DELETE"]
        || [requestTag isEqualToString:kSNNetworkRequestHeaderTagValueUpload])
    {
        NSString *path = [[_request URL] absoluteString];
        NSURL *url = [NSURL URLWithString:[path stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(parameters, self.client.stringEncoding)]];
        [_request setURL:url];
    }
    else
    {
        NSMutableData *data = [NSMutableData dataWithData:[_request HTTPBody]];
        BOOL hasData = (data.length > 0);
        switch (self.client.parameterEncoding)
        {
            case AFFormURLParameterEncoding:;
                NSString *appendString = AFQueryStringFromParametersWithEncoding(parameters, self.client.stringEncoding);
                NSData *appendData = [(hasData ? [NSString stringWithFormat:@"&%@", appendString] : appendString) dataUsingEncoding:self.client.stringEncoding];
                [data appendData:appendData];
                break;
            case AFJSONParameterEncoding:;
                if (hasData)
                {
                    NSString *originalJsonString = [[[NSString alloc] initWithData:data encoding:self.client.stringEncoding] autorelease];
                    NSError *error = nil;
                    NSDictionary *originalParameters = AFJSONDecode([originalJsonString dataUsingEncoding:NSUTF8StringEncoding], &error);
                    
                    if (!error)
                    {
                        [parameters addEntriesFromDictionary:originalParameters];
                    }
                }
                
                [request setHTTPBody:[SNAFJSONStringFromParameters(parameters) dataUsingEncoding:self.client.stringEncoding]];
                break;
            case AFPropertyListParameterEncoding:;
                
                // 暂不支持
                
                break;
            default:
                break;
        }
        [_request setHTTPBody:data];
    }
    
    return _request;
}

- (void)resetRequest:(NSMutableURLRequest *)_request
{
    [_request retain];
    [request release];
    request = _request;
}

- (void)loadImageWithPath:(NSString *)path encodeAsImage:(BOOL)encodeAsImage
{
    [self cancel];
    
    [client loadImageWithWrapper:self path:path encodeAsImage:encodeAsImage];
}

- (void)loadImageFileWithPath:(NSString *)path encodeAsImage:(BOOL)encodeAsImage
{
    [self cancel];
    
    [client loadImageFileWithWrapper:self path:path encodeAsImage:encodeAsImage];
}

#pragma mark - Response info

- (NSHTTPURLResponse *)response
{
    return operation.response;
}

- (NSData *)responseData
{
    return operation.responseData;
}

- (NSString *)responseString
{
    return operation.responseString;
}

#pragma mark - Callbacks

- (void)callbackSuccessBlockWithResponseObject:(id)responseObject
{
    if (successBlock)
    {
        successBlock(self, responseObject);
    }
}

- (void)callbackFailureBlockWithError:(NSError *)error
{
    if (failureBlock)
    {
        failureBlock(self, error);
    }
}

- (void)callbackSuccessBlockInSuccessQueueWithResponseObject:(id)responseObject
{
    if (successBlock)
    {
        dispatch_async(operation.successCallbackQueue ? operation.successCallbackQueue : dispatch_get_main_queue(), ^{
            successBlock(self, responseObject);
        });
    }
}

- (void)callbackFailureBlockInFailureQueueWithError:(NSError *)error
{
    if (failureBlock)
    {
        dispatch_async(operation.failureCallbackQueue ? operation.failureCallbackQueue : dispatch_get_main_queue(), ^{
            failureBlock(self, error);
        });
    }
}

@end
