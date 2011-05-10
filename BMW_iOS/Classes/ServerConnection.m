//
//  ServerConnection.m
//  BMW_iOS
//
//  Created by Aaron Sarnoff on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerConnection.h"
#include "JSONSerializableSupport.h"
#include "SBJSON.h"
#import "CLLocation+NSMutableDictionary.h"
#import "CLHeading+NSMutableDictionary.h"
#import "CMDeviceMotion+NSMutableDictionary.h"

@implementation ServerConnection

/*
 * hastily added for the demo (for HMI)
 * is there a better way to do this?
 */
/*
+(NSArray *)maxSpeedTable
{
    return [ServerConnection getJSONFromURL:[NSURL URLWithString:@"http://bunkermw.heroku.com/mobile_gps/get_max_speed_table"]];
}

+(NSArray *)maxSpeedRank
{
    NSString * udid = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *url =[NSString stringWithFormat:@"http://bunkermw.heroku.com/mobile_gps/get_user_rank_in_max_speed?udid=%@",udid];
    return [ServerConnection getJSONFromURL:[NSURL URLWithString:url]];
}

+(NSArray *)avgSpeedTable
{
    return [ServerConnection getJSONFromURL:[NSURL URLWithString:@"http://bunkermw.heroku.com/mobile_gps/get_avg_speed_table"]];
}

+(NSArray *)avgSpeedRank
{
    NSString * udid = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *url =[NSString stringWithFormat:@"http://bunkermw.heroku.com/mobile_gps/get_user_rank_in_avg_speed?udid=%@",udid];
    return [ServerConnection getJSONFromURL:[NSURL URLWithString:url]];
}

+(NSArray *)totalDistanceTable
{
    return [ServerConnection getJSONFromURL:[NSURL URLWithString:@"http://bunkermw.heroku.com/mobile_gps/get_total_distance_table"]];
}

+(NSArray *)getJSONFromURL:(NSURL *)url
{
    return [[NSString stringWithContentsOfURL:url] JSONValue];
}
 */
static ServerConnection * _sharedConnection;
+(ServerConnection *)sharedConnection
{
    if(_sharedConnection==nil)
        _sharedConnection = [[ServerConnection alloc] init];
    return _sharedConnection;
}

+(void)sendStats:(id)stats toURL:(NSString *)url
{
    if(![stats respondsToSelector:@selector(toDict)])
        return;
    
    NSMutableDictionary *statsDict = [stats toDict];
    //Will start an array with this and then send the queue
    [statsDict setObject:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"iphone_time"];
    [statsDict setObject:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"udid"];
    
    NSMutableURLRequest *req = [[[NSMutableURLRequest alloc] init] autorelease];
    NSString *post = [NSString stringWithFormat:@"data=%@",[statsDict JSONRepresentation]];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    [req setURL:[NSURL URLWithString:url]];
    [req setHTTPMethod:@"POST"];
    [req setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [req setHTTPBody:postData];
    
#ifdef POST_DATA
    [ServerConnection sendRequest:req delegate:[ServerConnection sharedConnection]];
#endif
    
    //NSLog(@"prev stats:%@",[statsDict JSONRepresentation]);
}

+(void)sendRequest:(NSURLRequest *)request delegate:(id)delegate
{
    [[ServerConnection sharedConnection] addConnection:
    [[[NSURLConnection alloc] initWithRequest:request delegate:[ServerConnection sharedConnection] startImmediately:YES] autorelease]
    forDelegate:delegate];
}

-(void) addConnection:(NSURLConnection *)key forDelegate:(id)value
{
    if(connectionDelegateDict==nil)
        connectionDelegateDict = CFDictionaryCreateMutable(
                                                           kCFAllocatorDefault,
                                                           0,
                                                           &kCFTypeDictionaryKeyCallBacks,
                                                           &kCFTypeDictionaryValueCallBacks);
    CFDictionaryAddValue(connectionDelegateDict, key, value);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *decodedStr=[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSArray *jsonArray = [decodedStr JSONValue];
    
    id delegate;
    if(connectionDelegateDict!=nil&&CFDictionaryGetValueIfPresent(connectionDelegateDict, connection, &delegate))
    {
        [delegate receiveStats:jsonArray];
        CFDictionaryRemoveValue(connectionDelegateDict, connection);
    }
}

-(void)receiveStats:(NSArray *)stats
{
    //NSLog(@"success! %@",stats);
    //do nothing
    return;
}

-(void)dealloc
{
    [super dealloc];
    CFRelease(connectionDelegateDict);
    connectionDelegateDict = nil;
}

@end
