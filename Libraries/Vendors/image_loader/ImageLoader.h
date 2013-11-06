// Copyright (c) 2009 Imageshack Corp.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import <Foundation/Foundation.h>
#import "yFrogImageDownoader.h"
#import "TTURLCache.h"

@class WBGIFDecodeOperation;

@protocol ImageLoaderDelegate;

@interface ImageLoader : NSObject<ImageDownoaderDelegate> 
{
	//NSMutableDictionary *_cache;
    NSCache *_cache;
	NSMutableDictionary *_activeDownloads;
	id <ImageLoaderDelegate> delegate;
	int cellImageTag;
	CGPoint imageCenter;
	CGRect viewRect;
	
	NSMutableDictionary *_dictLastUrlForView;
	
	WBGIFDecodeOperation *myWBGIFDecode;
    
    BOOL isScrolling;
    
    BOOL thumbNailImage;
}

+ (ImageLoader*)sharedLoader;
- (void)clearCacheImage;
- (void)initDownLoader:(NSString*)url;
- (UIImage*)imageWithURL:(NSString*)url;
- (void)setImageWithURL:(NSString*)url toView:(UIImageView*)imageView;
- (void)setImageWithURL:(NSString*)url toView:(UIImageView*)imageView delegate:(id <ImageLoaderDelegate>)dlgt;
- (void)setImageWithURL:(NSString *)url toButton:(UIButton *)button;

- (void)changeFrameImage:(UIImage*) photoImage photoImageView:(UIImageView*) photoImageView;
- (void)changeImage:(UIImage *) photoImage photoImageViewFrame:(UIImageView *) m_ImageView;

@property (nonatomic,assign) id <ImageLoaderDelegate> delegate;
@property (nonatomic) CGPoint imageCenter;
@property (nonatomic) CGRect viewRect;
@property (nonatomic,assign) NSCache *_cache;//NSMutableDictionary *_cache;
@property (nonatomic,assign) BOOL isScrolling;
@property (nonatomic,assign) BOOL thumbNailImage;

@end

@protocol ImageLoaderDelegate <NSObject>
@optional
- (void) onImageLoadComplete:(ImageLoader *) sender;
- (void) loadImageTotalSize:(long long) imageSize withImageLoader:(ImageLoader *) sender;
- (void) didReceiveImageSize:(long long) loadingSize withImageLoader:(ImageLoader *) sender;
- (void) gifLoadFailed:(ImageLoader *) sender;
- (void) imageLoadFailed:(ImageLoader *) sender;
@end
