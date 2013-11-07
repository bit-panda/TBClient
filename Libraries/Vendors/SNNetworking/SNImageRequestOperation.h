//
//  SNImageRequestOperation.h
//

#import "AFImageRequestOperation.h"
#import "SNNetworking.h"

@interface SNImageRequestOperation : AFImageRequestOperation <SNConfiguableRequestOperation>
{
    BOOL encodeAsImage;
    BOOL callbackAfterImageFileSaved;
    NSString *originalPath;
    
    id responseObject;
}

@property (nonatomic, assign) BOOL encodeAsImage;
@property (nonatomic, assign) BOOL callbackAfterImageFileSaved;

@end
