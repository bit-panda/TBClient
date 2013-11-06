//
//  WBGIFDecodeOperation.h

#import <Foundation/Foundation.h>

#define kGIFDidFinishDecodingNotification		@"GIFDidFinishDecodingNotification"

@interface WBGIFDecodeOperation : NSOperation {
	
	NSData *gifData;
	
	NSMutableArray *gifFrames;
	NSDictionary *gifDic;
	CGFloat gifDuration;
}

@property (nonatomic, retain) NSData *gifData;
@property (nonatomic, retain) NSDictionary *gifDic;

- (void)calc;

@end
