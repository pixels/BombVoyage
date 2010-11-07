//
//  BVDataDownloader.m
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/23.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "BVDataDownloader.h"
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
    [(BVDataDownloader*)ctx 
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
    [(BVDataDownloader*)ctx 
            endElementLocalName:localname 
            prefix:prefix 
            URI:URI];
}

static void	charactersFoundHandler(
        void* ctx, 
        const xmlChar* ch, 
        int len)
{
    [(BVDataDownloader*)ctx 
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

@implementation BVDataDownloader


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

- (void)sendLoginRequest:(NSString *)parameters {
  [self establishConnection:parameters];
}

- (void)establishConnection:(NSString *)parameters {
  if (conn && waiting) {
    [conn cancel];
    //[conn release];
  }

  NSString *urlstr = [NSString stringWithFormat:@"%@:%@", SERVER_URL, HTML_PORT];
  NSLog(urlstr);
  NSData *request_data = [parameters dataUsingEncoding:NSUTF8StringEncoding];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlstr]];
  [request setHTTPMethod: @"POST"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
  [request setHTTPBody:request_data];

  conn = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)receivedData {
  NSLog(@"parse chunk");
  xmlParseChunk(parser_context, (const char*)[receivedData bytes], [receivedData length], 0);
  waiting = false;
}

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)res {
  NSHTTPURLResponse *hres = (NSHTTPURLResponse *)res;
  // NSLog(@"Received Response. Status Code: %d", [hres statusCode]);
  // NSLog(@"Expected ContentLength: %qi", [hres expectedContentLength]);
  // NSLog(@"MIMEType: %@", [hres MIMEType]);
  // NSLog(@"Suggested File Name: %@", [hres suggestedFilename]);
  // NSLog(@"Text Encoding Name: %@", [hres textEncodingName]);
  // NSLog(@"URL: %@", [hres URL]);
  // NSLog(@"Received Response. Status Code: %d", [hres statusCode]);
  NSDictionary *dict = [hres allHeaderFields];
  NSArray *keys = [dict allKeys];
  for (int i = 0; i < [keys count]; i++) {
    // NSLog(@"    %@: %@", [keys objectAtIndex:i], [dict objectForKey:[keys objectAtIndex:i]]);
  }
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
  //[conn release];
  // NSLog(@"connection faled: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
  waiting = false;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
  NSString *contents = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
  NSLog(@"%@", contents);
  waiting = false;
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
  [[dics lastObject] setObject:dic forKey:key];
}

- (void)endElementLocalName:(const xmlChar*)localname 
        prefix:(const xmlChar*)prefix URI:(const xmlChar*)URI
{
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
    [self receiveReplyToLoginRequest:dic];

    parser_context = xmlCreatePushParserCtxt(&_saxHandlerStruct, self, NULL, 0, NULL);
    dic = [[NSMutableDictionary dictionary] retain];
    dics = [[NSMutableArray alloc] init];
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
  [conn cancel];
  [conn release];

  [dic release];
  [dics release];
  [current_characters release], current_characters = nil;
  [super dealloc];
}


@end
