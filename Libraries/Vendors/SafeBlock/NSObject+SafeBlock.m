//
//  NSObject+SafeBlock.m


#import "NSObject+SafeBlock.h"
#import <objc/runtime.h>

NSString * const SafeBlockObjectDidDeallocNotification = @"SafeBlockObjectDidDeallocNotification";

static char *safeBlockObjectHandlerKey = "SafeBlockObjectHandler";
static NSMutableDictionary *safeBlockObjects = nil;

@interface SafeBlockObjectHandler : NSObject
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, copy) SafeBlockDeallocBlock deallocBlock;
- (id)initWithObject:(id)object;
@end

@implementation SafeBlockObjectHandler
@synthesize identifier = _identifier;
@synthesize deallocBlock = _deallocBlock;
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        safeBlockObjects = (NSMutableDictionary *)CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL);
    });
}

- (id)initWithObject:(id)object
{
    self = [super init];
    if (self)
    {
        CFUUIDRef u = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef s = CFUUIDCreateString(kCFAllocatorDefault, u);
        CFRelease(u);
        _identifier =  (NSString *)s;
        
        [safeBlockObjects setObject:object forKey:_identifier];
    }
    
    return self;
}

- (void)dealloc
{
    // do sth with _identifier
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SafeBlockObjectDidDeallocNotification object:nil userInfo:[NSDictionary dictionaryWithObject:_identifier forKey:@"identifier"]];
    
    if (_deallocBlock)
    {
        _deallocBlock(_identifier);
    }
    
    [safeBlockObjects removeObjectForKey:_identifier];
    [_identifier release];
    [_deallocBlock release];
    [super dealloc];
}

@end

@implementation NSObject (SafeBlock)

- (SafeBlockObjectHandler *)safeBlockObjectHandler
{
    SafeBlockObjectHandler *handler = objc_getAssociatedObject(self, &safeBlockObjectHandlerKey);
    if (!handler)
    {
        handler = [[SafeBlockObjectHandler alloc] initWithObject:self];
        objc_setAssociatedObject(self, &safeBlockObjectHandlerKey, handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [handler release];
    }
    
    return handler;
}

- (NSString *)safeBlockIdentifier
{
    SafeBlockObjectHandler *handler = [self safeBlockObjectHandler];
    return handler.identifier;
}

- (void)setSafeBlockDeallocBlock:(SafeBlockDeallocBlock)deallocBlock;
{
    SafeBlockObjectHandler *handler = [self safeBlockObjectHandler];
    handler.deallocBlock = deallocBlock;
}

@end

id get_safe_block_object(NSString *safeBlockIdentifier)
{
//    if (is_safe_block_object_still_alive(safeBlockIdentifier))
//    {
        return [safeBlockObjects objectForKey:safeBlockIdentifier];
//    }
//    return nil;
}

BOOL is_safe_block_object_still_alive(NSString *safeBlockIdentifier)
{
    return (!safeBlockIdentifier || [safeBlockObjects objectForKey:safeBlockIdentifier]);
}

void dispatch_async_safe(NSString *safeBlockIdentifier, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_async(queue, ^{
        if (is_safe_block_object_still_alive(safeBlockIdentifier))
        {
            block();
        }
    });
}

void dispatch_after_safe(NSString *safeBlockIdentifier, dispatch_time_t when, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_after(when, dispatch_get_main_queue(), ^(void){
        if (is_safe_block_object_still_alive(safeBlockIdentifier))
        {
            block();
        }
    });
}