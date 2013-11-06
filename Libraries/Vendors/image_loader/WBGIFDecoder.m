//
//  WBGIFDecoder.m
//

#import "WBGIFDecoder.h"

// If this option is enabled, the process will consume more time & memory, but the result will be the best available;
// otherwise, if the GIF is using Do Not Dispose method, the resulted image sequence will have some transparency issues.
#define kGIFDisposalMethodEnabled			YES

@implementation WBGIFFrame

@synthesize data, delay, disposalMethod, area, header;

- (void)dealloc
{
	[data release];
	[header release];
	[super dealloc];
}

@end

@implementation WBGIFDecoder

@synthesize frames;
@synthesize duration;

// the decoder
// decodes GIF image data into separate frames
// based on the Wikipedia Documentation at:
//
// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Example_.gif_file
// http://en.wikipedia.org/wiki/Graphics_Interchange_Format#Animated_.gif
//
- (void)decodeGIF:(NSData *)GIFData
{
	GIF_pointer = GIFData;
    
    if (GIF_buffer != nil)
    {
        [GIF_buffer release];
    }
    
    if (GIF_global != nil)
    {
        [GIF_global release];
    }
    
    if (GIF_screen != nil)
    {
        [GIF_screen release];
    }
    
	[GIF_frames release];
	
    GIF_buffer = [[NSMutableData alloc] init];
	GIF_global = [[NSMutableData alloc] init];
	GIF_screen = [[NSMutableData alloc] init];
	GIF_frames = [[NSMutableArray alloc] init];
	
    // Reset file counters to 0
	dataPointer = 0;
	
	[self GIFSkipBytes: 6]; // GIF89a, throw away
	[self GIFGetBytes: 7]; // Logical Screen Descriptor
	
    // Deep copy
	[GIF_screen setData: GIF_buffer];
	
    // Copy the read bytes into a local buffer on the stack
    // For easy byte access in the following lines.
    int length = [GIF_buffer length];
	unsigned char aBuffer[length];
	[GIF_buffer getBytes:aBuffer length:length];
	
	if (aBuffer[4] & 0x80) GIF_colorF = 1; else GIF_colorF = 0; 
	if (aBuffer[4] & 0x08) GIF_sorted = 1; else GIF_sorted = 0;
	GIF_colorC = (aBuffer[4] & 0x07);
	GIF_colorS = 2 << GIF_colorC;
	
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes: (3 * GIF_colorS)];
        
        // Deep copy
		[GIF_global setData:GIF_buffer];
	}
	
	unsigned char bBuffer[1];
	while ([self GIFGetBytes:1] == YES)
    {
        [GIF_buffer getBytes:bBuffer length:1];
        
        if (bBuffer[0] == 0x3B)
        { // This is the end
            break;
        }
        
        switch (bBuffer[0])
        {
            case 0x21:
                // Graphic Control Extension (#n of n)
                [self GIFReadExtensions];
                break;
            case 0x2C:
                // Image Descriptor (#n of n)
                [self GIFReadDescriptor];
                break;
        }
	}
	
	// clean up stuff
	[GIF_buffer release];
    GIF_buffer = nil;
    
	[GIF_screen release];
    GIF_screen = nil;
	
	[GIF_global release];	
    GIF_global = nil;
}

