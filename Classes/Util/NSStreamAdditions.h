//
//  NSStreamAdditions.h
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/28.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStream (MyAdditions)

+ (void)getStreamsToHostNamed:(NSString *)hostName 
                         port:(NSInteger)port 
                  inputStream:(NSInputStream **)inputStreamPtr 
                 outputStream:(NSOutputStream **)outputStreamPtr;

@end
