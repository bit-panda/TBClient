//
//  SNNetworkClient.m
//

#import "SNNetworkClient.h"
#import "SNHTTPRequestOperationWrapper.h"
#import "SNImageRequestOperation.h"
#import "NSObject+SafeBlock.h"

typedef void (^AFHTTPRequestOperationSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^AFHTTPRequestOperationFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

void SNNetworkAddRequestParameter(NSMutableDictionary *parameters, NSString *name, NSString *value)
{
    if (name && value && parameters)
    {
        [parameters setObject:value forKey:name];
    }
}

@interface AFHTTPClient (SNNetworking)
@property (readwrite, nonatomic, retain) NSURL *baseURL;
@property (readwrite, nonatomic, retain) NSMutableArray *registeredHTTPOperationClassNames;
@end

@interface SNHTTPRequestOperationWrapper ()
@property (nonatomic, retain) AFHTTPRequestOperation *operation;
@end

@interface SNNetworkBaseClient ()
- (void)wrapOperation:(AFHTTPRequestOperation *)operation withWrapper:(SNHTTPRequestOperationWrapper *)wrapper;
- (void)unwrapOperation:(AFHTTPRequestOperation *)operation;
@end

@implementation SNNetworkBaseClient

@synthesize handleSafeBlockObjectDeallocNotification;

- (NSURL *)baseURL
{
    return [super baseURL];
}

- (void)resetBaseURL:(NSURL *)URL
{
    self.baseURL = URL;
}

#pragma mark - Cancel Request

- (void)cancelAllRequests
{
    [[self operationQueue] cancelAllOperations];
    NSArray *wrappers = [operationWrappers allValues];
    for (SNHTTPRequestOperationWrapper *wrapper in wrappers)
    {
        [self cancelWrapper:wrapper];
    }
    [operationWrappers removeAllObjects];
}

- (void)cancelWrapper:(SNHTTPRequestOperationWrapper *)wrapper
{
    [wrapper retain];
    [wrapper.operation clearBlocksAfterComplete];
    
    [wrapper.operation cancel];
    [self unwrapOperation:wrapper.operation];
    wrapper.operation = nil;
    [wrapper release];
}

- (void)cancelAllWrappersWithIdentifier:(NSString *)identifier
{
    NSSet *relatedWrappers = [[operationWrappers objectForKey:identifier] retain];
    [operationWrappers removeObjectForKey:identifier];
    
    for (SNHTTPRequestOperationWrapper *wrapper in relatedWrappers)
    {
        [self cancelWrapper:wrapper];
    }
    
    [relatedWrappers release];
}

- (void)handleSafeBlockObjectDidDeallocNotification:(NSNotification *)note
{
    NSString *identifier = [note.userInfo objectForKey:@"identifier"];
    [self cancelAllWrappersWithIdentifier:identifier];
}

#pragma mark - Memory management

- (id)initWithBaseURL:(NSURL *)URL requestConfigBlock:(void (^)(NSMutableURLRequest *request))_requestConfigBlock
{
    requestConfigBlock = [_requestConfigBlock copy];
    return [self initWithBaseURL:URL];
}

- (id)initWithBaseURL:(NSURL *)URL
{
    operationWrappers = [[NSMutableDictionary alloc] init];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    return [super initWithBaseURL:URL];
}

- (void)dealloc
{
    [self cancelAllRequests];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:SafeBlockObjectDidDeallocNotification object:nil];
    [requestConfigBlock release], requestConfigBlock = nil;
    [errorHandlerClass release], errorHandlerClass = nil;
    [operationWrappers release], operationWrappers = nil;
    [defaultParameters release], defaultParameters = nil;
    [defaultQueryParameters release], defaultQueryParameters = nil;
    
    [super dealloc];
}

- (void)setHandleSafeBlockObjectDeallocNotification:(BOOL)_handleSafeBlockObjectDeallocNotification
{
    handleSafeBlockObjectDeallocNotification = _handleSafeBlockObjectDeallocNotification;
    if (handleSafeBlockObjectDeallocNotification)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSafeBlockObjectDidDeallocNotification:) name:SafeBlockObjectDidDeallocNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SafeBlockObjectDidDeallocNotification object:nil];
    }
}

#pragma mark - Error handler

- (BOOL)registerErrorHandlerClass:(Class)_errorHandlerClass
{
    if (![_errorHandlerClass instancesRespondToSelector:@selector(handleError:forWrapper:)])
    {
        [errorHandlerClass release];
        errorHandlerClass = [_errorHandlerClass retain];
        return YES;
    }
    
    return NO;
}

- (void)clearErrorHandlerClass
{
    [errorHandlerClass release], errorHandlerClass = nil;
}

