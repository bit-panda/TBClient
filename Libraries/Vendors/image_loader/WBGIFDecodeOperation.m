//
//  WBGIFDecodeOperation.m
//

#import "WBGIFDecodeOperation.h"
#import "WBGIFDecoder.h"
#import <ImageIO/ImageIO.h>

CFDictionaryRef imageSourceOptions()
{
	static CFDictionaryRef options = NULL;
	
	if (!options) {
		options = (CFDictionaryRef)[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], kCGImagePropertyGIFDictionary, nil];
	}
	
	return options;
}

@implementation WBGIFDecodeOperation

@synthesize gifData;
@synthesize gifDic;

- (void)main
{
	if (!gifData) {
		return;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//if (CGImageSourceCreateWithData == NULL) {
//		// We are using ImageIO.
//		
//		gifDuration = 0;
//		
//		NSMutableArray *frames = nil;
//		CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef)gifData, NULL);
//		if (sourceRef) {
//			size_t count = CGImageSourceGetCount(sourceRef);
//			frames = [[NSMutableArray alloc] initWithCapacity:count];
//			for (size_t i = 0; i < count; i++) {
//				CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, i, NULL);
//				if (imageRef) {
//					
//					[frames addObject:[UIImage imageWithCGImage:imageRef]];
//					CGImageRelease(imageRef);
//					
//					NSDictionary *properties = (NSDictionary *)CGImageSourceCopyPropertiesAtIndex(sourceRef, i, imageSourceOptions());
//					NSDictionary *gifProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
//					gifDuration += [[gifProperties objectForKey:(NSString *)kCGImagePropertyGIFDelayTime] floatValue];
//					[properties release];
//				}
//			}
//			
//			CFRelease(sourceRef);
//		}
//		
//		gifFrames = frames;
//		
//		[self performSelectorOnMainThread:@selector(finishedDecoding) withObject:nil waitUntilDone:YES];
//		
//	} else {
		// ImageIO is not available; use the silly decoder, which has some problems with transparency.
		
		WBGIFDecoder *decoder = [[[WBGIFDecoder alloc] init] autorelease];
		[decoder decodeGIF:gifData];
		[self performSelectorOnMainThread:@selector(finishedDecodingWithDecoder:) withObject:decoder waitUntilDone:YES];
	//}
	
	[pool drain];
}
- (void)calc
{
	if (!gifData) {
		return;
	}
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (CGImageSourceCreateWithData != NULL) {
		// We are using ImageIO.
		
		gifDuration = 0;
		
		NSMutableArray *frames = nil;
		CGImageSourceRef sourceRef = CGImageSourceCreateWithData((CFDataRef)gifData, NULL);
		if (sourceRef) {
			size_t count = CGImageSourceGetCount(sourceRef);
			frames = [[NSMutableArray alloc] initWithCapacity:count];
			for (size_t i = 0; i < count; i++) {
				CGImageRef imageRef = CGImageSourceCreateImageAtIndex(sourceRef, i, NULL);
				if (imageRef) {
					
					[frames addObject:[UIImage imageWithCGImage:imageRef]];
					CGImageRelease(imageRef);
					
					NSDictionary *properties = (NSDictionary *)CGImageSourceCopyPropertiesAtIndex(sourceRef, i, imageSourceOptions());
					NSDictionary *gifProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
					gifDuration += [[gifProperties objectForKey:(NSString *)kCGImagePropertyGIFDelayTime] floatValue];
					[properties release];
				}
			}
			
			CFRelease(sourceRef);
		}
		
		gifFrames = frames;
		
		[self performSelectorOnMainThread:@selector(finishedDecoding) withObject:nil waitUntilDone:YES];
		
	} else {
	// ImageIO is not available; use the silly decoder, which has some problems with transparency.
	
	WBGIFDecoder *decoder = [[[WBGIFDecoder alloc] init] autorelease];
	[decoder decodeGIF:gifData];
	[self performSelectorOnMainThread:@selector(finishedDecodingWithDecoder:) withObject:decoder waitUntilDone:YES];
	}
	
	[pool drain];
}
// Use ImageIO.
- (void)finishedDecoding
{
	NSMutableArray *frames = gifFrames;
	NSNumber *duration = [NSNumber numberWithFloat:gifDuration];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:frames, @"frames", duration, @"duration", nil];
	self.gifDic = userInfo;
}

// Use GIF Decoder.
- (void)finishedDecodingWithDecoder:(WBGIFDecoder *)decoder
{
	NSMutableArray *frames = decoder.frames;
	NSNumber *duration = [NSNumber numberWithFloat:decoder.duration];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:frames, @"frames", duration, @"duration", nil];
	self.gifDic = userInfo;
}

- (void)dealloc
{
	[gifData release], gifData = nil;
	[gifFrames release], gifFrames = nil;
	[gifDic release], gifDic = nil;
	[super dealloc];
}

@end
