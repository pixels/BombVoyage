//
//  MainMenuViewCtrl.h
//  BombVoyage
//
//  Created by Karatsu Naoya on 10/10/02.
//  Copyright 2010 ajapax. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainMenuViewCtrl : UIViewController {
  UIButton* goToMapModeButton;
  UIButton* goToProfModeButton;
  UIButton* goToToolModeButton;
}

- (void)setButtonsMyself;
- (void)onGoToMapModeButtonPushed:(UIButton *)sender;

@end