#pragma mark - Create / Get operation wrapper

- (SNHTTPRequestOperationWrapper *)wrapperWithRequest:(NSMutableURLRequest *)request
                                         successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                                         failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock
{
    SNHTTPRequestOperationWrapper *wrapper = [[SNHTTPRequestOperationWrapper alloc] initWithWithRequest:request successBlock:successBlock failureBlock:failureBlock];
    return [wrapper autorelease];
}

- (SNHTTPRequestOperationWrapper *)wrapperOfOperation:(AFHTTPRequestOperation *)operation
{
    if (operation)
    {
        NSString *key = [NSString stringWithFormat:@"%p", operation];
        return [operationWrappers objectForKey:key];
    }
    return nil;
}

#pragma mark - Wrap / Unwrap operation

- (void)bindingWrapperToSafeBlockObject:(SNHTTPRequestOperationWrapper *)wrapper
{
    if (wrapper.safeBlockObjectIdentifier)
    {
        NSMutableSet *relatedSafeBlockObjectWrappers = [operationWrappers objectForKey:wrapper.safeBlockObjectIdentifier];
        if (!relatedSafeBlockObjectWrappers)
        {
            relatedSafeBlockObjectWrappers = [NSMutableSet set];
            [operationWrappers setObject:relatedSafeBlockObjectWrappers forKey:wrapper.safeBlockObjectIdentifier];
        }
        [relatedSafeBlockObjectWrappers addObject:wrapper];
    }
}

- (void)wrapOperation:(AFHTTPRequestOperation *)operation withWrapper:(SNHTTPRequestOperationWrapper *)wrapper
{
    wrapper.client = self;
    
    if (wrapper.operation != operation)
    {
        [wrapper retain];
        [self unwrapOperation:wrapper.operation];
        wrapper.operation = operation;
        NSString *key = [NSString stringWithFormat:@"%p", operation];
        [operationWrappers setObject:wrapper forKey:key];
        
        [self bindingWrapperToSafeBlockObject:wrapper];
        
        [wrapper release];
    }
}

- (void)unwrapOperation:(AFHTTPRequestOperation *)operation
{
    if (!operation)
    {
        return;
    }
    
    NSString *key = [NSString stringWithFormat:@"%p", operation];
    SNHTTPRequestOperationWrapper *wrapper = [operationWrappers objectForKey:key];
    if (wrapper)
    {
        if (wrapper.safeBlockObjectIdentifier)
        {
            NSMutableSet *relatedSafeBlockObjectWrappers = [operationWrappers objectForKey:wrapper.safeBlockObjectIdentifier];
            if (relatedSafeBlockObjectWrappers)
            {
                [relatedSafeBlockObjectWrappers removeObject:wrapper];
                if (relatedSafeBlockObjectWrappers.count == 0)
                {
                    [operationWrappers removeObjectForKey:wrapper.safeBlockObjectIdentifier];
                }
            }
            
        }
        
        [operationWrappers removeObjectForKey:key];
    }
}

#pragma mark - Create operation with wrapper

- (SNHTTPRequestOperationWrapper *)enqueueOperationWithRequest:(NSMutableURLRequest *)request
                                                      settings:(NSDictionary *)settings
                                                  successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                                                  failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock
{
    SNHTTPRequestOperationWrapper *wrapper = [self wrapperWithRequest:request
                                                         successBlock:successBlock
                                                         failureBlock:failureBlock];
    wrapper.settings = settings;
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request wrapper:wrapper];
    [self enqueueHTTPRequestOperation:operation];

    return wrapper;
}

