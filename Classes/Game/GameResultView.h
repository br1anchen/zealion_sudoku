//
//  GameResultView.h
//  Sudoku
//
//  Created by Kwang on 11/06/29.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameViewController;

@interface GameResultView : UIView {
	GameViewController*	m_controller;
	UILabel*	m_labelTime;
	UIButton*	m_btnNextPuzzle;
	UIButton*	m_btnSaveImage;
}

-(id) initResultView:(GameViewController*) controller;
-(void) createLabelTime;
-(void) createBtns;
-(void) onNextPuzzle;
-(void) onSaveImage;
-(void) setTime:(int)seconds;
-(UIImage*) getStageImage:(int)stage;

@end
