//
//  Define.h
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define SERVER_URL @"http://192.168.0.2"
#define SERVER_URL @"http://neo-gatto.com"
//#define TCP_SERVER_URL @"192.168.0.2"
#define TCP_SERVER_URL @"115.162.11.223"
#define HTML_PORT @"8124"
#define TCP_PORT 8128

#define WINDOW_W 320
#define WINDOW_H 460

#define TOOL_BUTTON_WIDTH 52
#define TOOL_BUTTON_HEIGHT 52

#define PARTICLE_COUNT 100

#define BOMB_CD 0
#define BOMB_BLASTING 1

#define randF() ((float)(rand() % 1001) * 0.001f)
