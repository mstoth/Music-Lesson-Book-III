//
//  GTMPieceList.h
//  Good Teaching Music
//
//  Created by Michael Toth on 3/13/13.
//  Copyright (c) 2013 Michael Toth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GTMPieceList : NSObject <NSURLConnectionDelegate>

@property (nonatomic,retain) NSMutableData *responseData;
@property (nonatomic, retain) NSDictionary *responseDictionary;
- (void) reload:(NSString *)instrument;
@end