- (NSMutableArray *)frames
{
	// Add all subframes to the animation
	NSMutableArray *array = [[NSMutableArray alloc] init];
	for (int i = 0; i < [GIF_frames count]; i++)
	{		
		UIImage *gifImage = [self getFrameAsImageAtIndex:i];
		
		if (gifImage) 
		{
			[array addObject: gifImage];
		}
	}
	
	if (!kGIFDisposalMethodEnabled) {
		return [array autorelease];
	} else 
	{
		
		if ([array count] == 0) 
		{
			return [array autorelease];
		}
		
		NSMutableArray *overlayArray = [[NSMutableArray alloc] init];
		UIImage *firstImage = [array objectAtIndex:0];
		CGSize size = firstImage.size;
		CGRect rect = CGRectZero;
		rect.size = size;
		
		UIGraphicsBeginImageContext(size);
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		
		int i = 0;
		WBGIFFrame *lastFrame = nil;
		for (UIImage *image in array) {
			WBGIFFrame *frame = [GIF_frames objectAtIndex:i];
			
			// Modified by Kai on Sept 13, 2011.
			// The disposal method gives instructions on what to do with the previous frame once a new frame is displayed.
			// Reference: http://www.learningwebdesign.com/pdf/animated_gifs.pdf
			
			if (lastFrame) {
				switch (lastFrame.disposalMethod) {
					case 1:
						// Do Not Dispose (Leave As Is).
						// With this option, any pixels not covered by the next frame continue to display. Use this method if you are using transparency within frames.
						//NSLog(@"Do not dispose.");
						
						break;
						
					case 2:
						// Restore to background color.
						// The background color or background tile shows through the transparent pixels of the new frame (replacing the image areas of the previous frame).
						CGContextClearRect(ctx, lastFrame.area);
						//NSLog(@"Restore background color");
						
						break;
						
					case 3:
						// TODO Restore to previous
						// This option restores to the state of the previous, undis­ posed frame. This method is not well supported and is best avoided.
						// Since this method is rarely used, simply use the "Do Not Dispose" method instead.
						break;
						
					default:
						// Unspecified (Nothing).
						// Use this option to replace one full­size, nontranspar­ent frame with another.
						
						break;
				}
			}
			
			CGContextSaveGState(ctx);
			CGContextScaleCTM(ctx, 1.0, -1.0);
			CGContextTranslateCTM(ctx, 0.0, -size.height);
			CGContextDrawImage(ctx, rect, image.CGImage);
			CGContextRestoreGState(ctx);
			[overlayArray addObject:UIGraphicsGetImageFromCurrentImageContext()];
			lastFrame = frame;
			i++;
		}
		
		UIGraphicsEndImageContext();
		
		[array release];
		
		return [overlayArray autorelease];
	}
}

- (CGFloat)duration
{
	// Count up the total delay, since Cocoa doesn't do per frame delays.
	double total = 0;
	for (WBGIFFrame *frame in GIF_frames) {
		total += frame.delay;
	}
	
	return total / 100;
}

// 
// Returns a subframe as NSMutableData.
// Returns nil when frame does not exist.
//
// Use this to write a subframe to the filesystems (cache etc);
- (NSData *)getFrameAsDataAtIndex:(int)index
{
	if (index < [GIF_frames count])
	{
		return ((WBGIFFrame *)[GIF_frames objectAtIndex:index]).data;
	}
	else
	{
		return nil;
	}
}

// 
// Returns a subframe as an autorelease UIImage.
// Returns nil when frame does not exist.
//
// Use this to put a subframe on your GUI.
- (UIImage *)getFrameAsImageAtIndex:(int)index
{
    NSData *frameData = [self getFrameAsDataAtIndex: index];
    UIImage *image = nil;
    
    if (frameData != nil)
    {
		image = [UIImage imageWithData:frameData];
    }
    
    return image;
}

- (void)GIFReadExtensions
{
	// 21! But we still could have an Application Extension,
	// so we want to check for the full signature.
	unsigned char cur[1], prev[1];
    [self GIFGetBytes:1];
    [GIF_buffer getBytes:cur length:1];
    
	while (cur[0] != 0x00)
    {
		
		// TODO: Known bug, the sequence F9 04 could occur in the Application Extension, we
		//       should check whether this combo follows directly after the 21.
		if (cur[0] == 0x04 && prev[0] == 0xF9)
		{
			[self GIFGetBytes:5];
			
			WBGIFFrame *frame = [[WBGIFFrame alloc] init];
			
			unsigned char buffer[5];
			[GIF_buffer getBytes:buffer length:5];
			frame.disposalMethod = (buffer[0] & 0x1c) >> 2;
			//NSLog(@"flags=%x, dm=%x", (int)(buffer[0]), frame.disposalMethod);
			
			// We save the delays for easy access.
			frame.delay = (buffer[1] | buffer[2] << 8);
			
			unsigned char board[8];
			board[0] = 0x21;
			board[1] = 0xF9;
			board[2] = 0x04;
			
			for(int i = 3, a = 0; a < 5; i++, a++)
			{
				board[i] = buffer[a];
			}
			
			frame.header = [NSData dataWithBytes:board length:8];
            
			[GIF_frames addObject:frame];
			[frame release];
			break;
		}
		
		prev[0] = cur[0];
        [self GIFGetBytes:1];
		[GIF_buffer getBytes:cur length:1];
	}	
}

