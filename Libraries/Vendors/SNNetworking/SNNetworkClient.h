//
//  SNNetworkClient.h
//  AFNetworkingDemo
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define kSNNetworkRequestHeaderTagName              @"SINA_Networking_Request_Tag"
#define kSNNetworkRequestHeaderTagValueUnknown      @"unknown"
#define kSNNetworkRequestHeaderTagValueNormal       @"normal"
#define kSNNetworkRequestHeaderTagValueImage        @"image"
#define kSNNetworkRequestHeaderTagValueUpload       @"upload"

void SNNetworkAddRequestParameter(NSMutableDictionary *parameters, NSString *name, NSString *value);

@protocol SNMultipartFormData <AFMultipartFormData>
@end

@class SNHTTPRequestOperationWrapper;

typedef void (^SNHTTPRequestOperationUploadProgressBlock)(double progress, long long totalBytes, long long uploadedBytes);
typedef void (^SNHTTPRequestOperationDownloadProgressBlock)(double progress, long long totalBytes, long long downloadedBytes);

typedef void (^SNHTTPRequestOperationSuccessBlock)(SNHTTPRequestOperationWrapper *operationWrapper, id responseObject);
typedef void (^SNHTTPRequestOperationFailureBlock)(SNHTTPRequestOperationWrapper *operationWrapper, NSError *error);

typedef void (^SNHTTPMultipartFormConstructingBodyBlock)(id <SNMultipartFormData>formData);

@protocol SNNetworkErrorHandler
+ (NSError *)handleError:(NSError *)error forWrapper:(SNHTTPRequestOperationWrapper *)wrapper;
@end

@protocol SNConfiguableRequestOperation <NSObject>
- (void)configWithSettings:(NSDictionary *)settings;
@end

@interface SNNetworkBaseClient : AFHTTPClient
{
    NSMutableDictionary *operationWrappers;
    NSMutableDictionary *defaultParameters;
    NSMutableDictionary *defaultQueryParameters;
    Class errorHandlerClass;
    void (^requestConfigBlock)(NSMutableURLRequest *request);
    BOOL handleSafeBlockObjectDeallocNotification;
}

- (id)initWithBaseURL:(NSURL *)URL requestConfigBlock:(void (^)(NSMutableURLRequest *request))requestConfigBlock;

- (NSURL *)baseURL;
- (BOOL)registerErrorHandlerClass:(Class)errorHandlerClass;
- (void)clearErrorHandlerClass;
- (void)setDefaultParameter:(NSString *)parameter value:(NSString *)value;
- (void)setDefaultQueryParameter:(NSString *)parameter value:(NSString *)value;

- (SNHTTPRequestOperationWrapper *)enqueueOperationWithRequest:(NSMutableURLRequest *)request
                                                  successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                                                  failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock;

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method 
                                      path:(NSString *)path 
                                parameters:(NSDictionary *)parameters
                                       tag:(NSString *)tag
                   appendDefaultParameters:(BOOL)appendDefaultParameters;

- (void)cancelAllRequests;
- (void)cancelWrapper:(SNHTTPRequestOperationWrapper *)wrapper;
- (void)cancelAllWrappersWithIdentifier:(NSString *)identifier;
- (void)resetBaseURL:(NSURL *)URL;

@property (nonatomic, assign) BOOL handleSafeBlockObjectDeallocNotification;

@end

@interface SNNetworkClient : SNNetworkBaseClient

#pragma mark - Normal request

/*
 path 请求的路径
 parameters 请求参数
 successBlock 成功之后的回调
 failureBlock 失败之后的回调
 */
- (SNHTTPRequestOperationWrapper *)getPath:(NSString *)path
                                parameters:(NSDictionary *)parameters
                              successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                              failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock;

- (SNHTTPRequestOperationWrapper *)getPath:(NSString *)path
                                parameters:(NSDictionary *)parameters
                               headerField:(NSDictionary *)headerField
                              successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                              failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock;

- (SNHTTPRequestOperationWrapper *)postPath:(NSString *)path 
                                 parameters:(NSDictionary *)parameters
                               successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                               failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock;

- (SNHTTPRequestOperationWrapper *)putPath:(NSString *)path 
                                parameters:(NSDictionary *)parameters 
                              successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                              failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock;

- (SNHTTPRequestOperationWrapper *)deletePath:(NSString *)path 
                                   parameters:(NSDictionary *)parameters 
                                 successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                                 failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock;

/*
 path 请求的路径
 parameters 请求参数
 constructingBodyWithBlock 添加文件内容数据的block
 successBlock 成功之后的回调
 failureBlock 失败之后的回调
 */
- (SNHTTPRequestOperationWrapper *)uploadPath:(NSString *)path 
                                   parameters:(NSDictionary *)parameters
                    constructingBodyWithBlock:(SNHTTPMultipartFormConstructingBodyBlock)constructingBodyBlock
                                 successBlock:(SNHTTPRequestOperationSuccessBlock)successBlock
                                 failureBlock:(SNHTTPRequestOperationFailureBlock)failureBlock;

- (void)resendOperationWithWrapper:(SNHTTPRequestOperationWrapper *)wrapper
                        properties:(NSDictionary *)properties;

@end
