//
//  OAuth+Additions.h
//
//  Created by Loren Brichter on 6/9/10.
//  Copyright 2010 Loren Brichter. All rights reserved.
//  https://bitbucket.org/atebits/oauthcore
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

@interface NSURL (OAuthAdditions)

+ (NSDictionary *)ab_parseURLQueryString:(NSString *)query;

@end

@interface NSString (OAuthAdditions)

+ (NSString *)ab_GUID;
- (NSString *)ab_RFC3986EncodedString;

@end

static NSInteger SortParameter(NSString *key1, NSString *key2, void *context)
{
	NSComparisonResult r = [key1 compare:key2];
	if(r == NSOrderedSame) { // compare by value in this case
		NSDictionary *dict = (NSDictionary *)context;
		NSString *value1 = [dict objectForKey:key1];
		NSString *value2 = [dict objectForKey:key2];
		return [value1 compare:value2];
	}
	return r;
}

static NSData *HMAC_SHA1(NSString *data, NSString *key)
{
	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [data UTF8String], [data length], buf);
	return [NSData dataWithBytes:buf length:CC_SHA1_DIGEST_LENGTH];
}