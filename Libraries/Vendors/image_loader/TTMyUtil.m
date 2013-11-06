//
//  TTMyUtil.m
//
//  Created by baoyin on 10-4-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TTMyUtil.h"

NSString* TTPathForBundleResource(NSString* relativePath) {
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	return [resourcePath stringByAppendingPathComponent:relativePath];
}
NSString* TTPathForDocumentsResource(NSString* relativePath) {
	static NSString* documentsPath = nil;
	if (!documentsPath) {
		NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsPath = [[dirs objectAtIndex:0] retain];
	}
	return [documentsPath stringByAppendingPathComponent:relativePath];
}
BOOL TTIsDocumentsURL(NSString* URL) {
	if (URL.length >= 12) {
		return [URL rangeOfString:@"documents://" options:0 range:NSMakeRange(0,12)].location == 0;
	} else {
		return NO;
	}
}
BOOL TTIsBundleURL(NSString* URL) {
	if (URL.length >= 9) {
		return [URL rangeOfString:@"bundle://" options:0 range:NSMakeRange(0,9)].location == 0;
	} else {
		return NO;
	}
}
