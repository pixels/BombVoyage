/*
 *  graphicUtil.mm
 *  BombVoyage
 *
 *  Created by Karatsu Naoya on 10/10/19.
 *  Copyright 2010 ajapax. All rights reserved.
 *
 */

#include "graphicUtil.h"

void drawSquare() {
  // Replace the implementation of this method to do your own custom drawing.
  static const GLfloat squareVertices[] = {
    -0.5f, -0.33f,
    0.5f, -0.33f,
    -0.5f,  0.33f,
    0.5f,  0.33f,
  };

  static const GLubyte squareColors[] = {
    255, 255,   0, 255,
    0,   255, 255, 255,
    0,     0,   0,   0,
    255,   0, 255, 255,
  };

  static float transY = 0.0f;

  glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f), 0.0f);
  transY += 0.075f;

  glVertexPointer(2, GL_FLOAT, 0, squareVertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
  glEnableClientState(GL_COLOR_ARRAY);

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

GLuint loadTexture(NSString* filename) {
  GLuint texture;
  NSLog(@"load texture");

  // 画像ファイルを展開(GCImageRefを作成)
  CGImageRef image = [UIImage imageNamed:filename].CGImage;
  if(!image) {
    NSLog(@"Error: %@ not found", filename);
    return 0;
  }

  size_t width = CGImageGetWidth(image);
  size_t height = CGImageGetHeight(image);

  // ビットマップデータを用意
  GLubyte* imageData = (GLubyte *) malloc(width * height * 4);
  memset(imageData, 0, width * height * 4);
  CGContextRef imageContext = CGBitmapContextCreate(imageData,width,height,8,width * 4,CGImageGetColorSpace(image),kCGImageAlphaPremultipliedLast);
  CGContextDrawImage(imageContext, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height),image);
  CGContextRelease(imageContext);

  // OpeGL用のテクスチャを生成
  glGenTextures(1, &texture);
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP, GL_TRUE);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
  free(imageData);

  return texture;
}

void drawTexture (float x, float y, float width, float height,
    GLuint texture, int red, int green, int blue, int alpha) {
  drawTexture2(x, y, width, height, texture, 0.0f, 0.0f, 1.0f, 1.0f,
      red, green, blue, alpha);
}

void drawTexture2(float x, float y, float width, float height,
    GLuint texture, float u, float v, float tex_width,
    float tex_height, int red, int green, int blue, int alpha) {

  const GLfloat squareVertices[] = {
    -0.5f*width + x, -0.5f*height + y,
    0.5f*width + x, -0.5f*height + y,
    -0.5f*width + x, 0.5f*height + y,
    0.5f*width + x, 0.5f*height + y,
  };
  const GLubyte squareColors[] = {
    red, green, blue, alpha,
    red, green, blue, alpha,
    red, green, blue, alpha,
    red, green, blue, alpha,
  };
  const GLfloat texCoords[] = {
    u, v+tex_height,
    u+tex_width, v+tex_height,
    u, v,
    u+tex_width, v,
  };

  glEnable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
  glVertexPointer(2, GL_FLOAT, 0, squareVertices);

  glBindTexture(GL_TEXTURE_2D, texture);

  glVertexPointer(2, GL_FLOAT, 0, squareVertices);

  glEnableClientState(GL_VERTEX_ARRAY);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
  glEnableClientState(GL_COLOR_ARRAY);
  glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisable(GL_TEXTURE_2D); // テクスチャ機能を有効にする
}

void printOpenGLError() {
  GLenum errCode = glGetError();
  if ( errCode == GL_NO_ERROR ) {
    NSLog(@"GL NO ERROR");
  } else if ( errCode == GL_INVALID_ENUM ) {
    NSLog(@"GL INVALID VALUE");
  } else if ( errCode == GL_INVALID_VALUE ) {
    NSLog(@"GL INVALID VALUE");
  } else if ( errCode == GL_INVALID_OPERATION ) {
    NSLog(@"GL INVALID OPERATION");
  } else if ( errCode == GL_STACK_OVERFLOW ) {
    NSLog(@"GL STACK OVERFLOW");
  } else if ( errCode == GL_STACK_UNDERFLOW ) {
    NSLog(@"GL STACK UNDERFLOW");
  } else if ( errCode == GL_OUT_OF_MEMORY ) {
    NSLog(@"GL STACK GL OUT OF MEMORY");
  } else {
    NSLog(@"OTHER ERROR");
  }
}
