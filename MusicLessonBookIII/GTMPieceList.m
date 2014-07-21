//
//  GTMPieceList.m
//  Good Teaching Music
//
//  Created by Michael Toth on 3/13/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import "GTMPieceList.h"
#import "XMLReader.h"

@implementation GTMPieceList
@synthesize responseData, responseDictionary;

- (GTMPieceList *)init {
    self = [super init];
    
    NSURLRequest *request;
    NSURL *url = [NSURL URLWithString:@"http://secure-sierra-9006.herokuapp.com/pieces.xml"];
    request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    assert(connection != nil);
    return self;
}

- (void) reload:(NSString *)instrument {
    NSURLRequest *request;
    NSString *urlString = [NSString stringWithFormat:@"http://secure-sierra-9006.herokuapp.com/pieces.xml?instrument=%@",instrument];
    NSURL *url = [NSURL URLWithString:urlString];
    request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    assert(connection != nil);

}

#pragma mark -
#pragma mark NSURLConnectionDelegate Methods

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"in didReceiveResponse");
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	NSUInteger status;
	NSString *mimeType;
	mimeType = [response MIMEType];
	status = [httpResponse statusCode];
    //NSLog(@"mimeType = %@, status = %d",mimeType,status);
    if ((([httpResponse statusCode]/100) == 2) && ([[response MIMEType] isEqual:@"application/xml"] || [[response MIMEType] isEqual:@"text/xml"]) ) {
        self.responseData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *theError = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        NSLog(@"%@",[theError description]);
    }

    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //NSLog(@"in didReceiveData");
    [self.responseData appendData:data];
    
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    return request;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *parseError = nil;
    //NSLog(@"in connectionDidFinishLoading");
    self.responseDictionary = [XMLReader dictionaryForXMLData:self.responseData error:parseError];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dataReceived" object:self];
    
}

@end
