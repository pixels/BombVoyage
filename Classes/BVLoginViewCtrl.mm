//
//  BVLoginViewCtrl.mm
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/24.
//  Copyright 2010 ajapax. All rights reserved.
//

#import "BVLoginViewCtrl.h"
#import "MessageText.h"
#import "EventNames.h"

@implementation BVLoginViewCtrl

- (void)viewDidLoad {
  [super viewDidLoad];

  [self setTextFields];

  [self setButtons];
}

- (void)setTextFields {
  name_tf = [[[UITextField alloc] initWithFrame:CGRectMake(0, 10, 200, 40)] autorelease];
  name_tf.placeholder = @"メールアドレスを入力してください．";
  name_tf.borderStyle = UITextBorderStyleRoundedRect;
  name_tf.delegate = self;
  [self.view addSubview:name_tf];

  pass_tf = [[[UITextField alloc] initWithFrame:CGRectMake(0, 60, 200, 40)] autorelease];
  pass_tf.placeholder = @"パスワードを入力してください．";
  pass_tf.borderStyle = UITextBorderStyleRoundedRect;
  pass_tf.secureTextEntry = YES;
  pass_tf.delegate = self;
  [self.view addSubview:pass_tf];

  message_tf = [[[UITextField alloc] initWithFrame:CGRectMake(0, 170, 200, 40)] autorelease];
  message_tf.textAlignment = UITextAlignmentCenter;
  [self.view addSubview:message_tf];
}

- (void)setButtons {
  loginButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
  [loginButton setTitle:LOGIN_MESSAGE forState:UIControlStateNormal];
  loginButton.enabled = true;
  [loginButton addTarget:self action:@selector(onLoginButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
  [loginButton setUserInteractionEnabled:YES];
  loginButton.frame = CGRectMake(0, 110, 150, 50);
  [self.view addSubview:loginButton];
}

- (void)onLoginButtonPushed:(NSNotification *)notification {
  [pass_tf resignFirstResponder];
  [name_tf resignFirstResponder];
  NSString* name_text;
  if (name_tf.text) {
    name_text = name_tf.text;
  } else {
    name_text = @"";
  }

  NSString* pass_text;
  if (pass_tf.text) {
    pass_text = pass_tf.text;
  } else {
    pass_text = @"";
  }

  NSArray *keys = [[NSArray alloc] initWithObjects:@"name", @"pass", nil];
  NSArray *values = [[NSArray alloc] initWithObjects:name_text, pass_text, nil];
  NSDictionary *data = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
  [keys release];
  [values release];
  [[NSNotificationCenter defaultCenter] postNotificationName:SEND_LOGIN_REQUEST_EVENT
						      object:nil
						    userInfo:data];
  [data release];

}

- (void)receiveReplyToLoginRequest:(NSDictionary *)dic {
	     if ([dic objectForKey:@"login"]) {
	  if ([[[[dic objectForKey:@"login"] objectForKey:@"success"] objectForKey:@"value"] isEqualToString:@"true"] || true) {
	    NSLog(@"success");
	    message_tf.text = @"ログインに成功しました！";
	    [[NSNotificationCenter defaultCenter] postNotificationName:GO_TO_MAIN_MENU_EVENT
								object:nil
							      userInfo:nil];
	  } else {
	    NSLog(@"failure");
	    message_tf.text = @"ログインに失敗しました．";
	  }
	     }
}

- (void)successToLogin:(NSDictionary *)dic {
}

- (void)failureToLogin:(NSDictionary *)dic {
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

@end