- (SNHTTPRequestOperationWrapper *)enqueueOperationWithRequest:(NSMutableURLRequest *)request
                                                  successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                                                  failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock
{
    return [self enqueueOperationWithRequest:request settings:nil successBlock:successBlock failureBlock:failureBlock];
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSMutableURLRequest *)request
                                                    wrapper:(SNHTTPRequestOperationWrapper *)wrapper
{
    __block SNNetworkBaseClient *blockSelf = self;

    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        SNHTTPRequestOperationWrapper *relatedWrapper = [blockSelf wrapperOfOperation:operation];
        [relatedWrapper retain];
        
        [blockSelf unwrapOperation:operation];
        [operation clearBlocksAfterComplete];
        
        if (is_safe_block_object_still_alive(relatedWrapper.safeBlockObjectIdentifier))
        {
            [relatedWrapper callbackSuccessBlockWithResponseObject:responseObject];
        }
        
        if (relatedWrapper.operation == operation)
        {
            relatedWrapper.operation = nil;
        }

        [relatedWrapper release];
        
    }
                                                                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
        SNHTTPRequestOperationWrapper *relatedWrapper = [blockSelf wrapperOfOperation:operation];
        [relatedWrapper retain];
        
        [blockSelf unwrapOperation:operation];
        [operation clearBlocksAfterComplete];
        
        if (blockSelf->errorHandlerClass)
        {
            error = [blockSelf->errorHandlerClass handleError:error forWrapper:relatedWrapper];
        }
        
        // 如果吃掉了error，则不回调
        if (error)
        {
#if WB_API_LOG_REPORT
            NSString *requestTag = [relatedWrapper.request valueForHTTPHeaderField:kSNNetworkRequestHeaderTagName];
            if ([requestTag isEqualToString:kSNNetworkRequestHeaderTagValueImage])
            {
                WBAPILogReport(NSStringFromClass([self class]), ([NSString stringWithFormat:@"%@-%@", relatedWrapper.request.URL.absoluteString, error]));
            }
#endif
            if (is_safe_block_object_still_alive(relatedWrapper.safeBlockObjectIdentifier))
            {
                [relatedWrapper callbackFailureBlockWithError:error];
            }
        }
        
        if (relatedWrapper.operation == operation)
        {
            relatedWrapper.operation = nil;
        }
        
        [relatedWrapper release];
        
    }];
    [self wrapOperation:operation withWrapper:wrapper];
    
    if (wrapper.settings && [operation conformsToProtocol:@protocol(SNConfiguableRequestOperation)])
    {
        [(id<SNConfiguableRequestOperation>)operation configWithSettings:wrapper.settings];
    }
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        SNHTTPRequestOperationWrapper *relatedWrapper = [blockSelf wrapperOfOperation:operation];
        if (relatedWrapper.uploadProgressBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                relatedWrapper.uploadProgressBlock((double)totalBytesWritten / totalBytesExpectedToWrite, totalBytesExpectedToWrite, totalBytesWritten);
            });
        }
    }];
    
    [operation setDownloadProgressBlock:^(NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        SNHTTPRequestOperationWrapper *relatedWrapper = [blockSelf wrapperOfOperation:operation];
        if (relatedWrapper.downloadProgressBlock)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                relatedWrapper.downloadProgressBlock((double)totalBytesRead / totalBytesExpectedToRead, totalBytesExpectedToRead, totalBytesRead);
            });
        }
    }];
    
    return operation;
}

#pragma mark - Default parameters

- (NSString *)pathByAppendDefaultQueryParameters:(NSString *)path
{
    if (defaultQueryParameters)
    {
        path = [path stringByAppendingFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", AFQueryStringFromParametersWithEncoding(defaultQueryParameters, self.stringEncoding)];
    }
    
    return path;
}

- (NSDictionary *)parametersByAppendDefaultParameters:(NSDictionary *)parameters
{
    if (defaultParameters)
    {
        if(!parameters)
        {
            parameters = [[defaultParameters copy] autorelease];
        }
        else
        {
            // 使用外面的参数覆盖默认参数
            NSMutableDictionary *_parameters = [NSMutableDictionary dictionaryWithDictionary:defaultParameters];
            [_parameters addEntriesFromDictionary:parameters];
            parameters = _parameters;
        }
    }
    
    return parameters;
}

- (void)setDefaultParameter:(NSString *)parameter value:(NSString *)value
{
    if (!parameter)
    {
        return;
    }
    
    if (value)
    {
        if (!defaultParameters)
        {
            defaultParameters = [[NSMutableDictionary alloc] init];
        }
        [defaultParameters setObject:value forKey:parameter];
    }
    else
    {
        [defaultParameters removeObjectForKey:parameter];
    }
}

- (void)setDefaultQueryParameter:(NSString *)parameter value:(NSString *)value
{
    if (!parameter)
    {
        return;
    }
    
    if (value)
    {
        if (!defaultQueryParameters)
        {
            defaultQueryParameters = [[NSMutableDictionary alloc] init];
        }
        [defaultQueryParameters setObject:value forKey:parameter];
    }
    else
    {
        [defaultQueryParameters removeObjectForKey:parameter];
    }
}

#pragma mark - Create request

- (NSMutableURLRequest *)_requestWithMethod:(NSString *)method 
                                       path:(NSString *)path 
                                 parameters:(NSDictionary *)parameters
{
    return [self requestWithMethod:method path:path parameters:parameters];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method 
                                      path:(NSString *)path 
                                parameters:(NSDictionary *)parameters
                                       tag:(NSString *)tag
                   appendDefaultParameters:(BOOL)appendDefaultParameters
{
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (appendDefaultParameters)
    {
        path = [self pathByAppendDefaultQueryParameters:path];
        parameters = [self parametersByAppendDefaultParameters:parameters];
    }
    
    NSMutableURLRequest *request = [self _requestWithMethod:method path:path parameters:parameters];
    if (requestConfigBlock)
    {
        requestConfigBlock(request);
    }
    [request setValue:(tag ? tag : kSNNetworkRequestHeaderTagValueUnknown)
        forHTTPHeaderField:kSNNetworkRequestHeaderTagName];
    
    return request;
}

- (NSMutableURLRequest *)normalRequestWithMethod:(NSString *)method 
                                            path:(NSString *)path 
                                      parameters:(NSDictionary *)parameters
{
    return [self requestWithMethod:method path:path
                        parameters:parameters
                               tag:kSNNetworkRequestHeaderTagValueNormal
           appendDefaultParameters:YES];
}

- (NSMutableURLRequest *)_multipartFormRequestWithMethod:(NSString *)method
                                                    path:(NSString *)path
                                              parameters:(NSDictionary *)parameters
                               constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>formData))block
{
    return [super multipartFormRequestWithMethod:method path:path parameters:parameters constructingBodyWithBlock:block];
}

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData>formData))block
{
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    path = [self pathByAppendDefaultQueryParameters:path];
    parameters = [self parametersByAppendDefaultParameters:parameters];
    NSMutableURLRequest *request = [self _multipartFormRequestWithMethod:method path:path parameters:parameters constructingBodyWithBlock:block];
    [request setValue:kSNNetworkRequestHeaderTagValueUpload
        forHTTPHeaderField:kSNNetworkRequestHeaderTagName];
    return request;
}

