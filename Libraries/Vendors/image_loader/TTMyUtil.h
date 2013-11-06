//
//  TTMyUtil.h
//
//  Created by baoyin on 10-4-1.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TTLOG NSLog
#define TT_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

NSString* TTPathForBundleResource(NSString* relativePath);
NSString* TTPathForDocumentsResource(NSString* relativePath);
BOOL TTIsDocumentsURL(NSString* URL);
BOOL TTIsBundleURL(NSString* URL);