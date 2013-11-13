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

#import "ImageLoader.h"
#import "TTURLCache.h"
#import "WBGIFDecodeOperation.h"
#import <ImageIO/ImageIO.h>


#define kMaximumImageCacheSize          15      // 10 MB.

@implementation ImageLoader
@synthesize delegate,imageCenter,viewRect,_cache,isScrolling,thumbNailImage;

- (id)init
{
	self = [super init];
	if(self)
	{
		//_cache = [[NSMutableDictionary alloc] initWithCapacity:20];
        _cache = [[NSCache alloc] init];
        [_cache setTotalCostLimit:kMaximumImageCacheSize * 1024 * 1024];
		_activeDownloads = [[NSMutableDictionary alloc] initWithCapacity:20];
		_dictLastUrlForView = [[NSMutableDictionary alloc] initWithCapacity:20];
		myWBGIFDecode = [[WBGIFDecodeOperation alloc] init];
	}
	
	return self;
}

- (void)clearCacheImage
{
	[[ImageLoader sharedLoader]._cache removeAllObjects];
}
+ (ImageLoader*)sharedLoader
{
	static ImageLoader *loader;
	
	if(!loader)
		loader = [[ImageLoader alloc] init];
	
	return loader;
}

- (UIImage*)imageWithURL:(NSString*)url
{
	UIImage *image = [[ImageLoader sharedLoader]._cache objectForKey:url];
	if(image) return image;
	
	NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
	if(!imageData) return nil;
	
	image = [UIImage imageWithData:imageData];
	if(image)
		[[ImageLoader sharedLoader]._cache setObject:image forKey:url];
	
	return image;
}

- (void)setImageWithURL:(NSString*)url toView:(UIImageView*)imageView
{	
	if (url==nil || ![url isKindOfClass:[NSString class]] || [url isEqualToString:@""]) {
		return;
	}
		
	NSString *imgvHash = [[NSString alloc]initWithFormat:@"%d",(int)imageView];
	[_dictLastUrlForView setObject:url forKey:imgvHash];
	[imgvHash release];
	
	NSMutableArray *newPendingViews;
    [self performSelector:@selector(initDownLoader:) withObject:url afterDelay:0.001f];
    if (imageView)
    {
        newPendingViews = [NSMutableArray arrayWithObject:imageView];
        [_activeDownloads setObject:newPendingViews forKey:url];
    }
}

- (void)setImageWithURL:(NSString *)url toButton:(UIButton *)button
{
    if (url == nil)
	{
		return;
	}
	
	NSString *imgvHash = [NSString stringWithFormat:@"%d", (int)button];
	[_dictLastUrlForView setObject:url forKey:imgvHash];
	UIImage *image = [[ImageLoader sharedLoader]._cache objectForKey:url];
	if(image)
	{
		[button setImage:image forState:UIControlStateNormal];
		
		if (delegate && [delegate respondsToSelector:@selector(onImageLoadComplete:)])
		{
			[delegate onImageLoadComplete:self];
		}
		return;
	}
	
	NSData* imgData = [[TTURLCache sharedCache] dataForURL:url];
    if(imgData)
    {
        image = [UIImage imageWithData:imgData];
        [button setImage:image forState:UIControlStateNormal];
        
        if (delegate&&[delegate respondsToSelector:@selector(onImageLoadComplete:)])
        {
            [delegate onImageLoadComplete:self];
        }
        return;
    }
    
	NSMutableArray *pendingViews = [_activeDownloads objectForKey:url];
	if (pendingViews)
	{
		[pendingViews addObject:button];
	}
	else
	{
        if(!isScrolling)
        {
            [self performSelector:@selector(initDownLoader:) withObject:url afterDelay:0.f];
            
            if(button)
            {
                pendingViews = [NSMutableArray arrayWithObject:button];
                [_activeDownloads setObject:pendingViews forKey:url];
            }
        }
	}
}

- (void)initDownLoader:(NSString*)url
{
    ImageDownoader *downloader = [[ImageDownoader alloc] init];
    [downloader getImageFromURL:url imageType:nonYFrog delegate:self];
    [downloader release];
}

- (void)setImageWithURL:(NSString*)url toView:(UIImageView*)imageView delegate:(id <ImageLoaderDelegate>)dlgt {
	self.delegate = dlgt;
	[self setImageWithURL:url toView:imageView];
}

- (void)loadImageTotalSize:(long long) imageSize
{    
	if (delegate&&[delegate respondsToSelector:@selector(loadImageTotalSize:withImageLoader:)])
	{
		[delegate loadImageTotalSize:imageSize withImageLoader:self];
	}
}
- (void)receivedLoadingImageSize: (long long) loadingImageSize
{
	if (delegate&&[delegate respondsToSelector:@selector(didReceiveImageSize:withImageLoader:)]) 
	{
		[delegate didReceiveImageSize:loadingImageSize withImageLoader:self];
	}
}

