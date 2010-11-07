//
//  BVTCPClient.m
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/23.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "BVTCPClient.h"
#import "EventNames.h"
#import "Define.h"

static void startElementHandler(
        void* ctx, 
        const xmlChar* localname, 
        const xmlChar* prefix, 
        const xmlChar* URI, 
        int nb_namespaces, 
        const xmlChar** namespaces, 
        int nb_attributes, 
        int nb_defaulted, 
        const xmlChar** attributes)
{
    [(BVTCPClient*)ctx 
            startElementLocalName:localname 
            prefix:prefix URI:URI 
            nb_namespaces:nb_namespaces 
            namespaces:namespaces 
            nb_attributes:nb_attributes 
            nb_defaulted:nb_defaulted 
            attributes:attributes];
}

static void	endElementHandler(
        void* ctx, 
        const xmlChar* localname, 
        const xmlChar* prefix, 
        const xmlChar* URI)
{
    [(BVTCPClient*)ctx 
            endElementLocalName:localname 
            prefix:prefix 
            URI:URI];
}

static void	charactersFoundHandler(
        void* ctx, 
        const xmlChar* ch, 
        int len)
{
    [(BVTCPClient*)ctx 
            charactersFound:ch len:len];
}

static xmlSAXHandler _saxHandlerStruct = {
    NULL,            /* internalSubset */
    NULL,            /* isStandalone   */
    NULL,            /* hasInternalSubset */
    NULL,            /* hasExternalSubset */
    NULL,            /* resolveEntity */
    NULL,            /* getEntity */
    NULL,            /* entityDecl */
    NULL,            /* notationDecl */
    NULL,            /* attributeDecl */
    NULL,            /* elementDecl */
    NULL,            /* unparsedEntityDecl */
    NULL,            /* setDocumentLocator */
    NULL,            /* startDocument */
    NULL,            /* endDocument */
    NULL,            /* startElement*/
    NULL,            /* endElement */
    NULL,            /* reference */
    charactersFoundHandler, /* characters */
    NULL,            /* ignorableWhitespace */
    NULL,            /* processingInstruction */
    NULL,            /* comment */
    NULL,            /* warning */
    NULL,            /* error */
    NULL,            /* fatalError //: unused error() get all the errors */
    NULL,            /* getParameterEntity */
    NULL,            /* cdataBlock */
    NULL,            /* externalSubset */
    XML_SAX2_MAGIC,  /* initialized */
    NULL,            /* private */
    startElementHandler,    /* startElementNs */
    endElementHandler,      /* endElementNs */
    NULL,            /* serror */
};

#import "NSStreamAdditions.h"

@implementation BVTCPClient

NSMutableData *data;

NSInputStream *iStream;
NSOutputStream *oStream;

CFReadStreamRef readStream = NULL;
CFWriteStreamRef writeStream = NULL;

- (id)init {
    self = [super init];
    if (self) {
      parser_context = xmlCreatePushParserCtxt(&_saxHandlerStruct, self, NULL, 0, NULL);
      dic = [[NSMutableDictionary dictionary] retain];
      dics = [[NSMutableArray alloc] init];
      waiting = false;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/
-(void) connectToServerUsingCFStream:(NSString *) urlStr portNo: (uint) portNo {
        
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, 
                                       (CFStringRef) urlStr, 
                                       portNo, 
                                       &readStream, 
                                       &writeStream);
    
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream, 
                                kCFStreamPropertyShouldCloseNativeSocket, 
                                kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, 
                                kCFStreamPropertyShouldCloseNativeSocket, 
                                kCFBooleanTrue);
        
        iStream = (NSInputStream *)readStream;
        [iStream retain];
        [iStream setDelegate:self];
        [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] 
            forMode:NSDefaultRunLoopMode];
        [iStream open];
        
        oStream = (NSOutputStream *)writeStream;
        [oStream retain];
        [oStream setDelegate:self];
        [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] 
            forMode:NSDefaultRunLoopMode];
        [oStream open];         
    }
}

-(void) connectToServerUsingStream:(NSString *)urlStr portNo: (uint) portNo {
  if (![urlStr isEqualToString:@""]) {
    NSURL *website = [NSURL URLWithString:urlStr];
    if (!website) {
      NSLog(@"%@ is not a valid URL");
      return;
    } else {
      NSLog(@"get stream");
      [NSStream getStreamsToHostNamed:urlStr 
				 port:portNo 
			  inputStream:&iStream
			 outputStream:&oStream];            
      [iStream retain];
      [oStream retain];

      [iStream setDelegate:self];
      [oStream setDelegate:self];

      [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
			 forMode:NSDefaultRunLoopMode];
      [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
			 forMode:NSDefaultRunLoopMode];

      [oStream open];
      [iStream open];            
    }
  }    
}

