//
//  SNNetworkImageCache.h
//

#import <Foundation/Foundation.h>

@interface SNNetworkImageCache : NSObject
{
    NSCache *memCache;
    NSString *diskCachePath;
}

+ (SNNetworkImageCache *)sharedCache;

- (NSString *)cachePathForURL:(NSString *)URL;

- (void)storeImageData:(NSData *)imageData forURL:(NSString *)URL;
- (void)storeImage:(UIImage *)image withData:(NSData *)imageData forURL:(NSString *)URL;
- (void)storeImage:(UIImage *)image forURL:(NSString *)URL;
- (void)storeImageData:(NSData *)imageData forURL:(NSString *)URL sync:(BOOL)isSync;
- (void)storeImage:(UIImage *)image withData:(NSData *)imageData forURL:(NSString *)URL sync:(BOOL)isSync;
- (void)storeImage:(UIImage *)image forURL:(NSString *)URL sync:(BOOL)isSync;


- (UIImage *)imageFromURL:(NSString *)URL;
- (NSData *)imageDataFromURL:(NSString *)URL;

- (BOOL)hasCachedURL:(NSString *)URL;
- (BOOL)hasDiskCachedURL:(NSString *)URL;
- (BOOL)hasMemoryCachedURL:(NSString *)URL;

- (void)removeImageForURL:(NSString *)URL;

- (void)clearCache;
- (void)clearMemory;
- (void)clearDisk;

@end
