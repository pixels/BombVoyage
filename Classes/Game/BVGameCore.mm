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
  dic = [[NSMutableDictionary alloc] init];
  loadTextures();


  for(int i=0; i<BOMB_COUNT; i++) {
    bomb[i] = new Bomb();
    bomb[i]->setTextures(dic);
  }

  addBomb(0.5, 0.5, 0.1, 0, 0);
  addBomb(0, 0, 0.1, 0, 0);
  addBomb(-0.5, 0.2, 0.1, 0, 0);
}

void BVGameCore::loadTextures() {
  blastTexture = loadTexture(@"splash.png");
  bombTexture = loadTexture(@"sample_bomb.png");
  //[dic setObject:blastTexture forKey:@"blast"];
  if(blastTexture != 0) {
    NSLog(@"splash_0.pngからテクスチャを生成しました！");
  }
}

void BVGameCore::addBomb(float x, float y, float size, float moveX, float moveY) {
  for(int i=0; i<BOMB_COUNT; i++) {
    if(bomb[i]->activeFlag == false) {
      bomb[i]->activeFlag = true;
      bomb[i]->x = x;
      bomb[i]->y = y;
      bomb[i]->size = size;
      bomb[i]->moveX = moveX;
      bomb[i]->moveY = moveY;
      bomb[i]->frameCount = 0;
      bomb[i]->lifeSpan = BOMB_COUNT;
      break;
    }
  }
}

void BVGameCore::draw() {
  glEnable(GL_BLEND); // アルファブレンディングを有効にする
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  drawBombs();
  glDisable(GL_BLEND);
  glEnable(GL_BLEND); // アルファブレンディングを有効にする
  glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  drawSplash();
  glDisable(GL_BLEND);
}

void BVGameCore::drawBombs() {
  GLfloat vertices[6 * 2 * BOMB_COUNT];
  GLubyte colors[6 * 4 * BOMB_COUNT];
  GLfloat texCoords[6 * 2 * BOMB_COUNT];

  int vertexIndex = 0;
  int colorIndex = 0;
  int texCoordIndex = 0;

  int activebombCount = 0;

  for(int i=0; i<BOMB_COUNT; i++) {
    if((bomb[i]->activeFlag == true) && (bomb[i]->mode == BOMB_CD)) {
      float centerX = bomb[i]->x;
      float centerY = bomb[i]->y;
      float size = bomb[i]->size;
      float vLeft = -0.5f*size + centerX;
      float vRight = 0.5f*size + centerX;
      float vTop = size + centerY;
      float vBottom = centerY;

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
      float lifePercentage = (float)(bomb[i]->frameCount) / (float)(bomb[i]->lifeSpan);
      int alpha = 255 * (1.0 - (sinf(0.1 * bomb[i]->frameCount) + 1) / 4);

      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = alpha; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = alpha; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = alpha; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = alpha; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = alpha; colors[colorIndex++] = 255;
      colors[colorIndex++] = 255; colors[colorIndex++] = alpha;
      colors[colorIndex++] = alpha; colors[colorIndex++] = 255;

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

      activebombCount++;
    }
  }

  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
  glBindTexture(GL_TEXTURE_2D, bombTexture);
  glVertexPointer(2, GL_FLOAT, 0, vertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
  glEnableClientState(GL_COLOR_ARRAY);

  glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glDrawArrays(GL_TRIANGLES, 0, activebombCount * 6);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
}
void BVGameCore::drawSplash() {
  GLfloat vertices[6 * 2 * PARTICLE_COUNT];
  GLubyte colors[6 * 4 * PARTICLE_COUNT];
  GLfloat texCoords[6 * 2 * PARTICLE_COUNT];

  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
  glBindTexture(GL_TEXTURE_2D, blastTexture);

  for(int i=0; i<BOMB_COUNT; i++) {
    int activeParticleCount = 0;
    int vertexIndex = 0;
    int colorIndex = 0;
    int texCoordIndex = 0;

    if(bomb[i]->activeFlag == true && bomb[i]->mode == BOMB_BLASTING) {
      for(int j=0; j<PARTICLE_COUNT; j++) {
	if(bomb[i]->particle[j]->activeFlag == true) {
      float centerX = bomb[i]->particle[j]->x;
      float centerY = bomb[i]->particle[j]->y;
      float size = bomb[i]->particle[j]->size;
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
      float lifePercentage = (float)(bomb[i]->particle[j]->frameCount) / (float)(bomb[i]->particle[j]->lifeSpan);
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
    }

    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    glEnableClientState(GL_COLOR_ARRAY);

    glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    glDrawArrays(GL_TRIANGLES, 0, activeParticleCount * 6);
  }

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
}

void BVGameCore::update() {
  for(int i=0; i<BOMB_COUNT; i++) {
    if(bomb[i]->activeFlag == true) {
      bomb[i]->update();
    }
  }
}
void BVGameCore::updateObjects(NSDictionary* dic) {
  float x = 2 * (randF() -0.5f);
  float y = 2 * (randF() -0.5f);
  float size = 0.7f;
  float moveX = 0.0f;
  float moveY = 0.0f;
  addBomb(x, y, size, moveX, moveY);
}

void BVGameCore::dealloc() {
  if (blastTexture) glDeleteTextures(1, &blastTexture);
}