- (void)receivedImage:(UIImage*)image sender:(ImageDownoader*)sender
{
	if(image)
	{		
		BOOL isGif = [sender.origURL hasSuffix:@".gif"];
		
        if (thumbNailImage) {
            image = [self getThumbnailImage:image];
        }else {
            [[ImageLoader sharedLoader]._cache setObject:image forKey:sender.origURL];

        }
		
		NSMutableArray *pendingViews = [_activeDownloads objectForKey:sender.origURL];
		if(pendingViews)
		{
			for(UIImageView *view in pendingViews)
			{
				switch (2500)
				{
					case 2000:	//信息流缩略图
					{
						[self changeFrameImage:image photoImageView:view];
						
						NSString *lastImgUrl = [_dictLastUrlForView objectForKey:[NSString stringWithFormat:@"%d",(int)view]];
						if ([lastImgUrl isEqual:sender.origURL])
						{
                            view.alpha = 0;
                            view.image = image;
                            [UIView beginAnimations:nil context:nil];
                            [UIView setAnimationDuration:0.2f];
                            view.alpha = 1;
                            [UIView commitAnimations];
                        }
						break;
					}
					case 2500:	//查看大图
					{
						[self changeImage: image photoImageViewFrame:view];
						
						if (isGif == YES)
						{
							NSData *imageData = [NSData dataWithData:sender.result];
							myWBGIFDecode.gifData = imageData;
							[myWBGIFDecode calc];
						}
						
						NSString *lastImgUrl = [_dictLastUrlForView objectForKey:[NSString stringWithFormat:@"%d",(int)view]];
						if ([lastImgUrl isEqual:sender.origURL])
						{
							if (isGif == YES)
							{
								NSDictionary *gifImageDic = [NSDictionary dictionaryWithDictionary:myWBGIFDecode.gifDic];
								NSArray *gifArray = nil;
                                
                                if ([gifImageDic objectForKey:@"frames"]) 
                                {
                                    gifArray = [gifImageDic objectForKey:@"frames"];
                                }
                                
                                if ([gifArray count] == 0) 
                                {
                                    view.alpha = 0;
                                    view.image = image;
                                    [UIView beginAnimations:nil context:nil];
                                    [UIView setAnimationDuration:0.2f];
                                    view.alpha = 1;
                                    [UIView commitAnimations];
                                    break;
                                }
                                
								float gifDuration = [(NSNumber *)[gifImageDic objectForKey:@"duration"] floatValue];
								
								
								if ([gifArray count] > 0) 
								{
									UIImage * firstFrameImage = [gifArray objectAtIndex:0];
									float gifSize = firstFrameImage.size.width * firstFrameImage.size.height * 4 / 1024 / 1024 * [gifArray count];
									
									 
									int maxSize;
									if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DeviceModel"] isEqualToString:@"ipad1"]) {
										maxSize = 40;
									}
									else {
										maxSize = 60;
										
									}
									
									if (gifSize < maxSize) 
									{
									
										//if (CGImageSourceCreateWithData != NULL)
											//[myWBGIFDecode main];
																				
										NSDictionary *gifImageDic = [NSDictionary dictionaryWithDictionary:myWBGIFDecode.gifDic];
										NSArray *gifArray = nil;
                                        
                                        if ([gifImageDic objectForKey:@"frames"]) 
                                        {
                                            gifArray = [gifImageDic objectForKey:@"frames"];
                                        }
                                        
                                        if ([gifArray count] == 0) 
                                        {
                                            view.alpha = 0;
                                            view.image = image;
                                            [UIView beginAnimations:nil context:nil];
                                            [UIView setAnimationDuration:0.2f];
                                            view.alpha = 1;
                                            [UIView commitAnimations];
                                            break;
                                        }
										
										//判断imageIO获取时间
										if (gifDuration == 0.0) 
										{
											gifDuration = [(NSNumber *)[gifImageDic objectForKey:@"duration"] floatValue];
										}
										//判断WBGIFDecoder获取时间
										if (gifDuration == 0.0) 
										{
											gifDuration = 0.1 * [gifArray count];
										}
										
										[view setImage:[gifArray objectAtIndex:0]];
										[view setBackgroundColor:[UIColor whiteColor]];
										[view sizeToFit];
										[view setAnimationImages: gifArray];
										[view setAnimationDuration:gifDuration];
										[view startAnimating];
									}
									else 
                                    {
                                        view.alpha = 0;
                                        view.image = image;
                                        [UIView beginAnimations:nil context:nil];
                                        [UIView setAnimationDuration:0.2f];
                                        view.alpha = 1;
                                        [UIView commitAnimations];
                                            
										if (delegate&&[delegate respondsToSelector:@selector(gifLoadFailed:)]) {
											[delegate gifLoadFailed:self];
										}
									}									
								}
								else 
								{
                                    view.alpha = 0;
                                    view.image = image;
                                    [UIView beginAnimations:nil context:nil];
                                    [UIView setAnimationDuration:0.2f];
                                    view.alpha = 1;
                                    [UIView commitAnimations];
								}																
							}
							else 
							{							 
                                view.alpha = 0;
                                view.image = image;
                                [UIView beginAnimations:nil context:nil];
                                [UIView setAnimationDuration:0.2f];
                                view.alpha = 1;
                                [UIView commitAnimations];
                 
							}

						}
							
						break;
					}
					default:
					{	
												
						NSString *lastImgUrl = [_dictLastUrlForView objectForKey:[NSString stringWithFormat:@"%d",(int)view]];
						if ([lastImgUrl isEqual:sender.origURL])
						{
                            [self setImage:image toView:view withUrl:lastImgUrl];
                            
                            view.alpha = 0;
                            [UIView beginAnimations:nil context:nil];
                            [UIView setAnimationDuration:0.2f];
                            view.alpha = 1;
                            [UIView commitAnimations];
						}
							
						break;
					}
				}
				
			}
				
		}
		
		[pendingViews removeAllObjects];
	}
    else
    {
        if(delegate && [delegate respondsToSelector:@selector(imageLoadFailed:)])
        {
            [delegate imageLoadFailed:self];
        }
    }
	
	[_activeDownloads removeObjectForKey:sender.origURL];
	
	if (delegate&&[delegate respondsToSelector:@selector(onImageLoadComplete:)])
    {
		[delegate onImageLoadComplete:self];
	}
}