-(void) writeToServer:(const uint8_t *) buf {
    [oStream write:buf maxLength:strlen((char*)buf)];    
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    switch(eventCode) {
        case NSStreamEventOpenCompleted: {
	  NSLog(@"open completed");
	  break;
	  }
        case NSStreamEventErrorOccurred: {
	  NSLog(@"error occurred");
	  // NSError *theError = [stream streamError]; 
	  // NSLog([theError localizedDescription]);
	  break;
	  }
        case NSStreamEventHasBytesAvailable:
        {
	  NSLog(@"receive data");
            if (data == nil) {
                data = [[NSMutableData data] retain];
            }
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len) {    
                [data appendBytes:(const void *)buf length:len];
                int bytesRead;
                bytesRead += len;
            } else {
                NSLog(@"No data.");
            }
            
	    parser_context = xmlCreatePushParserCtxt(&_saxHandlerStruct, self, NULL, 0, NULL);
	    dic = [[NSMutableDictionary dictionary] retain];
	    dics = [[NSMutableArray alloc] init];

            NSString *str = [[NSString alloc] initWithData:data 
                                encoding:NSUTF8StringEncoding];
	    xmlParseChunk(parser_context, (const char*)[data bytes], [data length], 0);
	    waiting = false;
                        
            [str release];
            [data release];        
            data = nil;
        } break;
    }
}

-(void) disconnect {
    [iStream close];
    [oStream close];
}

- (void)establishConnection {
  NSLog(@"establish connection");
  [self connectToServerUsingStream:TCP_SERVER_URL portNo:TCP_PORT];

  //const uint8_t *str = (uint8_t *)[@"test" cStringUsingEncoding:NSASCIIStringEncoding];
  //[self writeToServer:str];
}

- (void)startElementLocalName:(const xmlChar*)localname 
		       prefix:(const xmlChar*)prefix 
			  URI:(const xmlChar*)URI 
		nb_namespaces:(int)nb_namespaces 
		   namespaces:(const xmlChar**)namespaces 
		nb_attributes:(int)nb_attributes 
		 nb_defaulted:(int)nb_defaulted 
		   attributes:(const xmlChar**)attributes
{
  // NSog([NSString stringWithCString:(char*)localname encoding:NSUTF8StringEncoding]);
  [current_characters release], current_characters = nil;
  current_characters = [[NSMutableString string] retain];

  [dics addObject:dic];
  dic = [NSMutableDictionary dictionary];

  NSString*   key;
  key = [NSString stringWithCString:(char*)localname encoding:NSUTF8StringEncoding];
  NSLog(@"key : %@", key);
  [[dics lastObject] setObject:dic forKey:key];
}

- (void)endElementLocalName:(const xmlChar*)localname 
		     prefix:(const xmlChar*)prefix URI:(const xmlChar*)URI
{
  NSString * key = [NSString stringWithCString:(char*)localname encoding:NSUTF8StringEncoding];
  NSLog(@"end key : %@", key);

  if ( [current_characters length] > 0 ) {
    [dic setObject:current_characters forKey:@"value"];
    [current_characters release], current_characters = nil;
  }

  // NSLog([NSString stringWithCString:(char*)localname encoding:NSUTF8StringEncoding]);
  if ( [dics count] > 0 ) {
    dic = [dics lastObject];
    [dics removeLastObject];
  }

  if ( [dics count] == 0 ) {
    NSLog(@"%@", [dic description]);
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_OBJECT_UPDATE_EVENT object:nil userInfo:dic];
    [current_characters release], current_characters = nil;
  }
}

- (void) receiveReplyToLoginRequest:(NSDictionary *)dic {
       [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_REPLY_TO_LOGIN_REQUEST_EVENT
							   object:nil
							 userInfo:dic];
}

- (void) printDictionary:(NSDictionary*)dic depth:(int)depth {
  NSString* space = @"";
  for ( int i = 0; i < depth; i++ ) {
    space = [NSString stringWithFormat:@" %@", space];
  }
  for ( id key in [dic keyEnumerator]) {
    NSLog(@"%@%@", space, key);
    [self printDictionary:[dic objectForKey:key] depth:depth+1];
  }
}

- (void)charactersFound:(const xmlChar*)ch 
		    len:(int)len
{
  // 文字列を追加する
  if (current_characters) {
    NSString*   string;
    string = [[NSString alloc] initWithBytes:ch length:len encoding:NSUTF8StringEncoding];
    [current_characters appendString:string];
    [string release];
  }
}

- (void)dealloc {
  [self disconnect];

  [iStream release];
  [oStream release];

  if (readStream) CFRelease(readStream);
  if (writeStream) CFRelease(writeStream);

  [super dealloc];

  [conn cancel];
  [conn release];

  [dic release];
  [dics release];
  [current_characters release], current_characters = nil;
  [super dealloc];
}


@end
