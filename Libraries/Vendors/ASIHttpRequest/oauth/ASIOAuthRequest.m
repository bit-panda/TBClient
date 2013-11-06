//
//  ASIOAuthRequest.m
//  DownloadDemo
//
//  Created by Kai on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ASIOAuthRequest.h"
#import "OAuth+Additions.h"
#import "NSData+Base64.h"

@interface ASIOAuthRequest()

- (void)buildAuthorizationHeader;

@end

@implementation ASIOAuthRequest

@synthesize xAuth = _xAuth;
@synthesize xAuthUsername = _xAuthUsername;
@synthesize xAuthPassword = _xAuthPassword;
@synthesize xAuthSource = _xAuthSource;
@synthesize xAuthMode = _xAuthMode;
@synthesize consumerKey = _consumerKey;
@synthesize consumerSecret = _consumerSecret;
@synthesize tokenKey = _tokenKey;
@synthesize tokenSecret = _tokenSecret;
@synthesize returnedTokenKey = _returnedTokenKey;
@synthesize returnedTokenSecret = _returnedTokenSecret;
@synthesize returnedUserID = _returnedUserID;
@synthesize shouldNotBuildOAuthHeaders = _shouldNotBuildOAuthHeaders;

- (id)initWithURL:(NSURL *)newURL
{
	if ((self = [super initWithURL:newURL])) {
		_tokenSecret = @"";
	}
	
	return self;
}

- (void)buildPostBody
{
	[super buildPostBody];
	
	if (!_shouldNotBuildOAuthHeaders) {
		[self buildAuthorizationHeader];
	}
}

/********************************************************************
 ** 方法功能说明: 建立OAuth验证请求头.
 ** 首先, 添加基本OAuth字段, 根据是否为xAuth验证, 区分加入的字段.
 ** 然后, 加入POST和GET请求字段, 校正URL地址字符串. 最后进行HMAC-SHA1加密.
 ** 最后, 将所有字段拼装成一个字符串, 加入在请求头中.
 ** 注: xAuth验证用于获取Access token和Access token secret.
 ** 代码源自OAuthCore https://bitbucket.org/atebits/oauthcore
 ** 修改部分代码以适应ASIHTTPRequest和xAuth验证. 并减少了部分内存使用.
 *******************************************************************/