- (void)GIFReadDescriptor
{	
	[self GIFGetBytes:9];
    
    // Deep copy
	NSMutableData *GIF_screenTmp = [NSMutableData dataWithData:GIF_buffer];
	
	unsigned char aBuffer[9];
	[GIF_buffer getBytes:aBuffer length:9];
	
	CGRect rect;
	rect.origin.x = ((int)aBuffer[1] << 8) | aBuffer[0];
	rect.origin.y = ((int)aBuffer[3] << 8) | aBuffer[2];
	rect.size.width = ((int)aBuffer[5] << 8) | aBuffer[4];
	rect.size.height = ((int)aBuffer[7] << 8) | aBuffer[6];
	
	WBGIFFrame *frame = [GIF_frames lastObject];
	frame.area = rect;
	
	if (aBuffer[8] & 0x80) GIF_colorF = 1; else GIF_colorF = 0;
	
	unsigned char GIF_code = GIF_colorC, GIF_sort = GIF_sorted;
	
	if (GIF_colorF == 1)
    {
		GIF_code = (aBuffer[8] & 0x07);
        
		if (aBuffer[8] & 0x20)
        {
            GIF_sort = 1;
        }
        else
        {
        	GIF_sort = 0;
        }
	}
	
	int GIF_size = (2 << GIF_code);
	
	size_t blength = [GIF_screen length];
	unsigned char bBuffer[blength];
	[GIF_screen getBytes:bBuffer length:blength];
	
	bBuffer[4] = (bBuffer[4] & 0x70);
	bBuffer[4] = (bBuffer[4] | 0x80);
	bBuffer[4] = (bBuffer[4] | GIF_code);
	
	if (GIF_sort)
    {
		bBuffer[4] |= 0x08;
	}
	
    NSMutableData *GIF_string = [NSMutableData dataWithData:[@"GIF89a" dataUsingEncoding: NSUTF8StringEncoding]];
	[GIF_screen setData:[NSData dataWithBytes:bBuffer length:blength]];
    [GIF_string appendData: GIF_screen];
	
	if (GIF_colorF == 1)
    {
		[self GIFGetBytes:(3 * GIF_size)];
		[GIF_string appendData:GIF_buffer];
	}
    else
    {
		[GIF_string appendData:GIF_global];
	}
	
	// Add Graphic Control Extension Frame (for transparancy)
	[GIF_string appendData:frame.header];
	
	char endC = 0x2c;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	size_t clength = [GIF_screenTmp length];
	unsigned char cBuffer[clength];
	[GIF_screenTmp getBytes:cBuffer length:clength];
	
	cBuffer[8] &= 0x40;
	
	[GIF_screenTmp setData:[NSData dataWithBytes:cBuffer length:clength]];
	
	[GIF_string appendData: GIF_screenTmp];
	[self GIFGetBytes:1];
	[GIF_string appendData: GIF_buffer];
	
	while (true)
    {
		[self GIFGetBytes:1];
		[GIF_string appendData: GIF_buffer];
		
		unsigned char dBuffer[1];
		[GIF_buffer getBytes:dBuffer length:1];
		
		long u = (long) dBuffer[0];
        
		if (u != 0x00)
        {
			[self GIFGetBytes:u];
			[GIF_string appendData: GIF_buffer];
        }
        else
        {
            break;
        }
	}
	
	endC = 0x3b;
	[GIF_string appendBytes:&endC length:sizeof(endC)];
	
	// save the frame into the array of frames
	frame.data = GIF_string;
}

/* Puts (int) length into the GIF_buffer from file, returns whether read was succesfull */
- (BOOL)GIFGetBytes:(int)length
{
    if (GIF_buffer != nil)
    {
        [GIF_buffer release]; // Release old buffer
        GIF_buffer = nil;
    }
    
	if ([GIF_pointer length] >= dataPointer + length) // Don't read across the edge of the file..
    {
		GIF_buffer = [[GIF_pointer subdataWithRange:NSMakeRange(dataPointer, length)] retain];
        dataPointer += length;
		return YES;
	}
    else
    {
        return NO;
	}
}

/* Skips (int) length bytes in the GIF, faster than reading them and throwing them away.. */
- (BOOL)GIFSkipBytes:(int)length
{
    if ([GIF_pointer length] >= dataPointer + length)
    {
        dataPointer += length;
        return YES;
    }
    else
    {
    	return NO;
    }
}

- (void) dealloc
{
    if (GIF_buffer != nil)
    {
	    [GIF_buffer release];
    }
    
    if (GIF_screen != nil)
    {
		[GIF_screen release];
    }
	
    if (GIF_global != nil)
    {
        [GIF_global release];
    }
    
	[GIF_frames release];
	
	[super dealloc];
}

@end
