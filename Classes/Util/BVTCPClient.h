//
//  BVTCPClient.h
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/23.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libxml/tree.h>


@interface BVTCPClient : NSObject {
  NSData* buffer;
  NSURLConnection *conn;
  BOOL waiting;
  xmlParserCtxtPtr parser_context;

  BOOL is_channel, is_item;
  NSMutableArray* dics;
  NSMutableDictionary* dic;
  NSMutableString* current_characters;
}

@property (readonly) NSDictionary* channel;

@end
