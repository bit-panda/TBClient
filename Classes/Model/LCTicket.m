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

+ (NSArray *)ticketListWithHtmlData:(NSData *)htmlData
{
    NSString *html = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    return [self ticketListWithHtml:[html autorelease]];
}

+ (NSArray *)ticketListWithHtml:(NSString *)html
{
    NSMutableArray *tickets = [NSMutableArray array];
    
    NSError *error = nil;
    NSArray *ticketHtmls = [html componentsSeparatedByString:@"\\n"];
    
    for(NSString *ticketHtml in ticketHtmls)
    {
        NSRange range= [ticketHtml rangeOfString: @","];
        if(range.location!=NSNotFound)
        {
            NSString *ticketHtmlParsered = [ticketHtml substringFromIndex:range.location+1];
            ticketHtmlParsered = [ticketHtmlParsered stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
            ticketHtmlParsered = [ticketHtmlParsered stringByReplacingOccurrencesOfString:@"," withString:@"<br>"];
            
            HTMLParser *parser = [[HTMLParser alloc] initWithString:ticketHtmlParsered error:&error];
            if (error) {
                NSLog(@"HTMLParser Error: %@", error);
                return tickets;
            }
            
            HTMLNode *bodyNode = [parser body];
            [tickets addObject:[[self class] ticketWithNode:bodyNode]];
        }
    }
    
    return tickets;
}

+ (LCTicket *)ticketWithNode:(HTMLNode *)node
{
    LCTicket *ticket = [[LCTicket alloc] init];
    
    NSArray *children = node.children;
    NSInteger textIndex = 0;
    for (HTMLNode *child in children)
    {
        if (child.nodetype == HTMLTextNode || child.nodetype == HTMLFontNode)
        {
            [[self class] setAttributeOfTicket:ticket textIndex:textIndex value:child.allContents];
            textIndex ++;
        }
        else if (child.nodetype == HTMLHrefNode)
        {
            ticket.onclickInfo = [child getAttributeNamed:@"onclick"];
        }
        else if (child.nodetype == HTMLSpanNode)
        {
            ticket.trainCode = child.contents;
            ticket.trainID = [child getAttributeNamed:@"id"];
        }
        else
        {
            //<br>
            //<img>
        }
    }
    
    return [ticket autorelease];
}

+ (void)setAttributeOfTicket:(LCTicket *)ticket textIndex:(NSInteger)index value:(NSString *)value
{
    if ([value isEqualToString:@"有"])
    {
        value = @"1000";
    }
    else if([value isEqualToString:@"--"])
    {
        value = @"0";
    }
    
    switch (index)
    {
        case 0:
        {
            ticket.fromStation = value;
            break;
        }
        case 1:
        {
            ticket.startTime = value;
            break;
        }
        case 2:
        {
            ticket.destination = value;
            break;
        }
        case 3:
        {
            ticket.endTime = value;
            break;
        }
        case 4:
        {
            ticket.takeTime = value;
            break;
        }
        case 5:
        {
            ticket.leftSeatsBusiness = [value integerValue];
            break;
        }
        case 6:
        {
            ticket.leftSeatsSuper = [value integerValue];
            break;
        }
        case 7:
        {
            ticket.leftSeatsFirst = [value integerValue];
            break;
        }
        case 8:
        {
            ticket.leftSeatsSecond = [value integerValue];
            break;
        }
        case 9:
        {
            ticket.leftSeatsAdvanced = [value integerValue];
            break;
        }
        case 10:
        {
            ticket.leftSeatsSoftSleeper = [value integerValue];
            break;
        }
        case 11:
        {
            ticket.leftSeatsHardSleeper = [value integerValue];
            break;
        }
        case 12:
        {
            ticket.leftSeatsSoftSeat = [value integerValue];
            break;
        }
        case 13:
        {
            ticket.leftSeatsHardSeat = [value integerValue];
            break;
        }
        case 14:
        {
            ticket.leftSeatsNoSeat = [value integerValue];
            break;
        }
        case 15:
        {
            ticket.leftSeatsOther = [value integerValue];
            break;
        }

            
        default:
            break;
    }
}

@end
