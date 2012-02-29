//
//  StageViewController.h
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StageViewController : UIViewController {
	BOOL m_bHideNavBar;
}

-(void) createStageButtons;
-(void) changeBtnImage;
-(void) onStage:(id)sender;
-(UIButton*) createButton:(CGPoint)pos imageNormal:(NSString*)strNormal imagePress:(NSString*)strPress;
-(UIImage*) getStageImage:(int)stage;

@end
