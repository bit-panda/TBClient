//
//  AFHTTPRequestOperation+SNNetworking.m


#import "AFHTTPRequestOperation+SNNetworking.h"

@implementation AFHTTPRequestOperation (SNNetworking)

- (void)clearBlocksAfterComplete
{
    [self setUploadProgressBlock:nil];
    [self setDownloadProgressBlock:nil];
    [self setCompletionBlock:nil];
    [self setAuthenticationAgainstProtectionSpaceBlock:nil];
    [self setAuthenticationChallengeBlock:nil];
    [self setCacheResponseBlock:nil];
}

@end