- (void)buildAuthorizationHeader
{
	NSString *_oAuthNonce = [NSString ab_GUID];
	NSString *_oAuthTimestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
	NSString *_oAuthSignatureMethod = @"HMAC-SHA1";
	NSString *_oAuthVersion = @"1.0";
	
	NSMutableDictionary *oAuthAuthorizationParameters = [NSMutableDictionary dictionary];
	[oAuthAuthorizationParameters setObject:_oAuthNonce forKey:@"oauth_nonce"];
	[oAuthAuthorizationParameters setObject:_oAuthTimestamp forKey:@"oauth_timestamp"];
	[oAuthAuthorizationParameters setObject:_oAuthSignatureMethod forKey:@"oauth_signature_method"];
	[oAuthAuthorizationParameters setObject:_oAuthVersion forKey:@"oauth_version"];
	[oAuthAuthorizationParameters setObject:_consumerKey forKey:@"oauth_consumer_key"];
	
	if(_tokenKey)
		[oAuthAuthorizationParameters setObject:_tokenKey forKey:@"oauth_token"];
	
	if (_xAuth) {
		[oAuthAuthorizationParameters setObject:_xAuthUsername forKey:@"x_auth_username"];
		[oAuthAuthorizationParameters setObject:_xAuthPassword forKey:@"x_auth_password"];
		[oAuthAuthorizationParameters setObject:_xAuthMode forKey:@"x_auth_mode"];
	}
	
	// GET query and body parameters (POST).
	NSDictionary *additionalQueryParameters = [NSURL ab_parseURLQueryString:[url query]];
	NSMutableDictionary *additionalBodyParameters = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSDictionary *data in postData) {
		[additionalBodyParameters setObject:[data objectForKey:@"value"] forKey:[data objectForKey:@"key"]];
	}
	
	// Combine all parameters.
	NSMutableDictionary *parameters = [[oAuthAuthorizationParameters mutableCopy] autorelease];
	if (additionalQueryParameters) [parameters addEntriesFromDictionary:additionalQueryParameters];
	if (additionalBodyParameters) [parameters addEntriesFromDictionary:additionalBodyParameters];
	
	// -> UTF-8 -> RFC3986.
	NSMutableDictionary *encodedParameters = [NSMutableDictionary dictionary];
	for(NSString *key in parameters) {
		NSString *value = [parameters objectForKey:key];
		[encodedParameters setObject:[value ab_RFC3986EncodedString] forKey:[key ab_RFC3986EncodedString]];
	}
	
	NSArray *sortedKeys = [[encodedParameters allKeys] sortedArrayUsingFunction:SortParameter context:encodedParameters];
	
	NSMutableArray *parameterArray = [NSMutableArray array];
	for(NSString *key in sortedKeys) {
		[parameterArray addObject:[NSString stringWithFormat:@"%@=%@", key, [encodedParameters objectForKey:key]]];
	}
	NSString *normalizedParameterString = [parameterArray componentsJoinedByString:@"&"];
	
	NSString *normalizedURLString = [NSString stringWithFormat:@"%@://%@%@", [url scheme], [url host], [url path]];
	
	NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@",
									 [[self requestMethod] ab_RFC3986EncodedString],
									 [normalizedURLString ab_RFC3986EncodedString],
									 [normalizedParameterString ab_RFC3986EncodedString]];
	
	NSString *key = [NSString stringWithFormat:@"%@&%@",
					 [_consumerSecret ab_RFC3986EncodedString],
					 [_tokenSecret ab_RFC3986EncodedString]];
	
	NSData *signature = HMAC_SHA1(signatureBaseString, key);
	NSString *base64Signature = [signature base64EncodedString];
	
	NSMutableDictionary *authorizationHeaderDictionary = [[oAuthAuthorizationParameters mutableCopy] autorelease];
	[authorizationHeaderDictionary setObject:base64Signature forKey:@"oauth_signature"];
	
	if (_xAuth) {
		[authorizationHeaderDictionary setObject:_xAuthSource forKey:@"source"];
	}
	
	NSMutableArray *authorizationHeaderItems = [NSMutableArray array];
	for(NSString *key in authorizationHeaderDictionary) {
		NSString *value = [authorizationHeaderDictionary objectForKey:key];
		[authorizationHeaderItems addObject:[NSString stringWithFormat:@"%@=\"%@\"",
											 [key ab_RFC3986EncodedString],
											 [value ab_RFC3986EncodedString]]];
	}
	
	NSString *authorizationHeaderString = [authorizationHeaderItems componentsJoinedByString:@", "];
	authorizationHeaderString = [NSString stringWithFormat:@"OAuth %@", authorizationHeaderString];
	
	[self addRequestHeader:@"Authorization" value:authorizationHeaderString];
}

- (void)parseReturnedToken
{
	[_returnedTokenKey release]; _returnedTokenKey = nil;
	[_returnedTokenSecret release]; _returnedTokenSecret = nil;
	
	// We should have a reply like: oauth_token_secret=CC2sL93UdYzwpQT9&oauth_token=Nw86rNQ653BnSGSw&user_id=123456789.
	NSString *response = [self responseString];
	NSArray *pairs = [response componentsSeparatedByString:@"&"];
		
	for (NSString *pair in pairs) {
		
		NSArray* keyValue = [pair componentsSeparatedByString:@"="];
		if (keyValue.count != 2) 
			continue;
		
		NSString *key = [keyValue objectAtIndex:0];
		NSString *value = [keyValue objectAtIndex:1];
		
		if ([key compare:@"oauth_token"] == NSOrderedSame) {
			_returnedTokenKey = [value retain];
		} else if ([key compare:@"oauth_token_secret"] == NSOrderedSame) {
			_returnedTokenSecret = [value retain];
		} else if ([key compare:@"user_id"] == NSOrderedSame) {
			_returnedUserID = [[NSNumber numberWithLongLong:[value longLongValue]] retain];
		}
	}
}

- (void)dealloc
{
    [_xAuthUsername release];
    [_xAuthPassword release];
    [_xAuthSource release];
    [_xAuthMode release];
    [_consumerKey release];
    [_consumerSecret release];
    [_tokenKey release];
    [_tokenSecret release];
    [_returnedTokenKey release];
    [_returnedTokenSecret release];
	[_returnedUserID release];
	
	[super dealloc];
}

@end
