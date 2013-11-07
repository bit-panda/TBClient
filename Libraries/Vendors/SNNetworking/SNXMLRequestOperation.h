//
//  SNXMLRequestOperation.h
//

#import "AFXMLRequestOperation.h"
#import "AFNetworking.h"
#import "SNNetworkClient.h"

@class TBXML;

@interface SNXMLRequestOperation : AFHTTPRequestOperation <SNConfiguableRequestOperation>
{
    NSError *_XMLError;
    NSArray *_arrayQueryPaths;
    id _responseXML;
}

@property (readonly, nonatomic, retain) id responseXML;

- (BOOL)validateXMLStructureBeforeParse:(TBXML *)tbxml;
- (BOOL)validateXMLStructureAfterParse:(TBXML *)tbxml;

@end