- (void)setImage:(UIImage *)image toView:(id)view withUrl:(NSString *)url
{
	if([view isKindOfClass:[UIImageView class]])
	{
		((UIImageView *)view).image = image;
	}
	else if([view isKindOfClass:[UIButton class]])
	{
		[((UIButton *)view) setImage:image forState:UIControlStateNormal];
	}
}

-(void)changeFrameImage:(UIImage*) photoImage photoImageView:(UIImageView*) photoImageView
{
	CGSize wbImageRect = photoImage.size;
	
	float ratio ;
	
	CGRect imageSize = photoImageView.frame;
	
	if (wbImageRect.width >= wbImageRect.height)
	{
		ratio = wbImageRect.width /  wbImageRect.height;
		imageSize.size.height = 100;
		imageSize.size.width = imageSize.size.height * ratio;
	}
	else 
	{
		ratio = wbImageRect.height / wbImageRect.width;
		imageSize.size.width = 100;
		imageSize.size.height = imageSize.size.width * ratio;
	}
	
}

-(void)changeImage:(UIImage *) photoImage photoImageViewFrame:(UIImageView *) m_ImageView
{
	CGSize imageSize = photoImage.size;
	CGRect imageViewRect = m_ImageView.frame;
	
	if (imageSize.height < self.viewRect.size.height && imageSize.width < self.viewRect.size.width) 
	{
		imageViewRect.size = imageSize;
		m_ImageView.frame = imageViewRect;
		m_ImageView.center = self.imageCenter;
	}	
}

- (void)dealloc {
	
	[_cache removeAllObjects];
	[_cache release],_cache = nil;
	[_activeDownloads release],_activeDownloads = nil;
	[_dictLastUrlForView release],_dictLastUrlForView = nil;
	
	[myWBGIFDecode release];
    [super dealloc];
}
 
- (UIImage *)getThumbnailImage: (UIImage *)image
{
	UIImage *thumbnailImage;
	
	CGSize size = image.size;
	CGFloat ratio = 0;
	
	CGFloat thumbnailWdith = 170;
	CGFloat thumbnailHeight = 130;
    
    if (image.size.height < 170 || image.size.width < 130) 
    {
        return image;
    }
	
    ratio = (size.width > size.height) ? (thumbnailWdith / size.width) : (thumbnailHeight / size.height);
	
	CGRect rectImage = CGRectMake(0, 0, size.width * ratio, size.height* ratio);
	
	UIGraphicsBeginImageContext(rectImage.size);
	
	[image drawInRect: rectImage];
	
	thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
	
	return thumbnailImage;
} 
@end