@end

@implementation SNNetworkClient

#pragma mark - Perform HTTP request operation

- (SNHTTPRequestOperationWrapper *)getPath:(NSString *)path 
                                parameters:(NSDictionary *)parameters
                              successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                              failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock
{
	NSMutableURLRequest *request = [self normalRequestWithMethod:@"GET" path:path parameters:parameters];
    return [self enqueueOperationWithRequest:request successBlock:successBlock failureBlock:failureBlock];
}

- (SNHTTPRequestOperationWrapper *)getPath:(NSString *)path
                                parameters:(NSDictionary *)parameters
                               headerField:(NSDictionary *)headerField
                              successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                              failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock
{
	NSMutableURLRequest *request = [self normalRequestWithMethod:@"GET" path:path parameters:parameters];
    
    if (headerField)
    {
        [request setAllHTTPHeaderFields:headerField];
    }
    
    return [self enqueueOperationWithRequest:request successBlock:successBlock failureBlock:failureBlock];
}

- (SNHTTPRequestOperationWrapper *)postPath:(NSString *)path 
                                 parameters:(NSDictionary *)parameters
                               successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                               failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock
{
	NSMutableURLRequest *request = [self normalRequestWithMethod:@"POST" path:path parameters:parameters];
	return [self enqueueOperationWithRequest:request successBlock:successBlock failureBlock:failureBlock];
}

- (SNHTTPRequestOperationWrapper *)putPath:(NSString *)path 
                                parameters:(NSDictionary *)parameters 
                              successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                              failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock
{
	NSMutableURLRequest *request = [self normalRequestWithMethod:@"PUT" path:path parameters:parameters];
	return [self enqueueOperationWithRequest:request successBlock:successBlock failureBlock:failureBlock];
}

- (SNHTTPRequestOperationWrapper *)deletePath:(NSString *)path 
                                   parameters:(NSDictionary *)parameters
                                 successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                                 failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock
{
	NSMutableURLRequest *request = [self normalRequestWithMethod:@"DELETE" path:path parameters:parameters];
	return [self enqueueOperationWithRequest:request successBlock:successBlock failureBlock:failureBlock];
}

#pragma mark - Perform Upload request operation

- (SNHTTPRequestOperationWrapper *)uploadPath:(NSString *)path 
                                   parameters:(NSDictionary *)parameters
                    constructingBodyWithBlock:(SNHTTPMultipartFormConstructingBodyBlock)constructingBodyBlock
                                 successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                                 failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self multipartFormRequestWithMethod:@"POST" path:path parameters:parameters constructingBodyWithBlock:constructingBodyBlock];
    return [self enqueueOperationWithRequest:request successBlock:successBlock failureBlock:failureBlock];
}

#pragma mark - Use wrapper to resend an operation

- (void)resendOperationWithWrapper:(SNHTTPRequestOperationWrapper *)wrapper
                        properties:(NSDictionary *)properties;
{
    [[wrapper retain] autorelease];
    
    NSMutableURLRequest *request = [wrapper requestWithResendProperties:properties];
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      wrapper:wrapper];
    
    [self performSelector:@selector(enqueueHTTPRequestOperation:) withObject:operation afterDelay:.02f];
}

@end
