//
//  LCTicket.m
//  TBClient
//
//  Created by bitpanda on 13-11-18.
//  Copyright (c) 2013年 bitpanda. All rights reserved.
//

#import "LCTicket.h"
#import "HTMLParser.h"

@implementation LCTicket


+ (NSArray *)ticketListWithHtml:(NSData *)html
{
    NSMutableArray *tickets = [NSMutableArray array];
    
    NSError *error = nil;
//    HTMLParser *parser = [[HTMLParser alloc] initWithString:html error:&error];
    
    NSString *htmls = [[NSString alloc] initWithData:html encoding:NSUTF8StringEncoding];
    
    NSArray *hh = [htmls componentsSeparatedByString:@"\n"];
    
//    HTMLParser *parser = [[HTMLParser alloc] initWithData:html error:&error];
//    
//    if (error) {
//        NSLog(@"Error: %@", error);
//        return tickets;
//    }
//    
//    HTMLNode *bodyNode = [parser body];
//    
//    NSArray *children = bodyNode.children;
//    
//    NSArray *childrennode = ((HTMLNode *)[children objectAtIndex:0]).children;
//    
//    NSArray *spans = [bodyNode findChildTags:@"span"];
    
    for(NSString *span in hh)
    {
        NSRange range= [span rangeOfString: @","];
        if(range.location!=NSNotFound)
        {
            NSString *ss = [span substringFromIndex:range.location+1];
            NSLog(@"%@",ss);
        }
    }
    
    return tickets;
}

+ (LCTicket *)ticketWithNode:(HTMLNode *)node
{
    return nil;
}

@end
