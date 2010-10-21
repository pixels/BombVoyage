/*
 *  BVGameCore.mm
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/20.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#include "BVGameCore.h"
#include "Define.h"

BVGameCore::BVGameCore() {
  dic = [[NSDictionary alloc] init];
  loadTextures();

  for(int i=0; i<PARTICLE_COUNT; i++) {
    particle[i] = new Particle();
  }

  NSString *hitSoundFilePath = [[NSBundle mainBundle] pathForResource:@"blastSound" ofType:@"wav"];
  NSURL *hitSoundFileUrl = [NSURL fileURLWithPath:hitSoundFilePath];
  hitSound = [[AVAudioPlayer alloc] initWithContentsOfURL:hitSoundFileUrl error:nil];
  [hitSound prepareToPlay];
}

void BVGameCore::loadTextures() {
  blastTexture = loadTexture(@"splash.png");
  if(blastTexture != 0) {
    NSLog(@"splash_0.pngからテクスチャを生成しました！");
  }
}


void BVGameCore::add(float x, float y, float size, float moveX, float moveY) {
  for(int i=0; i<PARTICLE_COUNT; i++) {
    if(particle[i]->activeFlag == false) {
      particle[i]->activeFlag = true;
      particle[i]->x = x;
      particle[i]->y = y;
      particle[i]->size = size;
      particle[i]->moveX = moveX;
      particle[i]->moveY = moveY;
      particle[i]->frameCount = 0;
      particle[i]->lifeSpan = PARTICLE_COUNT;

      if ( i % 10 == 0 ) {
	[hitSound setCurrentTime:0.0f];
	[hitSound play];
      }
      break;
    }
  }
}

void BVGameCore::draw() {
  drawSplash();
}

void BVGameCore::drawSplash() {
  GLfloat vertices[6 * 2 * PARTICLE_COUNT];
  GLubyte colors[6 * 4 * PARTICLE_COUNT];
  GLfloat texCoords[6 * 2 * PARTICLE_COUNT];

  int vertexIndex = 0;
  int colorIndex = 0;
  int texCoordIndex = 0;

  int activeParticleCount = 0;

  for(int i=0; i<PARTICLE_COUNT; i++) {
    if(particle[i]->activeFlag == true) {
      float centerX = particle[i]->x;
      float centerY = particle[i]->y;
      float size = particle[i]->size;
      float vLeft = -0.5f*size + centerX;
      float vRight = 0.5f*size + centerX;
      float vTop = 0.5f*size + centerY;
      float vBottom = -0.5f*size + centerY;

      vertices[vertexIndex++] = vLeft;
      vertices[vertexIndex++] = vTop;
      vertices[vertexIndex++] = vRight;
      vertices[vertexIndex++] = vTop;
      vertices[vertexIndex++] = vLeft;
      vertices[vertexIndex++] = vBottom;

      vertices[vertexIndex++] = vRight;
      vertices[vertexIndex++] = vTop;
      vertices[vertexIndex++] = vLeft;
      vertices[vertexIndex++] = vBottom;
      vertices[vertexIndex++] = vRight;
      vertices[vertexIndex++] = vBottom;


      // color
      float lifePercentage = (float)(particle[i]->frameCount) / (float)(particle[i]->lifeSpan);
      int alpha = 255 - (int)round(lifePercentage * 255.0f);

      colors[colorIndex++] = 255; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = 255; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = 255; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = 255; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = 255; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = 255; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;

      texCoords[texCoordIndex++] = 0.0f;
      texCoords[texCoordIndex++] = 0.0f;
      texCoords[texCoordIndex++] = 1.0f;
      texCoords[texCoordIndex++] = 0.0f;
      texCoords[texCoordIndex++] = 0.0f;
      texCoords[texCoordIndex++] = 1.0f;

      texCoords[texCoordIndex++] = 1.0f;
      texCoords[texCoordIndex++] = 0.0f;
      texCoords[texCoordIndex++] = 0.0f;
      texCoords[texCoordIndex++] = 1.0f;
      texCoords[texCoordIndex++] = 1.0f;
      texCoords[texCoordIndex++] = 1.0f;

      activeParticleCount++;
    }
  }

  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
  glBindTexture(GL_TEXTURE_2D, blastTexture);
  glVertexPointer(2, GL_FLOAT, 0, vertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

  glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glDrawArrays(GL_TRIANGLES, 0, activeParticleCount * 6);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
}

void BVGameCore::update() {
  float x = randF() -0.5f;
  float y = randF() -0.5f;
  float size = randF() * 0.7f;
  float moveX = 0.0f;
  float moveY = 0.0f;
  add(x, y, size, moveX, moveY);

  for(int i=0; i<PARTICLE_COUNT; i++) {
    if(particle[i]->activeFlag == true) {
      particle[i]->update();
    }
  }
}

void BVGameCore::dealloc() {
  if (blastTexture) glDeleteTextures(1, &blastTexture);
}