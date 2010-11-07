/*
 *  Particle.h
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/19.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "graphicUtil.h"
#import "Define.h"

class Particle {
  public:
    float x;
    float y;
    float size;
    bool activeFlag;
    float moveX;
    float moveY;
    int frameCount;
    int lifeSpan;
    NSMutableArray blastArray;

    NSDictionary* textures;
    NSString* texture_name;

    Particle();
    void setTextures(NSDictionary* dic);
    void draw(GLuint texture);
    void update();
};
