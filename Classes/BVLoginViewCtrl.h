//
//  BVLoginViewCtrl.h
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/24.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BVLoginViewCtrl : UIViewController <UITextFieldDelegate> {
  UITextField *name_tf;
  UITextField *pass_tf;
  UITextField *message_tf;

  UIButton* loginButton;
}

@end
